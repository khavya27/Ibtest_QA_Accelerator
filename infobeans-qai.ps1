# infobeans-qai one-click setup + activate
#
# USAGE (run with dot-source so activation persists in your shell):
#   . .\infobeans-qai.ps1
#
# If you only want to activate an already-set-up environment:
#   . .\infobeans-qai.ps1 -ActivateOnly

param(
    [switch]$ActivateOnly
)

$ProjectDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Step { param($n, $total, $msg) Write-Host "  [$n/$total] $msg" -ForegroundColor Cyan }
function Ok   { Write-Host "         done." -ForegroundColor Green }
function Fail { param($msg) Write-Host "  ERROR: $msg" -ForegroundColor Red }

function Ask {
    param($Prompt, $Default)
    $ans = Read-Host "  $Prompt [$Default]"
    if ($ans) { return $ans } else { return $Default }
}

function Get-Python {
    # Returns @(exe, arg) e.g. @('py', '-3.13') or @('python3', '') so that
    # the caller can invoke: & $py[0] $py[1] -m venv ...
    # This avoids the PowerShell & operator treating "py -3.13" as a single
    # executable name when stored as a plain string.
    if (Get-Command py -ErrorAction SilentlyContinue) {
        # Prefer 3.12 or 3.13 — numpy/pandas have pre-built wheels for these.
        # Python 3.14+ is too new; many packages lack binary wheels for it.
        foreach ($ver in @("3.12", "3.13")) {
            $out = & py "-$ver" --version 2>&1
            if ($LASTEXITCODE -eq 0) { return @("py", "-$ver") }
        }
        # Fall back to whatever py -3 gives (warn if 3.14+)
        $out = & py -3 --version 2>&1
        if ($out -match "Python 3\.(\d+)" -and [int]$Matches[1] -ge 14) {
            Write-Host "  WARNING: Python $($out.ToString().Trim()) detected." -ForegroundColor Yellow
            Write-Host "  Python 3.14+ is not yet supported by numpy/pandas." -ForegroundColor Yellow
            Write-Host "  Please install Python 3.12 from https://www.python.org/downloads/" -ForegroundColor Yellow
            return $null
        }
        return @("py", "-3")
    }
    if (Get-Command python3 -ErrorAction SilentlyContinue) { return @("python3", "") }
    if (Get-Command python  -ErrorAction SilentlyContinue) { return @("python",  "") }
    return $null
}

function Read-LocalMk {
    param($Key, $Default)
    $lmk = "$ProjectDir\local.mk"
    if (Test-Path $lmk) {
        $line = Select-String -Path $lmk -Pattern "^$Key\s*:?=" | Select-Object -First 1
        if ($line) {
            $parts = $line.Line -split ":?=", 2
            if ($parts.Count -eq 2) {
                $val = $parts[1].Trim()
                if ($val) { return $val }
            }
        }
    }
    return $Default
}

# ---------------------------------------------------------------------------
# Activate-only mode
# ---------------------------------------------------------------------------
if ($ActivateOnly) {
    $venvDir = Read-LocalMk "VENV_DIR" "venv"
    $activateScript = "$ProjectDir\$venvDir\Scripts\Activate.ps1"
    if (-not (Test-Path $activateScript)) {
        Fail "Activate script not found at: $activateScript"
        Fail "Run '. .\infobeans-qai.ps1' to set up first."
        return
    }
    Write-Host ""
    Write-Host "  Activating virtual environment ($venvDir)..." -ForegroundColor Cyan
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    . "$activateScript"
    Write-Host ""
    Write-Host "  Environment active! You're ready to go." -ForegroundColor Green
    Write-Host "  Try: infobeans-qai --help"
    Write-Host ""
    return
}

# ===========================================================================
# FULL SETUP FLOW
# ===========================================================================
Write-Host ""
Write-Host "  ============================================" -ForegroundColor DarkGray
Write-Host "    infobeans-qai Setup" -ForegroundColor White
Write-Host "  ============================================" -ForegroundColor DarkGray
Write-Host ""

$totalSteps = 9

# ---------------------------------------------------------------------------
# Step 1: Configure
# ---------------------------------------------------------------------------
$runConfigure = $true
if (Test-Path "$ProjectDir\local.mk") {
    Write-Host "  Existing configuration found (local.mk)." -ForegroundColor DarkGray
    $choice = Read-Host "  Use existing config? [Y/n]"
    if ($choice -eq "" -or $choice -match "^[Yy]") {
        $runConfigure = $false
        Step 1 $totalSteps "Using existing configuration from local.mk."
        Ok
    } else {
        Write-Host ""
    }
}

