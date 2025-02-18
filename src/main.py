"""
@lotfi_bkmr
Battery Health Checker Application

A modern Windows application for monitoring battery health with a clean GUI.
Version: 0.7.0
"""

from src.gui.windows.main_window import BatteryHealthApp
from src.utils.resource_helper import get_resource_path
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPalette, QColor, QIcon
from PyQt6.QtWidgets import QApplication
import sys
import os

# Add the src directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)


def setup_dark_palette() -> QPalette:
    """
    Create and configure dark color palette for the application.

    Returns:
        QPalette: Configured dark color palette
    """
    dark_palette = QPalette()

    # Define colors
    window_color = QColor(32, 32, 32)
    text_color = Qt.GlobalColor.white
    base_color = QColor(25, 25, 25)
    button_color = QColor(53, 53, 53)
    highlight_color = QColor(42, 130, 218)

    # Set colors for different roles
    dark_palette.setColor(QPalette.ColorRole.Window, window_color)
    dark_palette.setColor(QPalette.ColorRole.WindowText, text_color)
    dark_palette.setColor(QPalette.ColorRole.Base, base_color)
    dark_palette.setColor(QPalette.ColorRole.AlternateBase, QColor(53, 53, 53))
    dark_palette.setColor(QPalette.ColorRole.ToolTipBase, text_color)
    dark_palette.setColor(QPalette.ColorRole.ToolTipText, text_color)
    dark_palette.setColor(QPalette.ColorRole.Text, text_color)
    dark_palette.setColor(QPalette.ColorRole.Button, button_color)
    dark_palette.setColor(QPalette.ColorRole.ButtonText, text_color)
    dark_palette.setColor(QPalette.ColorRole.BrightText, Qt.GlobalColor.red)
    dark_palette.setColor(QPalette.ColorRole.Link, highlight_color)
    dark_palette.setColor(QPalette.ColorRole.Highlight, highlight_color)
    dark_palette.setColor(
        QPalette.ColorRole.HighlightedText, Qt.GlobalColor.black)

    return dark_palette


def main():
    """
    Application entry point.
    Initializes and runs the Battery Health Checker application.
    """
    try:
        # Create application instance
        app = QApplication(sys.argv)

        # Set application-wide dark theme
        app.setPalette(setup_dark_palette())

        # Set application icon
        icon_path = get_resource_path("resources/icon.ico")
        print(f"Looking for icon at: {icon_path}")
        if os.path.exists(icon_path):
            print("Icon file found")
            app.setWindowIcon(QIcon(icon_path))
        else:
            print("Icon file not found!")

        # Create and show main window
        window = BatteryHealthApp()
        window.show()

        # Start event loop
        sys.exit(app.exec())

    except Exception as e:
        print(f"Fatal error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
