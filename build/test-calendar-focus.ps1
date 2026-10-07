param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
$flags=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class DateFocusProbe {
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
 [DllImport("user32.dll")] public static extern IntPtr GetWindowDC(IntPtr h);
 [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h,IntPtr d);
 [DllImport("gdi32.dll")] public static extern int GetPixel(IntPtr d,int x,int y);
}
'@
$form=New-Object Windows.Forms.Form
$picker=New-Object Windows.Forms.DateTimePicker
$picker.Format='Custom';$picker.CustomFormat='dd.MM.yyyy HH:mm:ss';$picker.Width=280
$picker.Value=[DateTime]'2026-10-07'
$form.Controls.Add($picker)
$type=$assembly.GetType('KeeTheme.Decorators.CenteredSearchDecorator+SearchBorderWindow')
$guard=[Activator]::CreateInstance($type,$flags,$null,@($picker.PSObject.BaseObject,$true),$null)
try {
 $form.Show();$picker.Focus() | Out-Null;[Windows.Forms.Application]::DoEvents()
 foreach($msg in @(0xF,0x201,0x202,0x100,0x101)) {
  [DateFocusProbe]::SendMessage($picker.Handle,$msg,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
  $dc=[DateFocusProbe]::GetWindowDC($picker.Handle)
  try {if([DateFocusProbe]::GetPixel($dc,3,3) -ne 0x262525){throw "Focused date field light at message $msg"}}
  finally {[DateFocusProbe]::ReleaseDC($picker.Handle,$dc) | Out-Null}
 }
 $calendar=New-Object Windows.Forms.MonthCalendar
 $form.Controls.Add($calendar);$calendar.Top=50
 $assembly.GetType('KeeTheme.KeeTheme').GetMethod('ApplyModernCalendarColors',$flags).Invoke($null,@($calendar.Handle)) | Out-Null
 $borderType=$assembly.GetType('KeeTheme.Decorators.CenteredSearchDecorator+CalendarBorderWindow')
 $border=[Activator]::CreateInstance($borderType,$flags,$null,@($calendar.Handle),$null)
 try {
  [DateFocusProbe]::SendMessage($calendar.Handle,0x85,[IntPtr]1,[IntPtr]::Zero) | Out-Null
  $dc=[DateFocusProbe]::GetWindowDC($calendar.Handle)
  try {if([DateFocusProbe]::GetPixel($dc,0,0) -ne 0x414141){throw 'Calendar border is not gray'}}
  finally {[DateFocusProbe]::ReleaseDC($calendar.Handle,$dc) | Out-Null}
 } finally {$border.Dispose();$calendar.Dispose()}
 Write-Output 'PASS focused date field stays dark after mouse/key paint; native calendar border gray'
} finally {$guard.Dispose();$form.Dispose()}
