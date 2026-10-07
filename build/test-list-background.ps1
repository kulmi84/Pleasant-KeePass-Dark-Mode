param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$ini=$a.GetType('KeeTheme.TemplateReader').GetMethod('GetFromResources',$f).Invoke($null,@('KeeTheme.Resources.ModernDark.ini'))
$template=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomThemeTemplate'),$f,$null,@($ini),$null)
$theme=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomTheme'),$f,$null,@($template),$null)
$form=New-Object Windows.Forms.Form
$lv=New-Object Windows.Forms.ListView
$lv.View=[Windows.Forms.View]::Details; $lv.Size=New-Object Drawing.Size(300,250)
$form.Controls.Add($lv)
$lv.Columns.Add('Title',100) | Out-Null
$lv.Columns.Add('Username',100) | Out-Null
$d=[Activator]::CreateInstance($a.GetType('KeeTheme.Decorators.ListViewDecorator'),$f,$null,@($lv.PSObject.BaseObject,$theme.PSObject.BaseObject),$null)
$enable=$d.GetType().GetMethod('EnableTheme',$f)
$paint=$d.GetType().GetMethod('HandleBackgroundPaint',$f)
$enable.Invoke($d,@($true,$theme.PSObject.BaseObject)) | Out-Null
$bmp=New-Object Drawing.Bitmap(300,250); $g=[Drawing.Graphics]::FromImage($bmp)
$event=New-Object Windows.Forms.PaintEventArgs($g,$lv.ClientRectangle)
$sentinel=[Drawing.Color]::Magenta
foreach($count in @(0,1,50)){
 $lv.Items.Clear()
 for($i=0;$i -lt $count;$i++){$lv.Items.Add('Entry '+$i) | Out-Null}
 $g.Clear($sentinel)
 $paint.Invoke($d,@($null,$event.PSObject.BaseObject)) | Out-Null
 if($bmp.GetPixel(50,0).ToArgb() -ne $sentinel.ToArgb()){throw 'Header overwritten'}
 if($count -lt 2){
  if($bmp.GetPixel(98,220).ToArgb() -ne $theme.ListView.BackColor.ToArgb()){throw 'Empty-area divider not covered'}
  if($count -eq 1 -and $bmp.GetPixel(50,$lv.Items[0].Bounds.Top+2).ToArgb() -ne $sentinel.ToArgb()){throw 'Entry overwritten'}
 }elseif($bmp.GetPixel(98,220).ToArgb() -ne $sentinel.ToArgb()){throw 'Visible rows overwritten in long list'}
}
$lv.Items.Clear()
$first=New-Object Windows.Forms.ListViewGroup('First search group')
$second=New-Object Windows.Forms.ListViewGroup('Second search group')
$empty=New-Object Windows.Forms.ListViewGroup('Empty group')
$lv.Groups.Add($first) | Out-Null; $lv.Groups.Add($second) | Out-Null; $lv.Groups.Add($empty) | Out-Null
# Deliberately reverse item index order relative to group display order.
$bottom=$lv.Items.Add('Bottom result'); $bottom.Group=$second
$upper=$lv.Items.Add('Upper result'); $upper.Group=$first
$lv.CreateControl(); $lv.Update()
$native=$d.GetType().GetField('_groupsPainter',$f).GetValue($d)
$headerMethod=$native.GetType().GetMethod('TryGetHeaderRectangle',$f)
$headers=@()
for($i=0;$i -le $lv.Groups.Count;$i++){
 $args=@($i,[Drawing.Rectangle]::Empty)
 if($headerMethod.Invoke($native,$args)){$headers+=,$args[1]}
}
if($headers.Count -lt 2){throw 'Native grouped search headers unavailable'}
$g.Clear($sentinel); $paint.Invoke($d,@($null,$event.PSObject.BaseObject)) | Out-Null
foreach($item in $lv.Items){
 $y=$item.Bounds.Top+2
 if($y -ge 0 -and $y -lt 250 -and $bmp.GetPixel(50,$y).ToArgb() -ne $sentinel.ToArgb()){throw 'Grouped search result overwritten'}
}
foreach($header in $headers){
 $y=$header.Top+2
 if($y -ge 0 -and $y -lt 250 -and $bmp.GetPixel(50,$y).ToArgb() -ne $sentinel.ToArgb()){throw 'Search group header overwritten'}
}
if($bmp.GetPixel(98,220).ToArgb() -ne $theme.ListView.BackColor.ToArgb()){throw 'Grouped search divider not covered'}
$lv.Groups.Clear(); $lv.Items.Clear(); $theme.ListView.ShowColumnSeparators=$true
$g.Clear($sentinel); $paint.Invoke($d,@($null,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(98,220).ToArgb() -ne $sentinel.ToArgb()){throw 'Legacy theme altered'}
$theme.ListView.ShowColumnSeparators=$false
$enable.Invoke($d,@($false,$theme.PSObject.BaseObject)) | Out-Null
$g.Clear($sentinel); $paint.Invoke($d,@($null,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(98,220).ToArgb() -ne $sentinel.ToArgb()){throw 'Disabled theme altered'}
$g.Dispose();$bmp.Dispose();$form.Dispose()
Write-Output 'PASS plain and grouped search backgrounds, reordered results and group headers preserved, legacy/disabled themes preserved'
