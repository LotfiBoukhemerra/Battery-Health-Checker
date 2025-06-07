"""
Battery Check Worker Module

This module provides worker threads for battery health checking operations
with support for multiple batteries.
"""

import time
from PyQt6.QtCore import QThread, pyqtSignal
from src.core.battery_checker import MultiBatteryHealthChecker, BatteryHealthChecker


class MultiBatteryCheckWorker(QThread):
    """
    Worker thread for checking battery health of a specific battery.
    Runs the battery checking process in the background to prevent UI freezing.
    """
    
    # Signals
    finished = pyqtSignal(dict)  # Emitted when check completes successfully
    error = pyqtSignal(str)      # Emitted when an error occurs
    progress = pyqtSignal(int)   # Emitted to update progress bar

    def __init__(self, battery_index: int = 0):
        """
        Initialize the worker.
        
        Args:
            battery_index: Index of the battery to check (0-based)
        """
        super().__init__()
        self.battery_index = battery_index
        self.checker = MultiBatteryHealthChecker()

    def run(self):
        """
        Main worker thread execution.
        Performs the battery health check and emits appropriate signals.
        """
        try:
            # Emit progress updates
            self.progress.emit(10)
            time.sleep(0.1)  # Small delay for UI responsiveness
            
            # Get available batteries
            batteries = self.checker.get_available_batteries()
            if not batteries:
                self.error.emit("No batteries detected in the system.")
                return
                
            if self.battery_index >= len(batteries):
                self.error.emit(f"Battery index {self.battery_index} is out of range.")
                return
            
            self.progress.emit(25)
            time.sleep(0.1)
            
            # Check if the system has administrator rights (if needed)
            # This is handled internally by the checker
            
            self.progress.emit(50)
            time.sleep(0.1)
            
            # Perform the actual battery health check
            result = self.checker.check_battery_health(self.battery_index)
            
            self.progress.emit(75)
            time.sleep(0.1)
            
            if result:
                self.progress.emit(100)
                time.sleep(0.1)
                self.finished.emit(result)
            else:
                selected_battery = batteries[self.battery_index]
                self.error.emit(f"Failed to check health for {selected_battery.name}. "
                              "This could be due to insufficient permissions or system limitations.")
                
        except Exception as e:
            self.error.emit(f"Unexpected error during battery check: {str(e)}")


class BatteryCheckWorker(QThread):
    """
    Legacy worker thread for backward compatibility.
    Checks the first available battery.
    """
    
    # Signals
    finished = pyqtSignal(dict)  # Emitted when check completes successfully
    error = pyqtSignal(str)      # Emitted when an error occurs
    progress = pyqtSignal(int)   # Emitted to update progress bar

    def __init__(self):
        """Initialize the legacy worker."""
        super().__init__()
        self.checker = BatteryHealthChecker()

    def run(self):
        """
        Main worker thread execution.
        Performs the battery health check and emits appropriate signals.
        """
        try:
            # Emit progress updates
            self.progress.emit(10)
            time.sleep(0.1)
            
            self.progress.emit(25)
            time.sleep(0.1)
            
            self.progress.emit(50)
            time.sleep(0.1)
            
            # Perform the actual battery health check
            result = self.checker.check_battery_health()
            
            self.progress.emit(75)
            time.sleep(0.1)
            
            if result:
                self.progress.emit(100)
                time.sleep(0.1)
                self.finished.emit(result)
            else:
                self.error.emit("Failed to check battery health. "
                              "This could be due to no battery present, insufficient permissions, "
                              "or system limitations.")
                
        except Exception as e:
            self.error.emit(f"Unexpected error during battery check: {str(e)}")


class BatteryDiscoveryWorker(QThread):
    """
    Worker thread for discovering available batteries.
    """
    
    # Signals
    batteries_found = pyqtSignal(list)  # Emitted with list of BatteryInfo objects
    error = pyqtSignal(str)             # Emitted when an error occurs

    def __init__(self):
        """Initialize the discovery worker."""
        super().__init__()
        self.checker = MultiBatteryHealthChecker()

    def run(self):
        """
        Main worker thread execution.
        Discovers available batteries and emits results.
        """
        try:
            batteries = self.checker.get_available_batteries()
            self.batteries_found.emit(batteries)
        except Exception as e:
            self.error.emit(f"Error discovering batteries: {str(e)}")