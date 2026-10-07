# KeeTheme Modern Dark – Dokumentation

KeePass selbst wird nicht verändert.

## Release 1.1.19: Einheitliche Extras-Icons

Der Nutzer bestätigt die neuen S/W-Symbole für Passwortgenerator, Passwortliste, TAN-Assistent, Trigger, Plugins und Optionen. Zusatzplugin-Logos im Extras-Menü werden in Graustufen gezeichnet, ohne die Originalbilder zu verändern. Der Modern-Dark-Menühaken ist neutral. Andere Themes behalten ihre bisherige Darstellung. Menü-, Theme-/Icon- und Suchfeld-Prüfungen bestehen. Die bestätigte Suchfeld-Korrektur aus 1.1.18 bleibt enthalten.

## Release 1.1.18: Fertiger Modern-Dark-Stand

Version 1.1.18 veröffentlicht den bestätigten stabilen Modern-Dark-Stand mit der zusätzlichen Suchfeld-Korrektur unten. Die Plugin-Metadaten nennen nun **KeeTheme Modern Dark** sowie **Marcin Kulmaczewski (kulmi84)** als Maintainer des Forks; Krzysztof Łaputa bleibt als ursprünglicher Autor von KeeTheme ausdrücklich genannt.

Der Release wurde gegen KeePass 2.61.1 gebaut. Die vorhandenen Theme-, Icon-, Dialog-, Kalender- und Schlüsseldatei-Korrekturen aus 1.1.17 bleiben unverändert.

## Release 1.1.18: Suchfeld ohne hellen Zwischenrahmen

Die neue Aufnahme zeigt einen weißen Hover-/Fokusrahmen im Suchfeld des Hauptfensters. Die bisherige Überzeichnung nach dem nativen WM_PAINT lässt diesen Zwischenstand kurz sichtbar werden. Der Suchfeld-Decorator zeichnet den nativen Client über WM_PRINTCLIENT in einen Speicherpuffer, ergänzt den dunklen Rahmen und Pfeil und zeigt erst das fertige Bild. Separates Löschen und Non-Client-Zeichnen sind dort unterdrückt. Die Änderung betrifft nur das moderne Toolbar-Suchfeld; die Schlüsseldatei und übrigen Dialogfelder verwenden ihre bisherigen Zeichenwege.

`test-search-flicker.ps1` verwendet eine echte ToolStripComboBox und einen absichtlich verlangsamten weißen Zwischenrahmen: der Kontrollfall zeigt ihn, der gepufferte Fall nicht. Hover, Fokus, Texteingabezustand, Suchverlauf-Auswahl und Aktivierung werden geprüft. Native Feld-, Schlüsseldatei-, Theme-/Icon- und Toolbar-Prüfungen bestehen ebenfalls. Eine isolierte Suchfeld-Aufnahme mit fiktiven Testdaten wurde geprüft. Der Nutzer bestätigt die Korrektur am betroffenen Rechner. 1.1.18 wird als stabiles Release mit aktualisierter ZIP veröffentlicht.

## Release 1.1.17: Bestätigte Schlüsseldatei-Korrektur

Der Nutzer bestätigt die korrigierte Pfeilfläche ohne helle Trennkante. Version 1.1.17 wird als stabiles Release mit fertiger DLL im ZIP veröffentlicht und bündelt die bisherigen Dialog-, Kalender- und Icon-Korrekturen. Direkte Aktualisierung von vorherigen Testversionen ist möglich.

Die README enthält vier aktualisierte, per Bildbearbeitung mit fiktiven Demo-Daten erstellte Ansichten: Hauptfenster, Hauptschlüssel, Eintragsdialog mit Kalender und Eintragsmenü. Private Namen, Pfade, Zugangsdaten, URLs und TOTP-Werte wurden ersetzt; PNG-Provenienz und Textmetadaten wurden entfernt. Die Ansichten sind Dokumentationsillustrationen und keine unveränderten Testaufnahmen. Private Originale und Diagnoseprotokolle bleiben außerhalb des Repositorys. Die Einschränkung der Datumssegment-Markierung bleibt bestehen.

## Testbuild 1.1.17: Eigene Pfeilfläche für die Schlüsseldatei

Das tatsächliche Nutzerprotokoll bestätigt 1.1.16, OwnerDrawFixed, Flat und DropDownList auch nach Shown. Eine spätere Rückstellung dieser Eigenschaften ist darin nicht erkennbar; die sichtbare Abweichung ist weiterhin nicht vollständig erklärt. Der native Pfeil-/Separatorbereich des Schlüsseldateifelds wird deshalb jetzt durch ein eigenes dunkles Kind-Control abgedeckt, statt ausschließlich nach nativen Zeichenmeldungen übermalt zu werden. Die Änderung ist auf m_cmbKeyFile mit aktivem modernem Feld-Decorator beschränkt.

Die Schaltfläche öffnet die originale ComboBox-Liste über DroppedDown; Tastaturbedienung und gespeicherter Dateipfad bleiben bei KeePass. Der Helfer folgt Größen- und Handle-Änderungen und wird mit dem Decorator entfernt. Der Dropdown-Test prüft die Existenz des Helfers, Öffnen der Originalliste, dunkle Trennkante und unveränderte Auswahl. Ein echter isolierter KeePass-Hauptschlüsseldialog mit langem fiktivem Pfad wurde erneut aufgenommen und geprüft. Keine private Aufnahme und kein privates Nutzerprotokoll wird veröffentlicht. Der anschließende Praxistest am betroffenen Rechner wurde positiv bestätigt; siehe Release 1.1.17 oben.

