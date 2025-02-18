"""
Battery Check Worker Module

This module provides a worker thread for performing battery health checks
without blocking the GUI.
"""

from PyQt6.QtCore import QThread, pyqtSignal
from src.core.battery_checker import BatteryHealthChecker


class BatteryCheckWorker(QThread):
    """
    Worker thread to handle battery health checking operations.

    Signals:
        finished (dict): Emits results of battery check
        error (str): Emits error messages
        progress (int): Emits progress updates (0-100)
    """

    finished = pyqtSignal(dict)
    error = pyqtSignal(str)
    progress = pyqtSignal(int)

    def run(self):
        """Execute battery health check workflow."""
        try:
            checker = BatteryHealthChecker()

            self.progress.emit(25)
            result = checker.check_battery_health()

            if not result:
                self.error.emit(
                    "No battery detected in the system.\nPlease ensure battery is present\nand try running as administrator.")
                return

            self.progress.emit(100)
            self.finished.emit(result)

        except Exception as e:
            self.error.emit(f"An unexpected error occurred: {str(e)}")
