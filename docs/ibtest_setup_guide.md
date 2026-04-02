<!--
Copyright (c) 2026 InfoBeans
Internal Authors: InfoBeans Accelerator Team
All rights reserved.

This software is proprietary and confidential.
Unauthorized copying, distribution, modification, or use
of this software, via any medium, is strictly prohibited.

This package is intended for internal enterprise use only.
-->

## 🚀 Prerequisites and Dependencies Setup

This guide provides direct links to official documentation for setting up all required dependencies, credentials, and integrations for the ibtest framework.

## 📋 System Requirements

### **Development Environment**
- **Python 3.12+** - [(Download Python)](https://python.org)
- **Git** - [(Download Git)](https://git-scm.com)

### **CI/CD Platforms**
- **GitHub Repository** - For GitHub Actions workflows

---

## 🔧 External Service Setup

### **1. Jira Xray Integration**

#### **Setup Links:**
1. **Create Jira Account** - [(Create Jira Account)](https://www.atlassian.com/software/jira)
2. **Install Xray App** - [(Install Xray)](https://docs.getxray.app/display/XRAY/Installation)
3. **Generate API Keys** - [(Generate Xray API Keys)](https://docs.getxray.app/display/XRAY/Authentication)

#### **Required Secrets/Variables:**
```bash
XRAY_CLIENT_ID=your-client-id-here
XRAY_CLIENT_SECRET=your-client-secret-here
XRAY_API_BASE_URL=https://your-domain.atlassian.net
XRAY_PROJECT_KEY=your-project-key-here
```

---

## 📢 Communication Setup

### **1. Slack Integration**

#### **Setup Links:**
1. **Create Slack App** - [(Create Slack App)](https://api.slack.com/apps)
2. **Enable Webhooks** - [(Enable Incoming Webhooks)](https://api.slack.com/messaging/webhooks)
3. **Set Permissions** - [(OAuth Permissions)](https://api.slack.com/apps)

#### **Required Secrets/Variables:**
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
SLACK_TOKEN=xoxb-your-bot-token
```

---

### **2. Microsoft Teams Integration**

#### **Setup Links:**
1. **Create Teams Webhook** - [(Create Teams Webhook)](https://docs.microsoft.com/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)
2. **Get Channel Email** - [(Get Teams Channel Email)](https://docs.microsoft.com/microsoftteams/platform/concepts/bots/bot-conversations/bots-conv-channel)

#### **Required Secrets/Variables:**
```bash
WEBHOOK_URL=https://outlook.office.com/webhook/YOUR/TEAMS/WEBHOOK
TEAMS_EMAIL=your-channel@teams.microsoft.com
```

---

### **3. Gmail Email Setup**

#### **Setup Links:**
1. **Create Gmail Account** - [(Create Gmail Account)](https://gmail.com)
2. **Enable 2FA** - [(Enable 2-Step Verification)](https://support.google.com/accounts/answer/1064203)
3. **Generate App Password** - [(Generate App Password)](https://support.google.com/accounts/answer/185833)

#### **Required Secrets/Variables:**
```bash
GMAIL_USERNAME=your-email@gmail.com
GMAIL_APP_PASSWORD=your-16-digit-app-password
NOTIFICATION_EMAIL=recipient@example.com
```

---

## 🔐 Credential Management

### **GitHub Actions Setup**

#### **Step 1: Access Repository Settings**
1. Go to your GitHub repository
2. Click "Settings" tab
3. Click "Secrets and variables" → "Actions"

#### **Step 2: Add All Required Secrets**
Click "New repository secret" for each:

| Secret Name | Description |
|-------------|-------------|
| `SLACK_WEBHOOK_URL` | Slack webhook URL |
| `SLACK_TOKEN` | Slack bot token |
| `WEBHOOK_URL` | Microsoft Teams webhook URL |
| `GMAIL_USERNAME` | Gmail email address |
| `GMAIL_APP_PASSWORD` | Gmail 16-digit app password |
| `NOTIFICATION_EMAIL` | Email recipient address |
| `XRAY_CLIENT_ID` | Jira Xray client ID |
| `XRAY_CLIENT_SECRET` | Jira Xray client secret |
| `XRAY_API_BASE_URL` | Jira Xray API base URL |
| `XRAY_PROJECT_KEY` | Jira Xray project key |



#### **Step 3: Create Environment-Specific Secrets**
1. Click "Environments" tab
2. Create environments: DEV, QA, PROD
3. Add secrets to each environment as needed

---

## 🧪 Notification Verification Scripts

#### **Notification Test**
```bash
# Test Slack
curl -X POST -H 'Content-type: application/json' \
  --data '{\"text\":\"Test notification\"}' \
  $SLACK_WEBHOOK_URL && echo "✅ Slack: OK" || echo "❌ Slack: Failed"

# Test Teams
curl -X POST -H 'Content-type: application/json' \
  --data '{\"text\":\"Test notification\"}' \
  $WEBHOOK_URL && echo "✅ Teams: OK" || echo "❌ Teams: Failed"
```

---

## 🔧 Local Development Setup

### **Environment Configuration**

#### **Create .env file:**
```bash
# .env
XRAY_CLIENT_ID="<XRAY_CLIENT_ID>"
XRAY_CLIENT_SECRET="<XRAY_CLIENT_SECRET>"
XRAY_API_BASE_URL="<XRAY_API_BASE_URL>"
XRAY_PROJECT_KEY="<XRAY_PROJECT_KEY>"
XRAY_PROJECT_ID="<XRAY_PROJECT_ID>"
JIRA_URL="<JIRA_URL>"
JIRA_API_EMAIL="<JIRA_API_EMAIL>"
JIRA_API_TOKEN="<JIRA_API_TOKEN>"
```

#### **Install Dependencies:**
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# macOS / Linux
source venv/bin/activate

# Windows
venv\Scripts\activate

# Reference:
# https://docs.python.org/3/library/venv.html

# Install ibtest framework from wheel
pip install ibtest-0.1.0-py3-none-any.whl

# Install Playwright browsers
playwright install chromium

# Basic configurations for framework level settings and github actions workflow.

# Creates basic sample test  to run locally/github actions workflow along with configuration files.
ibtest setup --app appname --scaffold true

# Creates full template with all test s (UI, API, DB tests, helpers, utils, test data).
ibtest setup --app appname --scaffold full

# Creates bare minimum configuration and a test file along with github actions workflow files.
ibtest setup --app appname --scaffold false

# Sets up pipeline-related files (.github, requirements.txt, docs, etc.) in the root directory.
ibtest setup-pipeline

#### **Run Tests Locally:**
ibtest run \
  --app saucedemoapp \        # Application name (must match folder under apps/)
  --config config.yaml \      # Environment-specific configuration file
  --workers-count 4 \         # Number of parallel test workers
  --split-level module \      # Split levels (test_file/module)
  --reruns 2 \                # Retry failed tests
  --reruns-delay 2            # Delay (in seconds) between retries
```

#### HTML Reports
Default Reports path: apps/appname/reports
---

## 🚨 Common Issues & Solutions

### **Authentication Errors**
- **Check Secret Names**: Ensure exact case-sensitive naming
- **Verify Copy-Paste**: Double-check credential values
- **Token Expiry**: Check if tokens/PATs have expired

### **Network Issues**
- **Firewall Rules**: Ensure services allow pipeline IPs
- **VPN Issues**: Check VPN connectivity if applicable
- **DNS Resolution**: Verify hostname resolution

### **Service-Specific Issues**
- **Jira Xray**: Check API quotas and project permissions
- **Slack/Teams**: Test webhook URLs independently

---

## 📞 Support Contacts

### **Framework Issues**
- **GitHub Issues**: Report bugs and feature requests
- **Email**: ib.dev.poc@InfoBeans.com
- **Slack**: #test-automation channel

### **External Services**
- **Jira Support**: Atlassian Support Portal
- **Slack Support**: Slack Help Center
- **Teams Support**: Microsoft Support

---

## 🔄 Maintenance Schedule

### **Credential Rotation**
- **Every 90 days**: Rotate all secrets and tokens
- **Set Reminders**: Calendar reminders for rotation dates
- **Stagger Updates**: Update services at different intervals

### **Service Monitoring**
- **Daily Health Checks**: Automated verification scripts
- **Weekly Reviews**: Check service usage and costs
- **Monthly Audits**: Review access logs and permissions

---

**Quick Setup Checklist:**
- [ ] Jira Xray account and API keys
- [ ] Slack webhook configuration
- [ ] Teams webhook setup
- [ ] Gmail app password generation
- [ ] GitHub Actions secrets configured
- [ ] Local tests passing
- [ ] Local development environment working

*This setup guide ensures a smooth onboarding experience and proper configuration of all framework dependencies.*
