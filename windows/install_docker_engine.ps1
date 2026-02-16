#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs Docker Engine on Windows (server/headless mode).

.DESCRIPTION
    This script installs Docker Engine as a Windows Service without Docker Desktop.
    Suitable for servers and headless environments. No GUI, no prompts, no licensing fees.
    Downloads Docker directly from docker.com (not the broken DockerMsftProvider).

.PARAMETER SkipReboot
    Don't auto-reboot after enabling Windows features.

.PARAMETER DockerVersion
    Docker Engine version to install. Default: 27.4.1

.PARAMETER ComposeVersion
    Docker Compose version to install. Default: v2.32.4

.EXAMPLE
    .\install_docker_engine.ps1
    Installs Docker Engine silently.

.EXAMPLE
    .\install_docker_engine.ps1 -SkipReboot
    Installs without automatic reboot.

.NOTES
    Requires Administrator privileges.
    Requires Windows 10/11 or Windows Server 2016+.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipReboot,

    [Parameter()]
    [string]$DockerVersion = "27.4.1",

    [Parameter()]
    [string]$ComposeVersion = "v2.32.4"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Import shared module
Import-Module "$PSScriptRoot\GHRunner.psm1" -Force

# ============================================================================
# Configuration
# ============================================================================

$script:Config = @{
    DockerDataPath = "$env:ProgramData\Docker"
    ComposeBaseUrl = "https://github.com/docker/compose/releases/download"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Test-DockerInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $dockerdExe = Get-DockerDaemonPath
    return Test-Path $dockerdExe
}

function Test-RequiredFeatures {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $requiredFeatures = @("Containers", "Microsoft-Hyper-V-All")

    foreach ($featureName in $requiredFeatures) {
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction Stop
            if ($feature.State -ne "Enabled") {
                return $false
            }
        }
        catch {
            return $false
        }
    }
    return $true
}

function Remove-BrokenDockerProvider {
    [CmdletBinding()]
    param()

    # Remove broken DockerMsftProvider if present
    $provider = Get-Module -ListAvailable -Name DockerMsftProvider -ErrorAction SilentlyContinue
    if ($provider) {
        Write-Log "Removing broken DockerMsftProvider module..." -Level Info
        try {
            Uninstall-Module -Name DockerMsftProvider -Force -AllVersions -ErrorAction SilentlyContinue
            Write-Log "DockerMsftProvider removed" -Level Success
        }
        catch {
            Write-Log "Could not remove DockerMsftProvider: $_" -Level Warning
        }
    }

    # Remove any leftover docker package from the broken provider
    $dockerPkg = Get-Package -Name docker -ProviderName DockerMsftProvider -ErrorAction SilentlyContinue
    if ($dockerPkg) {
        Write-Log "Removing broken Docker package from DockerMsftProvider..." -Level Info
        try {
            Uninstall-Package -Name docker -ProviderName DockerMsftProvider -Force -ErrorAction SilentlyContinue
            Write-Log "Broken Docker package removed" -Level Success
        }
        catch {
            Write-Log "Could not remove broken Docker package: $_" -Level Warning
        }
    }
}

function Enable-RequiredFeatures {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $requiredFeatures = @("Containers", "Microsoft-Hyper-V-All")
    $rebootRequired = $false

    foreach ($featureName in $requiredFeatures) {
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction Stop

            if ($feature.State -eq "Enabled") {
                Write-Log "$featureName already enabled" -Level Success
                continue
            }

            Write-Log "Enabling $featureName..." -Level Info
            $result = Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart -ErrorAction Stop

            if ($result.RestartNeeded) {
                Write-Log "$featureName enabled - reboot required" -Level Warning
                $rebootRequired = $true
            }
            else {
                Write-Log "$featureName enabled" -Level Success
            }
        }
        catch {
            Write-Log "Failed to enable $featureName`: $_" -Level Error
            throw
        }
    }

    return $rebootRequired
}

function Install-DockerEngine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    Write-Log "Downloading Docker Engine $Version..." -Level Info

    $dockerZipUrl = "https://download.docker.com/win/static/stable/x86_64/docker-$Version.zip"
    $zipPath = Join-Path $env:TEMP "docker-$Version.zip"
    $extractPath = $env:TEMP
    $dockerDest = Split-Path (Get-DockerPath) -Parent

    try {
        # Download Docker zip
        $progressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $dockerZipUrl -OutFile $zipPath -UseBasicParsing
        Write-Log "Download complete" -Level Success

        # Extract
        Write-Log "Extracting Docker..." -Level Info
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        # Move to Program Files
        $dockerExtracted = Join-Path $extractPath "docker"

        if (Test-Path $dockerDest) {
            # Stop service if running before replacing files
            Stop-Service docker -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Remove-Item $dockerDest -Recurse -Force
        }

        Move-Item $dockerExtracted $dockerDest -Force
        Write-Log "Docker installed to $dockerDest" -Level Success

        # Cleanup
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

        # Add to PATH permanently
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$dockerDest*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$dockerDest", "Machine")
            $env:Path = "$env:Path;$dockerDest"

            # Broadcast WM_SETTINGCHANGE so new processes pick up the PATH immediately
            if (-not ("Win32.NativeMethods" -as [Type])) {
                Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    public static extern IntPtr SendMessageTimeout(
                        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
                        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
            }
            $HWND_BROADCAST = [IntPtr]0xffff
            $WM_SETTINGCHANGE = 0x1a
            $result = [UIntPtr]::Zero
            [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref]$result) | Out-Null

            Write-Log "Added Docker to system PATH (permanent)" -Level Success
        }
    }
    catch {
        Write-Log "Failed to install Docker Engine: $_" -Level Error
        throw
    }
}

