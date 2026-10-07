param([string]$PluginPath)
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
foreach($field in $type.GetFields($f) | Where-Object {$_.Name -in @('_toolbarPadding','_toolbarAvailable','_searchSize','_searchAutoSize')}) {
    $field.SetValue($instance,[Activator]::CreateInstance($field.FieldType))
}
$type.GetField('_theme',$f).SetValue($instance,$theme)
$type.GetField('_enabled',$f).SetValue($instance,$true)
$form=New-Object KeePass.Forms.MainForm
$toolbar=New-Object Windows.Forms.ToolStrip
$form.Controls.Add($toolbar)
foreach($name in @('m_tbOpenDatabase','m_tbSaveDatabase','m_tbAddEntry','m_tbFind','m_tbCopyUserName','m_tbCopyPassword','m_tbLockWorkspace','m_tbSaveAll','thirdPartyButton')) {
    $item=New-Object Windows.Forms.ToolStripButton($name); $item.Name=$name; $toolbar.Items.Add($item) | Out-Null
}
$search=New-Object Windows.Forms.ToolStripComboBox
$search.Name='m_tbQuickFind'; $search.Width=120; $toolbar.Items.Add($search) | Out-Null
$originalWidth=$search.Width; $originalAuto=$search.AutoSize
$apply=$type.GetMethods($f) | Where-Object {$_.Name -eq 'Apply' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.FullName -eq 'System.Windows.Forms.ToolStripItemCollection'}
$apply.Invoke($instance,[object[]](,$toolbar.Items.PSObject.BaseObject)) | Out-Null
foreach($name in @('m_tbCopyUserName','m_tbCopyPassword','m_tbLockWorkspace','m_tbSaveAll')) {if(!$toolbar.Items[$name].Available){throw ('Original toolbar item hidden '+$name)}}
foreach($name in @('m_tbOpenDatabase','m_tbSaveDatabase','m_tbAddEntry','m_tbFind','thirdPartyButton')) {if(!$toolbar.Items[$name].Available){throw ('Hidden '+$name)}}
if($search.Width -lt 320){throw 'Search is too narrow'}
$padding=$toolbar.Items['m_tbOpenDatabase'].Padding
$apply.Invoke($instance,[object[]](,$toolbar.Items.PSObject.BaseObject)) | Out-Null
if($toolbar.Items['m_tbOpenDatabase'].Padding -ne $padding){throw 'Padding accumulated'}
$type.GetField('_enabled',$f).SetValue($instance,$false)
$apply.Invoke($instance,[object[]](,$toolbar.Items.PSObject.BaseObject)) | Out-Null
if(!$toolbar.Items['m_tbLockWorkspace'].Available -or $search.Width -ne $originalWidth -or $search.AutoSize -ne $originalAuto){throw 'Restoration failed'}
$form.Dispose()
$icons=$a.GetType('KeeTheme.Theme.ModernStandardIcons').GetMethod('Draw',$f)
$bitmap=New-Object Drawing.Bitmap(24,24); $graphics=[Drawing.Graphics]::FromImage($bitmap)
$rect=New-Object Drawing.Rectangle(0,0,24,24); $color=[Drawing.Color]::White
foreach($icon in @('Folder','FolderOpen','UserCommunication','Key','NetworkServer','EMail','Tool','Home','Monitor','TrashBin')) {
    $index=[int][Enum]::Parse([KeePassLib.PwIcon],$icon)
    if(!$icons.Invoke($null,@($graphics.PSObject.BaseObject,$rect.PSObject.BaseObject,$index,$color.PSObject.BaseObject))){throw ('Missing '+$icon)}
}
if($icons.Invoke($null,@($graphics.PSObject.BaseObject,$rect.PSObject.BaseObject,[int][KeePassLib.PwIcon]::Count,$color.PSObject.BaseObject))){throw 'Custom slot was replaced'}
$graphics.Dispose(); $bitmap.Dispose()
Write-Output 'PASS restored full toolbar, third-party preservation, search width, repeated application, restoration and standard icon mapping'
$type.GetField('_enabled',$f).SetValue($instance,$true)
$tree=New-Object Windows.Forms.TreeView
$tree.Name='m_tvGroups'; $tree.Size=New-Object Drawing.Size(240,160)
$images=New-Object Windows.Forms.ImageList
$images.ColorDepth=[Windows.Forms.ColorDepth]::Depth32Bit
$original=New-Object Drawing.Bitmap(16,16)
$ig=[Drawing.Graphics]::FromImage($original); $ig.Clear([Drawing.Color]::Magenta); $ig.Dispose()
$images.Images.Add($original) | Out-Null; $tree.ImageList=$images
$group=New-Object KeePassLib.PwGroup($true,$true,'Test',[KeePassLib.PwIcon]::Folder)
$group.CustomIconUuid=New-Object KeePassLib.PwUuid($true)
$node=New-Object Windows.Forms.TreeNode('Test'); $node.Tag=$group; $node.ImageIndex=0; $node.SelectedImageIndex=0
$tree.Nodes.Add($node) | Out-Null; $handle=$tree.Handle
$tree.DrawMode=[Windows.Forms.TreeViewDrawMode]::OwnerDrawAll
$canvas=New-Object Drawing.Bitmap(240,160); $cg=[Drawing.Graphics]::FromImage($canvas)
$event=New-Object Windows.Forms.DrawTreeNodeEventArgs($cg,$node,$node.Bounds,[Windows.Forms.TreeNodeStates]::Default)
$method=$type.GetMethod('DrawModernGroup',$f)
if(!$method.Invoke($instance,@($event.PSObject.BaseObject))){throw 'Tree drawing failed'}
$x=$node.Bounds.X-16-3+8; $y=$node.Bounds.Y+($node.Bounds.Height-16)/2+8
if($canvas.GetPixel([int]$x,[int]$y).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Custom tree icon was changed'}
$group.CustomIconUuid=[KeePassLib.PwUuid]::Zero
$node.ImageIndex=[int][KeePassLib.PwIcon]::Folder
$method.Invoke($instance,@($event.PSObject.BaseObject)) | Out-Null
$cg.Dispose(); $canvas.Dispose(); $tree.Dispose(); $images.Dispose(); $original.Dispose()
Write-Output 'PASS group tree renderer and custom UUID image preservation'
$list=New-Object Windows.Forms.ListView
$source=New-Object Windows.Forms.ImageList
$source.ColorDepth=[Windows.Forms.ColorDepth]::Depth32Bit
$img=New-Object Drawing.Bitmap(16,16); $gg=[Drawing.Graphics]::FromImage($img); $gg.Clear([Drawing.Color]::Magenta); $gg.Dispose()
for($i=0;$i -lt 70;$i++){$source.Images.Add($img) | Out-Null}
$list.SmallImageList=$source
$picker=[Activator]::CreateInstance($a.GetType('KeeTheme.Decorators.StandardIconPickerDecorator'),$f,$null,@($list.PSObject.BaseObject),$null)
$picker.GetType().GetMethod('Apply',$f).Invoke($picker,@($true,$theme.PSObject.BaseObject)) | Out-Null
if([Object]::ReferenceEquals($source,$list.SmallImageList)){throw 'Picker preview was not created'}
if(([Drawing.Bitmap]$source.Images[0]).GetPixel(8,8).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Shared source changed'}
Write-Output ('Source count '+$source.Images.Count+' Preview count '+$list.SmallImageList.Images.Count);
if(([Drawing.Bitmap]$list.SmallImageList.Images[69]).GetPixel(8,8).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Custom slot changed'}
$picker.GetType().GetMethod('Apply',$f).Invoke($picker,@($false,$theme.PSObject.BaseObject)) | Out-Null
if(![Object]::ReferenceEquals($source,$list.SmallImageList)){throw 'Picker restoration failed'}
$list.Dispose(); $source.Dispose(); $img.Dispose()
$hostForm=New-Object Windows.Forms.Form
$hostForm.ClientSize=New-Object Drawing.Size(1200,150)
$strip=New-Object Windows.Forms.ToolStrip
$strip.GripStyle=[Windows.Forms.ToolStripGripStyle]::Hidden
$hostForm.Controls.Add($strip)
$strip.Items.Add('Open') | Out-Null
$combo=New-Object Windows.Forms.ToolStripComboBox
$combo.AutoSize=$false; $strip.Items.Add($combo) | Out-Null
$center=[Activator]::CreateInstance($a.GetType('KeeTheme.Decorators.CenteredSearchDecorator'),$f,$null,@($strip.PSObject.BaseObject,$combo.PSObject.BaseObject),$null)
$strip.PerformLayout()
$expected=($strip.ClientSize.Width-$combo.Width)/2
if([Math]::Abs($combo.Bounds.X-$expected) -gt 5){throw ('Not centered: '+$combo.Bounds.X+' vs '+$expected)}
$hostForm.ClientSize=New-Object Drawing.Size(400,150); $strip.PerformLayout()
if($combo.Width -lt 100){throw 'Search became unusable'}
$center.Dispose()
if($strip.Items.ContainsKey('KeeThemeCenterSearchSpacer')){throw 'Spacer leaked'}
$hostForm.Dispose()
Write-Output 'PASS icon picker preview/source preservation/restoration and responsive centered search'
$borderBitmap=New-Object Drawing.Bitmap(320,24)
$borderGraphics=[Drawing.Graphics]::FromImage($borderBitmap)
$borderGraphics.Clear([Drawing.Color]::Magenta)
$borderDraw=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator').GetMethod('DrawSearchBorder',$f)
$borderSize=New-Object Drawing.Size(320,24)
$borderDraw.Invoke($null,@($borderGraphics.PSObject.BaseObject,$borderSize.PSObject.BaseObject)) | Out-Null
if($borderBitmap.GetPixel(0,0).R -ne 65 -or $borderBitmap.GetPixel(319,23).R -ne 65){throw 'Search border color incorrect'}
if($borderBitmap.GetPixel(10,10).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Search interior overwritten'}
$borderGraphics.Dispose(); $borderBitmap.Dispose()
Write-Output 'PASS dark search border and preserved interior'
$fieldDraw=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator').GetMethod('DrawFieldBorder',$f)
$bitmap=New-Object Drawing.Bitmap(320,24); $graphics=[Drawing.Graphics]::FromImage($bitmap)
foreach($focused in @($false,$true)){
 $graphics.Clear([Drawing.Color]::Magenta)
 $fieldDraw.Invoke($null,@($graphics.PSObject.BaseObject,$borderSize.PSObject.BaseObject,$focused)) | Out-Null
 $p=$bitmap.GetPixel(1,1)
 if(!$focused -and ($p.R -ne 65 -or $p.G -ne 65)){throw 'Field border incorrect'}
 if($focused -and ($p.R -ne 56 -or $p.G -ne 101 -or $p.B -ne 138)){throw 'Field focus color incorrect'}
 if($bitmap.GetPixel(10,10).ToArgb() -ne [Drawing.Color]::Magenta.ToArgb()){throw 'Field interior overwritten'}
}
$graphics.Dispose();$bitmap.Dispose()
Write-Output 'PASS dark field border, subtle focus and preserved interior'
$bitmap=New-Object Drawing.Bitmap(20,24);$graphics=[Drawing.Graphics]::FromImage($bitmap)
$buttonBounds=New-Object Drawing.Rectangle(0,0,20,24)
$buttonDraw=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator').GetMethod('DrawComboButton',$f)
$graphics.Clear([Drawing.Color]::Magenta)
$buttonDraw.Invoke($null,@($graphics.PSObject.BaseObject,$buttonBounds.PSObject.BaseObject)) | Out-Null
if($bitmap.GetPixel(0,10).R -ne 65){throw 'Dropdown separator not dark'}
if($bitmap.GetPixel(5,4).R -ne 37){throw 'Dropdown background incorrect'}
if($bitmap.GetPixel(10,12).R -ne 190){throw 'Dropdown arrow missing'}
$graphics.Dispose();$bitmap.Dispose()
Write-Output 'PASS dark dropdown separator, background and visible arrow'
$bitmap=New-Object Drawing.Bitmap(220,24);$graphics=[Drawing.Graphics]::FromImage($bitmap)
$bounds=New-Object Drawing.Rectangle(0,0,220,24);$font=New-Object Drawing.Font('Segoe UI',9)
$drawDate=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator').GetMethod('DrawDateField',$f)
$drawDate.Invoke($null,@($graphics.PSObject.BaseObject,$bounds.PSObject.BaseObject,'01.01.2030',$font.PSObject.BaseObject,$true)) | Out-Null
if($bitmap.GetPixel(160,12).R -ne 37){throw 'Date field background incorrect'}
$graphics.Dispose();$bitmap.Dispose();$font.Dispose()
Write-Output 'PASS dark date background'
