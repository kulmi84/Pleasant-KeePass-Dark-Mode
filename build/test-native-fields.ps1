param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class PaintProbe {
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left,Top,Right,Bottom; }
 [StructLayout(LayoutKind.Sequential)] public struct Info { public int Size; public Rect Item,Button; public int State; public IntPtr Combo,Edit,List; }
 [DllImport("user32.dll")] public static extern bool GetComboBoxInfo(IntPtr h,ref Info i);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
 [DllImport("gdi32.dll")] public static extern IntPtr CreateCompatibleDC(IntPtr dc);
 [DllImport("gdi32.dll")] public static extern int GetBkColor(IntPtr dc);
 [DllImport("gdi32.dll")] public static extern bool DeleteDC(IntPtr dc);
 [DllImport("user32.dll")] public static extern IntPtr GetWindowDC(IntPtr h);
 [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h,IntPtr dc);
 [DllImport("gdi32.dll")] public static extern int GetPixel(IntPtr dc,int x,int y);
}
"@
$t=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator+SearchBorderWindow')
$form=New-Object Windows.Forms.Form
$form.StartPosition='Manual';$form.Location=New-Object Drawing.Point(50,50)
$combo=New-Object Windows.Forms.ComboBox;$form.Controls.Add($combo)
$decorator=[Activator]::CreateInstance($t,$f,$null,@($combo.PSObject.BaseObject),$null)
$dc=[PaintProbe]::CreateCompatibleDC([IntPtr]::Zero)
try {
 foreach($enabled in @($true,$false,$true)) {
  $form.Enabled=$enabled
  foreach($msg in @(0x133,0x138)) {
   $brush=[PaintProbe]::SendMessage($combo.Handle,$msg,$dc,[IntPtr]::Zero)
   if($brush -eq [IntPtr]::Zero -or [PaintProbe]::GetBkColor($dc) -ne 0x262525){throw 'Combo child background became light'}
  }
 }
} finally {[PaintProbe]::DeleteDC($dc)|Out-Null;$decorator.Dispose()}
$combo.Enabled=$true
$decorator=[Activator]::CreateInstance($t,$f,$null,@($combo.PSObject.BaseObject,$true),$null)
$form.Show();$combo.Focus()|Out-Null;[Windows.Forms.Application]::DoEvents()
try {
 foreach($msg in @(0x200,0x201,0x202,0x7,0x8,0x100,0x101)) {
  [PaintProbe]::SendMessage($combo.Handle,$msg,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null
  $dc=[PaintProbe]::GetWindowDC($combo.Handle)
  try {if([PaintProbe]::GetPixel($dc,$combo.Width-7,4) -ne 0x262525){throw "Combo button became light after message $msg"}}
  finally {[PaintProbe]::ReleaseDC($combo.Handle,$dc)|Out-Null}
 }
 $info=New-Object PaintProbe+Info;$info.Size=[Runtime.InteropServices.Marshal]::SizeOf($info)
 [PaintProbe]::GetComboBoxInfo($combo.Handle,[ref]$info)|Out-Null
 $rect=New-Object PaintProbe+Rect;[PaintProbe]::GetWindowRect($info.Edit,[ref]$rect)|Out-Null
 foreach($msg in @(0xF,0x85,0x7,0x8,0x201,0x202)) {
  [PaintProbe]::SendMessage($info.Edit,$msg,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null
  $dc=[PaintProbe]::GetWindowDC($info.Edit)
  try {if([PaintProbe]::GetPixel($dc,$rect.Right-$rect.Left-1,2) -ne 0x262525){throw "Inner combo edit edge light after $msg"}}
  finally {[PaintProbe]::ReleaseDC($info.Edit,$dc)|Out-Null}
 }
} finally {$decorator.Dispose()}
$edit=New-Object Windows.Forms.TextBox;$edit.Location=New-Object Drawing.Point(0,40);$form.Controls.Add($edit)
$decorator=[Activator]::CreateInstance($t,$f,$null,@($edit.PSObject.BaseObject,$true),$null)
$form.Show();[Windows.Forms.Application]::DoEvents()
try {
 for($i=0;$i -lt 20;$i++) {
  [PaintProbe]::SendMessage($edit.Handle,0x85,[IntPtr]1,[IntPtr]::Zero)|Out-Null
  $dc=[PaintProbe]::GetWindowDC($edit.Handle)
  try {
   $pixel=[PaintProbe]::GetPixel($dc,0,0)
   if($pixel -ne 0x414141 -and $pixel -ne 0x8A6538){throw ('Native frame resurfaced: '+$pixel)}
  } finally {[PaintProbe]::ReleaseDC($edit.Handle,$dc)|Out-Null}
 }
} finally {$decorator.Dispose();$form.Dispose()}
'PASS modal/disabled ComboBox child colors and repeated native frame repaint'

