# Pleasant Dark Mode — Pleasant Password Server Dark Mode

**Pleasant Password Server Dark Mode** — a dark-mode plugin for the KeePass for Pleasant Password Server Windows client (Pleasant KeePass). Adds a dark theme, modern icons and dark menus.

**Dark-Mode-Plugin für Pleasant KeePass / Pleasant Password Server** mit dunkler Oberfläche, modernen Icons und dunklen Menüs. Eigenständiger Fork von KeeTheme Modern Dark 1.1.19.
Version: **1.0.0**. Maintainer: Marcin Kulmaczewski (kulmi84).

![Pleasant Dark Mode im Pleasant-Client](docs/PleasantDark-main.png)

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
- Eigenständiges Projekt Pleasant Dark Mode mit Version 1.0.0.

Assemblyname, Plugin-Klasse und Dateiname bleiben KeeTheme, damit KeePass das Plugin laden kann.
Dieser Fork ersetzt im Pleasant-Client die bestehende KeeTheme.dll; beide Varianten dürfen dort nicht gleichzeitig installiert werden.

[**Plugin-ZIP herunterladen / Download dark mode plugin**](https://github.com/kulmi84/Pleasant-Dark-Mode/releases/latest)

Das Release-ZIP enthält das installierbare Plugin **KeeTheme.dll**, README und Lizenz. Kein eigener Client erforderlich.

## Installation

1. Pleasant KeePass schließen und die bestehende KeeTheme.dll bzw. KeeTheme.plgx sichern.
2. Die bisherigen KeeTheme-Plugin-Dateien aus dem Pleasant-Plugins-Ordner nehmen.
3. Release-ZIP entpacken und die enthaltene `KeeTheme.dll` in `C:\Program Files (x86)\Pleasant Solutions\KeePass for Pleasant Password Server\Plugins` kopieren.
4. Pleasant KeePass starten und unter **Extras → Optionen → KeeTheme** das Theme **Modern Dark** aktivieren.
5. Hauptfenster, Password-Server-Menü, Anmeldedialog, Gruppen-/Eintragsdialoge und Theme-Umschaltung prüfen.

Die Konfigurationsschlüssel bleiben KeeTheme.* und übernehmen gegebenenfalls vorhandene Theme-Einstellungen.
WebView2-Inhalte und speziell gezeichnete Pleasant-Komponenten benötigen eine eigene Prüfung.

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