## Laufende Diagnose nach 1.1.16

Der Nutzer bestätigt die geladene Plugin-Version 1.1.16; die helle Linie bleibt dennoch bestehen. Die Vorschau im isolierten echten KeePass-Hauptschlüsseldialog zeigt bereits Ellipse und Abstand zum Pfeil. Diese Abweichung ist noch nicht erklärt. Eine kurze Windows-Assembly-Rundown-Abfrage war wegen fehlender Administratorrechte nicht möglich; es wurde kein Trace gestartet.

Das temporäre Diagnose-Zusatzplugin 1.0.3 erfasst jetzt zusätzlich DrawMode, FlatStyle und DropDownStyle von ComboBoxen sowie deren Zustand nach Shown. Es liest weiterhin weder Text noch Steuerelementnamen, Dateipfade, Einträge oder Passwörter. Die neue Datei heißt KeeTheme-ComboTrace.log; das frühere PaintTrace-Protokoll bleibt unangetastet. Die Analyse des tatsächlichen Nutzerzustands steht noch aus. Kein neuer funktionaler Build und kein neues stabiles Release wird daraus bereits als behoben dargestellt.

## Testbuild 1.1.16: Lange Pfade mit Abstand und Ellipse zeichnen

Die installierte DLL entspricht nach Versions-/Hashprüfung 1.1.15. Der Nutzer bestätigt, dass die Linie dauerhaft sichtbar bleibt. Mit einem langen fiktiven Pfad zeigt auch das Testfeld abgeschnittene Zeichen unmittelbar vor dem Pfeil. Standard-DropDownLists werden unter Modern Dark nun mit eigener Item-Zeichnung dargestellt: dunkler Hintergrund, Innenabstand und EndEllipsis statt abgeschnittener Zeichen; kein nativer Fokusrahmen innerhalb des Textbereichs. Der äußere Theme-Fokusrahmen bleibt bestehen. Ausgewählter Index und vollständiger zugrundeliegender Pfad werden nicht geändert. Bereits fremd gezeichnete ComboBoxen werden nicht übernommen; Theme-Abschaltung stellt den vorherigen DrawMode wieder her.

Der passende Dropdown-Test nutzt einen langen fiktiven Pfad und den tatsächlichen Item-Zeichner. Die lokale Bildschirmvorschau zeigt nun eine Ellipse und Abstand vor dem Pfeil. Theme-/Icon-Prüfungen bestehen. Die tatsächliche Hauptschlüsselansicht beim Nutzer bleibt zu bestätigen; kein neues öffentliches stabiles Release vor dieser Bestätigung.

## Testbuild 1.1.15: Schlüsseldatei-DropDownList korrekt berücksichtigen

Auch 1.1.14 lässt die helle Kante laut Nutzer bestehen. Die KeePass-KeyPromptForm verwendet eine DropDownList, die KeeTheme bisher im Popup-Stil darstellte. Die bisherigen Feldtests verwendeten stattdessen eine editierbare DropDown-ComboBox. Modern Dark verwendet jetzt für DropDownList den Flat-Stil; andere Themes behalten Popup. Der Edit-Kindfenster-Hook ist bei DropDownList ausgeschlossen, weil dort kein eigenständiger editierbarer Textbereich vorhanden ist.

`test-keyfile-dropdown.ps1` bildet die DropDownList/Flat-Konfiguration mit langem fiktivem Dateipfad nach und prüft die gesamte Kante vor dem Pfeil nach Fokus-, Maus- und Zeichenmeldungen sowie die unveränderte Auswahl. Der Test besteht. Eine lokale Bildschirmvorschau dieser Konfiguration wurde geprüft. Die tatsächliche Ansicht beim Nutzer ist noch zu bestätigen; das öffentliche Release bleibt bis dahin bei 1.1.13.

## Testbuild 1.1.14: Innerer Textfeldrand der Schlüsseldatei-ComboBox

Der Nutzer sieht in 1.1.13 weiterhin eine helle senkrechte Linie unmittelbar vor dem Dropdown-Pfeil. Die bisherige Prüfung deckte die Pfeilfläche ab, nicht den rechten Rand des eigenständigen nativen Edit-Kindfensters. Der neue Hook zeichnet auch dessen rechte Kante nach Fokus-, Maus- und Zeichenmeldungen dunkel. Zusätzlich wird der Zwischenraum zwischen Edit und Pfeil dunkel überzeichnet. Der Hook wird bei Handle-Zerstörung oder Theme-Abschaltung gelöst.

Der native Feldtest prüft nun zusätzlich genau die rechte Kante des Edit-Kindfensters nach dessen eigenen Meldungen. Diese Prüfung besteht mit 1.1.14. Die tatsächliche Schlüsseldatei-Ansicht am Nutzerrechner muss noch bestätigt werden; der Build bleibt zunächst ein Teststand.

## Version 1.1.13: Dropdown-Schaltflächen und Veröffentlichung

