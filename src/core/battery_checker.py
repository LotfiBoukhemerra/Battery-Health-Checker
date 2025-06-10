"""
Battery Health Checker Core Module

This module implements the core domain logic for battery health checking
with support for multiple batteries
"""

import os
import subprocess
import re
import sys
import time
from typing import Optional, Dict, List
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
class BatteryInfo:
    """Information about a single battery."""
    id: str
    name: str
    device_id: str
    availability: str


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
    def get_battery_list() -> List[BatteryInfo]:
        """Get list of all batteries in the system."""
        batteries = []
        
        try:
            # Use WMIC to get detailed battery information
            result = subprocess.run(
                ['WMIC', 'Path', 'Win32_Battery', 'Get', 'DeviceID,Name,Availability', '/format:csv'],
                capture_output=True,
                text=True,
                creationflags=CREATE_NO_WINDOW
            )
            
            if result.returncode == 0 and result.stdout.strip():
                lines = result.stdout.strip().split('\n')
                # Skip header line
                for line in lines[1:]:
                    if line.strip():
                        parts = line.split(',')
                        if len(parts) >= 4:  # Node,Availability,DeviceID,Name
                            availability = parts[1].strip() if len(parts) > 1 else ""
                            device_id = parts[2].strip() if len(parts) > 2 else ""
                            name = parts[3].strip() if len(parts) > 3 else ""
                            
                            if device_id and name:
                                battery_info = BatteryInfo(
                                    id=device_id,
                                    name=name,
                                    device_id=device_id,
                                    availability=availability
                                )
                                batteries.append(battery_info)
            
            # Fallback: If WMIC doesn't return detailed info, use simpler approach
            if not batteries:
                result = subprocess.run(
                    ['WMIC', 'Path', 'Win32_Battery', 'Get', 'DeviceID'],
                    capture_output=True,
                    text=True,
                    creationflags=CREATE_NO_WINDOW
                )
                
                if result.returncode == 0 and result.stdout.strip():
                    lines = result.stdout.strip().split('\n')
                    battery_count = 0
                    for line in lines[1:]:  # Skip header
                        if line.strip():
                            battery_count += 1
                            battery_info = BatteryInfo(
                                id=f"BATTERY_{battery_count}",
                                name=f"Battery {battery_count}",
                                device_id=line.strip(),
                                availability="Available"
                            )
                            batteries.append(battery_info)
                            
        except Exception as e:
            print(f"Error getting battery list: {str(e)}")
            # If all else fails, check if at least one battery exists
            if SystemService.check_battery_exists():
                batteries.append(BatteryInfo(
                    id="BATTERY_1",
                    name="Battery 1",
                    device_id="DEFAULT",
                    availability="Available"
                ))
        
        return batteries

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

    def generate_report(self, battery_id: str = None) -> bool:
        """Generate battery report for specific battery or all batteries."""
        try:
            if os.path.exists(self.report_path):
                os.remove(self.report_path)

            # Generate report for specific battery if ID provided
            cmd = ['powercfg', '/batteryreport', '/output', self.report_path]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                creationflags=CREATE_NO_WINDOW
            )

            time.sleep(1)  # Wait for file to be written
            return os.path.exists(self.report_path)
        except Exception as e:
            print(f"Failed to generate battery report: {str(e)}")
            return False
        
    def extract_capacity_values(self, battery_index: int = 0) -> Optional[BatteryCapacity]:
        """Extract capacity values for specific battery by index."""
        try:
            if not os.path.exists(self.report_path):
                return None

            with open(self.report_path, 'r', encoding='utf-8') as file:
                soup = BeautifulSoup(file.read(), 'html.parser')

            # Find the battery information table by searching through all tables
            battery_data = {}  # Will store data for each battery index
            
            for table in soup.find_all('table'):
                table_has_battery_info = False
                
                for row in table.find_all('tr'):
                    cells = row.find_all('td')
                    
                    if len(cells) >= 2:  # Need at least 2 columns (label + 1 battery)
                        label = cells[0].get_text().strip().upper()
                        
                        if "DESIGN CAPACITY" in label or "FULL CHARGE CAPACITY" in label:
                            table_has_battery_info = True
                            
                            if "DESIGN CAPACITY" in label:
                                # Extract design capacity for each battery
                                for i in range(1, len(cells)):  # Start from 1 to skip the label column
                                    battery_idx = i - 1  # Convert to 0-based index
                                    value = cells[i].get_text().strip()
                                    if battery_idx not in battery_data:
                                        battery_data[battery_idx] = {}
                                    battery_data[battery_idx]['design_capacity'] = self._extract_numeric_value(value)
                            
                            elif "FULL CHARGE CAPACITY" in label:
                                # Extract full charge capacity for each battery
                                for i in range(1, len(cells)):  # Start from 1 to skip the label column
                                    battery_idx = i - 1  # Convert to 0-based index
                                    value = cells[i].get_text().strip()
                                    if battery_idx not in battery_data:
                                        battery_data[battery_idx] = {}
                                    battery_data[battery_idx]['full_charge_capacity'] = self._extract_numeric_value(value)
                
                # If we found battery info in this table, we can stop searching
                if table_has_battery_info:
                    break
            
            if not battery_data:
                return None

            # Return the requested battery's data
            if battery_index in battery_data:
                battery_info = battery_data[battery_index]
                if battery_info.get('design_capacity') and battery_info.get('full_charge_capacity'):
                    return BatteryCapacity(
                        battery_info['design_capacity'], 
                        battery_info['full_charge_capacity']
                    )

            # Fallback: if no specific battery found, return first available data
            if battery_data:
                first_battery = list(battery_data.values())[0]
                if first_battery.get('design_capacity') and first_battery.get('full_charge_capacity'):
                    return BatteryCapacity(
                        first_battery['design_capacity'], 
                        first_battery['full_charge_capacity']
                    )

            return None

        except Exception as e:
            print(f"Failed to extract capacity values: {str(e)}")
            return None


    def extract_capacity_values_old(self, battery_index: int = 0) -> Optional[BatteryCapacity]:
        """Extract capacity values for specific battery by index."""
        try:
            if not os.path.exists(self.report_path):
                return None

            with open(self.report_path, 'r', encoding='utf-8') as file:
                soup = BeautifulSoup(file.read(), 'html.parser')

            # Find all battery information sections
            battery_sections = []
            current_battery = {}
            
            for table in soup.find_all('table'):
                for row in table.find_all('tr'):
                    cells = row.find_all('td')
                    if len(cells) >= 2:
                        label = cells[0].get_text().strip().upper()
                        value = cells[1].get_text().strip()

                        if "DESIGN CAPACITY" in label:
                            if current_battery and 'design_capacity' in current_battery:
                                # Save current battery info and start new one
                                battery_sections.append(current_battery)
                                current_battery = {}
                            current_battery['design_capacity'] = self._extract_numeric_value(value)
                        elif "FULL CHARGE CAPACITY" in label:
                            current_battery['full_charge_capacity'] = self._extract_numeric_value(value)

            print(current_battery)

            # Add the last battery if it exists
            if current_battery:
                battery_sections.append(current_battery)
            print(battery_sections)
            # Return the requested battery's data
            if battery_index < len(battery_sections):
                battery_data = battery_sections[battery_index]
                if battery_data.get('design_capacity') and battery_data.get('full_charge_capacity'):
                    return BatteryCapacity(
                        battery_data['design_capacity'], 
                        battery_data['full_charge_capacity']
                    )
            
            # Fallback: if no specific battery found, return first available data
            if battery_sections:
                battery_data = battery_sections[0]
                if battery_data.get('design_capacity') and battery_data.get('full_charge_capacity'):
                    return BatteryCapacity(
                        battery_data['design_capacity'], 
                        battery_data['full_charge_capacity']
                    )

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


