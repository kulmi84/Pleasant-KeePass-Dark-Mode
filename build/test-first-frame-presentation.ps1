param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
public class FirstFramePaintProbe : Control {
    public int WhitePresentations;
    public int Paints;
    public double FirstPaintOpacity = -1;
    [DllImport("user32.dll")] static extern bool GetLayeredWindowAttributes(IntPtr h, out uint key, out byte alpha, out uint flags);
    [DllImport("gdi32.dll")] static extern bool GdiFlush();
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("dwmapi.dll")] public static extern int DwmFlush();
    [DllImport("user32.dll")] static extern IntPtr GetDC(IntPtr w);
    [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr w, IntPtr d);
    [DllImport("gdi32.dll")] static extern uint GetPixel(IntPtr d, int x, int y);
    public int ScreenRed() {
        Point point = PointToScreen(new Point(30,30));
        IntPtr dc = GetDC(IntPtr.Zero);
        try { return (int)(GetPixel(dc, point.X, point.Y) & 255); }
        finally { ReleaseDC(IntPtr.Zero, dc); }
    }
    protected override void WndProc(ref Message message) {
        base.WndProc(ref message);
        if (message.Msg != 15) return;
        if (Paints == 0) { uint key, flags; byte alpha; FirstPaintOpacity = GetLayeredWindowAttributes(FindForm().Handle, out key, out alpha, out flags) ? alpha / 255.0 : 1; }
        ++Paints;
        using (Graphics graphics = Graphics.FromHwnd(Handle)) graphics.Clear(Color.White);
        GdiFlush(); DwmFlush();
        Thread.Sleep(180);
        if (ScreenRed() > 240) ++WhitePresentations;
        using (Graphics graphics = Graphics.FromHwnd(Handle)) graphics.Clear(Color.FromArgb(30,30,30));
        GdiFlush(); DwmFlush();
    }
}
'@
[FirstFramePaintProbe]::SetProcessDPIAware() | Out-Null
$flags=[Reflection.BindingFlags]'Public,NonPublic,Instance,Static'
$type=$a.GetType('KeeTheme.Decorators.FirstFrameDecorator')
$owner=New-Object Windows.Forms.Form
$owner.Text='KeeTheme synthetic first-frame test'
$owner.ShowInTaskbar=$false
$owner.TopMost=$true
$owner.StartPosition='CenterScreen'
$owner.Size=New-Object Drawing.Size(360,240)
$owner.BackColor=[Drawing.Color]::FromArgb(0,70,70)
$owner.Show()
[Windows.Forms.Application]::DoEvents()
$readings=@()
$paintOpacity=@()
try {
    foreach($guarded in @($false,$true)) {
        $form=New-Object Windows.Forms.Form
        $form.ShowInTaskbar=$false
        $form.StartPosition='Manual'
        $form.Location=New-Object Drawing.Point(($owner.Left+40),($owner.Top+40))
        $form.Size=New-Object Drawing.Size(240,140)
        $child=New-Object FirstFramePaintProbe
        $child.Dock='Fill'
        $form.Controls.Add($child)
        $decorator=$null
        try {
            # KeePass WindowAdded occurs after handle creation; match that lifecycle.
            $null=$form.Handle
            if($guarded){$decorator=[Activator]::CreateInstance($type,$flags,$null,@($form.PSObject.BaseObject),$null)}
            $form.Show($owner)
            [Windows.Forms.Application]::DoEvents()
            [FirstFramePaintProbe]::DwmFlush() | Out-Null
            $readings+=,$child.WhitePresentations
            $paintOpacity+=,$child.FirstPaintOpacity
            Write-Output "First frame: guarded=$guarded paints=$($child.Paints) first paint opacity=$($child.FirstPaintOpacity) white presentations=$($child.WhitePresentations) final opacity=$($form.Opacity) screen red=$($child.ScreenRed())"
            if($form.Opacity -ne 1){throw 'Original opacity not restored'}
            if($guarded -and ($child.Paints -eq 0 -or $child.ScreenRed() -gt 60)){throw 'Complete dark frame was not presented'}
        } finally { if($decorator){$decorator.Dispose()};$form.Dispose();[Windows.Forms.Application]::DoEvents() }
    }
    if($paintOpacity[0] -ne 1 -or $paintOpacity[1] -ne 0){throw 'First native paint was not kept off screen by the guard'}
    if($readings[1] -ne 0){throw 'Guard still presented a white initial child paint'}
    Write-Output 'PASS first native paint is off screen only with guard; completed dark frame is then presented'
    Write-Output 'LIMIT: this synthetic test does not reproduce the KeePass recording; live KeePass comparison remains required'
} finally { $owner.Dispose() }

$unshown=New-Object Windows.Forms.Form
$unshown.Opacity=0.75
$guard=[Activator]::CreateInstance($type,$flags,$null,@($unshown.PSObject.BaseObject),$null)
$guard.Dispose()
if($unshown.Opacity -ne 0.75){throw 'Cancelled initial presentation did not restore custom opacity'}
$unshown.Dispose()
Write-Output 'PASS original custom opacity restored on cancellation'