if ($runConfigure) {
    Step 1 $totalSteps "Configuring infobeans-qai..."
    Write-Host ""

    # Auto-detect wheel file in the same folder
    $whlFile = Get-Item "$ProjectDir\*.whl" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($whlFile) {
        $wheelDefault = $whlFile.Name
        # Warn if the filename contains spaces or parentheses — pip cannot install such files.
        if ($wheelDefault -match '[\s()]') {
            Write-Host ""
            Write-Host "  WARNING: The wheel file has an invalid filename:" -ForegroundColor Yellow
            Write-Host "    $wheelDefault" -ForegroundColor Yellow
            Write-Host "  pip cannot install wheel files with spaces or parentheses in the name." -ForegroundColor Yellow
            Write-Host "  Please rename it before continuing. Example:" -ForegroundColor Yellow
            $cleanName = $wheelDefault -replace '\s*\(\d+\)', '' -replace '\s+', '_'
            Write-Host "    Rename-Item '$wheelDefault' '$cleanName'" -ForegroundColor Cyan
            Write-Host ""
            Read-Host "  Press Enter once you have renamed the file, then re-run this script"
            return
        }
    } else {
        $wheelDefault = "infobeans_qai-0.1.0b3-py3-none-any.whl"
    }

    Write-Host "  === infobeans-qai configuration wizard ===" -ForegroundColor White
    Write-Host "  (Press Enter to keep the default shown in brackets)"
    Write-Host ""
    Write-Host "  -- Project settings --"
    $cfgVenvDir   = Ask "Virtual environment folder" "venv"
    $cfgWheelName = Ask "Wheel filename"             $wheelDefault
    if ($cfgWheelName -match '[\s()]') {
        Write-Host ""
        Write-Host "  ERROR: Wheel filename contains spaces or parentheses: '$cfgWheelName'" -ForegroundColor Red
        Write-Host "  pip cannot install wheel files with spaces or parentheses in the name." -ForegroundColor Red
        $cleanName = $cfgWheelName -replace '\s*\(\d+\)', '' -replace '\s+', '_'
        Write-Host "  Rename the file to: $cleanName" -ForegroundColor Cyan
        Write-Host "  Then re-run this script." -ForegroundColor Cyan
        Write-Host ""
        return
    }
    $cfgAppName   = Ask "App name"                   "appname"
    if ($cfgAppName -notmatch '^[a-zA-Z0-9_]+$') {
        Write-Host ""
        Write-Host "  ERROR: App name '$cfgAppName' is invalid." -ForegroundColor Red
        Write-Host "  Use only letters, numbers, and underscores (no spaces or hyphens)." -ForegroundColor Red
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "  -- Xray / Jira credentials (optional, press Enter to skip) --"
    $cfgXrayId    = Ask "XRAY_CLIENT_ID"     "<XRAY_CLIENT_ID>"
    $cfgXraySec   = Ask "XRAY_CLIENT_SECRET" "<XRAY_CLIENT_SECRET>"
    $cfgXrayUrl   = Ask "XRAY_API_BASE_URL"  "https://xray.cloud.getxray.app"
    $cfgXrayKey   = Ask "XRAY_PROJECT_KEY"   "<XRAY_PROJECT_KEY>"
    $cfgXrayPid   = Ask "XRAY_PROJECT_ID"    "<XRAY_PROJECT_ID>"
    $cfgJiraUrl   = Ask "JIRA_URL"           "<JIRA_URL>"
    $cfgJiraEmail = Ask "JIRA_API_EMAIL"     "<JIRA_API_EMAIL>"
    $cfgJiraToken = Ask "JIRA_API_TOKEN"     "<JIRA_API_TOKEN>"

    Write-Host ""
    Write-Host "  -- Git remote (optional) --"
    $cfgGitRemote = Ask "GIT_REMOTE" "https://github.com/<org>/<repo>.git"
    Write-Host ""

    $lmkLines = @(
        "# Generated by infobeans-qai.ps1",
        "VENV_DIR      := $cfgVenvDir",
        "WHEEL_NAME    := $cfgWheelName",
        "APP_NAME      := $cfgAppName",
        "GIT_REMOTE    := $cfgGitRemote",
        "XRAY_CLIENT_ID     := $cfgXrayId",
        "XRAY_CLIENT_SECRET := $cfgXraySec",
        "XRAY_API_BASE_URL  := $cfgXrayUrl",
        "XRAY_PROJECT_KEY   := $cfgXrayKey",
        "XRAY_PROJECT_ID    := $cfgXrayPid",
        "JIRA_URL           := $cfgJiraUrl",
        "JIRA_API_EMAIL     := $cfgJiraEmail",
        "JIRA_API_TOKEN     := $cfgJiraToken"
    )
    $lmkLines | Set-Content "$ProjectDir\local.mk" -Encoding UTF8
    Ok
}

# Read saved config
$venvDir   = Read-LocalMk "VENV_DIR"           "venv"
$wheelName = Read-LocalMk "WHEEL_NAME"         "infobeans_qai-0.1.0b3-py3-none-any.whl"
$appName   = Read-LocalMk "APP_NAME"           "appname"
$xrayId    = Read-LocalMk "XRAY_CLIENT_ID"     "<XRAY_CLIENT_ID>"
$xraySec   = Read-LocalMk "XRAY_CLIENT_SECRET" "<XRAY_CLIENT_SECRET>"
$xrayUrl   = Read-LocalMk "XRAY_API_BASE_URL"  "https://xray.cloud.getxray.app"
$xrayKey   = Read-LocalMk "XRAY_PROJECT_KEY"   "<XRAY_PROJECT_KEY>"
$xrayPid   = Read-LocalMk "XRAY_PROJECT_ID"    "<XRAY_PROJECT_ID>"
$jiraUrl   = Read-LocalMk "JIRA_URL"           "<JIRA_URL>"
$jiraEmail = Read-LocalMk "JIRA_API_EMAIL"     "<JIRA_API_EMAIL>"
$jiraToken = Read-LocalMk "JIRA_API_TOKEN"     "<JIRA_API_TOKEN>"

# ---------------------------------------------------------------------------
# Step 2: Check Python
# ---------------------------------------------------------------------------
Step 2 $totalSteps "Checking Python installation..."
$pythonCmd = Get-Python
if (-not $pythonCmd) {
    Fail "Python not found. Please install Python 3.12+ from https://python.org"
    return
}
Write-Host "         using: $($pythonCmd[0]) $($pythonCmd[1])" -ForegroundColor DarkGray
Ok

# ---------------------------------------------------------------------------
# Step 3: Create venv
# ---------------------------------------------------------------------------
Step 3 $totalSteps "Creating virtual environment ($venvDir)..."
$venvPath = "$ProjectDir\$venvDir"
if (Test-Path "$venvPath\Scripts\python.exe") {
    Write-Host "         already exists -- skipping." -ForegroundColor DarkGray
} else {
    $pyExe = $pythonCmd[0]
    $pyVer = $pythonCmd[1]
    if ($pyVer) {
        & $pyExe $pyVer -m venv "$venvPath"
    } else {
        & $pyExe -m venv "$venvPath"
    }
    if ($LASTEXITCODE -ne 0) { Fail "Python venv creation failed."; return }
}
Ok

# ---------------------------------------------------------------------------
# Step 4: Activate
# ---------------------------------------------------------------------------
Step 4 $totalSteps "Activating virtual environment..."
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
. "$venvPath\Scripts\Activate.ps1"
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Fail "Activation failed -- pip not found after activating venv."
    return
}
Ok

