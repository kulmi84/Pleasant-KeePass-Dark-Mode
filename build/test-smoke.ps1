param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$flags=[Reflection.BindingFlags]'Public,NonPublic,Static,Instance'
$reader=$a.GetType('KeeTheme.TemplateReader')
$templateType=$a.GetType('KeeTheme.Theme.CustomThemeTemplate')
$themeType=$a.GetType('KeeTheme.Theme.CustomTheme')
foreach($resource in $a.GetManifestResourceNames() | Where-Object { $_.EndsWith('.ini') }) {
    $ini=$reader.GetMethod('GetFromResources',$flags).Invoke($null,@([string]$resource))
    if(!$ini){throw ('Cannot load '+$resource)}
    $template=[Activator]::CreateInstance($templateType,$flags,$null,@($ini),$null)
    $theme=[Activator]::CreateInstance($themeType,$flags,$null,@($template),$null)
    if($resource.EndsWith('ModernDark.ini')) {
        if($theme.Form.BackColor.ToArgb() -ne [Drawing.ColorTranslator]::FromHtml('#1E1E1E').ToArgb()){throw 'Background mismatch'}
        if(!$theme.MenuItem.ModernIcons){throw 'Icons missing'}
        if($theme.MenuItem.DisabledForeColor.R -ne 190){throw 'Disabled text mismatch'}
        $roundTrip=$templateType.GetMethod('GetIniFile',$flags).Invoke($template,@())
        $reloaded=[Activator]::CreateInstance($templateType,$flags,$null,@($roundTrip),$null)
        if(!$reloaded.MenuItem.ModernIcons){throw 'Editor roundtrip lost icons'}
        $lv=New-Object Windows.Forms.ListView
        $lv.Name='m_lvEntries'
        $decorator=[Activator]::CreateInstance($a.GetType('KeeTheme.Decorators.ListViewDecorator'),$flags,$null,@($lv.PSObject.BaseObject,$theme.PSObject.BaseObject),$null)
        $method=$decorator.GetType().GetMethod('TryDrawModernStandardIcon',$flags)
        $bitmap=New-Object Drawing.Bitmap(24,24)
        $graphics=[Drawing.Graphics]::FromImage($bitmap)
        $entry=New-Object KeePassLib.PwEntry($true,$true)
        $item=New-Object Windows.Forms.ListViewItem('sample')
        $item.Tag=New-Object KeePass.UI.PwListItem($entry)
        $item.ImageIndex=0
        $rect=New-Object Drawing.Rectangle(0,0,24,24)
        if(!$method.Invoke($decorator,@($graphics.PSObject.BaseObject,$item.PSObject.BaseObject,$rect.PSObject.BaseObject))){throw 'Standard key not drawn'}
        $entry.CustomIconUuid=New-Object KeePassLib.PwUuid($true)
        if($method.Invoke($decorator,@($graphics.PSObject.BaseObject,$item.PSObject.BaseObject,$rect.PSObject.BaseObject))){throw 'Custom UUID was drawn'}
        $entry.CustomIconUuid=[KeePassLib.PwUuid]::Zero
        $item.ImageIndex=[int][KeePassLib.PwIcon]::Count
        if($method.Invoke($decorator,@($graphics.PSObject.BaseObject,$item.PSObject.BaseObject,$rect.PSObject.BaseObject))){throw 'Custom slot was drawn'}
        $item.ImageIndex=0
        $theme.MenuItem.ModernIcons=$false
        if($method.Invoke($decorator,@($graphics.PSObject.BaseObject,$item.PSObject.BaseObject,$rect.PSObject.BaseObject))){throw 'Legacy theme fallback failed'}
        $graphics.Dispose(); $bitmap.Dispose(); $lv.Dispose()
    }
    Write-Output ('PASS '+$resource)
}
Write-Output 'PASS custom UUID / custom slot preservation, standard drawing, theme roundtrip and legacy fallback'
