"""
Resource Helper Module

This module provides utilities for handling application resources,
ensuring proper path resolution in both development and packaged environments.
"""

import os
import sys

def get_resource_path(relative_path: str) -> str:
    """
    Get absolute path to a resource, works for dev and for PyInstaller.
    
    Args:
        relative_path (str): Path relative to the application root
        
    Returns:
        str: Absolute path to the resource
    """
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        # If not running as bundled exe, look in parent directory
        base_path = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    return os.path.join(base_path, relative_path) 