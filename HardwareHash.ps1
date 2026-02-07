[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

Install-Script -Name Get-WindowsAutopilotInfo -Force

$ComputerName = $env:COMPUTERNAME
$NetworkPath = "\\10.10.10.3\Local Intune\Hashes"
$OutputFile = Join-Path $NetworkPath "$ComputerName.csv"

Get-WindowsAutopilotInfo -OutputFile $OutputFile
