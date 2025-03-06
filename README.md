# VSCode Installer for Termux/PRoot-Distro

A robust, user-friendly script to install Visual Studio Code in Termux's PRoot-Distro Debian environment with automated setup for GitHub integration and GNOME Keyring.

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white)
![VSCode](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=flat&logo=visual-studio-code&logoColor=white)

## Features

- Comprehensive error handling
- Beautiful colorful UI
- Automated GNOME Keyring setup
- GitHub CLI integration
- Smart .deb package management
- Internet connection verification
- Minimal dependencies installation
- Multiple installation methods

## Prerequisites

- Termux with PRoot-Distro installed
- Debian environment in PRoot-Distro
- Active internet connection

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/vscode-termux-installer.git
```

2. Enter Debian environment:
```bash
proot-distro login debian
```

3. Navigate to script directory:
```bash
cd vscode-termux-installer
```

4. Make script executable:
```bash
chmod +x install_vscode.sh
```

5. Run the installer:
```bash
./install_vscode.sh
```

## Installation Options

The script offers multiple installation methods:

1. **Repository-based Installation**
   - Uses official Microsoft repository
   - Supports automatic updates
   - Recommended for most users

2. **Direct .deb Installation**
   - Supports offline installation
   - Uses existing .deb file if available
   - Downloads fresh copy if needed

## GitHub Integration

- Automated GitHub CLI setup
- Token-based authentication
- Support for:
  - GitHub Copilot
  - GitHub Codespaces
  - Pull Requests
  - Issue Management

## Troubleshooting

Common issues and solutions:

| Issue | Solution |
|-------|----------|
| Sandbox Error | Run: `code --no-sandbox` |
| GitHub Auth Failed | Run: `gh auth login --with-token` |
| Keyring Issues | Run: `gnome-keyring-daemon --start` |

## System Requirements

- Architecture: amd64, arm64, or armhf
- RAM: Minimum 1GB (2GB recommended)
- Storage: At least 1GB free space
- Internet: Required for initial setup

## Contributing

1. Fork the repository
2. Create your feature branch:
```bash
git checkout -b feature/AmazingFeature
```
3. Commit your changes:
```bash
git commit -m 'Add some AmazingFeature'
```
4. Push to the branch:
```bash
git push origin feature/AmazingFeature
```
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Microsoft VSCode Team
- Termux Development Team
- PRoot-Distro maintainers

## Support

If you encounter any issues:
1. Check the [Issues](https://github.com/yourusername/vscode-termux-installer/issues) page
2. Create a new issue with:
   - Your system information
   - Error messages
   - Steps to reproduce

## Future Plans

- [ ] Include popular extension pre-configuration
- [ ] Add backup/restore functionality
- [ ] Support for more PRoot distros

---

<p align="center">
  Made with ❤️ for the Termux community
</p>
