# Streamlit Applications

This directory contains Streamlit web applications for data visualization and interactive dashboards.

## Projects Overview

- **basic-webpage/** - Simple Streamlit web application with animations and styling

## About Streamlit

Streamlit is an open-source Python library that makes it easy to create and share beautiful, custom web apps for machine learning and data science. With Streamlit, you can build interactive applications without needing to know HTML, CSS, or JavaScript.

## Prerequisites

- Python 3.7+
- Streamlit package
- Additional dependencies per project

## Quick Start

### Install Streamlit
```bash
pip install streamlit
```

### Run Applications
```bash
# Navigate to project directory
cd basic-webpage/

# Run the Streamlit app
streamlit run app.py
```

### Access Applications
Once running, Streamlit apps are typically available at:
- Local: `http://localhost:8501`
- Network: `http://<your-ip>:8501`

## Common Streamlit Features

### Interactive Components
- **Widgets** - Sliders, buttons, text inputs, file uploads
- **Charts** - Matplotlib, Plotly, Altair integrations
- **Data Display** - Tables, metrics, JSON display
- **Media** - Images, videos, audio playback

### Layout and Styling
- **Columns** - Multi-column layouts
- **Containers** - Grouping elements
- **Sidebar** - Navigation and controls
- **Custom CSS** - Advanced styling options

### Data Handling
- **Data Sources** - CSV, JSON, databases, APIs
- **Caching** - Performance optimization
- **Session State** - Maintaining state across interactions

## Development Best Practices

### Project Structure
```
streamlit-app/
├── app.py                  # Main application
├── requirements.txt        # Dependencies
├── config.toml            # Streamlit configuration
├── style/                 # CSS stylesheets
├── data/                  # Data files
├── utils/                 # Helper functions
└── README.md              # Documentation
```

### Performance Optimization
- Use `@st.cache_data` for data loading
- Use `@st.cache_resource` for expensive computations
- Minimize data transfers
- Optimize chart rendering

### Configuration
Create `.streamlit/config.toml` for app settings:
```toml
[theme]
primaryColor = "#FF6B6B"
backgroundColor = "#FFFFFF"
secondaryBackgroundColor = "#F0F2F6"
textColor = "#262730"
font = "sans serif"

[server]
port = 8501
address = "0.0.0.0"
```

## Deployment Options

### Local Development
```bash
streamlit run app.py
```

### Streamlit Cloud
- Push to GitHub repository
- Connect to Streamlit Cloud
- Deploy with automatic updates

### Docker Deployment
```dockerfile
FROM python:3.9-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8501
CMD ["streamlit", "run", "app.py"]
```

### Self-Hosted
```bash
# Install and run on server
pip install streamlit
streamlit run app.py --server.port 8501 --server.address 0.0.0.0
```

## Security Considerations

- Validate user inputs
- Sanitize file uploads
- Use secrets management for API keys
- Implement authentication if needed
- Secure network access

## Troubleshooting

### Common Issues
- Port conflicts - Change port with `--server.port`
- Module import errors - Check virtual environment
- Performance issues - Implement caching
- Styling problems - Verify CSS syntax

### Debug Mode
```bash
# Run with debug information
streamlit run app.py --logger.level debug
```