function Register-DockerService {
    [CmdletBinding()]
    param()

    Write-Log "Registering Docker service..." -Level Info

    try {
        $dockerd = Get-DockerDaemonPath

        # Register the service
        & $dockerd --register-service

        if ($LASTEXITCODE -ne 0) {
            throw "dockerd --register-service failed with exit code $LASTEXITCODE"
        }

        Write-Log "Docker service registered" -Level Success
    }
    catch {
        Write-Log "Failed to register Docker service: $_" -Level Error
        throw
    }
}

function Install-DockerCompose {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    Write-Log "Installing Docker Compose $Version..." -Level Info

    $composeUrl = "$($script:Config.ComposeBaseUrl)/$Version/docker-compose-windows-x86_64.exe"
    $dockerPath = Split-Path (Get-DockerPath) -Parent

    # Docker CLI discovers plugins in <docker-exe-dir>\cli-plugins\ on Windows
    $pluginPath = Join-Path $dockerPath "cli-plugins"

    try {
        # Ensure cli-plugins directory exists
        if (-not (Test-Path $pluginPath)) {
            New-Item -ItemType Directory -Path $pluginPath -Force | Out-Null
        }

        # Download compose binary directly to the cli-plugins directory
        $composePath = Join-Path $pluginPath "docker-compose.exe"
        $progressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $composeUrl -OutFile $composePath -UseBasicParsing

        Write-Log "Docker Compose installed" -Level Success
    }
    catch {
        Write-Log "Failed to install Docker Compose: $_" -Level Warning
        Write-Log "You can install it manually later" -Level Info
    }
}

function Start-DockerService {
    [CmdletBinding()]
    param()

    Write-Log "Starting Docker service..." -Level Info

    try {
        Set-Service -Name docker -StartupType Automatic
        Start-Service docker -ErrorAction Stop

        # Wait for Docker to be ready
        $maxAttempts = 30
        $attempt = 0
        while ($attempt -lt $maxAttempts) {
            if (Test-DockerRunning) {
                Write-Log "Docker service is running" -Level Success
                return
            }
            $attempt++
            Start-Sleep -Seconds 2
        }

        Write-Log "Docker service started but may not be fully ready" -Level Warning
    }
    catch {
        Write-Log "Failed to start Docker service: $_" -Level Error
        throw
    }
}

# ============================================================================
# Main
# ============================================================================

function Install-Docker {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter()]
        [switch]$SkipReboot,

        [Parameter()]
        [string]$DockerVersion,

        [Parameter()]
        [string]$ComposeVersion
    )

    $exitCodes = Get-AllExitCodes

    Write-Log "Docker Engine Installation (Server Mode)" -Level Info
    Write-Log "========================================" -Level Info

    # Check Administrator
    Write-Log "Checking Administrator privileges..." -Level Info
    if (-not (Test-Administrator)) {
        Write-Log "This script requires Administrator privileges" -Level Error
        return $exitCodes.NoPermission
    }
    Write-Log "Running with Administrator privileges" -Level Success

    # Remove broken DockerMsftProvider if present
    Remove-BrokenDockerProvider

    # Check if already installed and running
    if (Test-DockerInstalled) {
        Write-Log "Docker is already installed" -Level Success
        $dockerExe = Get-DockerPath
        & $dockerExe --version
        if (Test-DockerRunning) {
            Write-Log "Docker service is running" -Level Success
        }
        else {
            Write-Log "Docker service is not running, attempting to start..." -Level Warning
            Start-DockerService
        }
        return $exitCodes.Success
    }

    # Enable required Windows features (Containers + Hyper-V)
    Write-Log "Checking required Windows features..." -Level Info
    if (-not (Test-RequiredFeatures)) {
        $rebootRequired = Enable-RequiredFeatures

        if ($rebootRequired) {
            if ($SkipReboot) {
                Write-Log "Reboot required. Run this script again after restart." -Level Warning
                return $exitCodes.Success
            }
            else {
                Write-Log "Rebooting in 10 seconds... (Ctrl+C to cancel)" -Level Warning
                Start-Sleep -Seconds 10
                Restart-Computer -Force
            }
        }
    }
    else {
        Write-Log "Required features are enabled (Containers, Hyper-V)" -Level Success
    }

    # Install Docker Engine
    Install-DockerEngine -Version $DockerVersion

    # Register Docker service
    Register-DockerService

    # Install Docker Compose
    Install-DockerCompose -Version $ComposeVersion

    # Start Docker service
    Start-DockerService

    # Verify
    Write-Host ""
    Write-Log "========================================" -Level Info
    Write-Log "Installation Complete!" -Level Success
    Write-Log "========================================" -Level Info

    if (Test-DockerRunning) {
        $dockerExe = Get-DockerPath
        & $dockerExe --version
        & $dockerExe compose version 2>$null

        Write-Host ""
        Write-Log "Test with: docker run hello-world" -Level Info
    }
    else {
        Write-Log "Docker installed but service not running. Reboot may be required." -Level Warning
    }

    return $exitCodes.Success
}

# ============================================================================
# Entry Point
# ============================================================================

$exitCode = Install-Docker -SkipReboot:$SkipReboot -DockerVersion $DockerVersion -ComposeVersion $ComposeVersion
exit $exitCode
