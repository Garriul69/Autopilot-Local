# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Saltarse políticas solo en esta ejecución
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Nombre del equipo
$ComputerName = $env:COMPUTERNAME

# Ruta de red destino
$NetworkPath = "\\10.10.10.3\Local Intune\Hashes"
$OutputFile = Join-Path $NetworkPath "$ComputerName.csv"

# URL oficial del script de Microsoft (SIN PSGallery)
$AutopilotScriptUrl = "https://raw.githubusercontent.com/microsoft/Intune-PowerShell-Scripts/master/WindowsAutopilot/Get-WindowsAutopilotInfo.ps1"

# Descargar script
$LocalScript = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"
Invoke-WebRequest -Uri $AutopilotScriptUrl -OutFile $LocalScript -UseBasicParsing

# Ejecutar script descargado
& powershell.exe -ExecutionPolicy Bypass -File $LocalScript -OutputFile $OutputFile