Die native ComboBox zeichnet ihren Pfeil auch bei Fokus-, Maus- und Tastaturmeldungen neu, ohne zwingend WM_PAINT auszulösen. Diese Nachzeichnungen werden jetzt ebenfalls mit dunkler Schaltfläche und grauer Trennlinie abgeschlossen, insbesondere bei der Schlüsseldatei im Hauptschlüsseldialog. Der native Feldtest prüft die Buttonfarbe nach diesen Meldungen. Theme-/Icon-Prüfungen und die echte KeePass-Integration prüfen den fertigen Build.

Der Nutzer bestätigt die Kalenderkorrektur aus 1.1.12. 1.1.13 bündelt die Änderungen seit dem vorherigen öffentlichen Release. Die README verweist auf den aktuellen Download und enthält zusätzlich eine echte Kalender-Popup-Aufnahme mit ausschließlich fiktivem Testdatum. Private Screenshots und Diagnoseprotokolle werden nicht veröffentlicht. Die bekannte Einschränkung der Datumssegment-Markierung bleibt dokumentiert; weitere Praxisbeobachtungen zum Einblenden auf mehreren Monitoren sind willkommen.

## Testbuild 1.1.12: Tatsächlicher DropDown-Rahmen und lesbare Wochentage

1.1.11 änderte den sichtbaren Rahmen beim Nutzer nicht. Die Untersuchung eines tatsächlich geöffneten DateTimePicker zeigt zwei Fenster: SysMonthCal32 liegt innerhalb eines separaten Popup-Fensters der Klasse DropDown. Der helle Außenrand gehört zum DropDown-Fenster. Jetzt wird dessen Rahmen überzeichnet; der Kalender selbst bekommt einen getrennten Paint-Hook für die Wochentage. MCM_HITTEST bestimmt die Zeilenhöhe, MCM_GETFIRSTDAYOFWEEK die Reihenfolge; die Beschriftungen stammen aus der aktuellen Kultur.

`test-calendar-popup.ps1` öffnet den echten Datumskalender eines eigenen Testfensters mit fiktivem Datum, prüft die Farbe des äußeren Popup-Rands und speichert eine Bildschirmvorschau ausschließlich dieses Test-Popups. Die Vorschau für 1.1.12 wurde visuell geprüft: graue Außenlinie, dunkler Randbereich und lesbare Wochentage. Der frühere Test eines isolierten MonthCalendar war für den sichtbaren Popup-Rahmen nicht aussagekräftig. Kontrolle am betroffenen Nutzerrechner bleibt erforderlich; Einschränkung der Datumssegment-Markierung aus 1.1.11 bleibt erhalten.

## Testbuild 1.1.11: Datumsfeld bei Fokus dunkel, Kalenderrahmen grau

Die bisherige dunkle Datumsdarstellung wurde bei ContainsFocus ausgelassen; deshalb erschien das native weiße Feld beim Anklicken. Die Nachzeichnung erfolgt jetzt auch bei Fokus und nach Maus-/Tastaturmeldungen. Sie zeigt das formatierte Datum einheitlich; die native Hervorhebung eines einzelnen Datumssegments wird dabei überdeckt. Die Datumseingabe bleibt beim nativen DateTimePicker, die Kalenderauswahl bleibt unverändert.

