"""
Build Script

This script handles the creation of an executable using PyInstaller
with proper configuration and resource bundling.
"""

import PyInstaller.__main__
import os
import sys
import shutil
import glob

def find_dll_paths():
    """Find the paths to required DLLs in the current Python environment."""
    found_dlls = []
    
    # Get the current Python environment directory
    python_dir = os.path.dirname(sys.executable)
    venv_name = os.path.basename(python_dir)
    
    print(f"Python executable: {sys.executable}")
    print(f"Python directory: {python_dir}")
    
    # If we're in a virtual environment, DLLs might be in different locations
    if 'venv' in python_dir.lower() or '.venv' in python_dir.lower():
        print("Virtual environment detected - checking venv DLL locations")
        
        # In virtual environments, DLLs are often in the base Python installation
        # or in the venv's DLLs folder
        potential_paths = [
            os.path.join(python_dir, 'DLLs'),
            os.path.join(python_dir, 'Scripts'),
            os.path.join(python_dir, '..', 'DLLs'),  # Go up one level
            os.path.join(os.path.dirname(python_dir), 'DLLs'),
            # Base Python installation (if virtual env is linked)
            os.path.join(sys.base_prefix, 'DLLs') if hasattr(sys, 'base_prefix') else None,
            os.path.join(sys.base_prefix, 'Library', 'bin') if hasattr(sys, 'base_prefix') else None,
        ]
    else:
        # Standard Python installation
        potential_paths = [
            os.path.join(python_dir, 'DLLs'),
            os.path.join(python_dir, 'Library', 'bin'),
            os.path.join(python_dir, 'bin'),
        ]
    
    # Filter out None values and non-existent paths
    dll_locations = [path for path in potential_paths if path and os.path.exists(path)]
    
    # Required DLLs with possible variations
    required_dlls = {
        'libcrypto': ['libcrypto-3-x64.dll', 'libcrypto-1_1-x64.dll'],
        'libssl': ['libssl-3-x64.dll', 'libssl-1_1-x64.dll'],
        'libbz2': ['LIBBZ2.dll', 'libbz2.dll'],
        'libffi': ['ffi.dll', 'libffi-8.dll', 'libffi.dll']
    }
    
    print("Searching for required DLLs in current environment...")
    
    for dll_dir in dll_locations:
        print(f"Checking: {dll_dir}")
        
        for dll_key, dll_variants in required_dlls.items():
            for dll_name in dll_variants:
                dll_path = os.path.join(dll_dir, dll_name)
                if os.path.exists(dll_path):
                    found_dlls.append(f'--add-binary={dll_path};.')
                    print(f"Found DLL: {dll_path}")
                    # Break after finding the first variant
                    break
    
    if not found_dlls:
        print("Warning: No DLLs found in current environment.")
        print("This might be fine if your virtual environment doesn't need them.")
    
    return found_dlls

