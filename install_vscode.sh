#!/bin/bash

# Enhanced UI colors and styles
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Enhanced status display functions
print_status() {
    echo -e "\n${BOLD}${BLUE}┌──${NC} ${BOLD}${WHITE}$1${NC}"
}

print_info() {
    echo -e "\n${BOLD}${GREEN}┌─────────────────────────────────┐${NC}"
    echo -e "${BOLD}${GREEN}│${NC}  ${BOLD}${GREEN}$1${NC}"
    echo -e "${BOLD}${GREEN}└─────────────────────────────────┘${NC}"
}

print_substatus() {
    echo -e "${BOLD}${BLUE}├──${NC} ${DIM}${WHITE}$1${NC}"
}

print_success() {
    echo -e "${BOLD}${GREEN}└─✓${NC} ${BOLD}${GREEN}$1${NC}"
}

print_error() {
    echo -e "${BOLD}${RED}└─✗${NC} ${BOLD}${RED}$1${NC}"
}

print_warning() {
    echo -e "${BOLD}${YELLOW}└─!${NC} ${BOLD}${YELLOW}$1${NC}"
}

print_header() {
    echo -e "\n${BOLD}${PURPLE}╔════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${PURPLE}║${NC}     ${BOLD}${CYAN}$1${NC}     ${BOLD}${PURPLE}║${NC}"
    echo -e "${BOLD}${PURPLE}╚════════════════════════════════════╝${NC}\n"
}

# Function for displaying status messages
print_status() {
    echo -e "${BLUE}[*] ${NC}$1"
}

print_success() {
    echo -e "${GREEN}[✓] ${NC}$1"
}

print_error() {
    echo -e "${RED}[✗] ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}[!] ${NC}$1"
}

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed."
        return 1
    fi
    return 0
}

# Function to handle errors
handle_error() {
    print_error "An error occurred: $1"
    print_warning "Attempting to fix..."
    return 1
}

# Function to check internet connection
check_internet() {
    print_status "Checking internet connection..."
    if ! curl -s --connect-timeout 5 https://packages.microsoft.com > /dev/null; then
        # First attempt failed, try debian.org as backup
        if ! curl -s --connect-timeout 5 https://deb.debian.org > /dev/null; then
            print_error "No internet connection!"
            print_warning "Please check your internet connection and try again."
            return 1
        fi
    fi
    print_success "Internet connection verified!"
    return 0
}

# Function to detect system architecture
get_architecture() {
    local arch=$(dpkg --print-architecture)
    echo "$arch"
}

# Function to get appropriate VSCode .deb URL
get_vscode_url() {
    local arch=$1
    case $arch in
        amd64|x86_64)
            echo "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
            ;;
        arm64|aarch64)
            echo "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
            ;;
        armhf|armv7l)
            echo "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-armhf"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to ask user for confirmation
