[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ComputerName = $env:COMPUTERNAME
$NetworkPath = "\\10.10.10.3\Local Intune\Hashes"
$OutputFile = Join-Path $NetworkPath "$ComputerName.csv"

$ScriptUrl = "https://raw.githubusercontent.com/microsoft/Intune-PowerShell-Scripts/master/WindowsAutopilot/Get-WindowsAutopilotInfo.ps1"
$LocalScript = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"

Invoke-WebRequest -Uri $ScriptUrl -OutFile $LocalScript -UseBasicParsing

& powershell.exe -ExecutionPolicy Bypass -File $LocalScript -OutputFile $OutputFile