Ein nur während des geöffneten Kalenders angehängtes NativeWindow überzeichnet dessen hellen klassischen Rand mit dunklem Hintergrund und einer einzelnen grauen Außenlinie (#414141). CloseUp und Dispose lösen den Hook wieder. Es werden keine Fensterpositionen oder Fensterstile geändert. `test-calendar-focus.ps1` prüft fokussierte Nachzeichnungen und den grauen Rand; der Kalenderfarbtest besteht ebenfalls. Visuelle Kontrolle auf dem Nutzerrechner bleibt erforderlich.

## Testbuild 1.1.10: Dunkler Kalender und geglättetes Häkchen

Beim Öffnen des Kalender-Popups wird nur auf diesem vorübergehenden nativen Kalender das Windows-Visual-Style abgeschaltet. Mit aktivem Visual Style ignoriert der Kalender die meisten Farbvorgaben ([Microsoft](https://learn.microsoft.com/en-us/windows/win32/controls/dtm-setmccolor)). MCM_SETCOLOR setzt anschließend Panel-Hintergrund #252526, Kopf #2D2D30, Text #F1F1F1 und benachbarte Monatsdaten #BEBEBE. Kalendernavigation und Auswahl bleiben native Windows-Funktionen. Der native Test prüft deaktiviertes Visual Style, alle sechs Farbfelder und die unveränderte Datumsauswahl.

Das Checkbox-Häkchen wird als geglätteter Vektor mit abgerundeten Linien gezeichnet. Die Glättung ist auf das Häkchen beschränkt; Rahmen und Text behalten ihre Darstellung. Der Erstbildschutz aus 1.1.9 bleibt erhalten. Der Nutzer meldet für 1.1.9 einen guten ersten Eindruck; der weitere Praxistest läuft noch.

## Testbuild 1.1.9: Kein vorzeitiges Anzeigen durch Form.Opacity

Auch 1.1.8 beseitigt laut Nutzer die weißen Flächen nicht; ein Fenster blitzt zuvor auf dem anderen Bildschirm auf. Das aktuelle Protokoll bestätigt nun zwar Deckkraft 0, aber bereits native Sichtbarkeit beim Anhängen an die Dialoge. Im [WinForms-Referenzcode](https://referencesource.microsoft.com/System.Windows.Forms/winforms/Managed/System/WinForms/Form.cs.html) setzt Form.Opacity über AllowTransparency die Fensterstile neu. Während Load ist die verwaltete Visible-Eigenschaft schon true; die Aktualisierung kann deshalb vorzeitig native Sichtbarkeit herstellen.

1.1.9 setzt die temporäre Transparenz direkt mit SetWindowLong/SetLayeredWindowAttributes. Es verwendet weder Form.Opacity noch ShowWindow oder SetWindowPos; KeePass behält seine Positionierungsreihenfolge. Nach dem ersten synchronen Zeichnen wird ausschließlich das temporäre Layered-Bit entfernt. Bereits sichtbare Fenster und bereits transparente Fenster anderer Plugins bleiben ausgenommen.

Der erweiterte echte KeePass-Integrationstest prüft bei WindowAdded native Sichtbarkeit false und Alpha 0, beim ersten Zeichnen Alpha 0 und anschließend Alpha 255. Er besteht mit 1.1.9 und schlägt mit der bisherigen 1.1.8 fehl. Hauptfenster und alle drei Testdialoge beenden den Test regulär. Die Testdialoge sind weiterhin außerhalb des Bildschirms; dies ist kein visueller Beweis, dass sämtliche weißen Flächen am betroffenen Rechner verschwunden sind. Der Praxistest bleibt erforderlich. Keine Veröffentlichung als bestätigtes stabiles Release.

## Testbuild 1.1.8: Native Sichtbarkeit statt WinForms-Visible

Das Nutzerprotokoll von 1.1.7 zeigt beim Anhängen an MainForm, KeyPromptForm und PwEntryForm bereits `Visible=True`, aber noch `nativeVisible=False` und `Opacity=1`. Beide bisherigen Visible-Prüfungen übersprangen damit den Schutz vor dem ersten sichtbaren Zeichenlauf. 1.1.8 prüft stattdessen `IsWindowVisible`, ohne einen Fensterhandle vorzeitig anzulegen. Bereits tatsächlich sichtbare Fenster bleiben ausgenommen.

`build/test-keepass-first-frame.ps1` startet eine separate echte KeePass-Kopie mit eigener Konfiguration und ausschließlich fiktiven Daten. Der Test prüft, dass die ersten nativen Zeichenläufe von Eintrags-, Gruppen- und Hauptschlüsseldialogen bei Deckkraft 0 erfolgen und die Deckkraft anschließend wieder 1 ist. Auch das Hauptfenster muss nach Shown wieder Deckkraft 1 erreichen. Die Testkopie berührt keine Nutzerinstallation und keine echten Datenbanken. Der Testaktor darf nicht als Plugin beim Nutzer installiert werden.

Der Integrationstest belegt die Korrektur des übersprungenen Schutzes; die Dialoge liegen außerhalb des Bildschirms. Er beweist daher nicht, dass sämtliche im Nutzervideo sichtbaren weißen Flächen verschwunden sind. 1.1.8 bleibt bis zur Bestätigung am betroffenen Rechner ein Testbuild. Das private Nutzerprotokoll wird nicht veröffentlicht.

## Testbuild 1.1.7: Erstes vollständiges Fensterbild vor der Einblendung

Diagnose-Zusatzplugin 1.0.2: Den Fassungen 1.0.0/1.0.1 fehlte `AssemblyProduct("KeePass Plugin")`. KeePass ignoriert solche DLLs vor der Initialisierung; deshalb fehlten Menüpunkt und Logdatei trotz korrekter Installation. Die Kennung ist ergänzt, und der Startup-Test prüft nun auch die Loader-Metadaten. Eine getrennte echte KeePass-2.61.1-Testkopie mit eigener Konfiguration und fiktiven Eintrags-, Gruppen- und Hauptschlüsseldialogen hat das Zusatzplugin geladen und das Zeichenprotokoll erstellt. Die Nutzerdateien und vorhandene Installation wurden dabei nicht verändert.

Diagnose-Zusatzplugin 1.0.1: Das Protokoll wird jetzt vor dem Anhängen der Überwachung angelegt. Hook-Fehler werden anhand ihres Typs aufgezeichnet. Wenn `Dokumente/ChatGPT/KeePass Dark Theme/outputs` vorhanden ist, wird die Logdatei dort gespeichert; sonst im Temp-Ordner. Das Extras-Menü „KeeTheme-Zeichenprotokoll: Speicherort anzeigen“ zeigt den tatsächlich gewählten Pfad und eventuelle Schreibfehler. Der neue Startup-Test prüft die Erstellung mit einem Test-Pluginhost, ohne Datenbank oder sichtbares Fenster.

**Ergebnis des Praxistests:** Die neuen Nutzeraufnahmen zeigen weiterhin weiße Steuerelemente beim Anzeigen der Dialoge. Der SHA-256-Vergleich bestätigt, dass die installierte DLL genau dem lokalen 1.1.7-Testbuild entspricht. 1.1.7 beseitigt den gemeldeten Fehler nicht. Der synthetische Test ist deshalb kein Reproduktions- oder Behebungstest für diesen KeePass-Fehler.

Für die weitere Diagnose liegt unter `build/diagnostics/KeeThemePaintTrace.cs` ein separates, temporäres Zusatzplugin. Es protokolliert frühe native Zeichenmeldungen, Sichtbarkeit, Deckkraft und Farben. Es liest keine Steuerelementtexte, Namen, Datenbankinhalte oder Passwörter und erstellt keine Screenshots. `test-log-privacy.ps1` überprüft, dass auch mit fiktiven geheimen Texten und Kontrollnamen ausschließlich technische Metadaten ausgegeben werden und keine Handles vorzeitig erzeugt werden. Das Protokoll wird lokal unter `Path.GetTempPath()/KeeTheme-PaintTrace.log` gespeichert. Nach der Diagnose kann das Zusatzplugin bei geschlossenem KeePass wieder entfernt werden. Ein neuer funktionaler Fix wird erst nach weiterer Diagnose bewertet.

Der Nutzer bestätigt: 1.1.6 verändert den Start, beseitigt aber die weiße Fläche weder beim Start noch beim Öffnen von Dialogen. Der Rahmen-Fix allein löst das Problem also nicht.

1.1.7 hält neu geöffnete KeePass-Haupt-, Eintrags-, Gruppen-, Hauptschlüssel- und Datenbankeinstellungsfenster während ihres ersten synchronen Zeichenlaufs transparent. Erst wenn alle Kindfenster und Theme-Nachzeichnungen zurückgekehrt sind, wird die ursprüngliche Fensterdeckkraft wiederhergestellt. Bereits sichtbare Fenster werden nicht ausgeblendet. Es gibt keine Wartezeiten, Timer oder Fade-Animationen im Plugin. Theme-Abschaltung beim Start, Mono und fremde Plugin-Fenster sind ausgenommen.

`build/test-first-frame-presentation.ps1` prüft mit eigenen synthetischen Fenstern, dass das erste native Zeichnen mit Schutz bei Deckkraft 0 statt 1 erfolgt und danach eine vollständig gezeichnete dunkle Fläche sichtbar ist. Abbruch stellt auch eine ursprüngliche Deckkraft von 0,75 wieder her. Der Test reproduziert den konkreten KeePass-Fehler aus der Aufnahme nicht; er belegt die geänderte Einblendereihenfolge. Die Live-Prüfung des Starts und der Dialoge bleibt offen, ebenso ein möglicher separater Neu-Zeichenfehler im bereits sichtbaren Hauptfenster beim Öffnen modaler Dialoge. Dieser Build ist ausdrücklich ein Teststand.

## Testbuild 1.1.6: Fensterrahmen beim Theming stabil halten

Der bisherige Titelleisten-Workaround setzte FormBorderStyle kurz auf None und anschließend zurück. Das änderte beim Öffnen und erneuten Theming die Fensterstruktur und die Größe des Inhalts. Die neue Fassung setzt ausschließlich das DWM-Attribut für die dunkle Titelleiste, wie in der [Microsoft-Dokumentation](https://learn.microsoft.com/de-de/windows/apps/desktop/modernize/ui/apply-windows-themes) beschrieben.

Die Lifecycle-Prüfung `build/test-titlebar-lifecycle.ps1` verwendet ein echtes WinForms-Fenster mit synthetischen Daten. Bei vier Titelleisten-Aktualisierungen erzeugt 1.1.5 zwölf native Stiländerungen und 24 Änderungen der Clientgröße; der Testbuild erzeugt jeweils null. Die dunkle Titelleiste bleibt aktiviert, Fensterhandle und Geometrie bleiben erhalten. Theme-, native Feld-, Gruppendialog- und Kontextmenüprüfungen bestehen ebenfalls.

Dies belegt die Entfernung dieses Auslösers, noch nicht die vollständige Beseitigung aller weißen Startframes. Der praktische Vergleich beim KeePass-Anwendungsstart und Öffnen von Eintrags-/Gruppendialogen steht aus. Die Nutzeraufnahmen bleiben lokal und werden nicht veröffentlicht. Vor Bestätigung ist 1.1.6 ein Testbuild, kein als fehlerfrei bestätigtes Release.

## Installation und Rückweg

KeePass schließen. Bisherige KeeTheme.dll/KeeTheme.plgx sichern und aus Plugins entfernen, damit nur eine Version geladen wird. Die neue KeeTheme.dll nach Plugins kopieren. KeePass starten, unter Extras > Optionen > KeeTheme das Theme Modern Dark auswählen und aktivieren (standardmäßig Strg+T). Bestehende Theme-Einstellungen werden respektiert; Modern Dark ist nur für neue Konfigurationen der Standard. Zum Rückweg KeePass schließen und die gesicherte Plugin-Version zurückkopieren.

## Version 1

Hintergrund #1E1E1E, Controls/Panels #252526, Menüs #2D2D30, Text #F1F1F1, deaktivierte Menütexte #BEBEBE. Baumselektion und Menü-Hover #3E3E42, Listenheader #252526. Die vorhandenen ListView-/TreeView-Zeichner und Windows-Dark-Scrollbar-Unterstützung bleiben erhalten. Inaktive Texte außerhalb von Menüs verwenden teilweise weiterhin die native Windows-/KeeTheme-Darstellung.

Einheitliche Linienicons für Neu, Öffnen, Speichern, Alle speichern, Eintrag hinzufügen, Benutzername, Passwort, URL öffnen/kopieren, Auto-Type, Suche, Ansichten, abgelaufene Einträge, Sperren und Tab schließen in der Haupttoolbar; Neu/Öffnen/Speichern auch im Hauptmenü, wenn dort ein Image vorhanden ist. Zeichnung skaliert mit dem vom Control gelieferten Bildrechteck. Es werden keine ToolStripItem.Images ersetzt; beim Theme-Wechsel gilt wieder der ursprüngliche Renderer. Unbekannte Kommandos und fremde Fenster erhalten ihre ursprünglichen Icons.

Baum und Eintragsliste zeichnen alle 69 Standardicons neu, darunter Schlüssel, Ordner, Benutzer, Server, E-Mail, Werkzeug, Monitor, Haus und Papierkorb. Für unbekannte zukünftige Icon-IDs bleibt das Originalbild erhalten. Nur m_lvEntries mit PwListItem-Tag, leerer CustomIconUuid und Index kleiner PwIcon.Count wird berücksichtigt. Alle eigenen Icons und alle anderen Standardicons bleiben unverändert. Keine Datenbankbilder oder ImageLists werden geschrieben.

## Erreichbarkeit und Grenzen

| Oberfläche | Plugin-Zugang | Status dieser Version |
| --- | --- | --- |
| TreeView | OwnerDrawText, Farben, natives Dark-Theme | Farben und Selektion; moderne Standardsymbole und Chevron-Pfeile; eigene Icons original |
| ListView | OwnerDraw, Header-/Gruppenzeichner, SmallImageList | Farben, Header und alle 69 Standardicon-Typen beim Zeichnen |
| Menu/ContextMenu | ToolStripRenderer, DropdownOpening | Farben, Hover, inaktive Texte; drei Hauptmenüicons |
| Toolbar | ToolStripRenderer.OnRenderItemImage | Alle 15 Standardtoolbar-Icontypen als Linienicons |
| Standard-/Custom-ImageLists | MainForm.ClientIcons ist öffentlich; ImageList.Images veränderbar | Bewusst keine Mutation der gemeinsamen Listen |
| Native Dialoge/Checkboxen/Comboboxen | Teilweise Windows-eigene Zeichnung | Keine vollständige WinUI-3-/Windows-11-Umstellung |

KeePass MainForm_Functions.cs (UpdateImageLists) baut die Listen bei Icon-Updates neu auf: Standardbilder zuerst, eigene Bilder ab PwIcon.Count. Gruppen/Einträge mit eigener UUID verweisen auf diese angehängten Slots. Ein globaler Austausch müsste Wiederaufbau, Datenbankwechsel, DPI-Wechsel, mehrere Dialoge und Wiederherstellung beim Abschalten behandeln. Die private Standardbild-Cache-Liste ist kein stabiler Plugin-Vertrag. Ein KeePass-Fork ist für die hier implementierten Änderungen nicht nötig; für vollständiges WinUI, Mica, native Rundungen und sämtliche Betriebssystemdialoge reicht KeeTheme nicht aus.

## Build und Prüfung

.NET Framework 3.5 und Windows PowerShell 5.1 erforderlich. Gegen die lokal installierte KeePass.exe gebaut. build/build-local.ps1 kann mit -KeePassPath und -OutputPath andere Pfade erhalten; es installiert nichts und kopiert den Build nicht automatisch in Plugins. Visual Studio/MSBuild bleibt über die Solution möglich; der lokale Ersatzbuild erzeugt Ressourcen ohne zusätzliches Windows SDK. Ein vorhandener C#-3.5-Typinferenzfehler wurde durch einen expliziten Lambda-Ausdruck behoben. Upstream-UpdateUrl ist leer, damit ein Fork-Build nicht über den Upstream-Updatehinweis ersetzt wird.

Build erfolgreich, nur bestehende Warnungen zu ungenutzten Variablen/Feldern. build/test-smoke.ps1 prüft alle drei eingebetteten Themes, Farben, Theme-Editor-Roundtrip, Standardicon-Zeichnung und Ausschluss eigener UUIDs/Slots sowie Rückfall bei ausgeschalteten modernen Icons. Diese Tests sind bestanden. Eine visuelle Prüfung in einer laufenden KeePass-Instanz ist noch offen; der Build ist eine Testversion.

Manuell prüfen: Theme an/aus und Wechsel zu alten Themes; Menü-/Kontextmenü-Hover und deaktivierte Befehle; Toolbar bei 100/125/150/200%; Standard-/eigene Icons in Baum, Liste und Eintragsdialog; zwei Datenbanken wechseln; Sperren/Entsperren; Theme-Editor speichern/laden; Windows-Synchronisierung und Hotkey. Keine echte Passwortdatenbank für den ersten Test erforderlich.

## Toolbar-Verfeinerung

Neue Icons mit runden Linienenden, dezente Trenner und abgerundete Hover-/Pressed-Flächen. Zusätzliche horizontale und vertikale Polsterung wird beim Abschalten oder Theme-Wechsel auf die ursprünglichen Werte zurückgesetzt; wiederholtes Anwenden addiert keine weiteren Abstände. Unbekannte Plugin-Kommandos behalten ihr Bild. Der Suchfeldrahmen wird in Modern Dark dunkel (#414141) nachgezeichnet. ModernDark-toolbar.png ist eine aus dem Icon-Zeichner erzeugte Stilvorschau, kein Screenshot einer laufenden KeePass-Instanz. build/test-toolbar.ps1 prüft 15 Icontypen bei 16/20/24/32px, unbekannte Kommandos und die Wiederherstellung des Graphics-Zustands; bestanden.

## Vollständige Toolbar, zentrierte Suche und Gruppenbaum

Die vollständige ursprüngliche Toolbar ist wieder sichtbar, mit den modernen Icons. Das breite Suchfeld wird mit einem dynamischen Abstand in der Toolbar zentriert, sobald Platz zwischen den Buttons und dem rechten Rand vorhanden ist. Bei schmalen Fenstern verkleinert es sich bis auf 100 Pixel und bleibt neben den Buttons; eine geometrische Zentrierung ist dort ohne Überlagerung nicht möglich. Bei Theme-Wechsel werden Polsterung, Suchfeldgröße und AutoSize wiederhergestellt. Der Gruppenbaum verwendet OwnerDrawAll mit Chevron-Pfeilen; Gruppentext, Auswahl, Fokus und eigene ImageList-Bilder bleiben erhalten. Die Standardicon-Auswahl ist nur bei leerer CustomIconUuid und Standardindex zulässig. Gemeinsame ImageLists werden weiterhin nicht verändert. Die Baumdarstellung setzt die übliche links-nach-rechts-Anordnung voraus.

build/test-compact.ps1 prüft die vollständige Toolbar, breitere Suche, fremde Buttons, wiederholtes Anwenden, Wiederherstellung sowie eigene Icons im Gruppenbaum. Alle Prüfungen bestanden. Live-Test im bestehenden KeePass-Fenster bleibt erforderlich; Plugin-Dateien werden nicht automatisch installiert.

## Icon-Auswahldialog

Die Standard-Icon-Liste im IconPickerForm erhält eine eigene ImageList mit denselben Indizes und Schlüsseln. Alle 69 Standardicons zeigen dieselben Linienicons wie Baum/Liste; unbekannte zukünftige IDs behalten ihr Original. Die gemeinsame KeePass-ImageList und die separate Liste benutzerdefinierter Datenbankicons werden nicht verändert. Vorschau wird nach dem Laden des Dialogs angewandt und bei Theme-Wechsel/Schließen sauber wiederhergestellt. Tests prüfen Vorschau, unveränderte Quellbilder und Custom-Slots, Wiederherstellung sowie Suchfeldzentrierung bei breiten und schmalen Fenstern.

## Ruhigere Eintragsliste

Modern Dark zeichnet keine senkrechten Spaltentrenner mehr in Listenzellen, Headern, Gruppen und Hintergrundbildern. Die abwechselnden Zeilen sind #1B1B1B und #202020. ShowColumnSeparators=False und UseThemeAlternatingColors=True sind im Theme-Editor einstellbar. Alte Themes behalten ihre bisherige Darstellung. Benutzerdefinierte Eintragsfarben bleiben erhalten; gespeicherte globale KeePass-Alternativfarben werden in diesem Theme durch die dezenten Theme-Farben ersetzt. Das Umschalten der alternierenden Zeilen über KeePass wird weiter respektiert.

build/test-standard-icons.ps1 prüft alle 69 Standardicons bei 16/24/32px und kontrolliert durch Pixelprüfungen, dass die Spaltentrenner im Modern-Dark-Theme ausbleiben und im bisherigen Modus weiterhin gezeichnet werden. Alle Prüfungen bestanden. Standardicon-Indizes bleiben unverändert; keine Datenbankmigration ist erforderlich.

## Weißes Fensterschloss

Das laufende KeePass-Hauptfenster erhält in Modern Dark das originale KeePass-Logo in Graustufen für Titelleiste und Windows-Fenstersymbol. UIStateUpdated wendet es nach KeePass-Icon-Updates erneut an. Beim Theme-Wechsel/Abschalten und Plugin-Terminierung wird das zuletzt von KeePass gesetzte Icon wiederhergestellt. EXE, Tray-Statussymbol und Datenbankicons werden nicht verändert.

Eine angeheftete Taskleisten-Verknüpfung kann weiterhin das EXE-Icon anzeigen. Dafür liegt KeePass-SW.ico bei: in den Eigenschaften der Verknüpfung unter Anderes Symbol auswählen. Das ICO enthält 16/32/48/64/128/256 Pixel; bis 128 Pixel werden klassische Windows-DIB-Bilder für saubere .NET-/WinForms-Kompatibilität verwendet. test-window-icon.ps1 prüft ICO-Größen, monochrome Windows-Zeichnung und Wiederherstellung.

## Nächste Schritte

Weitere Standardicons; explizite Listen-Auswahlfarben und vollständigerer deaktivierter Text. Vor einer stabilen Veröffentlichung ist die manuelle Matrix mit mehreren KeePass-Versionen erforderlich.

Spaltentrennlinien: Im KeeTheme-Theme-Editor unter ListView die Eigenschaft ShowColumnSeparators auf False setzen. Modern Dark setzt dies bereits voraus. Native GridLines werden ebenfalls abgeschaltet und beim Deaktivieren wiederhergestellt; der Hintergrund wird beim Theme-Wechsel erneuert.

Linien-Fix: Der native leere Bereich unter den Einträgen wird nach WM_PAINT gleichfarbig nachgezeichnet. Dieser zusätzliche Schritt gilt für ungegliederte und gruppierte Detail-Listen mit einfachem Theme-Hintergrund; Bildhintergründe bleiben davon ausgenommen. test-list-background.ps1 prüft leere/kurze/lange Listen, Überschriften, Einträge und Theme-Abschaltung. Live-Prüfung beim Nutzer steht noch aus.
Logoquelle: KeePass/KeePass/Resources/Icons/KeePass.ico aus dlech/KeePass2.x; unveränderte Form, nur Graustufenumwandlung.

Suchansicht: Der Hintergrund-Fix berücksichtigt nun gruppierte Suchtreffer. Alle Eintragszeilen und nativen Gruppenüberschriften werden vom überzeichneten Bereich ausgeschlossen, unabhängig von ihrer Indexreihenfolge. test-list-background.ps1 prüft native Gruppenüberschriften, umgekehrte Trefferreihenfolge und den freien Bereich unterhalb der Suche. Build und Prüfungen bestanden; Live-Prüfung dieser Suchansicht steht noch aus.

Eintragsdialog: Modern Dark zeichnet Standardicon-Vorschau, Passwortgenerator und Ablaufdatum modern. Die Vorschau liest die aktuelle Standard-ID und CustomIconUuid bei jedem Zeichnen; eigene Icons und originale Button-Bilder bleiben erhalten. Fehlende interne Felder fallen auf KeePass-Darstellung zurück. test-entry-icons.ps1 prüft Standard-ID-Wechsel, monochrome Darstellung, Custom-Icon-Schutz und Theme-Abschaltung. Live-Test offen.

Suchfeldrahmen: Native WM_PAINT/WM_NCPAINT-Nachzeichnung nur am zentrierten Modern-Dark-Suchfeld. Eingabe und Dropdown bleiben nativ. Hook wird bei Theme-Abschaltung entfernt; Handle-Neuerstellung berücksichtigt. Build, Layout-/Wiederherstellungs- und Rahmen-Pixeltests bestanden; Live-Prüfung offen.

Eintragsdialog-Rahmen: Textfelder, Kommentar-Rahmen und Ablaufdatum-Rahmen werden in Modern Dark mit #414141 nachgezeichnet; Fokus mit #38658A. Inhalte und native Bedienung bleiben erhalten. Rahmen-Pixeltests und Suchfeld-Layouttests bestanden; Live-Prüfung offen.

Datenbank öffnen: Dunkle Rahmen auch für Passwort und Schlüsseldatei-Auswahl. Die alten Banner-Grafiken in KeyPromptForm und PwEntryForm werden in Modern Dark durch einen flachen Hintergrund mit lokalisierter Überschrift ersetzt, ohne Originalbilder zu verändern. Native Dropdown-Buttons werden einschließlich Trenner und Pfeil dunkel nachgezeichnet; Eingabe und Auswahl bleiben nativ. Banner- und Dropdown-Pixeltests bestanden; Live-Test offen.
Datumsfeld: Im Ruhezustand #252526 Hintergrund und #F1F1F1 Text. Beim Fokussieren bleibt die native Datumsbearbeitung mit Segmentmarkierung erhalten. Kalenderauswahl bleibt nativ. Bitte Live-Darstellung prüfen.
Öffnen-Dialog: Originales KeePass-Logo in Graustufen vor der Überschrift Hauptschlüssel eingeben; Schlüsseldatei-Ordnerbutton mit modernem S/W-Symbol. Live-Test offen.
Banner: Eigenständige Fläche in Panel-Farbe #252526 mit dezenter unterer Trennlinie #414141. Originales S/W-Logo und Überschrift bleiben; alte Schlüsselgrafik bleibt ausgeblendet. Banner-Farbprüfung bestanden; Live-Test offen.
Banner-Motiv: Dezentes S/W-Tresormotiv nur rechts in der ursprünglichen Bannerhöhe; 50 Prozent Deckkraft und weicher Übergang zur Panel-Farbe. Logo und lokalisierte Überschrift werden nativ gezeichnet. Ressource ModernBanner.png ist eingebettet. Build und Banner-Prüfungen bestanden; Live-Test offen.
Praxistest: Nutzer bestätigt dunkle Rahmen und das kompakte S/W-Tresor-Banner im laufenden KeePass. Dieser bestätigte Stand wird auf den Hauptbranch übernommen; die README zeigt die deutsche Banner-Vorschau aus dem Plugin-Zeichner.

Version 1.1.0: Moderne Checkboxen für ungeprüft/geprüft/unbestimmt; Kennzeichnung #38658A für Auswahl und Menü-Hover. Dunkle Rahmen auch in PwGroupForm und DatabaseSettingsForm. Kalender-Dropdown erhält Windows-Dark-Theme und native Kalenderfarben; Windows kann diese Farben je nach Version ignorieren. Alle acht Prüfskripte bestanden. Die neuen Checkboxen, weiteren Dialoge und Kalenderdarstellung benötigen noch einen Live-Test.
