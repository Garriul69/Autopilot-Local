[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$ComputerName = $env:COMPUTERNAME
$SharePath   = "\\10.10.10.3\Local Intune\Hashes"

$CsvFile = Join-Path $SharePath "$ComputerName.csv"
$LogFile = Join-Path $SharePath "$ComputerName.log"

Start-Transcript -Path $LogFile -Force

try {
    sc.exe config dmwappushservice start= auto | Out-Null
    Start-Service dmwappushservice -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5

    $mdm = Get-CimInstance `
        -Namespace root\cimv2\mdm\dmmap `
        -ClassName MDM_DevDetail_Ext01 `
        -ErrorAction SilentlyContinue

    if (-not $mdm) {
        exit 3010
    }

    # URL OFICIAL CORRECTA
    $AutopilotUrl = "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/WindowsAutopilot/Get-WindowsAutopilotInfo.ps1"
    $LocalScript  = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"

    Invoke-WebRequest -Uri $AutopilotUrl -OutFile $LocalScript -UseBasicParsing

    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -ExecutionPolicy Bypass `
        -File $LocalScript `
        -OutputFile $CsvFile
}
finally {
    Stop-Transcript
}
