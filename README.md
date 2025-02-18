# Battery Health Checker

<div align="center">

<img src="resources/icon.png" alt="Battery Health Checker Logo" width="200"/>
<!-- ![Battery Health Checker Logo](resources/icon.png) -->

A Windows tool to monitor and analyze your laptop's battery health.

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue.svg?logo=paypal&style=flat-square)](https://www.paypal.com/paypalme/LotfiBoukhemerra) [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow.svg?logo=buy-me-a-coffee&style=flat-square)](https://buymeacoffee.com/eldev)

</div>

## Features

-   🔋 get battery health insrtantly
-   📊 Detailed battery capacity analysis
-   💻 Windows native integration
-   ⚡ Fast and lightweight

## Prerequisites

Before installing Battery Health Checker, ensure you have the following:

-   Windows 10/11 operating system
-   Administrator privileges (required for battery report generation)

if you want to test the code, you need:

-   Python 3.8 or higher
-   Git (optional, for cloning the repository)

## Installation

### Method 1: Using Pre-built Executable

1. Download the latest release from the [Releases](https://github.com/LotfiBoukhemerra/Battery-Health-Checker/releases/) page
2. Extract the ZIP file to your desired location
3. Run `BatteryHealthChecker.exe`

### Method 2: From Source Code

1. Clone the repository or download the source code:

```bash
git clone https://github.com/LotfiBoukhemerra/Battery-Health-Checker.git
cd Battery-Health-Checker
```

2. Create a virtual environment (recommended):

```bash
python -m venv venv
.\venv\Scripts\activate
```

3. Install required dependencies:

```bash
pip install -r requirements.txt
```

## Usage

### Running the Application

1. **Using the executable:**

    - Simply double-click `BatteryHealthChecker.exe`
    - If prompted, allow administrator privileges

2. **From source code:**
    - Navigate to the project directory
    - Run the launcher script:
    ```bash
    python launcher.py
    ```

### Features Guide

1. **Check Battery Health**

    - Click the "Check Battery Health" button
    - Wait for the analysis to complete
    - View detailed results including:
        - Design Capacity
        - Current Capacity
        - Health Percentage
        - Overall Status

2. **Understanding Results**
    - **Excellent** (90-100%): Battery is in optimal condition
    - **Good** (70-89%): Battery is performing well
    - **Fair** (50-69%): Consider monitoring battery performance
    - **Poor** (30-49%): Battery replacement may be needed soon
    - **Critical** (<30%): Battery replacement recommended

## Building from Source

To build the executable yourself:

1. Ensure you have PyInstaller installed:

```bash
pip install pyinstaller
```

2. Run the build script:

```bash
python src/build.py
```

The executable will be created in the `dist` directory.

## Project Structure

```
battery-health-checker/
├── launcher.py           # Application entry point
├── requirements.txt      # Python dependencies
├── src/
│   ├── core/            # Core business logic
│   ├── gui/             # User interface components
│   │   ├── widgets/     # Custom UI widgets
│   │   └── windows/     # Application windows
│   └── utils/           # Utility functions
└── resources/           # Application resources
```

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Commit your changes (`git commit -am 'Add new feature'`)
5. Push to the branch (`git push origin feature/improvement`)
6. Create a Pull Request

## Support the Project

If you find this tool useful, consider supporting its development:

<div align="center">

[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue.svg?logo=paypal&style=for-the-badge)](https://www.paypal.com/paypalme/LotfiBoukhemerra) [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow.svg?logo=buy-me-a-coffee&style=for-the-badge)](https://buymeacoffee.com/eldev)

</div>

Your support helps maintain and improve the Battery Health Checker!

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

-   Built with PyQt6 for modern UI
-   Uses Windows native battery reporting tools
-   Icons and resources from [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons)

---

<div align="center">

Made with ❤️ by <e/dev>

</div>
