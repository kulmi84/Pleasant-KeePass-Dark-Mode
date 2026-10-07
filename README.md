# Pleasant KeePass Dark Mode — Pleasant Password Server Dark Mode

**Pleasant Password Server Dark Mode** — a dark-mode plugin for the KeePass for Pleasant Password Server Windows client (Pleasant KeePass). Adds a dark theme, modern icons and dark menus.

**Dark-Mode-Plugin für Pleasant KeePass / Pleasant Password Server** mit dunkler Oberfläche, modernen Icons und dunklen Menüs. Eigenständiger Fork von KeeTheme Modern Dark 1.1.19.
Version: **1.0.0**. Maintainer: Marcin Kulmaczewski (kulmi84).

![Pleasant KeePass Dark Mode im Pleasant-Client](docs/PleasantDark-main.png)

Unveränderte Aufnahme, vom Nutzer als Projektvorschau bereitgestellt.

## Ziel und Stand

Zielkonfiguration laut Nutzer-Screenshots: KeePass 2.54 (64-Bit), Pleasant Password Server Plugin 9.2.0.0.
Der Build wurde erfolgreich gegen die lokal installierte Pleasant-KeePass.exe geprüft.
Der Nutzer hat am 7. Oktober 2026 bestätigt, dass das Theme im Pleasant-Client läuft. Einzelne Pleasant-spezifische Dialoge sind noch nicht systematisch geprüft.
Die vorhandenen Modern-Dark-Funktionen sind übernommen.

## Änderungen gegenüber Modern Dark 1.1.19

- Build und Visual-Studio-Projekt verwenden standardmäßig die Pleasant-KeePass.exe.
- Ältere PwUuid-API: Vergleich mit PwUuid.Zero statt der nicht vorhandenen IsZero-Eigenschaft. Benutzerdefinierte Icons bleiben dadurch ausgenommen.
- Die neuere lokalisierte Ressource MoreCommands wird nur verwendet, wenn die API sie bereitstellt.
- Eigenständiges Projekt Pleasant KeePass Dark Mode mit Version 1.0.0.

Assemblyname, Plugin-Klasse und Dateiname bleiben KeeTheme, damit KeePass das Plugin laden kann.
Dieser Fork ersetzt im Pleasant-Client die bestehende KeeTheme.dll; beide Varianten dürfen dort nicht gleichzeitig installiert werden.

