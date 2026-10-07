param([string]$PluginPath, [string]$PreviewPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System; using System.Drawing; using System.Threading;
using System.Windows.Forms; using System.Runtime.InteropServices;
public sealed class SearchPaintProbe : NativeWindow {
 public int ExposedWhite, BufferedPaints;
 [DllImport("user32.dll")] static extern IntPtr GetWindowDC(IntPtr h);
 [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr h,IntPtr d);
 [DllImport("gdi32.dll")] static extern uint GetPixel(IntPtr d,int x,int y);
 [DllImport("dwmapi.dll")] static extern int DwmFlush();
 public SearchPaintProbe(IntPtr handle){AssignHandle(handle);}
 protected override void WndProc(ref Message m){
  base.WndProc(ref m);
  if(m.Msg!=15 && m.Msg!=0x318)return;
  bool buffered=m.Msg==0x318;
  IntPtr dc=buffered?m.WParam:GetWindowDC(m.HWnd);
  using(Graphics g=Graphics.FromHdc(dc))using(Pen p=new Pen(Color.White,2))g.DrawRectangle(p,1,1,100,18);
  DwmFlush(); Thread.Sleep(80);
  IntPtr screen=GetWindowDC(m.HWnd);
  if((GetPixel(screen,1,1)&255)>230)++ExposedWhite;
  ReleaseDC(m.HWnd,screen);
  if(buffered)++BufferedPaints;else ReleaseDC(m.HWnd,dc);
 }
 public static void Hover(Control combo){
  var flags=System.Reflection.BindingFlags.Instance|System.Reflection.BindingFlags.NonPublic;
  typeof(Control).GetMethod("OnMouseEnter",flags).Invoke(combo,new object[]{EventArgs.Empty});
 }
 public static uint Pixel(Control c,int x,int y){IntPtr dc=GetWindowDC(c.Handle);try{return GetPixel(dc,x,y);}finally{ReleaseDC(c.Handle,dc);}}
}
'@
$form=New-Object Windows.Forms.Form
$form.StartPosition='Manual';$form.Location=New-Object Drawing.Point(80,80)
$form.Size=New-Object Drawing.Size(700,180)
$strip=New-Object Windows.Forms.ToolStrip
$search=New-Object Windows.Forms.ToolStripComboBox
$search.Name='m_tbQuickFind';$search.ComboBox.BackColor=[Drawing.Color]::FromArgb(37,37,38)
$search.ComboBox.ForeColor=[Drawing.Color]::White
$search.Items.AddRange(@('Demo one','Demo two'))
$search.Text='Demo search'
$strip.Items.Add($search)|Out-Null;$form.Controls.Add($strip)
$form.Show();[Windows.Forms.Application]::DoEvents()
$probe=New-Object SearchPaintProbe($search.ComboBox.Handle)
$decorator=$null
try {
 $search.ComboBox.Refresh()
 if($probe.ExposedWhite -eq 0){throw 'Control case did not expose injected native white frame'}
 $probe.ExposedWhite=0
 $type=$assembly.GetType('KeeTheme.Decorators.CenteredSearchDecorator')
 $flags=[Reflection.BindingFlags]'Public,NonPublic,Instance'
 $decorator=[Activator]::CreateInstance($type,$flags,$null,@($strip.PSObject.BaseObject,$search.PSObject.BaseObject),$null)
 $search.ComboBox.Refresh()
 # Remove the deliberately white control-case frame before measuring subsequent presentations.
 $probe.ExposedWhite=0
 $search.ComboBox.Focus()|Out-Null
 [SearchPaintProbe]::Hover($search.ComboBox)
 $search.ComboBox.Refresh()
 $form.Focus()|Out-Null
 $search.ComboBox.Refresh()
 if($probe.ExposedWhite -ne 0 -or $probe.BufferedPaints -eq 0){throw 'Native intermediate search frame was presented'}
 if([SearchPaintProbe]::Pixel($search.ComboBox,0,0) -ne 0x414141){throw 'Search outer frame is not dark gray'}
 if($search.Text -ne 'Demo search'){throw 'Search text changed'}
 $search.ComboBox.DroppedDown=$true;[Windows.Forms.Application]::DoEvents()
 if(!$search.ComboBox.DroppedDown){throw 'History dropdown failed'}
 $search.ComboBox.SelectedIndex=1;$search.ComboBox.DroppedDown=$false
 if($search.Text -ne 'Demo two'){throw 'History selection changed'}
 $form.Enabled=$false;$search.ComboBox.Refresh();$form.Enabled=$true
 $probe.ReleaseHandle()
 $search.ComboBox.Refresh()
 if($PreviewPath){
  $bitmap=New-Object Drawing.Bitmap($strip.Width,$strip.Height)
  $graphics=[Drawing.Graphics]::FromImage($bitmap)
  try {$graphics.CopyFromScreen($strip.PointToScreen([Drawing.Point]::Empty),[Drawing.Point]::Empty,$strip.Size);$bitmap.Save($PreviewPath)}
  finally {$graphics.Dispose();$bitmap.Dispose()}
 }
 Write-Output 'PASS: native white-frame control case detected; buffered search exposes no intermediate white border; hover/focus/text/history/disable preserved'
} finally {if($decorator){$decorator.Dispose()};$probe.ReleaseHandle();$form.Dispose()}
