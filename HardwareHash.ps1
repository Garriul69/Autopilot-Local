# Obtener nombre de la PC
$PCName = $env:COMPUTERNAME

# Ruta del recurso compartido
$SharePath = "\\10.10.10.3\Local Intune\Hashes"

# Archivo destino con el nombre de la PC
$OutputFile = Join-Path $SharePath "$PCName.csv"

try {
    # Importar el script de Autopilot (ya debe estar disponible en el sistema)
    Import-Module "C:\Ruta\Get-WindowsAutopilotInfo.ps1" -Force

    # Generar el hardware hash y guardarlo en la carpeta compartida
    Get-WindowsAutopilotInfo -OutputFile $OutputFile

    Write-Host "Hash de $PCName guardado en $OutputFile"
}
catch {
    Write-Host "Error al generar o guardar el hash de $PCName"
}
