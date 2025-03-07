<div align="center">
  <h1>🚀 VSCode Installer for Termux/PRoot-Distro</h1>
  <p>A powerful, user-friendly script to install Visual Studio Code in Termux's PRoot-Distro</p>

  ![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
  ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
  ![VSCode](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)
  
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Visual_Studio_Code_1.35_icon.svg/2048px-Visual_Studio_Code_1.35_icon.svg.png" alt="VSCode Logo" width="150px">
</div>

## ✨ Features

- 🛡️ **Secure User Setup**: Creates a dedicated user with sudo privileges
- 🎨 **Beautiful UI**: Colorful and intuitive interface
- 🔐 **Automated Setup**: Handles all configurations automatically
- 🔄 **Smart Installation**: Multiple installation methods
- 📦 **Package Management**: Handles dependencies intelligently
- 🚦 **Error Handling**: Comprehensive error detection and recovery
- 🎯 **GitHub Integration**: Built-in GitHub CLI setup

## 📋 Prerequisites

- [Termux](https://termux.dev) app installed
- PRoot-Distro with Debian installed
- Internet connection

## 🚀 Quick Start

1. **Enter Debian environment**:
```bash
proot-distro login debian
```

2. **Install git**:
```bash
apt update && apt install git -y
```

3. **Clone & Run**:
```bash
git clone https://github.com/shivamgwgtech/Install-VS-code-on-Android-Using-Termux vscode 
```

3. Navigate to script directory:
```bash
cd vscode
```

4. Make script executable:
```bash
chmod +x install_vscode.sh
./install_vscode.sh
```

## 🎯 Installation Methods

### 1. Repository Installation
- Uses official Microsoft repository
- Automatic updates support
- Recommended for most users

### 2. Direct .deb Installation
- Offline installation support
- Uses cached .deb if available
- Fresh download if needed

## 🔐 Security Features

- Creates non-root user automatically
- Configures sudo access securely
- Optional passwordless sudo
- Proper file permissions

## 🛠️ Post-Installation

After installation, you can:
- Start VSCode: `code`
- Enable Copilot: `code --enable-proposed-api=github.copilot`
- Configure Git: `gh auth login`

## ⚠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| Sandbox Error | Use `code --no-sandbox` |
| Display Error | Check `DISPLAY` variable |
| Permission Error | Verify sudo setup |

## 📱 Compatibility

- ✅ ARM64 devices
- ✅ ARM32 devices
- ✅ x86_64 devices

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Microsoft VSCode Team](https://github.com/microsoft/vscode)
- [Termux Development Team](https://github.com/termux)
- [PRoot-Distro maintainers](https://github.com/termux/proot-distro)

## 📞 Support

- 🐛 [Report Bug](https://github.com/shivamgwgtech/Install-VS-code-on-Android-Using-Termux/issues)
- 💡 [Request Feature](https://github.com/shivamgwgtech/Install-VS-code-on-Android-Using-Termux/issues)
- 📧 [Email Support](mailto:your.email@example.com)

<div align="center">

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=shivamgwgtech/Install-VS-code-on-Android-Using-Termux&type=Date)](https://star-history.com/#shivamgwgtech/Install-VS-code-on-Android-Using-Termux&Date)

---

<p align="center">Made with ❤️ for the Termux Community</p>

</div>
