# Verification: get_content.sh (ARD & Saartext)

**Verdict:** PASS

**Claim:** Beide Provider-Downloader fetchen Videotextseiten per curl,
extrahieren den Textinhalt und liefern sauberen Plain-Text ohne HTML-Tags.
Der ARD-Fix `sub=` statt `subpage=` ist Teil des Diffs.

**Method:** Direkter Aufruf der `get_content.sh`-Skripte mit echten Seitennummern.

---

## Steps

1. ✅ **ARD Seite 100/1** → Startseite mit Schlagzeilen, ARD-Logo als `·`-Grafik, kein HTML
   ```
   G7: Neue Russland-Sanktionen..... 104
   Saporischschja Ziel von Angriff.. 106
   ```

2. ✅ **Saartext Seite 110/1** → Nachrichtenübersicht mit Datum/Uhrzeit, kein HTML
   ```
   110      SAARTEXT    Mi.17.06. 05:38:02
   Saarbrücken: Regierung bringt neues Förderschulkonzept…
   ```

3. ✅ **HTML-Tags** → `grep -c '<'` = `0` bei beiden Providern

4. ✅ **ARD `sub=`-Parameter** → Seite 101/1 zeigt Tagesschau-Inhalt,
   Unterseiten werden korrekt angesteuert

5. ✅ **Saartext Unterseiten-Formatierung** → Subpage wird via `printf "%02d"`
   zu `02` formatiert, URL `/110/02` korrekt gebaut

6. 🔍 **ARD Seite 999** (nicht existierend) → leere Ausgabe, kein Fehler,
   kein Hinweis — Nutzer sieht blanken Bildschirm

7. 🔍 **Saartext nicht existierende Unterseite** → Server antwortet mit
   `"Die gewünschte Seite konnte nicht"` — zumindest eine Rückmeldung

---

## Findings

- ⚠️ **ARD: leere Seiten geben keine Rückmeldung.** Fehlt der
  `ARDTEXT_START`-Marker (Seite existiert nicht), liefert die Pipeline
  stillschweigend leere Ausgabe. Fallback empfohlen:
  ```bash
  ... | grep . || echo "  Seite nicht gefunden."
  ```
- `·` als Platzhalter für GIF-Grafiken funktioniert und macht Logo-Zeilen erkennbar.