ask_user() {
    echo -e "\n${BOLD}${CYAN}$1 (y/n)${NC}"
    read -r choice
    case $choice in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

# Function to install and setup GitHub CLI
setup_github_cli() {
    print_header "Setting up GitHub CLI"
    
    print_status "Installing GitHub CLI..."
    # Add GitHub CLI repository
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    # Update and install gh
    apt update
    apt install -y gh

    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI installation failed!"
        return 1
    fi
    
    print_success "GitHub CLI installed successfully!"
    return 0
}

# Function to handle GitHub token authentication
github_token_auth() {
    print_header "GitHub Authentication"
    
    print_status "To authenticate with GitHub, you'll need a Personal Access Token"
    print_substatus "You can create one at: ${UNDERLINE}https://github.com/settings/tokens${NC}"
    print_substatus "Required scopes: repo, read:org, workflow"
    
    echo -e "\n${BOLD}${CYAN}Would you like to enter your GitHub token now? (y/n)${NC}"
    read -r token_choice
    
    if [[ $token_choice =~ ^[Yy]$ ]]; then
        echo -e "\n${BOLD}${YELLOW}Enter your GitHub token:${NC} "
        read -r github_token
        
        if [ -n "$github_token" ]; then
            # Configure GitHub CLI with token
            echo "$github_token" | gh auth login --with-token
            if [ $? -eq 0 ]; then
                print_success "Successfully authenticated with GitHub!"
                
                # Test the authentication
                if gh auth status &> /dev/null; then
                    print_success "GitHub connection verified!"
                    
                    # Configure git credentials
                    git config --global credential.helper store
                    print_success "Git credentials configured!"
                    return 0
                fi
            else
                print_error "Authentication failed. Please check your token."
                return 1
            fi
        else
            print_error "No token provided."
            return 1
        fi
    else
        print_warning "Skipping GitHub authentication."
        return 0
    fi
}

# Automated keyring setup function
setup_keyring_automated() {
    print_header "Setting up GNOME Keyring"
    
    print_status "Configuring GNOME Keyring..."
    
    # Create keyring directories
    print_substatus "Creating keyring directories..."
    mkdir -p ~/.local/share/keyrings
    mkdir -p ~/.config/systemd/user/
    
    # Start keyring daemon
    print_substatus "Starting keyring daemon..."
    dbus-launch gnome-keyring-daemon --start --components=secrets,ssh
    
    # Create default keyring with empty password
    print_substatus "Creating default keyring..."
    echo -n "" | gnome-keyring-daemon --unlock
    
    # Add environment setup to bashrc
    print_substatus "Configuring environment..."
    if ! grep -q "gnome-keyring-daemon" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'

# GNOME Keyring environment setup
if [ -n "$DESKTOP_SESSION" ]; then
    eval $(gnome-keyring-daemon --start 2>/dev/null)
    export SSH_AUTH_SOCK
    export GNOME_KEYRING_CONTROL
    export GNOME_KEYRING_PID
fi
EOF
    fi

    # Create systemd service
    cat > ~/.config/systemd/user/gnome-keyring-daemon.service << 'EOF'
[Unit]
Description=GNOME Keyring Daemon
[Service]
Type=simple
ExecStart=/usr/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh
Restart=on-failure
[Install]
WantedBy=default.target
EOF

    # Enable and start service
    print_substatus "Enabling keyring service..."
    systemctl --user enable gnome-keyring-daemon.service
    systemctl --user start gnome-keyring-daemon.service

    print_success "GNOME Keyring setup completed!"
}

# Enhanced cleanup function
cleanup_files() {
    if [[ -f vscode.deb ]]; then
        if ask_user "Would you like to keep the VSCode installation file (vscode.deb)?"; then
            print_status "Keeping vscode.deb in current directory"
            print_substatus "You can find it at: $(pwd)/vscode.deb"
        else
            print_status "Removing installation file..."
            rm -f vscode.deb
            print_success "Cleanup completed!"
        fi
    fi
}

# Modify post_installation_setup to include GitHub CLI setup
post_installation_setup() {
    print_header "Post Installation Setup"

    # Setup GNOME Keyring
    if ask_user "Would you like to setup GNOME Keyring now? (Recommended for GitHub features)"; then
        setup_keyring_automated
    else
        print_warning "Skipping keyring setup. You might need it later for GitHub features."
    fi

    # Setup GitHub CLI and authentication
    if ask_user "Would you like to setup GitHub integration now?"; then
        if setup_github_cli; then
            github_token_auth
        else
            print_error "GitHub CLI setup failed!"
        fi
    fi

    # Create VSCode config directory
    mkdir -p ~/.config/Code/User/

    # Offer to create basic VSCode settings
    if ask_user "Would you like to create recommended VSCode settings?"; then
        cat > ~/.config/Code/User/settings.json << 'EOF'
{
    "editor.fontSize": 14,
    "editor.formatOnSave": true,
    "editor.minimap.enabled": false,
    "workbench.colorTheme": "Default Dark+",
    "terminal.integrated.fontSize": 14,
    "files.autoSave": "afterDelay",
    "github.gitAuthentication": true,
    "security.workspace.trust.enabled": true,
    "window.titleBarStyle": "custom"
}
EOF
        print_success "VSCode settings created!"
    fi

    # Cleanup installation files
    cleanup_files

    # Final instructions
    print_header "Setup Complete!"
    echo -e "${BOLD}${CYAN}Quick Start Guide:${NC}"
    echo -e "  ${BOLD}1.${NC} Start VSCode:              ${CYAN}code${NC}"
    echo -e "  ${BOLD}2.${NC} Start with no sandbox:     ${CYAN}code --no-sandbox${NC}"
    echo -e "  ${BOLD}3.${NC} Enable GitHub Copilot:     ${CYAN}code --enable-proposed-api=github.copilot${NC}"
    
    if pgrep -x "gnome-keyring-d" > /dev/null; then
        echo -e "\n${BOLD}${GREEN}GNOME Keyring Status:${NC} Running ✓"
    else
        echo -e "\n${BOLD}${YELLOW}GNOME Keyring Status:${NC} Not Running !"
        echo -e "To start keyring manually: ${CYAN}eval \$(gnome-keyring-daemon --start)${NC}"
    fi

    # Show GitHub status if CLI is installed
    if command -v gh &> /dev/null; then
        echo -e "\n${BOLD}${PURPLE}GitHub Status:${NC}"
        gh auth status 2>&1 | while read -r line; do
            echo -e "  ${BOLD}•${NC} $line"
        done
    fi

    # Show system information
    echo -e "\n${BOLD}${PURPLE}System Information:${NC}"
    echo -e "  ${BOLD}•${NC} VSCode Version: $(code --version 2>/dev/null | head -n1 || echo "Not found")"
    echo -e "  ${BOLD}•${NC} Architecture: $(dpkg --print-architecture)"
    echo -e "  ${BOLD}•${NC} Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    
    # Add troubleshooting tips
    echo -e "\n${BOLD}${YELLOW}Troubleshooting Tips:${NC}"
    echo -e "  ${BOLD}•${NC} If GitHub login fails:    ${CYAN}gh auth login --with-token${NC}"
    echo -e "  ${BOLD}•${NC} If keyring isn't working: ${CYAN}gnome-keyring-daemon --start --components=secrets${NC}"
    echo -e "  ${BOLD}•${NC} For password management:  ${CYAN}seahorse${NC}"
}

# Function for repository-based installation
install_from_repo() {
    print_status "📦 Installing VSCode from Microsoft Repository..."

    # Add Microsoft GPG key
    print_status "🔑 Adding Microsoft GPG key..."
    if ! sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > packages.microsoft.gpg; then
        handle_error "Failed to add Microsoft GPG key"
        return 1
    fi
    sudo mv packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg

    # Add VSCode repository
    print_status "📝 Adding VSCode repository..."
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

    # Update and install
    print_status "🔄 Updating package lists..."
    if ! sudo apt update; then
        handle_error "Failed to update package lists"
        return 1
    fi

    print_status "📥 Installing Visual Studio Code..."
    if ! sudo apt install -y code; then
        handle_error "Failed to install VSCode"
        return 1
    fi
}

# Function to check .deb file validity and version
check_deb_file() {
    local deb_file=$1
    
    # First check if file exists and is a valid .deb
    if [[ ! -f "$deb_file" ]] || ! dpkg-deb -I "$deb_file" &>/dev/null; then
        return 1
    fi

    # Get package details
    local pkg_name=$(dpkg-deb -f "$deb_file" Package)
    local pkg_version=$(dpkg-deb -f "$deb_file" Version)
    local pkg_arch=$(dpkg-deb -f "$deb_file" Architecture)
    
    if [[ "$pkg_name" == "code" ]]; then
        print_success "Found valid VSCode package:"
        print_substatus "Version: ${CYAN}${pkg_version}${NC}"
        print_substatus "Architecture: ${CYAN}${pkg_arch}${NC}"
        return 0
    fi
    return 1
}

handle_existing_deb() {
    local deb_file="vscode.deb"
    local arch=$(dpkg --print-architecture)
    
    if [[ -f "$deb_file" ]]; then
        print_header "Existing VSCode Package Found"
        
        if check_deb_file "$deb_file"; then
            while true; do
                echo -e "\n${BOLD}${CYAN}Would you like to:${NC}"
                echo -e "  ${BOLD}1.${NC} Use existing vscode.deb file"
                echo -e "  ${BOLD}2.${NC} Download fresh copy"
                echo -e "  ${BOLD}3.${NC} View detailed package info"
                echo -e "  ${BOLD}q.${NC} Quit installation"
                
                read -r -p "Enter choice [1-3/q]: " choice
                
                case $choice in
                    1)
                        print_status "Proceeding with existing package..."
                        return 0
                        ;;
                    2)
                        print_status "Will download fresh copy..."
                        rm -f "$deb_file"
                        return 1
                        ;;
                    3)
                        clear
                        print_header "Package Details"
                        dpkg-deb -I "$deb_file" | while read -r line; do
                            echo -e " ${BOLD}${CYAN}>${NC} $line"
                        done
                        echo -e "\nPress Enter to continue..."
                        read -r
                        clear
                        ;;
                    q|Q)
                        print_warning "Installation cancelled by user"
                        exit 0
                        ;;
                    *)
                        print_error "Invalid choice. Please try again."
                        ;;
                esac
            done
        else
            print_warning "Existing .deb file is invalid or corrupted"
            print_status "Would you like to download a fresh copy? (y/n)"
            read -r choice
            if [[ $choice =~ ^[Yy]$ ]]; then
                rm -f "$deb_file"
                return 1
            else
                print_error "Cannot proceed without valid .deb file"
                exit 1
            fi
        fi
    fi
    return 1
}

