# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Bypass solo para esta ejecución
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$ComputerName = $env:COMPUTERNAME
$SharePath   = "\\10.10.10.3\Local Intune\Hashes"

$CsvFile = Join-Path $SharePath "$ComputerName.csv"
$LogFile = Join-Path $SharePath "$ComputerName.log"

Start-Transcript -Path $LogFile -Force

try {
    # Asegurar servicio MDM
    sc.exe config dmwappushservice start= auto | Out-Null
    Start-Service dmwappushservice -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5

    $mdm = Get-CimInstance `
        -Namespace root\cimv2\mdm\dmmap `
        -ClassName MDM_DevDetail_Ext01 `
        -ErrorAction SilentlyContinue

    if (-not $mdm) {
        "MDM no inicializado. Requiere reinicio." | Out-File -Append $LogFile
        Stop-Transcript
        exit 3010
    }

    # Descargar script oficial Autopilot
    $AutopilotUrl = "https://raw.githubusercontent.com/microsoft/Intune-PowerShell-Scripts/master/WindowsAutopilot/Get-WindowsAutopilotInfo.ps1"
    $LocalScript  = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"

    Invoke-WebRequest -Uri $AutopilotUrl -OutFile $LocalScript -UseBasicParsing

    # Ejecutar en PowerShell 64 bits
    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -ExecutionPolicy Bypass `
        -File $LocalScript `
        -OutputFile $CsvFile

    if (-not (Test-Path $CsvFile)) {
        throw "El CSV no fue generado"
    }
}
catch {
    $_ | Out-File -Append $LogFile
}

Stop-Transcript
