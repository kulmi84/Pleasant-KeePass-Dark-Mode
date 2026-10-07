param([string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
[Reflection.Assembly]::LoadFrom('C:\Program Files\KeePass Password Safe 2\KeePass.exe') | Out-Null
$a=[Reflection.Assembly]::LoadFrom($PluginPath)
$f=[Reflection.BindingFlags]'Static,Public,NonPublic'
$state=$a.GetType('KeeThemePaintTrace.KeeThemePaintTraceExt').GetMethod('State',$f)
$form=New-Object Windows.Forms.Form
$form.Text='PRIVATE-DATABASE-NAME'
$box=New-Object Windows.Forms.TextBox
$box.Text='PRIVATE-SECRET-CONTENT'
$box.Name='PRIVATE-CONTROL-NAME'
$form.Controls.Add($box)
try {
    $line=$state.Invoke($null,@($box.PSObject.BaseObject))
    if($line -match 'PRIVATE'){throw 'Sensitive text or names appear in trace'}
    if($box.IsHandleCreated){throw 'Trace forces premature handle creation'}
    Write-Output ('PASS trace metadata only: '+$line)
} finally {$form.Dispose()}
