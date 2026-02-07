# ===============================
# Hardware Hash - Autopilot
# ===============================

# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Variables
$ComputerName = $env:COMPUTERNAME
$SharePath   = "\\10.10.10.3\Local Intune\Hashes"

$CsvFile = Join-Path $SharePath "$ComputerName.csv"
$LogFile = Join-Path $SharePath "$ComputerName.log"

# Iniciar log
Start-Transcript -Path $LogFile -Force

try {
    # URL CORRECTA del script Autopilot (TU GitHub)
    $AutopilotUrl = "https://raw.githubusercontent.com/Garriul69/Autopilot-Local/refs/heads/main/Get-WindowsAutopilotInfo.ps1"

    # Descargar script
    $AutopilotScript = Invoke-WebRequest -Uri $AutopilotUrl -UseBasicParsing -ErrorAction Stop

    # Cargar funciones en memoria
    Invoke-Expression $AutopilotScript.Content

    # Ejecutar obtención del Hardware Hash
    Get-WindowsAutopilotInfo -OutputFile $CsvFile -ErrorAction Stop
}
catch {
    Write-Error $_
}
finally {
    Stop-Transcript
}
