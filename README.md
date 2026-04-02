<!--
Copyright (c) 2026 InfoBeans
Internal Authors: InfoBeans Accelerator Team
All rights reserved.

This software is proprietary and confidential.
Unauthorized copying, distribution, modification, or use
of this software, via any medium, is strictly prohibited.

This package is intended for internal enterprise use only.
-->

# ibtest

*Comprehensive Test Automation Framework*

ibtest is a comprehensive test automation framework built on Python 3.12+ with Playwright, Pytest. The framework implements a modular architecture supporting JIRA-Xray Integration, Parallel Processing, HTML Reporting, Email, Teams and  Slack Notifications.

## ✨ Key Features

- **📊 Rich Reporting:** HTML, JSON, PDF report formats
- **🔧 CI/CD Ready:** GitHub Actions configured
- **📝 Test Management:** Jira Xray integration for test case tracking
- **⚡ Parallel Execution:** Fast test runs with ibtest
- **🛡️ Quality Gates:** Automatic screenshot capture on failures

## 🚀 Quick Start

### Prerequisites

- **Python 3.12+** (recommended)
- **Git** for version control

### Setup

1. **Create and activate a virtual environment (recommended):**
    - On Windows:
      ```bash
      python -m venv .venv
      .venv\Scripts\activate
      ```
    - On macOS/Linux:
      ```bash
      python3 -m venv .venv
      source .venv/bin/activate
      ```

2. **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3. **Install Playwright browsers:**
    ```bash
    playwright install
    ```

4. **Configure environment (optional):**
    - copy `.env.sample` to `.env` and edit as needed for environment-specific settings.

## Running Tests

1. **Run all tests:**
    ```bash
    ibtest run --app demoapp --config config.yaml --workers-count auto --split-level module --reruns 2 --reruns-delay 10 --debug-level INFO

    --app       		# Application name (must match folder under apps/)
    --config    		# Environment-specific configuration file
    --workers-count auto	# Number of parallel test workers
    --split-level module  # Split levels (test_file/module)
    --reruns 2		# Retry failed tests
    --reruns-delay 2	# Delay (in seconds) between retries
    --debug-level INFO        # INFO, DEBUG, WARNING, ERROR, CRITICAL
    ```
## Troubleshooting

- Ensure all dependencies are installed and the virtual environment is active.
- If browsers are missing, re-run `playwright install`.
- For verbose test output, use:
    ```bash
    ibtest run --app demoapp --config config.yaml --workers-count auto --split-level module --reruns 2 --reruns-delay 10 --debug-level DEBUG

    --app       		# Application name (must match folder under apps/)
    --config    		# Environment-specific configuration file
    --workers-count 	# Number of parallel test workers
    --split-level module  # Split levels (test_file/module)
    --reruns 2		# Retry failed tests
    --reruns-delay 2	# Delay (in seconds) between retries
    --debug-level DEBUG        # INFO, DEBUG, WARNING, ERROR, CRITICAL
    ```
- Check `pytest.ini` and `config.yaml` for correct configuration.

## Support
For questions or issues, contact the framework maintainer or raise an issue in the repository.