# Function for .deb based installation
install_from_deb() {
    print_header "Installing Visual Studio Code"
    
    local arch=$(dpkg --print-architecture)
    local download_url=$(get_vscode_url "$arch")
    
    # Handle existing .deb file
    if handle_existing_deb; then
        print_status "Using existing vscode.deb file"
    else
        print_status "Downloading VSCode for $arch architecture..."
        print_substatus "URL: $download_url"
        
        if ! wget --progress=bar:force:noscroll "$download_url" -O vscode.deb; then
            print_error "Download failed!"
            return 1
        fi
        
        # Verify downloaded file
        if ! check_deb_file "vscode.deb"; then
            print_error "Downloaded file is invalid!"
            rm -f vscode.deb
            return 1
        fi
    fi

    # Continue with installation...
    print_status "Installing VSCode package..."
    if ! dpkg -i vscode.deb; then
        print_warning "Fixing dependencies..."
        apt --fix-broken install -y
        if ! dpkg -i vscode.deb; then
            print_error "Installation failed!"
            return 1
        fi
    fi

    # Setup keyring automatically
    setup_keyring_automated
    
    # Offer GitHub setup
    post_installation_setup
}

# Function to create new user
create_user() {
    print_header "🔐 User Account Setup"
    
    # Check if sudo is installed
    if ! command -v sudo &>/dev/null; then
        print_status "📦 Installing sudo package..."
        apt update && apt install -y sudo
    fi

    while true; do
        echo -e "\n${BOLD}${CYAN}👤 Enter username (lowercase, no spaces):${NC}"
        read -r username
        
        # Validate username
        if [[ ! "$username" =~ ^[a-z][a-z0-9-]{2,}$ ]]; then
            print_error "❌ Invalid username format!"
            print_warning "Username must:"
            echo -e "  ${BOLD}•${NC} Start with a lowercase letter"
            echo -e "  ${BOLD}•${NC} Contain only lowercase letters, numbers, or hyphens"
            echo -e "  ${BOLD}•${NC} Be at least 3 characters long"
            continue
        fi
        
        # Check if user already exists
        if id "$username" &>/dev/null; then
            print_error "❌ User '$username' already exists!"
            continue
        fi
        
        # Get password with minimum 6 characters
        while true; do
            echo -e "\n${BOLD}${CYAN}🔑 Enter password for $username (min. 6 characters):${NC}"
            read -r password
            echo -e "${BOLD}${CYAN}🔄 Confirm password:${NC}"
            read -r password2
            
            if [ "$password" != "$password2" ]; then
                print_error "❌ Passwords don't match!"
                continue
            fi
            
            if [ ${#password} -lt 6 ]; then
                print_error "❌ Password must be at least 6 characters!"
                continue
            fi
            break
        done
        
        # Create user with home directory
        print_status "👥 Creating user account..."
        useradd -m -s /bin/bash "$username"
        echo "$username:$password" | chpasswd
        
        # Setup sudo access
        print_status "🔑 Setting up sudo access..."
        usermod -aG sudo "$username"
        
        # Configure sudoers
        echo -e "\n${BOLD}${CYAN}🔐 Allow sudo commands without password? [Y/n]:${NC}"
        read -r sudo_nopass
        case $sudo_nopass in
            [Nn]* ) 
                echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
                ;;
            * ) 
                echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
                ;;
        esac
        
        # Copy script to new user's home
        local script_path=$(readlink -f "$0")
        local script_name=$(basename "$script_path")
        local user_home="/home/$username"
        
        print_status "📋 Copying installation script..."
        cp "$script_path" "$user_home/$script_name"
        chown "$username:$username" "$user_home/$script_name"
        chmod +x "$user_home/$script_name"
        
        # Fix hostname resolution
        hostname=$(hostname)
        echo "127.0.0.1 $hostname" >> /etc/hosts
        
        print_success "✅ User account created successfully!"
        echo -e "\n${BOLD}${CYAN}📝 Account Details:${NC}"
        echo -e "  ${BOLD}•${NC} Username: ${GREEN}$username${NC}"
        echo -e "  ${BOLD}•${NC} Password: ${GREEN}$password${NC}"
        echo -e "  ${BOLD}•${NC} Sudo access: ${GREEN}Yes${NC}"
        
        # Switch to new user
        print_status "👤 Switching to user $username..."
        cd "$user_home"
        exec su - "$username"
        break
    done
}

