param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing @"
using System; using System.Windows.Forms; using System.Runtime.InteropServices;
public class NativePaintTextBox : TextBox {
 public int Frames;
 protected override void WndProc(ref Message m) { if(m.Msg==0x85) Frames++; base.WndProc(ref m); }
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
}
"@
$a=[Reflection.Assembly]::LoadFrom($PluginPath);$f=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$t=$a.GetType('KeeTheme.Decorators.CenteredSearchDecorator+SearchBorderWindow')
foreach($scrolling in @($false,$true)) {
 $box=New-Object NativePaintTextBox;$box.Multiline=$scrolling;if($scrolling){$box.ScrollBars='Vertical'}
 $d=[Activator]::CreateInstance($t,$f,$null,@($box.PSObject.BaseObject,$true),$null)
 try {
  $box.Frames=0;[NativePaintTextBox]::SendMessage($box.Handle,0x85,[IntPtr]1,[IntPtr]::Zero)|Out-Null
  if($scrolling -and $box.Frames -ne 1){throw 'Native scrollbar paint suppressed'}
  if(!$scrolling -and $box.Frames -ne 0){throw 'Single-line white frame allowed'}
 } finally {$d.Dispose();$box.Dispose()}
}
if($a.GetType('KeeTheme.KeeTheme').GetMethod('RefreshInitialFrames',$f)){throw 'Forced dialog repaint remains'}
if($a.GetType('KeeTheme.Decorators.RichTextBoxNativeWindow').GetProperty('ModernScrollBars',$f)){throw 'Scrollbar overlay remains'}
'PASS multiline native frame forwarding, single-line frame protection, removed forced redraw and scrollbar overlay'
