# Forzar TLS 1.2 (requerido para Install-Script)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Permitir ejecución solo para esta sesión
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# Asegurar que el path de scripts esté disponible
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

# Instalar el script de Microsoft (solo la primera vez)
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Obtener nombre del equipo
$ComputerName = $env:COMPUTERNAME

# Ruta del recurso compartido
$NetworkPath = "\\10.10.10.3\Local Intune\Hashes"

# Nombre final del archivo
$OutputFile = Join-Path $NetworkPath "$ComputerName.csv"

# Ejecutar el script y generar el CSV
Get-WindowsAutopilotInfo -OutputFile $OutputFile
