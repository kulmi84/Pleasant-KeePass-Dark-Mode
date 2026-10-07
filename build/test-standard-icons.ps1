param([string]$PluginPath,[string]$PreviewPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$draw=$a.GetType('KeeTheme.Theme.ModernStandardIcons').GetMethod('Draw',$f)
foreach($size in @(16,24,32)) {
    for($index=0;$index -lt [int][KeePassLib.PwIcon]::Count;$index++) {
        $bmp=New-Object Drawing.Bitmap($size,$size); $g=[Drawing.Graphics]::FromImage($bmp)
        $r=New-Object Drawing.Rectangle(0,0,$size,$size); $c=[Drawing.Color]::White
        if(!$draw.Invoke($null,@($g.PSObject.BaseObject,$r.PSObject.BaseObject,$index,$c.PSObject.BaseObject))){throw ('Missing standard icon '+$index)}
        $painted=0
        for($y=0;$y -lt $size;$y++){for($x=0;$x -lt $size;$x++){if($bmp.GetPixel($x,$y).A -gt 0){$painted++}}}
        if($painted -lt 8){throw ('Blank icon '+$index)}
        $g.Dispose(); $bmp.Dispose()
    }
}
$ini=$a.GetType('KeeTheme.TemplateReader').GetMethod('GetFromResources',$f).Invoke($null,@('KeeTheme.Resources.ModernDark.ini'))
$template=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomThemeTemplate'),$f,$null,@($ini),$null)
$theme=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomTheme'),$f,$null,@($template),$null)
if($theme.ListView.ShowColumnSeparators -or !$theme.ListView.UseThemeAlternatingColors){throw 'List options incorrect'}
if($theme.ListView.EvenRowColor.R -ne 27 -or $theme.ListView.OddRowColor.R -ne 32){throw 'Row shades incorrect'}
$form=New-Object Windows.Forms.Form; $lv=New-Object Windows.Forms.ListView
$form.Controls.Add($lv); $lv.View=[Windows.Forms.View]::Details
$header=New-Object Windows.Forms.ColumnHeader; $header.Width=100; $lv.Columns.Add($header) | Out-Null
$item=New-Object Windows.Forms.ListViewItem(''); $lv.Items.Add($item) | Out-Null
$decorator=[Activator]::CreateInstance($a.GetType('KeeTheme.Decorators.ListViewDecorator'),$f,$null,@($lv.PSObject.BaseObject,$theme.PSObject.BaseObject),$null)
$lv.GridLines=$true
$decorator.GetType().GetMethod('EnableTheme',$f).Invoke($decorator,@($true,$theme.PSObject.BaseObject)) | Out-Null
if($lv.GridLines){throw 'Native grid lines still enabled'}
$decorator.GetType().GetMethod('EnableTheme',$f).Invoke($decorator,@($false,$theme.PSObject.BaseObject)) | Out-Null
if(!$lv.GridLines){throw 'Native grid lines not restored'}
$decorator.GetType().GetMethod('EnableTheme',$f).Invoke($decorator,@($true,$theme.PSObject.BaseObject)) | Out-Null
$bmp=New-Object Drawing.Bitmap(100,30); $g=[Drawing.Graphics]::FromImage($bmp)
$sentinel=[Drawing.Color]::FromArgb(10,12,14); $g.Clear($sentinel)
$r=New-Object Drawing.Rectangle(0,0,100,30)
$event=New-Object Windows.Forms.DrawListViewSubItemEventArgs($g,$r,$item,$item.SubItems[0],0,0,$header,[Windows.Forms.ListViewItemStates]::Default)
$paint=$decorator.GetType().GetMethod('HandleListViewDrawSubItem',$f)
$paint.Invoke($decorator,@($lv.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(98,15).ToArgb() -ne $sentinel.ToArgb()){throw 'Column separator still drawn'}
$theme.ListView.ShowColumnSeparators=$true
$paint.Invoke($decorator,@($lv.PSObject.BaseObject,$event.PSObject.BaseObject)) | Out-Null
if($bmp.GetPixel(98,15).ToArgb() -ne $theme.ListView.ColumnBorderColor.ToArgb()){throw 'Legacy separator lost'}
$g.Dispose(); $bmp.Dispose(); $form.Dispose()
Write-Output 'PASS all 69 standard icons at 16/24/32px, darker row palette and separator removal/legacy fallback'
if($PreviewPath) {
    $bmp=New-Object Drawing.Bitmap(900,630); $g=[Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::FromArgb(27,27,27))
    $font=New-Object Drawing.Font('Segoe UI',17,[Drawing.FontStyle]::Bold)
    $small=New-Object Drawing.Font('Segoe UI',9)
    $brush=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(241,241,241))
    $g.DrawString('69 moderne Standardicons',$font,$brush,24,20)
    for($index=0;$index -lt 69;$index++) {
        $x=30+($index%10)*87; $y=80+[Math]::Floor($index/10)*74
        $r=New-Object Drawing.Rectangle($x,$y,32,32); $c=[Drawing.Color]::FromArgb(241,241,241)
        $draw.Invoke($null,@($g.PSObject.BaseObject,$r.PSObject.BaseObject,$index,$c.PSObject.BaseObject)) | Out-Null
        $g.DrawString([string]$index,$small,$brush,($x+8),($y+38))
    }
    $bmp.Save($PreviewPath,[Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose(); $font.Dispose(); $small.Dispose(); $brush.Dispose()
}
