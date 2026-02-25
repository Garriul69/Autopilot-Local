# ==============================================================================
# Script: Actualizar microsip.ps1 (Versión WEB)
# Objetivo: Descargar e instalar Microsip 2025 desde servidor oficial
# ==============================================================================

# 1. Configuración de URLs y Rutas
$url        = "https://microsip.b-cdn.net/DescargasSoporte/Microsip/Instalar2025.exe"
$tempDir    = "C:\Temp"
$localExe   = Join-Path $tempDir "Instalar2025.exe"

# 2. Argumentos de instalación silenciosa
$installArgs = @(
    '/SP-',
    '/VERYSILENT',
    '/NORESTART',
    'TASKS="desktopicon"'
)

try {
    # 3. Preparación de carpeta local
    if (!(Test-Path $tempDir)) {
        Write-Host "Creando directorio temporal..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }

    # 4. Descarga del instalador
    Write-Host "Descargando Microsip 2025 desde el sitio oficial..." -ForegroundColor Cyan
    # Forzamos el uso de TLS 1.2 para asegurar la descarga en sistemas antiguos
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $localExe -ErrorAction Stop

    # 5. Ejecución de la instalación
    Write-Host "Iniciando instalación silenciosa..." -ForegroundColor Yellow
    $process = Start-Process -FilePath $localExe -ArgumentList $installArgs -Wait -PassThru

    # Verificación de éxito
    if ($process.ExitCode -eq 0) {
        Write-Host "Instalación completada exitosamente." -ForegroundColor Green
    } else {
        Write-Warning "El instalador terminó con el código de salida: $($process.ExitCode)"
    }

} catch {
    Write-Error "Error durante el proceso: $($_.Exception.Message)"
} finally {
    # 6. Limpieza profunda
    if (Test-Path $tempDir) {
        Write-Host "Eliminando archivos temporales..." -ForegroundColor Gray
        Remove-Item -Path $tempDir -Recurse -Force
    }
}