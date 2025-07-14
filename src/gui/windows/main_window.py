"""
Main Window Module

This module provides the main application window with battery health monitoring interface
supporting multiple batteries.
"""

import sys
import os
import ctypes
from PyQt6.QtWidgets import (QMainWindow, QWidget, QVBoxLayout,
                             QPushButton, QLabel, QProgressBar, QHBoxLayout,
                             QFrame, QButtonGroup, QRadioButton)
from PyQt6.QtCore import Qt, QUrl, pyqtSignal
from PyQt6.QtGui import QIcon, QColor, QDesktopServices

from src.gui.widgets.status_indicator import StatusIndicator
from src.gui.workers.battery_check_worker import MultiBatteryCheckWorker
from src.utils.resource_helper import get_resource_path


class BatterySelectionWidget(QWidget):
    """Widget for selecting between multiple batteries."""
    
    battery_changed = pyqtSignal(int)  # Signal emitted when battery selection changes
    
    def __init__(self):
        super().__init__()
        self.battery_buttons = []
        self.button_group = QButtonGroup()
        self._setup_ui()
        
    def _setup_ui(self):
        """Initialize the battery selection UI."""
        self.layout = QHBoxLayout(self)
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.layout.setSpacing(10)
        
        # Battery count indicator
        self.count_label = QLabel("No batteries detected")
        self.count_label.setStyleSheet("""
            color: #666666;
            font-size: 12px;
            font-weight: bold;
        """)
        self.layout.addWidget(self.count_label)
        self.layout.addStretch()
        
    def update_batteries(self, batteries):
        """Update the battery selection options."""
        # Clear existing buttons
        for button in self.battery_buttons:
            self.button_group.removeButton(button)
            button.deleteLater()
        self.battery_buttons.clear()
        
        # Update count label
        battery_count = len(batteries)
        if battery_count == 0:
            self.count_label.setText("No batteries detected")
            self.count_label.setStyleSheet("color: #ff5252; font-size: 12px; font-weight: bold;")
        elif battery_count == 1:
            self.count_label.setText("1 battery detected")
            self.count_label.setStyleSheet("color: #06c86f; font-size: 12px; font-weight: bold;")
        else:
            self.count_label.setText(f"{battery_count} batteries detected")
            self.count_label.setStyleSheet("color: #06c86f; font-size: 12px; font-weight: bold;")
        
        # Add radio buttons for each battery
        if battery_count > 1:
            for i, battery in enumerate(batteries):
                radio_button = QRadioButton(f"Battery {i+1}")
                radio_button.setStyleSheet("""
                    QRadioButton {
                        color: #ffffff;
                        font-size: 12px;
                        spacing: 5px;
                    }
                    QRadioButton::indicator {
                        width: 14px;
                        height: 14px;
                    }
                    QRadioButton::indicator:unchecked {
                        border: 2px solid #666666;
                        border-radius: 7px;
                        background-color: transparent;
                    }
                    QRadioButton::indicator:checked {
                        border: 2px solid #3dbaff;
                        border-radius: 7px;
                        background-color: #3dbaff;
                    }
                    QRadioButton::indicator:hover {
                        border: 2px solid #3dbaff;
                    }
                """)
                
                if i == 0:  # Select first battery by default
                    radio_button.setChecked(True)
                
                self.battery_buttons.append(radio_button)
                self.button_group.addButton(radio_button, i)
                self.layout.addWidget(radio_button)
                
            # Connect signal
            self.button_group.idClicked.connect(self.battery_changed.emit)
    
    def get_selected_battery(self) -> int:
        """Get the index of the currently selected battery."""
        return self.button_group.checkedId() if self.button_group.checkedId() != -1 else 0


