"""
Battery Health Checker Core Module

This module implements the core domain logic for battery health checking
"""

import os
import subprocess
import re
import sys
import time
from typing import Optional, Dict
from dataclasses import dataclass
from bs4 import BeautifulSoup

from src.core.logger import BatteryLogger

# Constants
CREATE_NO_WINDOW = 0x08000000
HEALTH_THRESHOLDS = {
    'EXCELLENT': 90,
    'GOOD': 70,
    'FAIR': 50,
    'POOR': 30
}


@dataclass
class BatteryCapacity:
    """Value object representing battery capacity measurements."""
    design_capacity: float
    full_charge_capacity: float


class BatteryHealthStatus:
    """Value object representing battery health status."""

    def __init__(self, percentage: float):
        self.percentage = percentage
        self.status = self._determine_status(percentage)

    @staticmethod
    def _determine_status(percentage: float) -> str:
        """Determine battery health status based on percentage."""
        if percentage >= HEALTH_THRESHOLDS['EXCELLENT']:
            return 'Excellent'
        elif percentage >= HEALTH_THRESHOLDS['GOOD']:
            return 'Good'
        elif percentage >= HEALTH_THRESHOLDS['FAIR']:
            return 'Fair'
        elif percentage >= HEALTH_THRESHOLDS['POOR']:
            return 'Poor'
        return 'Critical'


class SystemService:
    """Service layer for system-level operations."""

    @staticmethod
    def check_admin_rights() -> bool:
        """Check if the application has administrator privileges."""
        try:
            return os.getuid() == 0
        except AttributeError:
            try:
                return subprocess.run(
                    ['net', 'session'],
                    capture_output=True,
                    check=True,
                    creationflags=CREATE_NO_WINDOW if sys.platform == 'win32' else 0
                ).returncode == 0
            except:
                return False

    @staticmethod
    def check_battery_exists() -> bool:
        """Verify if a battery is present in the system using multiple methods."""
        methods = [
            ('WMIC', SystemService._check_using_wmic),
            ('PowerCfg', SystemService._check_using_powercfg),
            ('Registry', SystemService._check_using_reg),
        ]

        for method_name, method in methods:
            try:
                if method():
                    print(f"Battery detected using {method_name} method")
                    return True
            except Exception as e:
                print(
                    f"Battery detection failed using {method_name}: {str(e)}")

        return False

    @staticmethod
    def _check_using_wmic() -> bool:
        result = subprocess.run(
            ['WMIC', 'Path', 'Win32_Battery', 'Get', 'Status'],
            capture_output=True,
            text=True,
            creationflags=CREATE_NO_WINDOW
        )
        return bool(result.stdout.strip())

    @staticmethod
    def _check_using_powercfg() -> bool:
        temp_file = os.path.join(os.environ['TEMP'], 'battery_test.html')
        result = subprocess.run(
            ['powercfg', '/batteryreport', '/output', temp_file],
            capture_output=True,
            text=True,
            creationflags=CREATE_NO_WINDOW
        )

        if os.path.exists(temp_file):
            os.remove(temp_file)

        return result.returncode == 0

    @staticmethod
    def _check_using_reg() -> bool:
        result = subprocess.run(
            ['reg', 'query', 'HKLM\\HARDWARE\\ACPI\\BCMA'],
            capture_output=True,
            text=True,
            creationflags=CREATE_NO_WINDOW
        )
        return result.returncode == 0


class BatteryReportRepository:
    """Repository for managing battery report data."""

    def __init__(self, report_path: str = None):
        self.report_path = report_path or os.path.join(
            os.environ['TEMP'],
            'battery_report.html'
        )

    def generate_report(self) -> bool:
        try:
            if os.path.exists(self.report_path):
                os.remove(self.report_path)

            result = subprocess.run(
                ['powercfg', '/batteryreport', '/output', self.report_path],
                capture_output=True,
                text=True,
                creationflags=CREATE_NO_WINDOW
            )

            time.sleep(1)  # Wait for file to be written
            return os.path.exists(self.report_path)
        except Exception as e:
            print(f"Failed to generate battery report: {str(e)}")
            return False

    def extract_capacity_values(self) -> Optional[BatteryCapacity]:
        try:
            if not os.path.exists(self.report_path):
                return None

            with open(self.report_path, 'r', encoding='utf-8') as file:
                soup = BeautifulSoup(file.read(), 'html.parser')

            design_capacity = None
            full_charge_capacity = None

            for table in soup.find_all('table'):
                for row in table.find_all('tr'):
                    cells = row.find_all('td')
                    if len(cells) >= 2:
                        label = cells[0].get_text().strip().upper()
                        value = cells[1].get_text().strip()

                        if "DESIGN CAPACITY" in label:
                            design_capacity = self._extract_numeric_value(
                                value)
                        elif "FULL CHARGE CAPACITY" in label:
                            full_charge_capacity = self._extract_numeric_value(
                                value)

            if design_capacity and full_charge_capacity:
                return BatteryCapacity(design_capacity, full_charge_capacity)
            return None

        except Exception as e:
            print(f"Failed to extract capacity values: {str(e)}")
            return None

    @staticmethod
    def _extract_numeric_value(value_text: str) -> Optional[float]:
        try:
            match = re.search(r'([\d,]+)', value_text)
            if match:
                return float(match.group(1).replace(',', ''))
            return None
        except Exception:
            return None


class BatteryHealthChecker:
    """Core service for checking battery health."""

    def __init__(self, report_path: str = None):
        """Initialize the service with optional custom report path."""
        self.system_service = SystemService()
        self.repository = BatteryReportRepository(report_path)
        self.logger = BatteryLogger()

    def check_battery_health(self) -> Optional[Dict]:
        """Perform complete battery health check."""
        self.logger.info("Starting battery health check")

        if not self.system_service.check_battery_exists():
            self.logger.error("No battery detected in system")
            return None

        self.logger.info("Battery detected, generating report")
        if not self.repository.generate_report():
            self.logger.error("Failed to generate battery report")
            return None

        self.logger.info("Report generated, extracting capacity values")
        capacity = self.repository.extract_capacity_values()
        if not capacity:
            self.logger.error("Failed to extract capacity values from report")
            return None

        self.logger.info(
            f"Capacity values extracted: Design={capacity.design_capacity}, Full={capacity.full_charge_capacity}")
        health_percentage = self._calculate_health(
            capacity.design_capacity,
            capacity.full_charge_capacity
        )

        if health_percentage is None:
            self.logger.error("Failed to calculate health percentage")
            return None

        health_status = BatteryHealthStatus(health_percentage)
        self.logger.info(
            f"Health check completed: {health_percentage}% - {health_status.status}")

        return {
            'design_capacity': capacity.design_capacity,
            'full_charge_capacity': capacity.full_charge_capacity,
            'health_percentage': health_percentage,
            'status': health_status.status
        }

    @staticmethod
    def _calculate_health(design_capacity: float, full_charge_capacity: float) -> Optional[float]:
        """Calculate battery health percentage."""
        try:
            if design_capacity and full_charge_capacity and design_capacity > 0:
                health_percentage = (
                    full_charge_capacity / design_capacity) * 100
                return round(health_percentage, 2)
            return None
        except Exception:
            return None
