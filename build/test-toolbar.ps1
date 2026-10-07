param([string]$PluginPath, [string]$PreviewPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$draw=$a.GetType('KeeTheme.Theme.ModernToolbarIcons').GetMethod('Draw',[Reflection.BindingFlags]'Static,NonPublic')
$names=@('m_tbNewDatabase','m_tbOpenDatabase','m_tbSaveDatabase','m_tbSaveAll','m_tbAddEntry','m_tbCopyUserName','m_tbCopyPassword','m_tbOpenUrl','m_tbCopyUrl','m_tbAutoType','m_tbFind','m_tbEntryViewsDropDown','m_tbViewsShowExpired','m_tbLockWorkspace','m_tbCloseTab')
foreach($size in @(16,20,24,32)) {
    foreach($name in $names) {
        $bmp=New-Object Drawing.Bitmap($size,$size)
        $g=[Drawing.Graphics]::FromImage($bmp)
        $rect=New-Object Drawing.Rectangle(0,0,$size,$size)
        $color=[Drawing.Color]::FromArgb(241,241,241)
        $args=@($g.PSObject.BaseObject,$rect.PSObject.BaseObject,[string]$name,$color.PSObject.BaseObject)
        if(!$draw.Invoke($null,$args)){throw ('Missing '+$name)}
        $painted=0
        for($y=0;$y -lt $size;$y++){for($x=0;$x -lt $size;$x++){if($bmp.GetPixel($x,$y).A -gt 0){$painted++}}}
        if($painted -lt 8){throw ('Empty glyph '+$name)}
        if($g.Transform.OffsetX -ne 0 -or $g.Transform.OffsetY -ne 0){throw 'Graphics state leaked'}
        $args[2]='unknown-plugin-command'
        if($draw.Invoke($null,$args)){throw 'Unknown command replaced'}
        $g.Dispose(); $bmp.Dispose()
    }
}
Write-Output 'PASS 15 toolbar glyphs at 16/20/24/32px, unknown-command fallback and graphics restoration'
if($PreviewPath) {
    $bmp=New-Object Drawing.Bitmap(780,160)
    $g=[Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::FromArgb(30,30,30))
    $panel=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(45,45,48))
    $text=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(241,241,241))
    $font=New-Object Drawing.Font('Segoe UI',10)
    $small=New-Object Drawing.Font('Segoe UI',9)
    $g.DrawString('Datei     Gruppe     Eintrag     Suchen     Ansicht     Extras     Hilfe',$font,$text,16,10)
    $g.FillRectangle($panel,0,39,780,43)
    for($i=0;$i -lt $names.Length;$i++) {
        $rect=New-Object Drawing.Rectangle((17+34*$i),50,20,20)
        $color=if($i -in @(3,5,6,7,8,9)){[Drawing.Color]::FromArgb(190,190,190)}else{[Drawing.Color]::FromArgb(241,241,241)}
        $draw.Invoke($null,@($g.PSObject.BaseObject,$rect.PSObject.BaseObject,[string]$names[$i],$color.PSObject.BaseObject)) | Out-Null
    }
    $border=New-Object Drawing.Pen([Drawing.Color]::FromArgb(70,70,75))
    $g.DrawRectangle($border,552,47,211,27)
    $g.DrawString('Suchen ...',$small,$text,565,52)
    $g.DrawString('Modern Dark · Icon-Vorschau aus dem Plugin-Zeichner',$font,$text,16,101)
    $g.DrawString('Toolbar: 20 px · Eigene Eintragsicons bleiben unverändert',$small,$text,16,129)
    $bmp.Save($PreviewPath,[Drawing.Imaging.ImageFormat]::Png)
    $border.Dispose(); $font.Dispose(); $small.Dispose(); $panel.Dispose(); $text.Dispose(); $g.Dispose(); $bmp.Dispose()
}
