param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class CalendarProbe {
 [DllImport("uxtheme.dll")] public static extern IntPtr GetWindowTheme(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,int msg,IntPtr w,IntPtr l);
}
'@
$calendar=New-Object Windows.Forms.MonthCalendar
try {
 $calendar.SetDate([DateTime]'2026-10-07')
 $handle=$calendar.Handle
 $method=$assembly.GetType('KeeTheme.KeeTheme').GetMethod('ApplyModernCalendarColors',[Reflection.BindingFlags]'Static,NonPublic')
 $method.Invoke($null,@($handle)) | Out-Null
 if([CalendarProbe]::GetWindowTheme($handle) -ne [IntPtr]::Zero){throw 'Calendar visual style still overrides custom colors'}
 $expected=@(0x262525,0xF1F1F1,0x302D2D,0xF1F1F1,0x262525,0xBEBEBE)
 for($i=0;$i -lt 6;$i++) {
  if([CalendarProbe]::SendMessage($handle,0x100B,[IntPtr]$i,[IntPtr]::Zero).ToInt32() -ne $expected[$i]){throw "Wrong calendar color $i"}
 }
 if($calendar.SelectionStart -ne [DateTime]'2026-10-07'){throw 'Theming changed selected date'}
 Write-Output 'PASS native calendar: visual-style override removed, six dark colors applied, selected date preserved'
} finally {$calendar.Dispose()}