# ---------------------------------------------------------------------------
# Step 5: Install build tools
# ---------------------------------------------------------------------------
Step 5 $totalSteps "Installing build tools (setuptools, wheel)..."
pip install -q "setuptools>=80.9.0,<81" wheel | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "Failed to install setuptools/wheel."; return }
Ok

# ---------------------------------------------------------------------------
# Step 6: Install wheel + all dependencies
# ---------------------------------------------------------------------------
Step 6 $totalSteps "Installing infobeans-qai wheel and dependencies (this may take a minute)..."
$wheelPath = "$ProjectDir\$wheelName"
if (-not (Test-Path $wheelPath)) {
    Fail "Wheel file not found: $wheelPath"
    Fail "Make sure '$wheelName' is in the same folder as infobeans-qai.ps1"
    return
}

pip install -q "numpy>=2.3.3" "--only-binary=:all:"
if ($LASTEXITCODE -ne 0) { Fail "Failed to install numpy. Try upgrading Python to 3.12 or 3.13 (64-bit)."; return }
pip install -q "pytest-dependency==0.6.1" --no-build-isolation
if ($LASTEXITCODE -ne 0) { Fail "Failed to install pytest-dependency."; return }
pip install -q "$wheelPath" "--prefer-binary"
if ($LASTEXITCODE -ne 0) { Fail "Failed to install wheel '$wheelName'."; return }
pip install -q pytest-playwright
if ($LASTEXITCODE -ne 0) { Fail "Failed to install pytest-playwright."; return }
Ok