# Check user environment
check_environment() {
    print_header "🔍 Environment Check"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        while true; do
            print_warning "⚠️  You are running as root!"
            echo -e "\n${BOLD}${CYAN}Choose an option:${NC}"
            echo -e "  ${BOLD}[1]${NC} 👤 Create a new user account ${GREEN}(recommended)${NC}"
            echo -e "  ${BOLD}[2]${NC} ⚠️  Continue as root ${YELLOW}(not recommended)${NC}"
            echo -e "  ${BOLD}[Q]${NC} ❌ Quit\n"
            echo -e "${BOLD}${CYAN}Enter your choice [1/2/Q]:${NC} "
            read -r choice
            
            case ${choice,,} in  # Convert to lowercase
                1|"one"|"create"|"user")
                    create_user
                    break
                    ;;
                2|"two"|"root"|"continue")
                    print_warning "⚠️  Continuing as root..."
                    break
                    ;;
                q|"quit"|"exit"|"")
                    print_status "👋 Installation cancelled"
                    exit 0
                    ;;
                *)
                    print_error "❌ Invalid choice! Please try again."
                    sleep 1
                    clear
                    ;;
            esac
        done
    fi
    
    # Check for sudo access
    if ! sudo -v &>/dev/null; then
        print_error "❌ You don't have sudo privileges!"
        echo -e "Please run:"
        echo -e "${CYAN}su -c 'usermod -aG sudo $USER'${NC}"
        exit 1
    fi
}

