# Python Projects

This directory contains Python applications and utilities.

## Projects Overview

- **git-helper/** - Python utility for Git repository management and automation

## Development Environment

### Prerequisites
- Python 3.7+ installed
- pip package manager
- Virtual environment (recommended)

### Setting Up Virtual Environment
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Common Development Practices

### Code Quality
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Include docstrings for functions and classes
- Write unit tests for core functionality

### Package Management
```bash
# Install packages
pip install package-name

# Freeze dependencies
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt
```

### Building Executables
Some projects use PyInstaller for creating standalone executables:
```bash
# Install PyInstaller
pip install pyinstaller

# Build executable
pyinstaller your-script.py

# Build with spec file
pyinstaller your-script.spec
```

## Project Structure

Each Python project typically follows this structure:
```
project-name/
├── src/                    # Source code
├── tests/                  # Unit tests
├── docs/                   # Documentation
├── requirements.txt        # Dependencies
├── setup.py               # Package setup
├── README.md              # Project documentation
└── .gitignore             # Git ignore rules
```

## Testing

### Running Tests
```bash
# Run all tests
python -m pytest

# Run specific test file
python -m pytest tests/test_file.py

# Run with coverage
python -m pytest --cov=src
```

## Deployment

### Local Development
```bash
# Install in development mode
pip install -e .

# Run application
python -m your_package
```

### Production Deployment
- Use requirements.txt for dependency management
- Consider using Docker for containerization
- Implement proper logging and error handling
- Use environment variables for configuration