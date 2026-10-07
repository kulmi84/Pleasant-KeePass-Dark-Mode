param([string]$PluginPath)
$ErrorActionPreference='Stop'
$fileInfo=[Diagnostics.FileVersionInfo]::GetVersionInfo($PluginPath)
if($fileInfo.ProductName -ne 'KeePass Plugin'){throw 'KeePass loader would ignore DLL: required product metadata missing'}
Write-Output 'PASS KeePass plugin discovery metadata'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$properties=[KeePass.Plugins.IPluginHost].GetProperties()
$members=foreach($property in $properties) {
    $getter=if($property.Name -eq 'MainWindow'){'return Window;'}else{'throw new System.NotSupportedException();'}
    'public '+$property.PropertyType.FullName+' '+$property.Name+' { get { '+$getter+' } }'
}
$source='public sealed class PaintTraceTestHost : KeePass.Plugins.IPluginHost { public KeePass.Forms.MainForm Window = new KeePass.Forms.MainForm(); '+($members -join ' ')+' }'
$hostSource=Join-Path ([IO.Path]::GetTempPath()) 'KeeThemePaintTraceTestHost.cs'
$hostDll=Join-Path ([IO.Path]::GetTempPath()) 'KeeThemePaintTraceTestHost.dll'
[IO.File]::WriteAllText($hostSource,$source)
& "$env:WINDIR\Microsoft.NET\Framework\v3.5\csc.exe" /nologo /target:library ('/out:'+$hostDll) '/r:C:\Program Files\KeePass Password Safe 2\KeePass.exe' /r:System.Windows.Forms.dll /r:System.Drawing.dll /r:System.Core.dll $hostSource
if($LASTEXITCODE -ne 0){throw 'Test host compilation failed'}
[Reflection.Assembly]::LoadFrom($hostDll) | Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
$plugin=[Activator]::CreateInstance($assembly.GetType('KeeThemePaintTrace.KeeThemePaintTraceExt'))
$hostStub=New-Object PaintTraceTestHost
try {
    if(!$plugin.Initialize($hostStub)){throw 'Diagnostic plugin did not initialize'}
    $flags=[Reflection.BindingFlags]'NonPublic,Instance'
    $path=$plugin.GetType().GetField('path',$flags).GetValue($plugin)
    if(!(Test-Path -LiteralPath $path)){throw 'Startup log missing'}
    if(!(Get-Content -LiteralPath $path -Raw).Contains('Diagnostic session.')){throw 'Startup evidence missing'}
    Write-Output ('PASS startup log created at '+$path)
} finally {$plugin.Terminate();$hostStub.Window.Dispose()}