# ---------------------------------------------------------------------------
# Step 7: Install Playwright browsers
# ---------------------------------------------------------------------------
Step 7 $totalSteps "Installing Playwright browsers (chromium)..."
playwright install chromium
if ($LASTEXITCODE -ne 0) { Fail "Playwright browser install failed."; return }
Ok

# ---------------------------------------------------------------------------
# Step 8: Scaffold app + pipeline + .env
# ---------------------------------------------------------------------------
Step 8 $totalSteps "Scaffolding app '$appName', pipeline files, and .env..."
$venvPython = "$venvPath\Scripts\python.exe"
if (-not (Test-Path $venvPython)) {
    Fail "Python not found in venv at: $venvPython"
    Fail "The wheel may not have installed correctly. Re-run the script."
    return
}
& $venvPython -m infobeans_qai setup --app "$appName" --scaffold true --overwrite
if ($LASTEXITCODE -ne 0) { Fail "'infobeans-qai setup' failed."; return }
& $venvPython -m infobeans_qai setup-pipeline
if ($LASTEXITCODE -ne 0) { Fail "'infobeans-qai setup-pipeline' failed."; return }

$envLines = @(
    "# infobeans-qai environment configuration",
    "# Replace <placeholder> values with your real credentials.",
    "",
    "PYTEST_XDIST_WORKER_COUNT=auto",
    "XRAY_CLIENT_ID=`"$xrayId`"",
    "XRAY_CLIENT_SECRET=`"$xraySec`"",
    "XRAY_API_BASE_URL=$xrayUrl",
    "XRAY_PROJECT_KEY=`"$xrayKey`"",
    "XRAY_PROJECT_ID=`"$xrayPid`"",
    "JIRA_URL=`"$jiraUrl`"",
    "JIRA_API_EMAIL=`"$jiraEmail`"",
    "JIRA_API_TOKEN=`"$jiraToken`""
)
$envLines | Set-Content "$ProjectDir\.env" -Encoding UTF8
Ok

# ---------------------------------------------------------------------------
# Step 9: Write activate.ps1 shortcut
# ---------------------------------------------------------------------------
Step 9 $totalSteps "Writing activate.ps1 shortcut..."
$activateLines = @(
    "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass",
    ". `"$venvPath\Scripts\Activate.ps1`""
)
$activateLines | Set-Content "$ProjectDir\activate.ps1" -Encoding UTF8
Ok

Write-Host ""
Write-Host "  ============================================" -ForegroundColor DarkGray
Write-Host "    Setup complete! Environment is active." -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  IMPORTANT: Always activate the environment before running any commands." -ForegroundColor Yellow
Write-Host "  Open a new terminal in this folder and run:" -ForegroundColor Yellow
Write-Host "    . .\activate.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Then you can run:"
Write-Host "    infobeans-qai run --app $appName   -- run your tests" -NoNewline; Write-Host ""
Write-Host '    infobeans-qai --help               -- see all commands'
Write-Host ""
Write-Host "  To register with Claude Desktop (activate first, then):"
Write-Host '    infobeans-qai setup-claude'
Write-Host ""
Write-Host "  Next time you open a terminal, activate with:"
Write-Host "    . .\activate.ps1"
Write-Host "  or:"
Write-Host "    . .\infobeans-qai.ps1 -ActivateOnly"
Write-Host ""

# If run directly (not dot-sourced), pause so the window stays open.
if ($MyInvocation.InvocationName -ne ".") {
    Write-Host ""
    Write-Host "  NOTE: Run this script with dot-source to keep the venv active:" -ForegroundColor Yellow
    Write-Host "    . .\infobeans-qai.ps1" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Press Enter to close"
}