[**Plugin-ZIP herunterladen / Download dark mode plugin**](https://github.com/kulmi84/Pleasant-KeePass-Dark-Mode/releases/latest)

Das Release-ZIP enthält das installierbare Plugin **KeeTheme.dll**, README und Lizenz. Kein eigener Client erforderlich.

## Automatische Installation unter Windows

ZIP von diesem Release herunterladen und vollstaendig entpacken. **PowerShell als Administrator** oeffnen und im entpackten Ordner ausfuehren:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-PleasantDarkMode.ps1
```

Der Installer findet den Pleasant-Client in den Standardordnern, prueft die SHA-256-Pruefsumme der DLL und verlangt, dass der Client geschlossen ist. Vorhandene `KeeTheme.dll`/`KeeTheme.plgx` werden ausserhalb des Plugins-Ordners unter `KeeTheme-backups` gesichert. Danach wird die neue DLL installiert und gezielt mit `Unblock-File` freigegeben. Bei einem Installationsfehler werden vorhandene Plugin-Dateien wiederhergestellt.

Abweichender Installationsordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-PleasantDarkMode.ps1 -InstallDirectory 'D:\Pleasant\KeePass'
```

Mit `-WhatIf` laesst sich der geplante Vorgang ohne Installation pruefen. `ExecutionPolicy Bypass` gilt nur fuer diesen PowerShell-Aufruf; die dauerhafte Einstellung wird nicht geaendert. Eine zentral vorgegebene Unternehmensrichtlinie kann die Skriptausfuehrung weiterhin verhindern. Dann die manuelle Installation verwenden.

**English:** Extract the release ZIP, close Pleasant KeePass, and run the command above in an administrator PowerShell window. The installer verifies the DLL hash, backs up existing theme plugins, installs the DLL and unblocks that DLL only.

## Installation (manuell)

1. Pleasant KeePass schließen und die bestehende KeeTheme.dll bzw. KeeTheme.plgx sichern.
2. Die bisherigen KeeTheme-Plugin-Dateien aus dem Pleasant-Plugins-Ordner nehmen.
3. Vor dem Entpacken: Rechtsklick auf das heruntergeladene ZIP → **Eigenschaften → Zulassen → Übernehmen** (falls angezeigt). Dann Release-ZIP entpacken und die enthaltene `KeeTheme.dll` in `C:\Program Files (x86)\Pleasant Solutions\KeePass for Pleasant Password Server\Plugins` kopieren.
4. Pleasant KeePass starten und unter **Extras → Optionen → KeeTheme** das Theme **Modern Dark** aktivieren.
5. Hauptfenster, Password-Server-Menü, Anmeldedialog, Gruppen-/Eintragsdialoge und Theme-Umschaltung prüfen.

Die Konfigurationsschlüssel bleiben KeeTheme.* und übernehmen gegebenenfalls vorhandene Theme-Einstellungen.
WebView2-Inhalte und speziell gezeichnete Pleasant-Komponenten benötigen eine eigene Prüfung.

## Windows blockiert das Plugin (0x80131515)

Falls KeePass das Plugin als inkompatibel meldet und in den Details **0x80131515**, „Vorgang wird nicht unterstützt“ oder eine „Netzwerkadresse“ nennt, kann die Windows-Internetmarkierung das Laden der DLL verhindern. Auf einem weiteren Rechner wurde der Fehler durch Freigeben der DLL behoben.

Pleasant KeePass schließen. Rechtsklick auf die installierte `KeeTheme.dll` → **Eigenschaften → Zulassen → Übernehmen**, dann KeePass neu starten. Alternativ PowerShell als Administrator öffnen:

```powershell
Unblock-File -LiteralPath 'C:\Program Files (x86)\Pleasant Solutions\KeePass for Pleasant Password Server\Plugins\KeeTheme.dll'
```

**English:** Before extracting the downloaded ZIP, open Properties, select **Unblock**, and Apply (if shown). If error **0x80131515** occurs after installation, close KeePass and unblock the installed `KeeTheme.dll`, then restart.

[Microsoft: .NET Framework loading of assemblies from remote sources](https://learn.microsoft.com/en-us/dotnet/framework/configure-apps/file-schema/runtime/loadfromremotesources-element).

## Build

In **Windows PowerShell 5.1** aus diesem Projektordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build\build-local.ps1 -OutputPath "$PWD\dist\KeeTheme.dll"
```

Ein abweichender Clientpfad kann mit `-KeePassPath` angegeben werden.
Der manuelle Ressourcenbuild benötigt Windows PowerShell 5.1; PowerShell 7 unterstützt hier die binär serialisierten ResX-Ressourcen nicht.
Die übernommenen Prüfskripte und `docs/ModernDark.md` dokumentieren den ursprünglichen KeePass-Fork und sind noch keine Pleasant-Testnachweise.

## Herkunft und Lizenz

Basis: [kulmi84/KeeTheme](https://github.com/kulmi84/KeeTheme), Modern Dark 1.1.19.
Ursprüngliches KeeTheme: [xatupal/KeeTheme](https://github.com/xatupal/KeeTheme), Krzysztof Łaputa.
Lizenz: [MIT](LICENSE). Quellenhinweise für KeePass-Grafiken stehen in `docs/ModernDark.md`.
Dies ist ein unabhängiger Theme-Fork, kein offizielles Produkt von Pleasant Solutions.