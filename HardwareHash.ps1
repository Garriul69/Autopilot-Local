# ===============================
# Hardware Hash - Autopilot
# ===============================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ComputerName = $env:COMPUTERNAME
$SharePath   = "\\10.10.10.3\Local Intune\Hashes"

$CsvFile = Join-Path $SharePath "$ComputerName.csv"
$LogFile = Join-Path $SharePath "$ComputerName.log"

$TempScript = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"
$AutopilotUrl = "https://raw.githubusercontent.com/Garriul69/Autopilot-Local/refs/heads/main/Get-WindowsAutopilotInfo.ps1"

Start-Transcript -Path $LogFile -Force

try {
    # Descargar script Autopilot a disco
    Invoke-WebRequest -Uri $AutopilotUrl -OutFile $TempScript -UseBasicParsing -ErrorAction Stop

    # Ejecutar script correctamente
    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -ExecutionPolicy Bypass `
        -File $TempScript `
        -OutputFile $CsvFile `
        -ErrorAction Stop
}
catch {
    Write-Error $_
}
finally {
    Stop-Transcript
}
