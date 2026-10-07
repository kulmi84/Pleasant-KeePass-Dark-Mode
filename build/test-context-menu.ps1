param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe')|Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath);$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$ini=$a.GetType('KeeTheme.TemplateReader').GetMethod('GetFromResources',$f).Invoke($null,@('KeeTheme.Resources.ModernDark.ini'))
$template=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomThemeTemplate'),$f,$null,@($ini),$null)
$theme=[Activator]::CreateInstance($a.GetType('KeeTheme.Theme.CustomTheme'),$f,$null,@($template),$null)
$r=$theme.ToolStripRenderer
$menu=New-Object Windows.Forms.ContextMenuStrip;$menu.Name='m_ctxGroupList';$menu.Renderer=$r
$source=New-Object Drawing.Bitmap(16,16);$g=[Drawing.Graphics]::FromImage($source);$g.Clear([Drawing.Color]::Magenta);$g.Dispose()
$names=@('m_ctxGroupAdd','m_ctxGroupEdit','m_ctxGroupDelete','m_ctxGroupMoveToTop','m_ctxGroupMoveOneUp','m_ctxGroupMoveOneDown','m_ctxGroupMoveToBottom','m_ctxGroupMoveToPreviousParent','m_ctxGroupSort','m_ctxGroupSortRec','m_ctxGroupExpand','m_ctxGroupCollapse','m_ctxGroupDX','m_ctxGroupFind','m_ctxEntryCopyPassword','m_ctxEntryEdit')
$draw=$a.GetType('KeeTheme.Theme.ModernToolbarIcons').GetMethod('Draw',$f)
foreach($name in $names){
 $item=New-Object Windows.Forms.ToolStripMenuItem($name);$item.Name=$name;$item.Image=$source;$menu.Items.Add($item)|Out-Null
 foreach($enabled in @($true,$false)){
  $item.Enabled=$enabled;$b=New-Object Drawing.Bitmap(24,24);$g=[Drawing.Graphics]::FromImage($b);$g.Clear([Drawing.Color]::Black)
  $rect=New-Object Drawing.Rectangle(4,4,16,16)
  $e=New-Object Windows.Forms.ToolStripItemImageRenderEventArgs($g,$item,$source,$rect)
  $r.DrawItemImage($e)
  for($x=0;$x -lt 24;$x++){for($y=0;$y -lt 24;$y++){$p=$b.GetPixel($x,$y);if($p.R -ne $p.G -or $p.G -ne $p.B){throw ('Color icon survived '+$name)}}}
  $g.Dispose();$b.Dispose()
 }
}
if($source.GetPixel(8,8).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Original image changed'}
# Test nested context root resolution, including detached menus.
$parent=New-Object Windows.Forms.ToolStripMenuItem('Rearrange');$menu.Items.Add($parent)|Out-Null
$child=New-Object Windows.Forms.ToolStripMenuItem('Up');$child.Name='m_ctxGroupMoveOneUp';$child.Image=$source;$parent.DropDownItems.Add($child)|Out-Null
$b=New-Object Drawing.Bitmap(24,24);$g=[Drawing.Graphics]::FromImage($b);$g.Clear([Drawing.Color]::Black)
$r.DrawItemImage((New-Object Windows.Forms.ToolStripItemImageRenderEventArgs($g,$child,$source,$rect)))
for($x=0;$x -lt 24;$x++){for($y=0;$y -lt 24;$y++){$p=$b.GetPixel($x,$y);if($p.R -ne $p.G){throw 'Nested menu used original image'}}}
$g.Dispose();$b.Dispose();$menu.Dispose();$source.Dispose()
'PASS group/entry context aliases, detached and nested roots, disabled icons and unchanged source images'
$extras=New-Object Windows.Forms.ToolStripMenuItem('Extras');$extras.Name='m_menuTools'
$source=New-Object Drawing.Bitmap(16,16);$g=[Drawing.Graphics]::FromImage($source);$g.Clear([Drawing.Color]::Magenta);$g.Dispose()
foreach($name in @('m_menuToolsPwGenerator','m_menuToolsGeneratePwList','m_menuToolsTanWizard','m_menuToolsTriggers','m_menuToolsPlugins','m_menuToolsOptions','thirdPartyPlugin')){
 $item=New-Object Windows.Forms.ToolStripMenuItem($name);$item.Name=$name;$item.Image=$source;$extras.DropDownItems.Add($item)|Out-Null
 foreach($enabled in @($true,$false)){
  $item.Enabled=$enabled;$bitmap=New-Object Drawing.Bitmap(24,24);$g=[Drawing.Graphics]::FromImage($bitmap);$g.Clear([Drawing.Color]::Black)
  $r.DrawItemImage((New-Object Windows.Forms.ToolStripItemImageRenderEventArgs($g,$item,$source,$rect)))
  for($x=0;$x -lt 24;$x++){for($y=0;$y -lt 24;$y++){$pixel=$bitmap.GetPixel($x,$y);if($pixel.R -ne $pixel.G -or $pixel.G -ne $pixel.B){throw ('Color survived Extras rendering '+$name)}}}
  $g.Dispose();$bitmap.Dispose()
 }
}
if($source.GetPixel(8,8).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Plugin source icon mutated'}
$extras.Dispose();$source.Dispose()
'PASS Extras vector icons and third-party grayscale rendering, enabled/disabled, source preservation'