# Main installation function
install_vscode() {
    clear
    echo -e "${PURPLE}=================================${NC}"
    echo -e "${CYAN}VSCode Installation Script for Termux${NC}"
    echo -e "${PURPLE}=================================${NC}"
    echo

    # Check if running in proot-distro
    if [ ! -f /etc/debian_version ]; then
        print_error "This script must be run in proot-distro Debian!"
        print_warning "Please run 'proot-distro login debian' first."
        exit 1
    fi

    # Check internet connection
    print_status "Checking internet connection..."
    check_internet || return 1

    # Update package lists
    print_status "Updating package lists..."
    if ! apt update; then
        handle_error "Failed to update package lists"
        print_warning "Trying to fix package lists..."
        rm -f /var/lib/apt/lists/* && apt update
    fi

    # Install required dependencies
    print_status "Installing required dependencies..."
    local dependencies=(
        # Core utilities
        "apt-transport-https"  # HTTPS transport for apt
        "ca-certificates"      # SSL certificates
        "curl"                 # URL data transfer tool
        "git"                 # Version control system
        "gnome-keyring"       # Password/key manager
        "gpg"                 # GNU Privacy Guard
        "wget"                # File download utility

        # Libraries
        "libatk1.0-0"         # Accessibility toolkit
        "libgbm1"             # Graphics buffer manager
        "libgtk-3-0"          # GUI toolkit
        "libnss3"             # Network Security Services
        "libsecret-1-0"       # Secret storage
    )   

    for dep in "${dependencies[@]}"; do
        print_info "Installing $dep..."
        if ! apt install -y "$dep"; then
            handle_error "Failed to install $dep"
            print_warning "Retrying installation of $dep..."
            apt --fix-broken install -y
            apt install -y "$dep"
        fi
    done

    # Installation method selection
    while true; do
        echo
        echo -e "${CYAN}Please select installation method:${NC}"
        echo -e "${YELLOW}1) Install from Microsoft Repository (Recommended)${NC}"
        echo -e "${YELLOW}2) Install from .deb package${NC}"
        echo
        read -p "Enter your choice (1 or 2): " install_choice

        case $install_choice in
            1)
                install_from_repo
                break
                ;;
            2)
                install_from_deb
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done

    # Verify installation
    if check_command code; then
        print_success "Visual Studio Code has been successfully installed!"
        echo
        print_status "You can now start VSCode by typing 'code'"
        echo
        print_warning "Note: You might need to run 'code --no-sandbox' if you encounter any issues"
        echo
        print_success "Installation completed successfully!"
        
        echo -e "${BOLD}${CYAN}Usage Instructions:${NC}"
        echo -e "  ${BOLD}1.${NC} Start VSCode:          ${CYAN}code${NC}"
        echo -e "  ${BOLD}2.${NC} With GitHub Copilot:   ${CYAN}code --enable-proposed-api=github.copilot${NC}"
        echo -e "  ${BOLD}3.${NC} With custom keyring:   ${CYAN}code --password-store=gnome${NC}"
        
        echo -e "\n${BOLD}${YELLOW}Available GitHub Features:${NC}"
        echo -e "  ${BOLD}•${NC} Copilot"
        echo -e "  ${BOLD}•${NC} Codespaces"
        echo -e "  ${BOLD}•${NC} Pull Requests"
        echo -e "  ${BOLD}•${NC} Issue Management"
        
        echo -e "\n${BOLD}${GREEN}GitHub Commands:${NC}"
        echo -e "  ${BOLD}•${NC} Check status:    ${CYAN}gh auth status${NC}"
        echo -e "  ${BOLD}•${NC} Login again:     ${CYAN}gh auth login${NC}"
        echo -e "  ${BOLD}•${NC} View PRs:        ${CYAN}gh pr list${NC}"
        echo -e "  ${BOLD}•${NC} Create PR:       ${CYAN}gh pr create${NC}"
    else
        print_error "Installation verification failed."
        print_warning "Please try running the script again or report the issue."
        return 1
    fi
}

# Main script execution
main() {
    clear
    print_header "🚀 VSCode Installer for Termux/PRoot"
    
    # Check environment first
    check_environment
    
    # Check for required packages
    print_status "📦 Checking required packages..."
    local required_packages=(wget curl sudo)
    local missing_packages=()
    
    for pkg in "${required_packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        print_warning "⚠️  Missing required packages: ${missing_packages[*]}"
        if ask_user "Would you like to install them now?"; then
            sudo apt update
            sudo apt install -y "${missing_packages[@]}"
        else
            print_error "❌ Cannot proceed without required packages"
            exit 1
        fi
    fi
    
    # Continue with installation
    if install_vscode; then
        print_success "✅ Installation completed successfully!"
    else
        echo
        echo -e "${YELLOW}Would you like to try again? (y/n)${NC}"
        read -r choice
        case $choice in
            [Yy]* ) return 1;;
            * ) exit 1;;
        esac
    fi
    
}

# Run main function
main 