class BatteryHealthApp(QMainWindow):
    """
    Main application window with multi-battery support.
    """

    def __init__(self):
        """Initialize the main window."""
        super().__init__()
        self.worker = None
        self.batteries = []
        self.current_battery_index = 0
        self._init_ui()
        self._setup_window_properties()
        self._setup_styles()
        self._detect_batteries()

    def _init_ui(self):
        """Initialize the user interface components."""
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        layout = QVBoxLayout(central_widget)
        layout.setSpacing(20)
        layout.setContentsMargins(40, 40, 40, 20)

        # Battery selection widget
        self.battery_selector = BatterySelectionWidget()
        self.battery_selector.battery_changed.connect(self._on_battery_changed)
        layout.addWidget(self.battery_selector)

        # Main content area
        content_layout = QHBoxLayout()
        content_layout.setSpacing(40)
        layout.addLayout(content_layout)

        self._setup_left_card(content_layout)
        self._setup_right_card(content_layout)

        # Add footer with donation links
        self._setup_footer(layout)

    def _setup_window_properties(self):
        """Set up window properties and icons."""
        self.setWindowTitle('Multi-Battery Health Checker v 0.9.0')
        self.setMinimumSize(900, 550)

        icon_path = get_resource_path("resources/icon.ico")
        if os.path.exists(icon_path):
            self.setWindowIcon(QIcon(icon_path))
            if sys.platform == 'win32':
                # Set taskbar icon for Windows
                myappid = 'com.elldev.batterychecker.0.9.0'
                ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(
                    myappid)

    def _setup_left_card(self, main_layout):
        """Set up the left card containing the battery indicator."""
        left_card = self._create_card()
        left_layout = QVBoxLayout(left_card)
        left_layout.setSpacing(20)
        left_layout.setContentsMargins(30, 30, 30, 30)

        status_title = self._create_title_label("Battery Status")
        left_layout.addWidget(status_title)

        self.status_indicator = StatusIndicator()
        self.status_indicator.setFixedSize(280, 140)
        left_layout.addWidget(self.status_indicator,
                              alignment=Qt.AlignmentFlag.AlignCenter)
        left_layout.addStretch()

        main_layout.addWidget(left_card)

    def _setup_right_card(self, main_layout):
        """Set up the right card containing battery details and controls."""
        right_card = self._create_card()
        right_layout = QVBoxLayout(right_card)
        right_layout.setSpacing(20)
        right_layout.setContentsMargins(30, 30, 30, 30)

        details_title = self._create_title_label("Battery Details")
        right_layout.addWidget(details_title)

        self.details_label = QLabel()
        self.details_label.setObjectName("detailsLabel")
        self.details_label.setWordWrap(True)
        self.details_label.setText("Select a battery and click 'Check Battery Health' to begin.")
        right_layout.addWidget(self.details_label)

        self.progress_bar = self._create_progress_bar()
        right_layout.addWidget(self.progress_bar)
        right_layout.addStretch()

        button_container = QWidget()
        button_layout = QHBoxLayout(button_container)
        button_layout.setContentsMargins(0, 0, 0, 0)

        self.check_button = self._create_check_button()
        button_layout.addWidget(self.check_button)
        
        # Refresh batteries button
        self.refresh_button = self._create_refresh_button()
        button_layout.addWidget(self.refresh_button)
        
        button_layout.addStretch()

        right_layout.addWidget(button_container)
        main_layout.addWidget(right_card)

    def _create_card(self) -> QWidget:
        """Create a styled card widget."""
        card = QWidget()
        card.setStyleSheet("""
            QWidget {
                background-color: #0c0f13;
                border-radius: 12px;
            }
        """)
        return card

    def _create_title_label(self, text: str) -> QLabel:
        """Create a styled title label."""
        label = QLabel(text)
        label.setStyleSheet("""
            color: #ffffff;
            font-size: 16px;
            font-weight: bold;
        """)
        return label

    def _create_progress_bar(self) -> QProgressBar:
        """Create a styled progress bar."""
        progress_bar = QProgressBar()
        progress_bar.setFixedHeight(10)
        progress_bar.hide()
        return progress_bar

    def _create_check_button(self) -> QPushButton:
        """Create the battery check button."""
        button = QPushButton('Check Battery Health')
        button.setObjectName("checkButton")
        button.setFixedWidth(200)
        button.setFixedHeight(45)
        button.clicked.connect(self.start_check)
        button.setCursor(Qt.CursorShape.PointingHandCursor)
        return button

    def _create_refresh_button(self) -> QPushButton:
        """Create the refresh batteries button."""
        button = QPushButton('Refresh')
        button.setFixedWidth(80)
        button.setFixedHeight(45)
        button.clicked.connect(self._detect_batteries)
        button.setCursor(Qt.CursorShape.PointingHandCursor)
        button.setStyleSheet("""
            QPushButton {
                background-color: transparent;
                color: #3dbaff;
                border: 1px solid rgba(61, 186, 255, 0.5);
                border-radius: 8px;
                padding: 4px 12px;
                font-size: 12px;
            }
            QPushButton:hover {
                background-color: #3dbaff;
                color: white;
            }
        """)
        return button

    def _setup_footer(self, layout):
        """Set up the footer with donation links."""
        footer = QWidget()
        footer_layout = QHBoxLayout(footer)
        footer_layout.setContentsMargins(10, 10, 10, 10)

        # Version label
        version_label = QLabel("v0.9.0")
        version_label.setStyleSheet("""
            color: #666666;
            font-size: 12px;
        """)
        footer_layout.addWidget(version_label)

        footer_layout.addStretch()

        # Donation links
        # paypal_btn = self._create_link_button(
        #     "Support via PayPal", "https://www.paypal.com/paypalme/LotfiBoukhemerra")
        # coffee_btn = self._create_link_button(
        #     "Buy me a Coffee", "https://buymeacoffee.com/eldev")

        # footer_layout.addWidget(paypal_btn)
        # footer_layout.addWidget(coffee_btn)

        layout.addWidget(footer)

    def _create_link_button(self, text: str, url: str) -> QPushButton:
        """Create a styled link button."""
        button = QPushButton(text)
        button.setStyleSheet("""
            QPushButton {
                background-color: transparent;
                color: #3dbaff;
                border: 1px solid rgba(61, 186, 255, 0.5);
                border-radius: 4px;
                padding: 4px 12px;
                font-size: 12px;
            }
            QPushButton:hover {
                background-color: #3dbaff;
                color: white;
            }
        """)
        button.setCursor(Qt.CursorShape.PointingHandCursor)
        button.clicked.connect(lambda: QDesktopServices.openUrl(QUrl(url)))
        return button

    def _setup_styles(self):
        """Set up application-wide styles."""
        self.setStyleSheet("""
            QMainWindow {
                background-color: #13171b;
            }
            QPushButton#checkButton {
                background-color: #3dbaff;
                color: white;
                border: none;
                border-radius: 8px;
                padding: 8px 24px;
                font-size: 14px;
                font-weight: bold;
            }
            QPushButton#checkButton:hover {
                background-color: #0084ff;
            }
            QPushButton#checkButton:pressed {
                background-color: #0058bd;
            }
            QPushButton#checkButton:disabled {
                background-color: #13171b;
                color: #666666;
            }
            QProgressBar {
                border: none;
                background-color: #13171b;
                border-radius: 5px;
                height: 6px;
                text-align: center;
            }
            QProgressBar::chunk {
                background-color: #3dbaff;
                border-radius: 5px;
            }
            QLabel#detailsLabel {
                color: #ffffff;
                font-size: 15px;
                line-height: 1.6;
                padding: 10px;
                background-color: #333333;
                border-radius: 8px;
            }
        """)

    def _detect_batteries(self):
        """Detect available batteries and update UI."""
        from src.core.battery_checker import MultiBatteryHealthChecker
        
        checker = MultiBatteryHealthChecker()
        self.batteries = checker.get_available_batteries()
        self.battery_selector.update_batteries(self.batteries)
        
        # Enable/disable check button based on battery availability
        self.check_button.setEnabled(len(self.batteries) > 0)
        
        if len(self.batteries) == 0:
            self.details_label.setText("No batteries detected. Please check your system or refresh.")
            self.status_indicator.update_status(QColor("#666666"), "No Battery")
        else:
            self.current_battery_index = 0
            battery_name = self.batteries[0].name if self.batteries else "Unknown"
            self.details_label.setText(f"Ready to check {battery_name}. Click 'Check Battery Health' to begin.")
            self.status_indicator.update_status(QColor("#3dbaff"), "Ready")

    def _on_battery_changed(self, battery_index: int):
        """Handle battery selection change."""
        self.current_battery_index = battery_index
        if battery_index < len(self.batteries):
            battery_name = self.batteries[battery_index].name
            self.details_label.setText(f"Ready to check {battery_name}. Click 'Check Battery Health' to begin.")
            self.status_indicator.update_status(QColor("#3dbaff"), "Ready")

    def start_check(self):
        """Start the battery health check process."""
        if not self.batteries:
            self.details_label.setText("No batteries available for checking.")
            return

        # Get selected battery index
        selected_index = self.battery_selector.get_selected_battery()
        if selected_index >= len(self.batteries):
            selected_index = 0

        selected_battery = self.batteries[selected_index]
        
        # Reset UI to default state
        self.status_indicator.update_status(QColor("#3dbaff"), "")
        self.details_label.setText(f"Checking {selected_battery.name} health...")
        self.progress_bar.setValue(0)
        self.progress_bar.show()
        self.check_button.setEnabled(False)
        self.refresh_button.setEnabled(False)

        self.worker = MultiBatteryCheckWorker(selected_index)
        self.worker.finished.connect(self.handle_results)
        self.worker.error.connect(self.handle_error)
        self.worker.progress.connect(self.progress_bar.setValue)
        self.worker.start()

    def handle_results(self, results: dict):
        """Process and display the battery check results."""
        health = results['health_percentage']
        battery_name = results.get('battery_name', 'Battery')

        # Determine status color and text
        if health >= 80:
            color = QColor("#06c86f")  # Green
            status = "Excellent"
        elif health >= 60:
            color = QColor("#E6B455")  # Orange
            status = "Good"
        else:
            color = QColor("#FF5252")  # Red
            status = "Poor"

        health = min(health, 100)

        # Update UI
        self.status_indicator.update_status(color, f"{health:.0f}%")
        self.details_label.setText(
            f"Battery: {battery_name}\n"
            f"Design Capacity: {results['design_capacity']:,.0f} mWh\n"
            f"Current Capacity: {results['full_charge_capacity']:,.0f} mWh\n"
            f"Health: {health:.1f}%\n"
            f"Status: Battery is in {status} condition"
        )

        self._reset_ui_state()

    def handle_error(self, error_message: str):
        """Handle and display error messages."""
        self.status_indicator.update_status(QColor("#C42B1C"), "Error")
        self.details_label.setText(f"Error: {error_message}")
        self._reset_ui_state()

    def _reset_ui_state(self):
        """Reset UI elements to their default state."""
        self.check_button.setEnabled(True)
        self.refresh_button.setEnabled(True)
        self.progress_bar.hide()