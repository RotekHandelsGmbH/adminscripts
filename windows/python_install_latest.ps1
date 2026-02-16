#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Install latest Python using official installer.

.DESCRIPTION
    Downloads official Python installer from python.org.
    Installs to C:\opt\Python<version>-<arch> by default.
    Creates symlink at C:\opt\python_latest_64 (or _32).

.PARAMETER InstallRoot
    Root directory for installation (default: C:\opt).

.PARAMETER SymlinkRoot
    Root for symlink (default: C:\opt).

.PARAMETER Arch
    Architecture: 64 or 32 (default: 64).

.EXAMPLE
    .\python_install_latest.ps1
    Installs to C:\opt\python-3.14.3-64, symlink at C:\opt\python_latest_64

.EXAMPLE
    .\python_install_latest.ps1 -Arch 32
    Installs to C:\opt\python-3.14.3-32, symlink at C:\opt\python_latest_32
#>

[CmdletBinding()]
param(
    [string]$InstallRoot = 'C:\opt',
    [string]$SymlinkRoot = 'C:\opt',
    [ValidateSet('64', '32')]
    [string]$Arch = '64'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Get-LatestPythonVersion {
    Write-Host "[INFO] Querying python.org..." -ForegroundColor Cyan
    $html = (Invoke-WebRequest -Uri 'https://www.python.org/downloads/windows/' -UseBasicParsing).Content

    $pattern = if ($Arch -eq '64') { 'python-(\d+\.\d+\.\d+)-amd64\.exe' } else { 'python-(\d+\.\d+\.\d+)\.exe' }
    $matches = [regex]::Matches($html, $pattern)

    $versions = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object { [version]$_ } -Descending -Unique

    foreach ($v in $versions) {
        if ($v -notmatch '(a|b|rc)') {
            Write-Host "[OK] Latest: $v" -ForegroundColor Green
            return $v
        }
    }
    throw "No stable version found"
}

function Install-Python {
    param(
        [string]$Version,
        [string]$TargetPath
    )

    # 32-bit installer is named differently
    $exeName = if ($Arch -eq '64') { "python-$Version-amd64.exe" } else { "python-$Version.exe" }
    $url = "https://www.python.org/ftp/python/$Version/$exeName"
    $installer = "$env:TEMP\$exeName"

    # Download
    Write-Host "[INFO] Downloading $exeName..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing
    Write-Host "[OK] Downloaded" -ForegroundColor Green

    # Ensure target directory parent exists
    $targetParent = Split-Path $TargetPath -Parent
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    # Remove existing installation at target if present
    if (Test-Path $TargetPath) {
        Write-Host "[WARN] Removing existing installation at $TargetPath..." -ForegroundColor Yellow
        Remove-Item -Path $TargetPath -Recurse -Force
    }

    # Build installer arguments
    # See: https://docs.python.org/3/using/windows.html#installing-without-ui
    $installerArgs = @(
        '/quiet'                        # Silent install
        "TargetDir=`"$TargetPath`""     # Custom install location
        'InstallAllUsers=1'             # Install for all users (requires admin)
        'PrependPath=0'                 # Don't modify PATH
        'AssociateFiles=0'              # Don't associate .py files
        'Shortcuts=0'                   # Don't create shortcuts
        'Include_doc=0'                 # Skip documentation
        'Include_launcher=0'            # Skip py.exe launcher
        'Include_pip=1'                 # Include pip
        'Include_tcltk=1'               # Include tkinter
        'Include_test=0'                # Skip test suite
        'Include_tools=1'               # Include Tools/ scripts
    )
    $argString = $installerArgs -join ' '

    Write-Host "[INFO] Installing to $TargetPath..." -ForegroundColor Cyan
    Write-Host "[INFO] Args: $argString" -ForegroundColor DarkGray

    $proc = Start-Process -FilePath $installer -ArgumentList $argString -Wait -PassThru

    if ($proc.ExitCode -ne 0) {
        throw "Installer failed with exit code $($proc.ExitCode)"
    }
    Write-Host "[OK] Installed" -ForegroundColor Green

    # Cleanup installer
    Remove-Item $installer -Force -ErrorAction SilentlyContinue

    # Verify installation
    if (-not (Test-Path "$TargetPath\python.exe")) {
        throw "Installation failed - python.exe not found at $TargetPath"
    }

    return $TargetPath
}

function New-Symlink {
    param([string]$Target, [string]$Link)

    if (-not (Test-Path (Split-Path $Link -Parent))) {
        New-Item -ItemType Directory -Path (Split-Path $Link -Parent) -Force | Out-Null
    }

    if (Test-Path $Link) {
        Remove-Item $Link -Force
    }

    Write-Host "[INFO] Creating symlink: $Link -> $Target" -ForegroundColor Cyan
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    Write-Host "[OK] Symlink created" -ForegroundColor Green
}

# Main

# Double-check admin rights (in addition to #Requires)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "        Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Python Installer ($Arch-bit) ===" -ForegroundColor Cyan
Write-Host ""

$version = Get-LatestPythonVersion

# Build target path: C:\opt\python-3.14.3-64 or C:\opt\python-3.14.3-32
$targetPath = Join-Path $InstallRoot "python-$version-$Arch"

$installPath = Install-Python -Version $version -TargetPath $targetPath

$symlinkPath = Join-Path $SymlinkRoot "python_latest_$Arch"
New-Symlink -Target $installPath -Link $symlinkPath

# Verify
Write-Host ""
Write-Host "[INFO] Verifying..." -ForegroundColor Cyan
& "$symlinkPath\python.exe" --version
& "$symlinkPath\python.exe" -m pip --version

$checks = @('Scripts\pip.exe', 'Lib\venv\__init__.py', 'Lib\tkinter\__init__.py')
foreach ($c in $checks) {
    $p = Join-Path $installPath $c
    $name = Split-Path $c -Leaf
    if (Test-Path $p) {
        Write-Host "[OK] $name" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $name" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Installed: $installPath" -ForegroundColor Green
Write-Host "Symlink:   $symlinkPath" -ForegroundColor Green
