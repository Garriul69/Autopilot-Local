# Obtener nombre de la PC
$PCName = $env:COMPUTERNAME

# Ruta del recurso compartido
$SharePath = "\\10.10.10.3\Local Intune\Hashes"

# Archivo destino con el nombre de la PC
$OutputFile = Join-Path $SharePath "$PCName.csv"

try {
    # Descargar el script oficial de Autopilot desde GitHub (raw URL)
    $AutopilotScript = "$env:TEMP\Get-WindowsAutopilotInfo.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Garriul69/Autopilot-Local/refs/heads/main/Get-WindowsAutopilotInfo.ps1" -OutFile $AutopilotScript

    # Ejecutar el script descargado (dot-sourcing)
    . $AutopilotScript

    # Generar el hardware hash y guardarlo en la carpeta compartida
    Get-WindowsAutopilotInfo -OutputFile $OutputFile

    Write-Host "Hash de $PCName guardado en $OutputFile"
}
catch {
    Write-Host "Error al generar o guardar el hash de $PCName"
}
