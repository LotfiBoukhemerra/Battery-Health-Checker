"""
@lotfi_bkmr
Launcher script for Battery Health Checker
"""

from src.main import main
import os
import sys

# Add project root to Python path
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.append(project_root)


if __name__ == "__main__":
    main()
