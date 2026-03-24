<!--
Copyright (c) 2026 InfoBeans
Internal Authors: InfoBeans Accelerator Team
All rights reserved.

This software is proprietary and confidential.
Unauthorized copying, distribution, modification, or use
of this software, via any medium, is strictly prohibited.

This package is intended for internal enterprise use only.
-->

# ibtest Framework - Folder Structure Documentation

## Complete Directory Architecture

This document provides a comprehensive breakdown of every directory and file in the ibtest framework, explaining their purpose, contents, and interdependencies.

## Root Level Structure

```
ibtest/
├── .github/                   # GitHub Actions workflows and templates
├── apps/                      # Application source code and test implementation
├── framework/                 # Core source code and test implementation
├── docs/                      # Documentation and guides
├── ibtest.py                  # Entry point for test execution
├── linter.py                  # Linter command to run various linting on source code.
└── [Configuration Files]      # Root-level configuration files
```

## Detailed Directory Breakdown

### **1. .github/** - GitHub Actions Workflows

#### **Directory Structure**
```
.github/
├── scripts/
│   ├── prepare_email_body.py        # Email body generation script
├── templates/
│   └── email-template.html          # HTML email template for notifications
└── workflows/
    ├── MasterPipeline.yml           # Main GitHub Actions workflow
    └──StaticCodeAnalysis.yml        # SCA workflow
```

#### **Purpose and Functionality**
- **MasterPipeline.yml**: Comprehensive GitHub Actions workflow
  - **Execution Modes**:
    - `parallel-with-pytest`: Uses pytest-xdist for parallel execution
  - **Environment Management**: Dynamic environment configuration
  - **Artifact Management**: Automated report generation and upload
  - **Multi-Channel Notifications**: Slack, Teams, and email integration

- **Static Code Analysis**: Pre-execution quality gates
  - Code quality assessment before test execution
  - Security vulnerability scanning

### **3. framework/** - Core Source Code

#### **Directory Structure**
```
framework/
├── browser/                      # Browser instance management
│   ├── __init__.py
│   └── browser_factory.py        # Browser setup and teardown
├── core/                         # Foundation classes and base functionality
│   ├── utils/                    # Core utility functions
│   |   ├── __init__.py
│   |   └── logger.py             # Singleton logging object for the framework
│   ├── __init__.py
├── hooks/                        # Pytest pluggable hooks via -p option
│   ├── __init__.py
│   ├── pytest_xray_hook.py       # Hook to parse xray markers
├── plugins/                      # Framework plugins
│   ├── __init__.py
│   ├── html_report/              # Plugin to integrate HTML reporting tool
│   ├── jira/                     # Plugin to integrate Jira Xray API
├── scaffold_tests/               # Scaffold tests
│   ├── resources/                # Template files for scaffolding
│   ├── scaffold.py               # Scaffold tool
└── __init__.py
```

### **4. ibtest.py - Main test runner

Comphrehensive tool that helps all the option to scaffold and setup test testss, run test testss. 

### **5. linter.py - linter script

Tool to run lint checking and fixing.

### **6. Configuration Files** - Root-Level Configuration

#### **Core Configuration Files**
- **`requirements.txt`**: Python dependency management (69 dependencies)
  - **Core Testing**: pytest, playwright
  - **Reporting**: reportlab, pytest-html, pytest-json-report

## File Interdependencies

### **Configuration Hierarchy**
```
Root Level
├── requirements.txt (Dependencies)
├── pyproject.toml (Test Framework Settings)
└── conftest.py (Test Fixtures & Hooks)


CI/CD Integration
└── .github/workflows/ (GitHub Actions)
```

This comprehensive folder structure provides a scalable, maintainable foundation for enterprise-level test automation with extensive integration capabilities.
