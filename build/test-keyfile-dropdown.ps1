param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe')|Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type @'
using System;using System.Runtime.InteropServices;
public static class KeyFileProbe {
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int Left,Top,Right,Bottom;}
 [StructLayout(LayoutKind.Sequential)] public struct Info {public int Size;public Rect Item,Button;public int State;public IntPtr Combo,Edit,List;}
 [DllImport("user32.dll")]public static extern bool GetComboBoxInfo(IntPtr h,ref Info i);
 [DllImport("user32.dll")]public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
 [DllImport("user32.dll")]public static extern IntPtr GetWindowDC(IntPtr h);
 [DllImport("user32.dll")]public static extern int ReleaseDC(IntPtr h,IntPtr dc);
 [DllImport("gdi32.dll")]public static extern int GetPixel(IntPtr dc,int x,int y);
}
'@
$form=New-Object Windows.Forms.Form
$combo=New-Object Windows.Forms.ComboBox
$combo.Name="m_cmbKeyFile";
$combo.DropDownStyle='DropDownList';$combo.FlatStyle='Flat';$combo.Width=240
$combo.BackColor=[Drawing.Color]::FromArgb(37,37,38);$combo.ForeColor=[Drawing.Color]::FromArgb(241,241,241)
$combo.Items.Add('C:\Demo\Example Database Keys\Demo Family Vault\Example.keyx')|Out-Null;$combo.SelectedIndex=0
$theme=[Runtime.Serialization.FormatterServices]::GetUninitializedObject($assembly.GetType("KeeTheme.KeeTheme"))
$drawMethod=$assembly.GetType("KeeTheme.KeeTheme").GetMethod("HandleModernComboDrawItem",[Reflection.BindingFlags]"Instance,NonPublic")
$combo.DrawMode="OwnerDrawFixed"
$combo.add_DrawItem({param($drawSender,$drawArgs) $drawMethod.Invoke($theme,@($drawSender,$drawArgs))|Out-Null})
$form.Controls.Add($combo)
$flags=[Reflection.BindingFlags]'Instance,Public,NonPublic'
$guard=[Activator]::CreateInstance($assembly.GetType('KeeTheme.Decorators.CenteredSearchDecorator+SearchBorderWindow'),$flags,$null,@($combo.PSObject.BaseObject,$true),$null)
try {
 $form.Show();$combo.Focus()|Out-Null;[Windows.Forms.Application]::DoEvents()
 $info=New-Object KeyFileProbe+Info;$info.Size=[Runtime.InteropServices.Marshal]::SizeOf($info)
 [KeyFileProbe]::GetComboBoxInfo($combo.Handle,[ref]$info)|Out-Null
 foreach($msg in @(0xF,0x85,0x7,0x8,0x200,0x201,0x202)) {
  [KeyFileProbe]::SendMessage($combo.Handle,$msg,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null
  $dc=[KeyFileProbe]::GetWindowDC($combo.Handle)
  try {for($y=3;$y -lt $combo.Height-3;$y++) {
   if([KeyFileProbe]::GetPixel($dc,$info.Button.Left-1,$y) -ne 0x262525){throw "Light key-file separator after message $msg at y=$y"}
  }} finally {[KeyFileProbe]::ReleaseDC($combo.Handle,$dc)|Out-Null}
 }
 $arrow=$combo.Controls.Find('KeeThemeKeyFileArrow',$false)
 if($arrow.Count -ne 1){throw 'Managed key-file arrow missing'}
 $click=$arrow[0].GetType().GetMethod('OnMouseDown',[Reflection.BindingFlags]'Instance,NonPublic')
 $mouse=New-Object Windows.Forms.MouseEventArgs([Windows.Forms.MouseButtons]::Left,1,5,5,0)
 $click.Invoke($arrow[0],@($mouse.PSObject.BaseObject))|Out-Null
 if(!$combo.DroppedDown){throw 'Managed arrow did not open original list'}
 $combo.DroppedDown=$false
 if($combo.SelectedIndex -ne 0){throw 'Rendering changed selected key file'}
 Write-Output 'PASS matching DropDownList/Flat configuration: separator stays dark; selection unchanged'
}finally{$guard.Dispose();$form.Dispose()}
