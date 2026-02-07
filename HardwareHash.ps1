# ==========================================
# Hardware Hash - Windows Autopilot (LOCAL)
# Basado en Get-WindowsAutopilotInfo.ps1
# ==========================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -------- CONFIGURACIÓN --------
$ComputerName = $env:COMPUTERNAME
$SharePath   = "\\10.10.10.3\Local Intune\Hashes"

$CsvFile = Join-Path $SharePath "$ComputerName.csv"
$LogFile = Join-Path $SharePath "$ComputerName.log"

# -------- LOG --------
Start-Transcript -Path $LogFile -Force

try {

    Write-Output "Iniciando obtención de Hardware Hash para $ComputerName"

    # Crear sesión CIM local
    $session = New-CimSession

    # Serial
    $serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber

    # Intentar obtener Hardware Hash desde MDM
    $devDetail = Get-CimInstance `
        -CimSession $session `
        -Namespace root/cimv2/mdm/dmmap `
        -Class MDM_DevDetail_Ext01 `
        -Filter "InstanceID='Ext' AND ParentID='./DevDetail'" `
        -ErrorAction SilentlyContinue

    if ($devDetail -and $devDetail.DeviceHardwareData) {
        $hash = $devDetail.DeviceHardwareData
        Write-Output "Hardware Hash obtenido correctamente"
    }
    else {
        throw "No se pudo obtener el Hardware Hash. El equipo puede requerir reinicio o no estar listo para Autopilot."
    }

    # Producto (normalmente vacío)
    $product = ""

    # Crear objeto final
    $result = New-Object psobject -Property @{
        "Device Serial Number" = $serial
        "Windows Product ID"   = $product
        "Hardware Hash"        = $hash
    }

    # Guardar CSV (formato Autopilot)
    $result |
        Select "Device Serial Number","Windows Product ID","Hardware Hash" |
        ConvertTo-Csv -NoTypeInformation |
        ForEach-Object { $_ -replace '"','' } |
        Out-File -FilePath $CsvFile -Encoding ASCII

    Write-Output "Archivo CSV generado en $CsvFile"

    Remove-CimSession $session
}
catch {
    Write-Error $_
}
finally {
    Stop-Transcript
}