class MultiBatteryHealthChecker:
    """Core service for checking health of multiple batteries."""

    def __init__(self, report_path: str = None):
        """Initialize the service with optional custom report path."""
        self.system_service = SystemService()
        self.repository = BatteryReportRepository(report_path)
        self.logger = BatteryLogger()
        self._batteries = []

    def get_available_batteries(self) -> List[BatteryInfo]:
        """Get list of all available batteries."""
        if not self._batteries:
            self._batteries = self.system_service.get_battery_list()
        return self._batteries

    def check_battery_health(self, battery_index: int = 0) -> Optional[Dict]:
        """Perform battery health check for specific battery."""
        batteries = self.get_available_batteries()
        if not batteries:
            self.logger.error("No batteries detected in system")
            return None
            
        if battery_index >= len(batteries):
            self.logger.error(f"Battery index {battery_index} out of range")
            return None
        print("Batteries",batteries)
        selected_battery = batteries[battery_index]
        self.logger.info(f"Starting battery health check for {selected_battery.name}")

        self.logger.info("Generating battery report")
        if not self.repository.generate_report(selected_battery.device_id):
            self.logger.error("Failed to generate battery report")
            return None

        self.logger.info("Report generated, extracting capacity values")
        capacity = self.repository.extract_capacity_values(battery_index)
        print(capacity)
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
            f"Health check completed for {selected_battery.name}: {health_percentage}% - {health_status.status}")

        return {
            'battery_name': selected_battery.name,
            'battery_id': selected_battery.id,
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


# Backward compatibility
class BatteryHealthChecker(MultiBatteryHealthChecker):
    """Legacy single battery checker for backward compatibility."""
    
    def check_battery_health(self) -> Optional[Dict]:
        """Check health of first available battery."""
        result = super().check_battery_health(0)
        if result:
            # Remove battery-specific fields for backward compatibility
            result.pop('battery_name', None)
            result.pop('battery_id', None)
        return result


if __name__ == "__main__":
    checker = MultiBatteryHealthChecker()
    batteries = checker.get_available_batteries()
    
    if batteries:
        print(f"Found {len(batteries)} battery(ies):")
        for i, battery in enumerate(batteries):
            print(f"  {i+1}. {battery.name} (ID: {battery.id})")
            
        # Check each battery
        for i in range(len(batteries)):
            print(f"\nChecking {batteries[i].name}...")
            result = checker.check_battery_health(i)
            if result:
                print(f"Battery Health: {result['health_percentage']}% - {result['status']}")
            else:
                print("Battery health check failed.")
    else:
        print("No batteries detected.")