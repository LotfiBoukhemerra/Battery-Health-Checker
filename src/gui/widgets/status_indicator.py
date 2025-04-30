"""
Status Indicator Widget Module

This module provides a custom Qt widget for displaying battery health status
with smooth animations and a modern design.
"""

from PyQt6.QtWidgets import QFrame
from PyQt6.QtCore import Qt, QPropertyAnimation, QEasingCurve, pyqtProperty, QRectF
from PyQt6.QtGui import QPainter, QPainterPath, QFont, QColor, QPen, QLinearGradient


class StatusIndicator(QFrame):
    """
    Custom widget for displaying battery health status with animations.

    Features:
    - Animated battery level indicator
    - Smooth color transitions
    - Modern design with rounded corners
    - Customizable status text
    """

    def __init__(self, parent=None):
        """Initialize the status indicator widget."""
        super().__init__(parent)
        self._init_ui()
        self._init_properties()

    def _init_ui(self):
        """Initialize UI properties."""
        self.setFixedSize(280, 140)
        self.setFrameStyle(QFrame.Shape.NoFrame)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)

    def _init_properties(self):
        """Initialize widget properties."""
        self._color = QColor("#3dbaff")  # Default blue color
        self.status_text = ""  # Empty initial text
        self._percentage = 0

        # Setup color animation
        self._color_animation = QPropertyAnimation(self, b"color")
        self._color_animation.setDuration(500)
        self._color_animation.setEasingCurve(QEasingCurve.Type.OutCubic)

        # Setup percentage animation
        self._percentage_animation = QPropertyAnimation(self, b"percentage")
        self._percentage_animation.setDuration(1000)
        self._percentage_animation.setEasingCurve(QEasingCurve.Type.OutCubic)

    def paintEvent(self, event):
        """
        Custom paint event to draw the battery indicator.

        Args:
            event: QPaintEvent instance
        """
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        # Define battery shape dimensions
        body_width = self.width() - 40
        body_height = self.height() - 20
        tip_width = 20
        tip_height = 40

        # Draw battery outline
        self._draw_battery_outline(
            painter, body_width, body_height, tip_width, tip_height)

        # Draw battery level
        if self._percentage > 0:
            self._draw_battery_level(painter, body_width, body_height)

        # Draw status text
        self._draw_status_text(painter)

    def _draw_battery_outline(self, painter, body_width, body_height, tip_width, tip_height):
        """Draw the battery outline with shadow effect."""
        path = QPainterPath()

        # Main battery body with rounder corners
        path.addRoundedRect(20, 10, body_width, body_height, 15, 15)

        # Battery tip
        tip_x = body_width + 20
        tip_y = (self.height() - tip_height) // 2
        path.addRoundedRect(tip_x, tip_y, tip_width, tip_height, 8, 8)

        # Draw shadow with larger offset
        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(QColor(0, 0, 0, 20))
        painter.drawPath(path.translated(3, 3))

        # Draw outline with gradient
        gradient = self._create_background_gradient(path.boundingRect())
        painter.setBrush(gradient)
        painter.setPen(QPen(QColor("#13171b"), 2))
        painter.drawPath(path)

    def _create_background_gradient(self, rect):
        """Create a subtle gradient for the battery background."""
        gradient = QLinearGradient(rect.topLeft(), rect.bottomRight())
        gradient.setColorAt(0, QColor("#13171b"))
        gradient.setColorAt(1, QColor("#2d3741"))
        return gradient

    def _draw_battery_level(self, painter, body_width, body_height):
        """Draw the battery level indicator with glow effect."""
        level_width = (body_width - 10) * (self._percentage / 100)
        level_rect = QRectF(25, 15, level_width, body_height - 10)

        # Draw glow effect
        glow_color = QColor(self._color)
        glow_color.setAlpha(30)
        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(glow_color)
        glow_rect = level_rect.adjusted(-5, -5, 5, 5)
        painter.drawRoundedRect(glow_rect, 12, 12)

        # Draw main level
        painter.setBrush(QColor(self._color))
        painter.drawRoundedRect(level_rect, 12, 12)

    def _draw_status_text(self, painter):
        """Draw the status text."""
        painter.setPen(QColor("#ffffff"))
        font = QFont("Segoe UI", 24, QFont.Weight.Bold)
        painter.setFont(font)
        painter.drawText(
            self.rect(), Qt.AlignmentFlag.AlignCenter, self.status_text)

    def update_status(self, color: QColor, text: str):
        """
        Update the status indicator with new color and text.

        Args:
            color: QColor for the battery level
            text: Status text to display
        """
        # Animate color change
        self._color_animation.setStartValue(self._color)
        self._color_animation.setEndValue(color)
        self._color_animation.start()

        # Animate percentage change
        try:
            new_percentage = float(text.strip('%'))
            self._percentage_animation.setStartValue(self._percentage)
            self._percentage_animation.setEndValue(new_percentage)
            self._percentage_animation.start()
        except ValueError:
            self._percentage = 0

        self.status_text = text
        self.update()

    @pyqtProperty(QColor)
    def color(self):
        return self._color

    @color.setter
    def color(self, color):
        self._color = color
        self.update()

    @pyqtProperty(float)
    def percentage(self):
        return self._percentage

    @percentage.setter
    def percentage(self, value):
        self._percentage = value
        self.update()
