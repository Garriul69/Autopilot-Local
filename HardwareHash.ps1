[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Forzar NuGet
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
}

# Confiar PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Asegurar PowerShellGet
if (-not (Get-Module -ListAvailable PowerShellGet)) {
    Install-Module PowerShellGet -Force -Confirm:$false
}

$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

# Instalar script Autopilot
Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false

$ComputerName = $env:COMPUTERNAME
$NetworkPath = "\\10.10.10.3\Local Intune\Hashes"
$OutputFile = Join-Path $NetworkPath "$ComputerName.csv"

Get-WindowsAutopilotInfo -OutputFile $OutputFile
