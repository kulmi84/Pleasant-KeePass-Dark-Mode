param([string]$PluginPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$assembly = [Reflection.Assembly]::LoadFrom($PluginPath)
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class TitlebarLifecycleProbe : Form {
    public int StyleChanges, ClientResizes;
    public TitlebarLifecycleProbe() {
        ShowInTaskbar = false;
        StartPosition = FormStartPosition.Manual;
        Location = new Point(-3000, -3000);
        Controls.Add(new TextBox { Name = "probe", Text = "Synthetic data" });
    }
    protected override void WndProc(ref Message m) {
        if (m.Msg == 0x007D) ++StyleChanges;
        base.WndProc(ref m);
    }
    protected override void OnClientSizeChanged(EventArgs e) {
        ++ClientResizes;
        base.OnClientSizeChanged(e);
    }
    [DllImport("dwmapi.dll")]
    public static extern int DwmGetWindowAttribute(IntPtr h, int a, out int v, int s);
}
'@
$flags = [Reflection.BindingFlags]'Public,NonPublic,Static'
$method = $assembly.GetType('KeeTheme.Win10ThemeMonitor').GetMethod('UseImmersiveDarkMode', $flags, $null, @([Windows.Forms.Form],[bool]), $null)
$form = New-Object TitlebarLifecycleProbe
try {
    $form.Show()
    [Windows.Forms.Application]::DoEvents()
    $originalHandle = $form.Handle
    $originalStyle = $form.FormBorderStyle
    $originalBounds = $form.Bounds
    $form.StyleChanges = 0
    $form.ClientResizes = 0
    foreach ($enabled in @($true, $true, $false, $true)) {
        $method.Invoke($null, @($form.PSObject.BaseObject, $enabled)) | Out-Null
    }
    $dark = 0
    $result = [TitlebarLifecycleProbe]::DwmGetWindowAttribute($form.Handle, 20, [ref]$dark, 4)
    Write-Output "Titlebar updates: style changes=$($form.StyleChanges), client resizes=$($form.ClientResizes), DWM result=$result, dark=$dark"
    if ($form.StyleChanges -ne 0 -or $form.ClientResizes -ne 0) { throw 'Titlebar update changes window structure and triggers client relayout' }
    if ($form.Handle -ne $originalHandle -or $form.FormBorderStyle -ne $originalStyle -or $form.Bounds -ne $originalBounds) { throw 'Window geometry or handle changed' }
    if ($result -eq 0 -and $dark -ne 1) { throw 'Dark titlebar was not enabled' }
    Write-Output 'PASS repeated titlebar updates preserve window structure, bounds and handle'
} finally { $form.Dispose() }
