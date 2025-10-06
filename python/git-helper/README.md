# Git Helper Utility

A Python application for Git repository management and automation tasks.

## Overview

Git Helper is a command-line utility designed to streamline common Git operations and provide additional functionality for repository management.

## Contents

- **git-helper-05.spec** - PyInstaller specification file for building executable
- **build/** - Build artifacts and compiled executables
- **.vscode/** - Visual Studio Code configuration

## Features

Based on the build configuration, this tool likely provides:
- Git repository automation
- Batch operations across multiple repositories
- Enhanced Git workflow management
- Command-line interface for common Git tasks

## Building the Application

### Prerequisites
- Python 3.7+
- PyInstaller package
- Git installed and accessible

### Install Dependencies
```bash
# Install PyInstaller
pip install pyinstaller

# Install other dependencies (if requirements.txt exists)
pip install -r requirements.txt
```

### Build Executable
```bash
# Build using spec file
pyinstaller git-helper-05.spec

# Alternative: Direct build (if .py file exists)
pyinstaller git-helper-05.py
```

### Build Output
The executable will be created in:
- **dist/** - Final executable files
- **build/** - Intermediate build files

## PyInstaller Configuration

The `git-helper-05.spec` file contains build specifications:
- **Analysis** - Source file scanning and dependency detection
- **PYZ** - Python archive creation
- **EXE** - Executable generation settings
- **Hidden Imports** - Additional modules to include
- **Data Files** - Non-Python files to bundle

### Spec File Customization
```python
# Add hidden imports
hiddenimports=['module1', 'module2']

# Include data files
datas=[('config.ini', '.'), ('templates/', 'templates/')]

# Exclude modules
excludes=['unnecessary_module']

# Set executable options
console=True,  # or False for windowed
icon='app.ico'  # Application icon
```

## Development Setup

### Local Development
```bash
# Clone or navigate to project
cd git-helper/

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Run in development mode
python git-helper-05.py
```

### VS Code Configuration
The `.vscode/` directory may contain:
- **settings.json** - Project-specific settings
- **launch.json** - Debug configurations
- **tasks.json** - Build tasks

## Common Git Helper Operations

### Repository Management
```bash
# Clone multiple repositories
git-helper clone --file repos.txt

# Update all repositories
git-helper update --directory ~/projects

# Check status across repositories
git-helper status --recursive
```

### Batch Operations
```bash
# Batch commit across repositories
git-helper commit --message "Update documentation"

# Batch push to remote
git-helper push --branch main

# Batch pull from remote
git-helper pull --all
```

## Usage Examples

### Basic Commands
```bash
# Show help
git-helper --help

# List available commands
git-helper list

# Check version
git-helper --version
```

### Advanced Features
```bash
# Generate repository report
git-helper report --output report.html

# Backup repositories
git-helper backup --destination /backup/git/

# Sync with remote repositories
git-helper sync --dry-run
```

## Configuration

### Configuration File
Create a config file (if supported):
```ini
[default]
git_path = /usr/bin/git
default_branch = main
backup_path = ~/git-backups

[repositories]
auto_discover = true
ignore_paths = .git,node_modules,.vscode
```

### Environment Variables
```bash
# Set Git path
export GIT_HELPER_GIT_PATH=/usr/local/bin/git

# Set default directory
export GIT_HELPER_DEFAULT_DIR=~/projects
```

## Troubleshooting

### Common Issues
- **Git not found** - Ensure Git is in PATH
- **Permission denied** - Check file permissions
- **Import errors** - Verify all dependencies are installed
- **Executable not working** - Rebuild with updated PyInstaller

### Debug Mode
```bash
# Run with verbose output
git-helper --verbose command

# Enable debug logging
git-helper --debug command
```

## Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

### Code Style
- Follow PEP 8 guidelines
- Use meaningful variable names
- Add docstrings to functions
- Include type hints where appropriate

## Distribution

### Creating Releases
```bash
# Build executable
pyinstaller git-helper-05.spec

# Test executable
./dist/git-helper-05/git-helper-05 --help

# Package for distribution
tar -czf git-helper-v0.5.tar.gz -C dist git-helper-05/
```

### Installation
```bash
# Extract and install
tar -xzf git-helper-v0.5.tar.gz
sudo cp git-helper-05/git-helper-05 /usr/local/bin/
sudo chmod +x /usr/local/bin/git-helper-05
```