param([string]$PluginPath,[string]$OutputPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Application]::EnableVisualStyles()
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$assembly=[Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type @"
using System; using System.Runtime.InteropServices; using System.Text;
public static class PopupProbe {
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left,Top,Right,Bottom; }
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern IntPtr GetWindowDC(IntPtr h);
 [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h,IntPtr d);
 [DllImport("gdi32.dll")] public static extern int GetPixel(IntPtr h,int x,int y);
 [DllImport("user32.dll")] public static extern IntPtr GetParent(IntPtr h);
 [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr h,int i);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern int GetClassName(IntPtr h,StringBuilder text,int n);
}
"@
$form=New-Object Windows.Forms.Form
$form.TopMost=$true; $form.Text='Synthetic calendar preview';$form.StartPosition='CenterScreen'
$picker=New-Object Windows.Forms.DateTimePicker
$picker.Value=[DateTime]'2026-10-07';$picker.Width=260;$form.Controls.Add($picker)
$flags=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$type=$assembly.GetType('KeeTheme.Decorators.CenteredSearchDecorator+SearchBorderWindow')
$guard=[Activator]::CreateInstance($type,$flags,$null,@($picker.PSObject.BaseObject,$true),$null)
$form.Show();$picker.Focus() | Out-Null
[PopupProbe]::SendMessage($picker.Handle,0x100,[IntPtr]0x73,[IntPtr]::Zero)|Out-Null
[Windows.Forms.Application]::DoEvents()
$h=[PopupProbe]::SendMessage($picker.Handle,0x1008,[IntPtr]::Zero,[IntPtr]::Zero)
try {
 if($h -eq [IntPtr]::Zero){throw 'No actual date-picker popup'}
 $assembly.GetType('KeeTheme.KeeTheme').GetMethod('ApplyModernCalendarColors',$flags).Invoke($null,@($h))|Out-Null
 $popup=[PopupProbe]::GetParent($h)
 [PopupProbe]::SendMessage($popup,0xF,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null
 [PopupProbe]::SendMessage($h,0xF,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null
 [Windows.Forms.Application]::DoEvents()
 $dc=[PopupProbe]::GetWindowDC($popup)
 try {if([PopupProbe]::GetPixel($dc,0,0) -ne 0x414141){throw 'Actual DropDown popup border is not gray'}; Write-Output 'PASS actual DateTimePicker DropDown border is gray'} finally {[PopupProbe]::ReleaseDC($popup,$dc)|Out-Null}
 $rect=New-Object PopupProbe+Rect
 [PopupProbe]::GetWindowRect($popup,[ref]$rect)|Out-Null
 Start-Sleep -Milliseconds 250
 [Windows.Forms.Application]::DoEvents()
 $bitmap=New-Object Drawing.Bitmap(($rect.Right-$rect.Left),($rect.Bottom-$rect.Top))
 $graphics=[Drawing.Graphics]::FromImage($bitmap)
 $graphics.CopyFromScreen($rect.Left,$rect.Top,0,0,$bitmap.Size)
 if(!$OutputPath){$OutputPath=Join-Path ([IO.Path]::GetTempPath()) ('KeeTheme-calendar-'+[Guid]::NewGuid()+'.png')}
 $bitmap.Save($OutputPath)
 Write-Output ('Synthetic preview: '+$OutputPath)
 $graphics.Dispose();$bitmap.Dispose()
 for($i=0;$i -lt 3 -and $h -ne [IntPtr]::Zero;$i++) {
  $name=New-Object Text.StringBuilder(256);[PopupProbe]::GetClassName($h,$name,256)|Out-Null
  Write-Output ($name.ToString()+' handle='+$h+' style='+[PopupProbe]::GetWindowLong($h,-16).ToString('X8')+' ex='+[PopupProbe]::GetWindowLong($h,-20).ToString('X8'))
  $h=[PopupProbe]::GetParent($h)
 }
} finally {$guard.Dispose();$form.Close();$form.Dispose()}
