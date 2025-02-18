"""
Build Script

This script handles the creation of an executable using PyInstaller
with proper configuration and resource bundling.
"""

import PyInstaller.__main__
import os
import sys
import shutil

def check_resources():
    """Verify that all required resources are present."""
    resources_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'resources')
    required_files = ['icon.ico']
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(os.path.join(resources_dir, file)):
            missing_files.append(file)
    
    if missing_files:
        raise FileNotFoundError(f"Missing required resource files: {', '.join(missing_files)}")

def clean_build_dirs():
    """Clean up build and dist directories."""
    dirs_to_clean = ['build', 'dist']
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    for dir_name in dirs_to_clean:
        dir_path = os.path.join(project_root, dir_name)
        if os.path.exists(dir_path):
            try:
                shutil.rmtree(dir_path)
                print(f"Cleaned {dir_name} directory")
            except Exception as e:
                print(f"Warning: Could not clean {dir_name} directory: {e}")

def build_executable():
    """Build the executable with PyInstaller."""
    try:
        # Verify resources
        check_resources()
        
        # Clean previous builds
        clean_build_dirs()
        
        # Add project root to Python path
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(current_dir)
        sys.path.append(project_root)
        
        # Prepare resource path based on OS
        resource_separator = ';' if sys.platform == 'win32' else ':'
        resource_path = f"resources/icon.ico{resource_separator}resources"
        
        # PyInstaller configuration
        pyinstaller_args = [
            os.path.join('src', 'main.py'),
            '--name=BatteryHealthChecker',
            '--onefile',
            '--windowed',
            f'--icon={os.path.join("resources", "icon.ico")}',
            f'--add-data={resource_path}',
            '--hidden-import=PyQt6.QtCore',
            '--hidden-import=PyQt6.QtGui',
            '--hidden-import=PyQt6.QtWidgets',
            '--hidden-import=bs4',
            '--hidden-import=lxml',
            '--noconsole',
            '--clean',
            '--noconfirm',
            '--log-level=WARN',
            # Optimize for size without using strip
            '--optimize=2'
        ]
        
        # Run PyInstaller
        print("Starting build process...")
        PyInstaller.__main__.run(pyinstaller_args)
        print("Build completed successfully!")
        
        # Verify build output
        exe_name = 'BatteryHealthChecker.exe' if sys.platform == 'win32' else 'BatteryHealthChecker'
        exe_path = os.path.join(project_root, 'dist', exe_name)
        
        if not os.path.exists(exe_path):
            raise FileNotFoundError("Build failed: Executable not found in dist directory")
        
        print(f"Executable created at: {exe_path}")
        
    except Exception as e:
        print(f"Build failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    build_executable()