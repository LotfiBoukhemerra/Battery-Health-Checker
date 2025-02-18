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
        """Verify if a battery is present in the system."""
        try:
            result = subprocess.run(
                ['WMIC', 'Path', 'Win32_Battery', 'Get', 'Status'],
                capture_output=True,
                text=True,
                creationflags=CREATE_NO_WINDOW if sys.platform == 'win32' else 0
            )
            return 'Status' in result.stdout and len(result.stdout.strip().split('\n')) > 1
        except Exception:
            return False


class BatteryReportRepository:
    """Repository for managing battery report data."""

    def __init__(self, report_path: str = None):
        """Initialize with optional custom report path."""
        self.report_path = report_path or os.path.join(
            os.path.expanduser('~'), 'battery_report.html')

    def generate_report(self) -> bool:
        """Generate a battery report using Windows powercfg command."""
        try:
            if os.path.exists(self.report_path):
                try:
                    os.remove(self.report_path)
                except Exception as e:
                    print(f"Warning: Could not remove old report: {e}")

            process = subprocess.run(
                ['powercfg', '/batteryreport', '/output', self.report_path],
                capture_output=True,
                text=True,
                encoding='utf-8',
                creationflags=CREATE_NO_WINDOW if sys.platform == 'win32' else 0
            )

            if process.returncode != 0:
                return False

            time.sleep(2)
            return os.path.exists(self.report_path)

        except Exception:
            return False

    def extract_capacity_values(self) -> Optional[BatteryCapacity]:
        """Extract capacity values from the battery report."""
        try:
            if not os.path.exists(self.report_path):
                return None

            with open(self.report_path, 'r', encoding='utf-8') as file:
                content = file.read()
                soup = BeautifulSoup(content, 'html.parser')

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

        except Exception:
            return None

    @staticmethod
    def _extract_numeric_value(value_text: str) -> Optional[float]:
        """Extract numeric value from text string."""
        try:
            match = re.search(r'([\d,]+)', value_text)
            return float(match.group(1).replace(',', '')) if match else None
        except Exception:
            return None


class BatteryHealthChecker:
    """Core service for checking battery health."""

    def __init__(self, report_path: str = None):
        """Initialize the service with optional custom report path."""
        self.system_service = SystemService()
        self.repository = BatteryReportRepository(report_path)

    def check_battery_health(self) -> Optional[Dict]:
        """
        Perform complete battery health check.

        Returns:
            Optional[Dict]: Battery health information or None if check fails
        """
        if not self.system_service.check_battery_exists():
            return None

        if not self.repository.generate_report():
            return None

        capacity = self.repository.extract_capacity_values()
        if not capacity:
            return None

        health_percentage = self._calculate_health(
            capacity.design_capacity,
            capacity.full_charge_capacity
        )

        if health_percentage is None:
            return None

        health_status = BatteryHealthStatus(health_percentage)

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
