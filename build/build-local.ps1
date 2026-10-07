param([string]$KeePassPath = 'C:\Program Files (x86)\Pleasant Solutions\KeePass for Pleasant Password Server\KeePass.exe', [string]$OutputPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
$sourceRoot = Join-Path $PSScriptRoot '../KeeTheme'
$sourceRoot = (Resolve-Path $sourceRoot).Path
if (!$OutputPath) { $OutputPath = Join-Path $sourceRoot 'bin/Release/KeeTheme.dll' }
New-Item -ItemType Directory -Force (Split-Path $OutputPath) | Out-Null
$resourceDir = Join-Path $sourceRoot 'obj/manual'
New-Item -ItemType Directory -Force $resourceDir | Out-Null
$compilerArgs = @('/nologo','/target:library','/optimize+',('/out:'+$OutputPath),('/r:'+$KeePassPath),'/r:System.Core.dll','/r:System.Design.dll','/r:System.Drawing.dll','/r:System.Windows.Forms.dll','/r:System.Xml.Linq.dll','/r:System.Data.DataSetExtensions.dll','/r:System.Data.dll','/r:System.Xml.dll')
foreach ($resx in Get-ChildItem $sourceRoot -Recurse -Filter *.resx) {
    $relative = $resx.FullName.Substring($sourceRoot.Length+1)
    $name = 'KeeTheme.'+$relative.Replace('\','.').Replace('.resx','.resources')
    $target = Join-Path $resourceDir $name
    $reader = New-Object System.Resources.ResXResourceReader($resx.FullName)
    $reader.BasePath = $resx.DirectoryName
    $writer = New-Object System.Resources.ResourceWriter($target)
    try {
        foreach ($entry in $reader.GetEnumerator()) { $writer.AddResource($entry.Key,$entry.Value) }
        $writer.Generate()
    } finally { $writer.Close(); $reader.Close() }
    $compilerArgs += '/resource:'+$target+','+$name
}
foreach ($ini in Get-ChildItem (Join-Path $sourceRoot Resources) -Filter *.ini) {
    $compilerArgs += '/resource:'+$ini.FullName+',KeeTheme.Resources.'+$ini.Name
}
$compilerArgs += '/resource:'+(Join-Path $sourceRoot 'Resources/ModernWindow.ico')+',KeeTheme.Resources.ModernWindow.ico'
$compilerArgs += '/resource:'+(Join-Path $sourceRoot 'Resources/ModernBanner.png')+',KeeTheme.Resources.ModernBanner.png'
$compilerArgs += Get-ChildItem $sourceRoot -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' } | ForEach-Object { $_.FullName }
& "$env:WINDIR\Microsoft.NET\Framework\v3.5\csc.exe" $compilerArgs
if ($LASTEXITCODE -ne 0) { throw 'Compilation failed' }
Write-Output ('Built '+$OutputPath)
