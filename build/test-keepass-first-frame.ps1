param([Parameter(Mandatory=$true)][string]$PluginPath,
      [string]$KeePassPath='C:\Program Files\KeePass Password Safe 2\KeePass.exe')
$ErrorActionPreference='Stop'
$testDir=Join-Path ([IO.Path]::GetTempPath()) ('KeeTheme-integration-'+[Guid]::NewGuid())
New-Item -ItemType Directory -Path (Join-Path $testDir 'Plugins') -Force | Out-Null
$sourceDir=Split-Path $KeePassPath
foreach($pattern in @('KeePass.exe','KeePass.exe.config','KeePass.XmlSerializers.dll','KeePassLibN*.dll')) {
    Get-ChildItem $sourceDir -Filter $pattern | Copy-Item -Destination $testDir
}
Copy-Item -LiteralPath $PluginPath -Destination (Join-Path $testDir 'Plugins\KeeTheme.dll')
$config=@'
<Configuration>
<Meta><PreferUserConfiguration>false</PreferUserConfiguration></Meta>
<Application><Start><OpenLastFile>false</OpenLastFile><CheckForUpdate>false</CheckForUpdate><CheckForUpdateConfigured>true</CheckForUpdateConfigured></Start></Application>
<Integration><LimitToSingleInstance>false</LimitToSingleInstance></Integration>
<Security><MasterKeyOnSecureDesktop>false</MasterKeyOnSecureDesktop></Security>
<Custom><Item><Key>KeeTheme.Enabled</Key><Value>True</Value></Item><Item><Key>KeeTheme.Template</Key><Value>KeeTheme.Resources.ModernDark.ini</Value></Item></Custom>
</Configuration>
'@
$config | Set-Content (Join-Path $testDir 'KeePass.config.xml') -Encoding UTF8
$config | Set-Content (Join-Path $testDir 'local.config.xml') -Encoding UTF8
& "$env:WINDIR\Microsoft.NET\Framework\v3.5\csc.exe" /nologo /target:library (('/out:')+(Join-Path $testDir 'Plugins\APaintProbe.dll')) (('/r:')+(Join-Path $testDir 'KeePass.exe')) /r:System.dll /r:System.Core.dll /r:System.Drawing.dll /r:System.Windows.Forms.dll (Join-Path $PSScriptRoot 'integration\APaintProbe.cs')
if($LASTEXITCODE -ne 0){throw 'Integration actor compilation failed'}
$exe=Join-Path $testDir 'KeePass.exe'
$process=Start-Process -FilePath $exe -ArgumentList ('-cfg-local:"'+(Join-Path $testDir 'local.config.xml')+'"') -WorkingDirectory $testDir -WindowStyle Hidden -PassThru
if(!$process.WaitForExit(30000)) {
    if($process.Path -eq $exe){Stop-Process -Id $process.Id}
    throw "Isolated KeePass timed out; artifacts: $testDir"
}
$trace=[IO.File]::ReadAllText((Join-Path $testDir 'trace.txt'))
if($trace -match 'ERROR' -or $trace -notmatch 'DONE'){throw "Integration failed; artifacts: $testDir"}
if($trace -notmatch 'Main queued opacity=1 alpha=255'){throw 'Main window opacity was not restored'}
foreach($name in @('PwEntryForm','GroupForm','KeyPromptForm')) {
    if($trace -notmatch ('WindowAdded '+$name+' visible=True opacity=1 alpha=0 nativeVisible=False')){throw "$name first-frame guard was skipped"}
    if($trace -notmatch ('FirstPaint '+$name+'/[^\r\n]*alpha=0')){throw "$name initial paint was visible"}
    if($trace -notmatch ('Shown '+$name+' opacity=1 alpha=255')){throw "$name opacity was not restored"}
}
Write-Output "PASS actual KeePass: initial dialog painting at native alpha 0; no premature native visibility; main and dialogs restored to alpha 255. Trace: $testDir\trace.txt"
Write-Output 'LIMIT: uses synthetic data and offscreen dialogs; user-visible white flash still requires manual confirmation.'
