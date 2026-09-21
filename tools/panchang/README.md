# Panchang table generator

Generates the tithi table the calendar feature reads:

- `lib/features/calendar/data/sample_tithi.dart` — bundled table, used in demo
  mode and as the seed for Firestore.
- `out/tithi-<from>-<to>.json` — one object per day, shaped for
  `TithiDay.fromMap`, to import into the `tithi/{yyyy-MM-dd}` collection.

```sh
npm install
npm run generate                  # 2026–2027 by default
npm run generate -- --from 2026 --to 2030
npm run check                     # verify only, write nothing
npm run validate                  # check against the 2023 golden year
```

`npm run validate` recomputes 2023 — which contained Adhik Shravan (18 Jul –
16 Aug) — and asserts nine published Ekadashi dates plus the adhik month's
range. It exercises month naming, adhik detection and the vrat deferral rule
against an independent record, so run it after touching any of them. **Do not
edit those expectations to make a change pass.**

The generator refuses to write if any anchor or invariant fails, so a bad
regeneration can't silently reach the app.

## Why the table is generated, not computed on-device

The astronomy lives in a JS library (`mhah-panchang`) with no Dart equivalent,
and — more importantly — a computed tithi is not the same thing as the date a
haveli observes. Generating here leaves a reviewable diff that can be checked
against a mandir panchang before it ships.

## Traps this generator works around

All four were verified against the library, not read from its docs:

1. `calculate(date)` does **not** return `Masa` — only `calendar(date, lat, lng)`
   does. Reading `result.Masa` off `calculate()` is always `undefined`.
2. `MoonMasa.name_en_IN` is **off by one** from `MoonMasa.ino`: ino 5 is
   Bhadrapada, but the library labels it "Aswina". The ino is correct, so we
   index our own month table with it and ignore the library's name.
3. `Tithi.name_en_IN` uses Telugu-flavoured spellings — "Ekadasi", "Punnami",
   "Dasami", "Vidhiya" — so any lookup table keyed on Sanskrit names misses
   silently. We key on `Tithi.ino` (0–29) instead.
4. **`MoonMasa.ino` lags by a month around an adhik maas**, and
   `MoonMasa.isLeapMonth` is wrong outright (in 2029 it flags contradictory
   months). Naming months from the ino put Mohini Ekadashi 2026 a month late and
   placed the adhik maas in Vaishakh instead of Ashadh.

   So the month name comes from the **solar sankranti** instead, which is what
   actually defines an amanta month: lunar months are split at the paksha cycle
   (Vad → Sud), the sun's sidereal sign is read at each month's first sunrise,
   and the rasi entered during a month names it (Mesha → Chaitra, Vrishabha →
   Vaishakh, …). A month containing no sankranti is adhik and takes the
   following nij month's name. Nothing reads the library's month fields now.

## Ekadashi vrat days

The Ekadashi tithi does not land on exactly one civil day per fortnight. It can
span two sunrises (vriddhi) or none at all (kshaya). Pushtimarg follows the
Vaishnav convention, which defers rather than advances the fast:

| case                        | vrat day                  |
| --------------------------- | ------------------------- |
| tithi at one sunrise        | that day                  |
| vriddhi — two sunrises      | the **second** day        |
| kshaya — no sunrise         | the following Dwadashi    |

So `tithi == 11` is the wrong test for "is it Agiyaras": in a kshaya fortnight it
matches nothing and the fast is dropped. The observance day is stored on each
row as `ekadashi_vrat` and read through `TithiDay.isEkadashi`.

Every vriddhi/kshaya fortnight is printed on each run — **check those dates
against your mandir's panchang**, since the deferral rule is a convention and a
haveli may observe differently.

## Before shipping a new range

1. `npm run generate -- --from <y> --to <y>`
2. Read the VERIFY block and confirm each flagged date.
3. Spot-check Janmashtami, Diwali, Annakut, Holi and the Ekadashis against a
   Vaishnav panchang.
4. `flutter test` — `test/tithi_table_test.dart` guards the parsed table.
5. Add or correct utsavs in the `UTSAV` table here, not in the generated Dart.

Tithi is sampled at **Ahmedabad sunrise** (23.0225 N, 72.5714 E, IST). A user in
another timezone still sees the Ahmedabad panchang, which is the intent — change
`PLACE` to move it.
