param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath);$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$ini=$a.GetType('KeeTheme.TemplateReader').GetMethod('GetFromResources',$f).Invoke($null,@('KeeTheme.Resources.ModernDark.ini'))
$t=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomThemeTemplate'),$f,$null,@($ini),$null)
$theme=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomTheme'),$f,$null,@($t),$null)
$type=$a.GetType('KeeTheme.KeeTheme');$instance=[Runtime.Serialization.FormatterServices]::GetUninitializedObject($type)
$type.GetField('_theme',$f).SetValue($instance,$theme);$type.GetField('_enabled',$f).SetValue($instance,$true)
$checkbox=New-Object Windows.Forms.CheckBox;$checkbox.Size=New-Object Drawing.Size(120,24);$checkbox.BackColor=[Drawing.Color]::FromArgb(30,30,30);$checkbox.Text='Demo'
$bitmap=New-Object Drawing.Bitmap(120,24);$graphics=[Drawing.Graphics]::FromImage($bitmap)
$event=New-Object Windows.Forms.PaintEventArgs($graphics,$checkbox.ClientRectangle)
$paint=$type.GetMethod('HandleModernCheckBoxPaint',$f)
$results=@()
foreach($state in @([Windows.Forms.CheckState]::Unchecked,[Windows.Forms.CheckState]::Checked,[Windows.Forms.CheckState]::Indeterminate)){
 $checkbox.CheckState=$state;$graphics.Clear([Drawing.Color]::Magenta)
 $paint.Invoke($instance,@($checkbox.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
 if($bitmap.GetPixel(50,12).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Checkbox label area overwritten'}
 $sum=0L;for($y=0;$y -lt 24;$y++){for($x=0;$x -lt 16;$x++){$sum+=$bitmap.GetPixel($x,$y).ToArgb()}};$results+=,$sum
 if($checkbox.CheckState -ne $state){throw 'Checkbox state modified'}
}
if(($results | Select-Object -Unique).Count -ne 3){throw 'Checkbox states not distinct'}
$type.GetField('_enabled',$f).SetValue($instance,$false);$graphics.Clear([Drawing.Color]::Magenta)
$paint.Invoke($instance,@($checkbox.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($bitmap.GetPixel(5,12).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Disabled theme paints checkbox'}
$graphics.Dispose();$bitmap.Dispose();$checkbox.Dispose()
Write-Output 'PASS checkbox states distinct, labels and state preserved, disabled theme unchanged'