def copy_dlls_manually():
    """Manually copy required DLLs to the dist directory as a fallback."""
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Possible DLL locations
    dll_locations = [
        r'C:\ProgramData\miniconda3\DLLs',
        r'C:\ProgramData\miniconda3\Library\bin',
        r'C:\ProgramData\anaconda3\DLLs',
        r'C:\ProgramData\anaconda3\Library\bin'
    ]
    
    required_dlls = [
        'libcrypto-3-x64.dll',
        'libssl-3-x64.dll',
        'LIBBZ2.dll',
        'ffi.dll'
    ]
    
    # Find dist directory
    dist_dir = os.path.join(project_root, 'dist', 'BatteryHealthChecker')
    if not os.path.exists(dist_dir):
        dist_dir = os.path.join(project_root, 'dist')
    
    if not os.path.exists(dist_dir):
        print("Dist directory not found, skipping manual DLL copy")
        return
    
    print("Attempting to copy DLLs manually...")
    
    for dll_name in required_dlls:
        dll_found = False
        for location in dll_locations:
            dll_path = os.path.join(location, dll_name)
            if os.path.exists(dll_path):
                try:
                    dest_path = os.path.join(dist_dir, dll_name)
                    shutil.copy2(dll_path, dest_path)
                    print(f"Copied {dll_name} to {dest_path}")
                    dll_found = True
                    break
                except Exception as e:
                    print(f"Failed to copy {dll_name}: {e}")
        
        if not dll_found:
            print(f"Warning: Could not find {dll_name}")

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
        # Verify we're using the right Python environment
        print(f"Using Python: {sys.executable}")
        print(f"Python version: {sys.version}")
        
        # Check if we're in a virtual environment
        if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
            print(f"Virtual environment detected: {sys.prefix}")
        else:
            print("Warning: Not in a virtual environment!")
        
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
        
        # Find DLL paths
        dll_binaries = find_dll_paths()
        
        # Hidden imports for common issues
        hidden_imports = [
            'PyQt6.QtCore',
            'PyQt6.QtGui', 
            'PyQt6.QtWidgets',
            'bs4',
            'lxml',
            '_ctypes',
            '_ssl',
            '_hashlib',
            '_bz2',
            'ctypes.util',
            'ctypes._endian'
        ]
        
        # PyInstaller configuration
        pyinstaller_args = [
            os.path.join('src', 'main.py'),
            '--name=BatteryHealthChecker',
            '--onefile',  # Changed from --onefile for better compatibility
            '--windowed',
            f'--icon={os.path.join("resources", "icon.ico")}',
            f'--add-data={resource_path}',
            '--noconsole',
            '--clean',
            '--noconfirm',
            '--log-level=DEBUG',  # Changed to DEBUG for more info
            '--optimize=2',
            # Additional collections to ensure all dependencies
            '--collect-all=ctypes',
            '--collect-all=ssl',
            '--collect-all=hashlib',
            '--collect-all=bz2',
            # Exclude some problematic modules that might cause issues
            '--exclude-module=tkinter',
            '--exclude-module=matplotlib',
            '--exclude-module=numpy',
            '--exclude-module=pandas'
        ]
        
        # Add hidden imports
        for import_name in hidden_imports:
            pyinstaller_args.append(f'--hidden-import={import_name}')
        
        # Add DLL binaries
        pyinstaller_args.extend(dll_binaries)
        
        # Print configuration for debugging
        print("PyInstaller configuration:")
        for arg in pyinstaller_args:
            print(f"  {arg}")
        print()
        
        # Run PyInstaller
        print("Starting build process...")
        PyInstaller.__main__.run(pyinstaller_args)
        print("Build completed successfully!")
        
        # Verify build output
        exe_name = 'BatteryHealthChecker.exe' if sys.platform == 'win32' else 'BatteryHealthChecker'
        dist_dir = os.path.join(project_root, 'dist', 'BatteryHealthChecker')
        exe_path = os.path.join(dist_dir, exe_name)
        
        # Check if directory-based build exists
        if not os.path.exists(exe_path):
            # Check for onefile build
            exe_path = os.path.join(project_root, 'dist', exe_name)
        
        if not os.path.exists(exe_path):
            # List what's actually in the dist directory
            dist_base = os.path.join(project_root, 'dist')
            if os.path.exists(dist_base):
                print(f"Contents of dist directory:")
                for item in os.listdir(dist_base):
                    item_path = os.path.join(dist_base, item)
                    if os.path.isdir(item_path):
                        print(f"  Directory: {item}")
                        for subitem in os.listdir(item_path):
                            print(f"    {subitem}")
                    else:
                        print(f"  File: {item}")
            raise FileNotFoundError("Build failed: Executable not found in expected location")
        
        print(f"Executable created at: {exe_path}")
        if os.path.exists(exe_path):
            print(f"Executable size: {os.path.getsize(exe_path) / (1024*1024):.1f} MB")
        
        # Try to copy DLLs manually as a backup
        try:
            copy_dlls_manually()
        except Exception as e:
            print(f"Manual DLL copy failed: {e}")
        
    except Exception as e:
        print(f"Build failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    build_executable()