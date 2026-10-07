param([string]$PluginPath,[string]$PreviewPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$ini=$a.GetType('KeeTheme.TemplateReader').GetMethod('GetFromResources',$f).Invoke($null,@('KeeTheme.Resources.ModernDark.ini'))
$template=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomThemeTemplate'),$f,$null,@($ini),$null)
$theme=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomTheme'),$f,$null,@($template),$null)
$type=$a.GetType('KeeTheme.KeeTheme')
$instance=[Runtime.Serialization.FormatterServices]::GetUninitializedObject($type)
$type.GetField('_theme',$f).SetValue($instance,$theme)
$type.GetField('_enabled',$f).SetValue($instance,$true)
$form=New-Object KeePass.Forms.PwEntryForm
$button=$form.Controls.Find('m_btnIcon',$true)[0]
$source=New-Object Drawing.Bitmap(16,16)
$button.Image=$source; $button.BackColor=[Drawing.Color]::FromArgb(37,37,38);$button.ForeColor=[Drawing.Color]::White
$bmp=New-Object Drawing.Bitmap($button.Width,$button.Height);$g=[Drawing.Graphics]::FromImage($bmp)
$event=New-Object Windows.Forms.PaintEventArgs($g,$button.ClientRectangle)
$paint=$type.GetMethod('HandleModernEntryButtonPaint',$f)
$custom=$form.GetType().GetField('m_pwCustomIconID',$f)
$icon=$form.GetType().GetField('m_pwEntryIcon',$f)
$custom.SetValue($form,[KeePassLib.PwUuid]::Zero)
$hashes=@()
foreach($id in @(0,48)){
 $icon.SetValue($form,[KeePassLib.PwIcon]$id)
 $g.Clear([Drawing.Color]::Magenta)
 $paint.Invoke($instance,@($button.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
 $sum=0L
 for($y=4;$y -lt 19;$y++){for($x=8;$x -lt 24;$x++){$p=$bmp.GetPixel($x,$y);if($p.R -ne $p.G -and $p.ToArgb() -ne $button.BackColor.ToArgb()){throw 'Old colored icon retained'};$sum+=$p.ToArgb()}}
 $hashes+=,$sum
 if(![Object]::ReferenceEquals($button.Image,$source)){throw 'Original image replaced'}
}
if($hashes[0] -eq $hashes[1]){throw 'Selected standard icon not refreshed'}
$custom.SetValue($form,(New-Object KeePassLib.PwUuid($true)))
$g.Clear([Drawing.Color]::Magenta);$paint.Invoke($instance,@($button.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(16,10).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Custom icon overwritten'}
$custom.SetValue($form,[KeePassLib.PwUuid]::Zero)
$type.GetField('_enabled',$f).SetValue($instance,$false)
$g.Clear([Drawing.Color]::Magenta);$paint.Invoke($instance,@($button.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(16,10).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Disabled theme painted'}
$g.Dispose();$bmp.Dispose();$form.Dispose();$source.Dispose()
Write-Output 'PASS standard entry preview refresh, monochrome drawing, custom image and disabled theme preserved'
$type.GetField('_enabled',$f).SetValue($instance,$true)
$keyForm=New-Object KeePass.Forms.KeyPromptForm
$banner=$keyForm.Controls.Find('m_bannerImage',$true)[0]
$original=New-Object Drawing.Bitmap(417,60)
$banner.Image=$original
$canvas=New-Object Drawing.Bitmap($banner.Width,$banner.Height)
$graphics=[Drawing.Graphics]::FromImage($canvas)
$event=New-Object Windows.Forms.PaintEventArgs($graphics,$banner.ClientRectangle)
$paintBanner=$type.GetMethod('HandleModernBannerPaint',$f)
$graphics.Clear([Drawing.Color]::Magenta)
$paintBanner.Invoke($instance,@($banner.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($canvas.GetPixel(2,2).ToArgb() -ne $theme.Control.BackColor.ToArgb()){throw 'Modern banner background incorrect'}
if($canvas.GetPixel(2,$banner.Height-1).R -ne 65){throw 'Banner divider missing'}
if(![Object]::ReferenceEquals($banner.Image,$original)){throw 'Banner source image altered'}
if($PreviewPath){$canvas.Save($PreviewPath,[Drawing.Imaging.ImageFormat]::Png)}
$type.GetField('_enabled',$f).SetValue($instance,$false)
$graphics.Clear([Drawing.Color]::Magenta)
$paintBanner.Invoke($instance,@($banner.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($canvas.GetPixel(2,2).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Disabled banner painted'}
$graphics.Dispose();$canvas.Dispose();$keyForm.Dispose();$original.Dispose()
Write-Output 'PASS flat unlock banner, original image and disabled theme preserved'
