#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param([string]$InstallDirectory)

$ErrorActionPreference = 'Stop'
$expectedHash = 'FE10B7DAF92F1D5C1ECF2CA2E2AA63A7E88B5CFC7AF8416DF224FE76FA857627'
function Get-DllHash([string]$Path) {
    $stream = [IO.File]::OpenRead($Path)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-','') }
    finally { $stream.Dispose(); $algorithm.Dispose() }
}
$source = Join-Path $PSScriptRoot 'KeeTheme.dll'
if (!(Test-Path -LiteralPath $source -PathType Leaf)) { throw 'KeeTheme.dll fehlt neben dem Installer. ZIP vollstaendig entpacken.' }
if ((Get-DllHash $source) -ne $expectedHash) { throw 'Die DLL stimmt nicht mit der geprueften Version 1.0.0 ueberein. Installation abgebrochen.' }

if (!$InstallDirectory) {
    $candidates = @(${env:ProgramFiles(x86)}, $env:ProgramFiles) | Where-Object { $_ } | ForEach-Object {
        Join-Path $_ 'Pleasant Solutions\KeePass for Pleasant Password Server'
    } | Select-Object -Unique
    $found = @($candidates | Where-Object { Test-Path -LiteralPath (Join-Path $_ 'KeePass.exe') -PathType Leaf })
    if ($found.Count -ne 1) { throw 'Pleasant-Ordner nicht eindeutig gefunden. Mit -InstallDirectory den Clientordner angeben.' }
    $InstallDirectory = $found[0]
}
$client = (Resolve-Path -LiteralPath $InstallDirectory).Path
$exe = Join-Path $client 'KeePass.exe'
if (!(Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'Im angegebenen Clientordner fehlt KeePass.exe.' }
foreach ($process in @(Get-Process -Name KeePass -ErrorAction SilentlyContinue)) {
    if (!$process.Path -or [string]::Equals($process.Path, $exe, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Pleasant KeePass zuerst schliessen. Ein KeePass-Prozess laeuft noch oder kann nicht zugeordnet werden.'
    }
}
$plugins = Join-Path $client 'Plugins'
$target = Join-Path $plugins 'KeeTheme.dll'
$oldFiles = @('KeeTheme.dll','KeeTheme.plgx') | ForEach-Object { Join-Path $plugins $_ } | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
$backup = Join-Path (Join-Path $client 'KeeTheme-backups') ((Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8))
if (!$PSCmdlet.ShouldProcess($client, 'KeeTheme sichern, Version 1.0.0 installieren und nur diese DLL freigeben')) { return }
$saved = @()
$installed = $false
try {
    New-Item -ItemType Directory -Path $plugins -Force | Out-Null
    # Backups stay outside Plugins so KeePass cannot load a second theme plugin.
    if (@($oldFiles).Count -gt 0) { New-Item -ItemType Directory -Path $backup -Force | Out-Null }
    foreach ($old in $oldFiles) {
        $copy = Join-Path $backup ([IO.Path]::GetFileName($old))
        Copy-Item -LiteralPath $old -Destination $copy
        $saved += @{Original=$old;Backup=$copy}
    }
    foreach ($entry in $saved) { Remove-Item -LiteralPath $entry.Original }
    $installed = $true
    Copy-Item -LiteralPath $source -Destination $target
    Unblock-File -LiteralPath $target
    if ((Get-DllHash $target) -ne $expectedHash) { throw 'Pruefung der installierten DLL fehlgeschlagen.' }
    Write-Output ('Installiert und freigegeben: ' + $target)
    if ($saved.Count -gt 0) { Write-Output ('Sicherung: ' + $backup) }
    Write-Output 'Pleasant KeePass starten; Extras > Optionen > KeeTheme > Modern Dark aktivieren.'
} catch {
    $failure = $_
    if ($installed -and (Test-Path -LiteralPath $target)) { Remove-Item -LiteralPath $target }
    foreach ($entry in $saved) { Copy-Item -LiteralPath $entry.Backup -Destination $entry.Original -Force }
    throw ('Installation fehlgeschlagen. Vorhandene Plugin-Dateien wurden wiederhergestellt. Bei Zugriffsfehlern PowerShell als Administrator starten. Ursache: ' + $failure.Exception.Message)
}
