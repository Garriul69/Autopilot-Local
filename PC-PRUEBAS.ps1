# ===============================
# VARIABLES BASE
# ===============================

$BasePath = "\\10.10.10.3\General\Local Intune\Apps"
$TempPath = "C:\TempESET"
$ErrorActionPreference = "Stop"

Write-Host "Iniciando instalación automática..." -ForegroundColor Cyan

# Crear carpeta temporal
if (Test-Path $TempPath) { Remove-Item $TempPath -Recurse -Force }
New-Item -ItemType Directory -Path $TempPath | Out-Null

# ===============================
# 1. INSTALACIONES DE APLICACIONES
# ===============================

Write-Host "Copiando e instalando Spark..." -ForegroundColor Yellow
Copy-Item "$BasePath\Spark\spark_2_7_7.exe" $TempPath -Force
Start-Process "$TempPath\spark_2_7_7.exe" -ArgumentList "-q" -Wait

Write-Host "Copiando e instalando Visual C++ Redistributable x86..." -ForegroundColor Yellow
Copy-Item "$BasePath\VC_redist\VC_redist.x86.exe" $TempPath -Force
Start-Process "$TempPath\VC_redist.x86.exe" -ArgumentList "/install /quiet /norestart" -Wait

Write-Host "Copiando e instalando MySQL Connector ODBC 8.0 (32 bits)..." -ForegroundColor Yellow
Copy-Item "$BasePath\MySQL Connector ODBC\MySQL Connector ODBC 8.0.22 (32 bits).msi" $TempPath -Force
Start-Process "msiexec.exe" -ArgumentList "/i `"$TempPath\MySQL Connector ODBC 8.0.22 (32 bits).msi`" /qn /norestart" -Wait

Write-Host "Copiando e instalando Google Chrome..." -ForegroundColor Yellow
Copy-Item "$BasePath\Google Chrome\googlechromestandaloneenterprise64.msi" $TempPath -Force
Start-Process "msiexec.exe" -ArgumentList "/i `"$TempPath\googlechromestandaloneenterprise64.msi`" /qn /norestart" -Wait

Write-Host "Copiando e instalando Synology Drive Client..." -ForegroundColor Yellow
Copy-Item "$BasePath\Synology Drive Client\Synology Drive Client-3.5.1-16102-x64.msi" $TempPath -Force
Start-Process "msiexec.exe" -ArgumentList "/i `"$TempPath\Synology Drive Client-3.5.1-16102-x64.msi`" /qn /norestart" -Wait

Write-Host "Copiando e Instalando TeamViewer..." -ForegroundColor Yellow
Copy-Item "$BasePath\TeamViewer\TeamViewer_Setup_x64.exe" $TempPath -Force
Start-Process "$TempPath\TeamViewer_Setup_x64.exe" -ArgumentList "/S" -Wait

Write-Host "Copiando e Instalando Office..." -ForegroundColor Yellow
Copy-Item -Path "$BasePath\Office" -Destination $TempPath -Recurse -Force
Start-Process "$TempPath\Office\setup.exe" -ArgumentList "/configure configuration.xml" -Wait

Copy-Item -Path $SourceFolder -Destination "C:\" -Recurse -Force

# ===============================
# 2. CREAR ORIGEN DE DATOS ODBC (DSN)
# ===============================

Write-Host "Configurando DSN ODBC..." -ForegroundColor Yellow

$dsnName = "Ventas"
$description = "Sistema Empresarial Grupo Guadalupe"
$server = "192.168.1.1"
$port = "3306"
$user = "AFOFOFOOOO"
$pwd = "NOPITINOOO"
$database = "ventas"

$driverDll = "C:\Program Files (x86)\MySQL\Connector ODBC 8.0\myodbc8w.dll"
$base = "HKLM:\SOFTWARE\WOW6432Node\ODBC\ODBC.INI"

New-Item -Path "$base\$dsnName" -Force | Out-Null
Set-ItemProperty -Path "$base\$dsnName" -Name "Driver" -Value $driverDll
Set-ItemProperty -Path "$base\$dsnName" -Name "Description" -Value $description
Set-ItemProperty -Path "$base\$dsnName" -Name "Server" -Value $server
Set-ItemProperty -Path "$base\$dsnName" -Name "Port" -Value $port
Set-ItemProperty -Path "$base\$dsnName" -Name "User" -Value $user
Set-ItemProperty -Path "$base\$dsnName" -Name "Password" -Value $pwd
Set-ItemProperty -Path "$base\$dsnName" -Name "Database" -Value $database
Set-ItemProperty -Path "$base\$dsnName" -Name "NO_PROMPT" -Value "1"
Set-ItemProperty -Path "$base\$dsnName" -Name "AUTO_RECONNECT" -Value "1"
Set-ItemProperty -Path "$base\$dsnName" -Name "BIG_PACKETS" -Value "1"

if (-not (Test-Path "$base\ODBC Data Sources")) {
    New-Item -Path "$base\ODBC Data Sources" | Out-Null
}
Set-ItemProperty -Path "$base\ODBC Data Sources" -Name $dsnName -Value "MySQL ODBC 8.0 Unicode Driver"

# ===============================
# 3. COPIAR CARPETA Sigg2002 A C:\
# ===============================

Write-Host "Copiando carpeta Sigg2002..." -ForegroundColor Yellow

$SourceFolder = "$BasePath\Sigg2002"
$TargetFolder = "C:\Sigg2002"

if (-not (Test-Path $SourceFolder)) {
    Write-Error "No se encontró la carpeta Sigg2002 en $BasePath"
    exit 1
}

if (Test-Path $TargetFolder) {
    Remove-Item $TargetFolder -Recurse -Force
}

Copy-Item -Path $SourceFolder -Destination "C:\" -Recurse -Force

# ===============================
# 4. CREAR ACCESO DIRECTO EN EL ESCRITORIO
# ===============================

Write-Host "Creando acceso directo en el escritorio..." -ForegroundColor Yellow

$exePath = "C:\Sigg2002\Ventas\Ventas.exe"
$desktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
$shortcutPath = "$desktop\Ventas.lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.WorkingDirectory = "C:\Sigg2002\Ventas"
$shortcut.IconLocation = "C:\Sigg2002\Ventas\ventas.ico"
$shortcut.Save()

# ===============================
# 5. INSTALACIÓN DE OCX
# ===============================

Write-Host "Instalando bbListView OCX (32 bits)..." -ForegroundColor Yellow

$ocxSourcePath = "$BasePath\bbListView\bbListView"
$syswow64 = "$env:windir\SysWOW64"

$files = @("bbListView.ocx","bbListView.tlb","bbListView.hlp")
foreach ($file in $files) {
    $src = Join-Path $ocxSourcePath $file
    if (Test-Path $src) {
        Copy-Item $src $syswow64 -Force
    } else {
        Write-Error "Archivo faltante: $file"
        exit 1
    }
}

Start-Process "$syswow64\regsvr32.exe" -ArgumentList "/s `"$syswow64\bbListView.ocx`"" -Wait

Write-Host "bbListView OCX instalado correctamente." -ForegroundColor Green

# ===============================
# LIMPIEZA FINAL
# ===============================

Write-Host "Eliminando carpeta temporal..." -ForegroundColor Yellow
Remove-Item $TempPath -Recurse -Force

Write-Host "Instalación completa finalizada correctamente." -ForegroundColor Green
exit 0

