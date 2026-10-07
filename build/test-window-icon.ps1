param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
foreach($size in @(16,32,48,64,128)) {
    $stream=$a.GetManifestResourceStream('KeeTheme.Resources.ModernWindow.ico')
    $icon=New-Object Drawing.Icon($stream,$size,$size)
    if($icon.Width -ne $size -or $icon.Height -ne $size){throw ('ICO size missing: wanted '+$size+' loaded '+$icon.Width)}
    $icon.Dispose(); $stream.Dispose()
}
$stream=$a.GetManifestResourceStream('KeeTheme.Resources.ModernWindow.ico')
$reader=New-Object IO.BinaryReader($stream)
$reader.ReadUInt16() | Out-Null
if($reader.ReadUInt16() -ne 1 -or $reader.ReadUInt16() -ne 6){throw 'ICO directory invalid'}
$stream.Position=6+16*5
if($reader.ReadByte() -ne 0 -or $reader.ReadByte() -ne 0){throw '256px ICO entry missing'}
$reader.Dispose()
$form=New-Object Windows.Forms.Form
$form.Icon=[Drawing.SystemIcons]::Information
$original=$form.Icon
$type=$a.GetType('KeeTheme.Decorators.WindowIconDecorator')
$d=[Activator]::CreateInstance($type,$f,$null,@($form.PSObject.BaseObject),$null)
$apply=$type.GetMethod('Apply',$f)
$apply.Invoke($d,@($true)) | Out-Null
if([Object]::ReferenceEquals($form.Icon,$original)){throw 'Icon unchanged'}
$bitmap=New-Object Drawing.Bitmap($form.Icon.Width,$form.Icon.Height)
$graphics=[Drawing.Graphics]::FromImage($bitmap); $graphics.Clear([Drawing.Color]::Transparent)
$graphics.DrawIcon($form.Icon,(New-Object Drawing.Rectangle(0,0,$bitmap.Width,$bitmap.Height))); $graphics.Dispose(); $painted=0
for($y=0;$y -lt $bitmap.Height;$y++){for($x=0;$x -lt $bitmap.Width;$x++){
    $pixel=$bitmap.GetPixel($x,$y)
    if($pixel.A -gt 0){$painted++; if($pixel.R -ne $pixel.G -or $pixel.G -ne $pixel.B){throw ('Non-grey pixel '+$pixel.ToString())}}
}}
if($painted -lt 10){throw 'Icon empty'}
$bitmap.Dispose()
$form.Icon=[Drawing.SystemIcons]::Warning
$latest=$form.Icon
$apply.Invoke($d,@($true)) | Out-Null
$apply.Invoke($d,@($false)) | Out-Null
if(![Object]::ReferenceEquals($form.Icon,$latest)){throw 'Latest original not restored'}
$apply.Invoke($d,@($true)) | Out-Null
$d.Dispose()
if(![Object]::ReferenceEquals($form.Icon,$latest)){throw 'Unloading did not restore icon'}
$d.Dispose(); $form.Dispose()
Write-Output 'PASS six ICO directory entries and five WinForms sizes, monochrome drawing, database icon refresh and disable/unload restoration'
