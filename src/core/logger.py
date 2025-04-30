"""
Logger module for Battery Health Checker.
"""

import os
import logging
from datetime import datetime


class BatteryLogger:
    """Logger class for battery-related operations."""

    def __init__(self):
        self._setup_logger()

    def _setup_logger(self):
        """Setup logging configuration."""
        log_dir = os.path.join(os.getenv('APPDATA'),
                               'BatteryHealthChecker', 'logs')
        os.makedirs(log_dir, exist_ok=True)

        log_file = os.path.join(
            log_dir, f'battery_checker_{datetime.now().strftime("%Y%m%d")}.log')

        # Setup logging format
        formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )

        # File handler
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)

        # Setup logger
        self.logger = logging.getLogger('BatteryHealthChecker')
        self.logger.setLevel(logging.DEBUG)
        self.logger.addHandler(file_handler)

    def debug(self, message: str):
        """Log debug message."""
        self.logger.debug(message)

    def info(self, message: str):
        """Log info message."""
        self.logger.info(message)

    def warning(self, message: str):
        """Log warning message."""
        self.logger.warning(message)

    def error(self, message: str):
        """Log error message."""
        self.logger.error(message)
