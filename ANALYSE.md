# Analyse: videotext.sh

## Projektübersicht

Ein bash-basierter TUI-Browser für deutsche Videotexte (Teletext), laufend in Termux auf Android.

**Struktur:**

- `videotext.sh` — Hauptskript, TUI-Controller, Eingabeverarbeitung
- `Videotext_Providers.conf` — Provider-Registry
- `includes/<domain>/get_content.sh` — Plugin pro Anbieter (curl + sed-Pipeline)

**Provider:**

| Kürzel | Domain | Startseite |
|--------|--------|------------|
| `ard-text` | ard-text.de | 100 |
| `saartext` | saartext.de | 110 |

---

## Offene Änderung (nicht committed)

`includes/ard-text.de/get_content.sh:6` — URL-Parameter-Fix:

- Alt: `subpage=$subpage`
- Neu: `sub=$subpage`

Der echte ARD-Text-API-Parameter heißt `sub=`, nicht `subpage=`.

---

## Bugs / Probleme

### 1. Debug-Output im Produktionscode

`videotext.sh:86–88`

```bash
echo provider $provider
echo startpage $startpage
echo page $page
```

Diese Zeilen sind immer sichtbar und sollten entfernt werden.

---

### 2. `--list` endet mit Fehlermeldung

Wenn das Skript als `videotext --list` aufgerufen wird, wird die Provider-Liste gedruckt, danach läuft der Code jedoch weiter bis:

```bash
if [ -z "$config" ]; then
  echo "Provider nicht gefunden."
  exit 1
fi
```

Im List-Modus wird `config` nie gesetzt — der Nutzer sieht die Liste **und** eine Fehlermeldung.

---

### 3. Doppeltes `nnn` im `case`

`videotext.sh:123` und `127`

```bash
"n" | "nnn" | "lll" | "N" | "l" | "L" | "d" | "D") # Next
"b" | "bbb" | "nnn" | "B" | "h" | "H" | "a" | "A") # Back
```

`nnn` kommt in beiden Zweigen vor — der Back-Zweig kann `nnn` nie erreichen.

---

### 4. `-` als Rücknavigation fehlt

Die Hilfe zeigt `h a b -   Eine Seite zurück`, aber `-` ist nicht im `case`-Statement implementiert.

---

### 5. `--help` nicht als CLI-Option implementiert

Hilfe ist nur per `p` / `?` innerhalb des TUI erreichbar. Konsistent wäre eine `--help`-Option beim Aufruf.

---

### 6. README veraltet

`README.md:8` — Der Header lautet noch `# saartext.sh`, obwohl das Projekt jetzt `videotext.sh` (Multi-Provider) ist.

---

## Architektur-Anmerkungen

- Das Plugin-System (`includes/<domain>/get_content.sh`) ist sauber erweiterbar — neuer Provider = neue Zeile in `.conf` + neues Unterverzeichnis.
- `read -n3` liest 3 Zeichen oder bis Enter, daher die `"q"` / `"qqq"` Doppelmuster — funktioniert, ist aber erklärungsbedürftig.
- saartext nutzt `<pre>`-Tags, daher kein HTML-Entity-Decoding nötig (im Gegensatz zu ard-text).
