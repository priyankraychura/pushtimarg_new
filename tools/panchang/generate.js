#!/usr/bin/env node
/**
 * Generates the tithi table used by the Flutter calendar feature.
 *
 * Why a generator and not an on-device hook: the app already models tithis as a
 * shipped per-year table (`lib/features/calendar/domain/tithi_day.dart`), and a
 * drik-ganita engine is a Node/JS library with no Dart equivalent. Computing the
 * table here lets the output be eyeballed against an authoritative Vaishnav
 * panchang before it ever reaches a devotee's screen.
 *
 * Correctness notes about `mhah-panchang` (verified against the library, not the
 * docs) — these are the traps a naive port falls into:
 *
 *   1. `calculate(date)` does NOT return `Masa`. Only `calendar(date, lat, lng)`
 *      does. Reading `result.Masa` off `calculate()` is always undefined.
 *   2. `MoonMasa.name_en_IN` is off by one from `MoonMasa.ino` (ino 5 is
 *      Bhadrapada, but the library labels it "Aswina"). The *ino* is correct, so
 *      we index our own month table with it and ignore the library's name.
 *   3. `Tithi.name_en_IN` uses Telugu-flavoured spellings ("Ekadasi", "Punnami",
 *      "Dasami", "Vidhiya"), so name-keyed lookup tables silently miss. We key
 *      off `Tithi.ino` (0-based, 0..29) instead.
 *   4. `MoonMasa.isLeapMonth` is unreliable (it flags contradictory months in
 *      2029). We derive adhik maas from repeated consecutive month inos.
 *
 * Usage:
 *   npm install
 *   npm run generate              # writes the Dart table + Firestore JSON
 *   npm run generate -- --from 2026 --to 2028
 *   npm run check                 # self-check only, writes nothing
 */

const fs = require('fs');
const path = require('path');
const SunCalc = require('suncalc');
const { MhahPanchang } = require('mhah-panchang');

// --- CONFIG ---

/** Ahmedabad. Tithi is sampled at this location's sunrise. */
const PLACE = { lat: 23.0225, lng: 72.5714, tz: 'Asia/Kolkata' };

/** India observes no DST, so a fixed offset is exact rather than approximate. */
const IST_OFFSET_MIN = 5 * 60 + 30;

/**
 * Amanta (new-moon-ending) month names in `MoonMasa.ino` order, spelled the way
 * the app spells them. Gujarati calendars are amanta, so the month rolls over at
 * Amas and Krishna paksha belongs to the month whose Shukla preceded it.
 */
const MONTHS_GU = [
  'Chaitra', 'Vaishakh', 'Jeth', 'Ashadh', 'Shravan', 'Bhadarva',
  'Aaso', 'Kartak', 'Magshar', 'Posh', 'Maha', 'Fagan',
];

/** Ekadashi names by amanta month + paksha. Adhik maas is handled separately. */
const EKADASHI = {
  'Chaitra|sud': 'Kamada', 'Chaitra|vad': 'Varuthini',
  'Vaishakh|sud': 'Mohini', 'Vaishakh|vad': 'Apara',
  'Jeth|sud': 'Nirjala', 'Jeth|vad': 'Yogini',
  'Ashadh|sud': 'Devshayani', 'Ashadh|vad': 'Kamika',
  'Shravan|sud': 'Pavitra', 'Shravan|vad': 'Aja',
  'Bhadarva|sud': 'Jal Jhilani', 'Bhadarva|vad': 'Indira',
  'Aaso|sud': 'Pashankusha', 'Aaso|vad': 'Rama',
  'Kartak|sud': 'Prabodhini', 'Kartak|vad': 'Utpanna',
  'Magshar|sud': 'Mokshada', 'Magshar|vad': 'Saphala',
  'Posh|sud': 'Putrada', 'Posh|vad': 'Shattila',
  'Maha|sud': 'Jaya', 'Maha|vad': 'Vijaya',
  'Fagan|sud': 'Amalaki', 'Fagan|vad': 'Papmochani',
};
const EKADASHI_ADHIK = { sud: 'Padmini', vad: 'Parama' };

/**
 * Utsav overlay keyed by `month|paksha|tithi`. Deliberately limited to utsavs
 * whose lunar date is unambiguous — VERIFY against your mandir's panchang before
 * shipping, and add haveli-specific utsavs here rather than in the Dart file.
 */
const UTSAV = {
  'Chaitra|sud|9': ['Ram Navami'],
  'Vaishakh|sud|3': ['Akha Trij'],
  'Vaishakh|vad|11': ['Shri Vallabhacharya Prakatyotsav'],
  'Ashadh|sud|2': ['Rath Yatra'],
  'Ashadh|sud|11': ['Dev Podhi Agiyaras'],
  'Shravan|sud|15': ['Raksha Bandhan'],
  'Shravan|vad|8': ['Janmashtami'],
  'Shravan|vad|9': ['Nandotsav'],
  'Bhadarva|sud|4': ['Ganesh Chaturthi'],
  'Aaso|sud|10': ['Dashera'],
  'Aaso|sud|15': ['Sharad Punam'],
  'Aaso|vad|13': ['Dhanteras'],
  'Aaso|vad|15': ['Diwali'],
  'Kartak|sud|1': ['Bestu Varas', 'Annakut'],
  'Kartak|sud|2': ['Bhai Bij'],
  'Kartak|sud|11': ['Dev Uthi Agiyaras'],
  'Kartak|sud|15': ['Dev Diwali'],
  'Maha|vad|13': ['Mahashivratri'],
  'Fagan|sud|15': ['Holi'],
  'Fagan|vad|1': ['Dhuleti'],
};

/**
 * 2023 is a golden year: it contained Adhik Shravan (18 Jul - 16 Aug 2023) and
 * its Ekadashi dates are widely published, so it exercises month naming, adhik
 * detection and the vrat deferral rule against an independent record. Run with
 * `--validate`. Do not edit these to make a change pass.
 */
const GOLDEN_2023 = [
  ['2023-05-01', 'Vaishakh Sud 11', 'Mohini'],
  ['2023-05-31', 'Jeth Sud 11', 'Nirjala'],
  ['2023-06-14', 'Jeth Vad 11', 'Yogini'],
  ['2023-06-29', 'Ashadh Sud 11', 'Devshayani'],
  ['2023-07-13', 'Ashadh Vad 11', 'Kamika'],
  ['2023-07-29', 'Adhik Shravan Sud 11', 'Padmini'],
  ['2023-08-12', 'Adhik Shravan Vad 11', 'Parama'],   // vriddhi: Vad 11 at two
                                                      // sunrises, fast on the 2nd
  ['2023-08-27', 'Shravan Sud 11', 'Pavitra'],
  ['2023-09-10', 'Shravan Vad 11', 'Aja'],
];

/**
 * Anchors the generator asserts before writing anything. These are the dates the
 * hand-written demo table already got right, so a regression here means the
 * astronomy or the ino mapping drifted.
 */
const ANCHORS = [
  // label anchors
  ['2026-09-04', 'Shravan Vad 8', 'Janmashtami'],
  ['2026-09-21', 'Bhadarva Sud 10', null],
  ['2026-03-03', 'Fagan Punam', null],
  // Ekadashi vrat days. The hand-written demo table this replaced assumed a flat
  // 15 tithis per fortnight, so it drifted: it placed Pashankusha on 21 Oct 2026,
  // but the Ekadashi tithi does not touch that sunrise (Aaso Sud 7 is vriddhi).
  ['2026-09-07', 'Shravan Vad 11', 'Aja'],
  ['2026-09-22', 'Bhadarva Sud 11', 'Jal Jhilani'],
  ['2026-10-06', 'Bhadarva Vad 11', 'Indira'],
  ['2026-10-22', 'Aaso Sud 11', 'Pashankusha'],
  // Confirmed against a panchang by the app owner. These two are what caught the
  // MoonMasa.ino lag: the ino-based naming put Mohini on 27 May, a month late.
  ['2026-04-27', 'Vaishakh Sud 11', 'Mohini'],
  ['2026-05-27', 'Jeth Sud 11', 'Nirjala'],
  ['2026-11-05', 'Aaso Vad 11', 'Rama'],
  // Kartak Sud 11 is kshaya in 2026 (begins after sunrise on 20 Nov, ends before
  // sunrise on 21 Nov), so the vrat defers to the Dwadashi day.
  ['2026-11-21', 'Kartak Sud 12', 'Prabodhini'],
];

// --- DATE HELPERS (all arithmetic in UTC so the host timezone cannot leak in) ---

const dayMs = 86400000;
const utc = (y, m, d) => new Date(Date.UTC(y, m - 1, d));
const addDays = (date, n) => new Date(date.getTime() + n * dayMs);
const key = (date) => date.toISOString().slice(0, 10);

/** Noon IST of the given UTC midnight, the safe sample point for `getTimes`. */
const noonIst = (date) => new Date(date.getTime() + (12 * 60 - IST_OFFSET_MIN) * 60000);

const hhmm = (date) =>
  date && !Number.isNaN(date.getTime())
    ? date.toLocaleTimeString('en-US', {
        timeZone: PLACE.tz, hour: '2-digit', minute: '2-digit', hour12: true,
      })
    : null;

// --- CORE ---

const panchang = new MhahPanchang();

/** Raw panchang for one civil day, sampled at Ahmedabad sunrise. */
function sampleDay(date) {
  const times = SunCalc.getTimes(noonIst(date), PLACE.lat, PLACE.lng);
  const sunrise = times.sunrise;
  if (!sunrise || Number.isNaN(sunrise.getTime())) {
    throw new Error(`no sunrise for ${key(date)} at ${PLACE.lat},${PLACE.lng}`);
  }
  const t = panchang.calculate(sunrise);
  const cal = panchang.calendar(sunrise, PLACE.lat, PLACE.lng);

  const tithiIno = t.Tithi.ino;               // 0..29, Shukla 1 .. Krishna 15
  return {
    date,
    sunrise,
    sunset: times.sunset,
    sunRasi: cal.Raasi.ino,                   // sun's sidereal sign; names the month
    paksha: tithiIno < 15 ? 'sud' : 'vad',
    tithi: (tithiIno % 15) + 1,
    libPaksha: t.Paksha.name_en_IN,           // cross-checked in selfCheck
  };
}

/**
 * Segments days into lunar months, then names each one from the solar sankranti
 * it contains — which is what actually defines an amanta month.
 *
 * `MoonMasa.ino` is NOT usable for this. It lags by a month around an adhik
 * maas: across Apr-Jul 2026 it reports Vaishakh for the month that is really
 * Jeth, which mislabels Mohini and Nirjala Ekadashi. `MoonMasa.isLeapMonth` is
 * wrong too. Only the sun's sidereal sign is reliable.
 *
 * The classical rule: a lunar month is named after the rasi the sun enters
 * during it (sun enters Mesha -> Chaitra, Vrishabha -> Vaishakh, ...). A month
 * containing no sankranti at all is adhik, and takes the name of the nij month
 * that follows it.
 *
 * Boundaries are the paksha cycle (a new month begins at Sud 1, i.e. wherever Vad
 * is followed by Sud), so the sign is read at each month's first sunrise: if the
 * next month starts in a different rasi, the sankranti into that rasi happened
 * inside this month and names it.
 */
function nameLunarMonths(days) {
  const months = [];
  for (const d of days) {
    const cur = months[months.length - 1];
    const prevDay = cur && cur.days[cur.days.length - 1];
    if (!cur || (prevDay.paksha === 'vad' && d.paksha === 'sud')) months.push({ days: [d] });
    else cur.days.push(d);
  }
  for (const m of months) m.startRasi = m.days[0].sunRasi;

  // Pass 1: nij months take the rasi entered during them; adhik months contain no
  // sankranti, so the sun is still in the same sign when the next month opens.
  for (let i = 0; i < months.length - 1; i++) {
    const m = months[i];
    m.isAdhik = months[i + 1].startRasi === m.startRasi;
    m.rasiIndex = m.isAdhik ? null : months[i + 1].startRasi;
  }

  // Pass 2: an adhik month borrows its name from the nij month it precedes.
  for (let i = months.length - 2; i >= 0; i--) {
    if (months[i].isAdhik) months[i].rasiIndex = months[i + 1].rasiIndex;
  }

  for (const m of months) {
    if (m.rasiIndex == null) continue;              // clipped tail of the scan
    m.baseMonth = MONTHS_GU[m.rasiIndex];
    for (const d of m.days) {
      d.lunarMonth = months.indexOf(m);
      d.isAdhik = m.isAdhik;
      d.baseMonth = m.baseMonth;
      d.monthGu = (m.isAdhik ? 'Adhik ' : '') + m.baseMonth;
    }
  }

  // Two adhik months cannot be adjacent, and a complete month is 29-30 days.
  for (let i = 1; i < months.length - 1; i++) {
    const n = months[i].days.length;
    if (n < 29 || n > 30) {
      throw new Error(
        `lunar month starting ${key(months[i].days[0].date)} has ${n} days (expected 29-30)`,
      );
    }
    if (months[i].isAdhik && months[i - 1].isAdhik) {
      throw new Error(`two adjacent adhik months at ${key(months[i].days[0].date)}`);
    }
  }
  return days.filter((d) => d.monthGu !== undefined);
}

/**
 * Vikram Samvat, Gujarati (Kartak-based) reckoning: the year rolls over at
 * Kartak Sud 1, NOT on a fixed Gregorian date. Adhik Kartak, if it ever occurs,
 * does not start the year — only Nij Kartak does.
 */
function assignVikramSamvat(days) {
  const boundaries = days.filter(
    (d) => d.baseMonth === 'Kartak' && !d.isAdhik && d.paksha === 'sud' && d.tithi === 1,
  );
  if (!boundaries.length) throw new Error('no Kartak Sud 1 in the scanned range');
  for (const d of days) {
    let b = null;
    for (const cand of boundaries) {
      if (cand.date.getTime() <= d.date.getTime()) b = cand;
      else break;
    }
    // +57 once the new year has started, +56 while still in the old one.
    d.vikramSamvat = b
      ? b.date.getUTCFullYear() + 57
      : d.date.getUTCFullYear() + 56;
  }
  return days;
}

/**
 * Assigns the Ekadashi vrat day per fortnight using the Vaishnav convention.
 *
 * The Ekadashi *tithi* does not map one-to-one onto civil days: it can span two
 * sunrises (vriddhi) or none at all (kshaya). Pushtimarg follows the Vaishnav
 * rule, which defers rather than advances the fast:
 *
 *   - tithi at exactly one sunrise  -> fast that day
 *   - vriddhi (two sunrises)        -> fast the SECOND day
 *   - kshaya (no sunrise)           -> fast the following Dwadashi day
 *
 * Deriving the vrat day from `tithi == 11` alone drops a fast entirely in a
 * kshaya fortnight, which is why the flag is stored rather than computed on the
 * device. Every non-trivial fortnight is reported for human verification.
 */
function assignEkadashi(days) {
  const notes = [];
  const fortnights = new Map();
  for (const d of days) {
    const fk = `${d.lunarMonth}|${d.paksha}`;
    if (!fortnights.has(fk)) fortnights.set(fk, []);
    fortnights.get(fk).push(d);
  }

  for (const group of fortnights.values()) {
    const hits = group.filter((d) => d.tithi === 11);
    let vrat = null;
    let kind = 'normal';

    if (hits.length === 1) {
      vrat = hits[0];
    } else if (hits.length >= 2) {
      vrat = hits[hits.length - 1];
      kind = 'vriddhi';
    } else {
      vrat = group.find((d) => d.tithi === 12) ?? null;
      kind = 'kshaya';
    }

    // A fortnight clipped by the ends of the generated range legitimately has no
    // Ekadashi; a complete one missing both tithi 11 and 12 does not.
    const clipped = group.length < 13;
    if (!vrat) {
      if (!clipped) {
        notes.push({
          fk: `${group[0].monthGu}|${group[0].paksha}`,
          kind: 'MISSING',
          detail: `no tithi 11 or 12 in the fortnight from ${key(group[0].date)}`,
        });
      }
      continue;
    }

    vrat.isEkadashiVrat = true;
    vrat.ekadashiName = vrat.isAdhik
      ? EKADASHI_ADHIK[vrat.paksha]
      : EKADASHI[`${vrat.baseMonth}|${vrat.paksha}`] ?? null;

    if (kind !== 'normal') {
      notes.push({
        fk: `${vrat.monthGu}|${vrat.paksha}`,
        kind,
        detail: `vrat on ${key(vrat.date)} (${label(vrat)})`,
      });
    }
  }
  return notes;
}

function decorate(days) {
  for (const d of days) {
    d.isEkadashiVrat = false;
    d.ekadashiName = null;
    d.utsav = d.isAdhik ? [] : UTSAV[`${d.baseMonth}|${d.paksha}|${d.tithi}`] ?? [];
  }
  const notes = assignEkadashi(days);
  return notes;
}

function build(fromYear, toYear) {
  // Scan wider than we emit: adhik detection needs the neighbouring lunar month,
  // and the Vikram Samvat boundary needs the previous Kartak Sud 1.
  const scanStart = addDays(utc(fromYear, 1, 1), -420);
  const scanEnd = addDays(utc(toYear, 12, 31), 60);
  const days = [];
  for (let d = scanStart; d.getTime() <= scanEnd.getTime(); d = addDays(d, 1)) {
    days.push(sampleDay(d));
  }
  const named = nameLunarMonths(days);
  const notes = decorate(assignVikramSamvat(named));
  const inRange = named.filter(
    (d) => d.date.getUTCFullYear() >= fromYear && d.date.getUTCFullYear() <= toYear,
  );
  return { days: inRange, notes };
}

// --- SELF-CHECK ---

const label = (d) => {
  const short = d.paksha === 'sud' && d.tithi === 15 ? 'Punam'
    : d.paksha === 'vad' && d.tithi === 15 ? 'Amas'
    : `${d.paksha === 'sud' ? 'Sud' : 'Vad'} ${d.tithi}`;
  return `${d.monthGu} ${short}`;
};

function selfCheck(days) {
  const byKey = new Map(days.map((d) => [key(d.date), d]));
  const problems = [];

  for (const [date, expectLabel, expectName] of ANCHORS) {
    const d = byKey.get(date);
    if (!d) { problems.push(`${date}: outside generated range`); continue; }
    const got = label(d);
    if (got !== expectLabel) problems.push(`${date}: expected "${expectLabel}", got "${got}"`);
    if (expectName) {
      const names = [d.ekadashiName, ...d.utsav].filter(Boolean);
      if (!names.includes(expectName)) {
        problems.push(`${date}: expected "${expectName}" among [${names.join(', ') || 'nothing'}]`);
      }
    }
  }

  for (const d of days) {
    const at = key(d.date);
    if (d.tithi < 1 || d.tithi > 15) problems.push(`${at}: tithi ${d.tithi} out of range`);
    const libPk = d.libPaksha === 'Shukla' ? 'sud' : 'vad';
    if (libPk !== d.paksha) {
      problems.push(`${at}: paksha ${d.paksha} disagrees with library ${d.libPaksha}`);
    }
    if (d.isEkadashiVrat && !d.ekadashiName) problems.push(`${at}: vrat day with no Ekadashi name`);
    if (d.ekadashiName && !d.isEkadashiVrat) problems.push(`${at}: named Ekadashi that is not a vrat day`);
  }

  // Exactly one vrat per complete fortnight, i.e. 24 per lunar year (26 with an
  // adhik maas). Dates must be strictly increasing and 10-20 days apart.
  const vrats = days.filter((d) => d.isEkadashiVrat);
  for (let i = 1; i < vrats.length; i++) {
    const gap = Math.round((vrats[i].date - vrats[i - 1].date) / dayMs);
    if (gap < 10 || gap > 20) {
      problems.push(`${key(vrats[i].date)}: ${gap} days after the previous Ekadashi`);
    }
  }
  const months = new Set(days.map((d) => `${d.monthGu}|${d.paksha}`)).size;
  return { problems, ekadashiCount: vrats.length, months };
}

// --- EMIT ---

const pipe = (d) => [
  key(d.date), d.monthGu, d.paksha, d.tithi,
  d.ekadashiName ?? '', d.utsav.join(';'), d.isEkadashiVrat ? 'E' : '',
].join('|');

function dartFile(days, fromYear, toYear) {
  const rows = days.map((d) => `  ${pipe(d)}`).join('\n');
  return `// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Regenerate with:  cd tools/panchang && npm install && npm run generate
// Source: mhah-panchang (drik ganita), sampled at Ahmedabad sunrise (23.0225 N,
// 72.5714 E, IST). Range ${fromYear}-01-01 to ${toYear}-12-31.
//
// Tithis are computed, not transcribed from a mandir panchang. Vaishnav utsav
// observance can differ from the computed tithi by a day; verify before relying
// on these dates for vrat or utsav.

import '../domain/tithi_day.dart';

/// Computed tithi table for ${fromYear}–${toYear}, used in demo mode and as the
/// seed for the Firestore \`tithi/{yyyy-MM-dd}\` collection.
final List<TithiDay> sampleTithi = _parse(_table);

List<TithiDay> _parse(String table) {
  final days = <TithiDay>[];
  for (final line in table.split('\\n')) {
    final row = line.trim();
    if (row.isEmpty) continue;
    final f = row.split('|');
    days.add(TithiDay(
      date: DateTime.parse(f[0]),
      monthGu: f[1],
      paksha: f[2] == 'vad' ? Paksha.vad : Paksha.sud,
      tithi: int.parse(f[3]),
      ekadashiName: f[4].isEmpty ? null : f[4],
      utsav: f[5].isEmpty ? const [] : f[5].split(';'),
      ekadashiVrat: f[6] == 'E',
    ));
  }
  return days;
}

/// \`date|month|paksha|tithi|ekadashiName|utsav;utsav|E\` — a trailing \`E\` marks
/// the day the Ekadashi vrat is observed.
const String _table = '''
${rows}
''';
`;
}

const jsonRows = (days) => days.map((d) => ({
  date: key(d.date),
  month_gu: d.monthGu,
  paksha: d.paksha,
  tithi: d.tithi,
  vikram_samvat: d.vikramSamvat,
  utsav: d.utsav,
  ekadashi_vrat: d.isEkadashiVrat,
  ...(d.ekadashiName ? { ekadashi_name: d.ekadashiName } : {}),
  sunrise: hhmm(d.sunrise),
  sunset: hhmm(d.sunset),
}));

// --- MAIN ---

function main() {
  const argv = process.argv.slice(2);
  const arg = (name, fallback) => {
    const i = argv.indexOf(`--${name}`);
    return i >= 0 && argv[i + 1] ? Number(argv[i + 1]) : fallback;
  };
  const checkOnly = argv.includes('--check');
  const validate = argv.includes('--validate');

  if (validate) {
    process.stdout.write('Validating against the 2023 golden year (Adhik Shravan)...\n');
    const { days } = build(2023, 2023);
    const byKey = new Map(days.map((d) => [key(d.date), d]));
    const bad = [];
    for (const [date, expectLabel, expectName] of GOLDEN_2023) {
      const d = byKey.get(date);
      if (!d) { bad.push(`${date}: missing`); continue; }
      if (label(d) !== expectLabel) bad.push(`${date}: expected "${expectLabel}", got "${label(d)}"`);
      if (d.ekadashiName !== expectName) {
        bad.push(`${date}: expected "${expectName}", got "${d.ekadashiName ?? 'nothing'}"`);
      }
    }
    const adhik = [...new Set(days.filter((x) => x.isAdhik).map((x) => x.monthGu))];
    if (adhik.join() !== 'Adhik Shravan') bad.push(`adhik maas: expected Adhik Shravan, got ${adhik.join() || 'none'}`);
    if (bad.length) {
      process.stderr.write(`FAILED ${bad.length} check(s):\n`);
      for (const b of bad) process.stderr.write(`  - ${b}\n`);
      process.exit(1);
    }
    process.stdout.write(`  ${GOLDEN_2023.length} published dates + Adhik Shravan all match\n`);
    return;
  }
  const fromYear = arg('from', 2026);
  const toYear = arg('to', 2027);

  process.stdout.write(`Computing ${fromYear}-01-01 .. ${toYear}-12-31 at Ahmedabad sunrise...\n`);
  const { days, notes } = build(fromYear, toYear);
  const { problems, ekadashiCount, months } = selfCheck(days);

  process.stdout.write(`  ${days.length} days, ${months} fortnights, ${ekadashiCount} Ekadashi vrat days\n`);
  const adhik = [...new Set(days.filter((d) => d.isAdhik).map((d) => d.monthGu))];
  process.stdout.write(`  adhik maas: ${adhik.length ? adhik.join(', ') : 'none'}\n`);

  const relevant = notes.filter((n) => {
    const y = Number(n.detail.match(/\d{4}/)?.[0] ?? 0);
    return n.kind === 'MISSING' || (y >= fromYear && y <= toYear);
  });
  if (relevant.length) {
    process.stdout.write('\nVERIFY these against your mandir panchang — the tithi did not\n');
    process.stdout.write('map cleanly onto one sunrise, so the Vaishnav deferral rule was applied:\n');
    for (const n of relevant) {
      process.stdout.write(`  [${n.kind}] ${n.fk.split('|').slice(0, 2).join(' ')} — ${n.detail}\n`);
    }
  }

  if (problems.length) {
    process.stderr.write(`\nFAILED ${problems.length} check(s):\n`);
    for (const p of problems.slice(0, 20)) process.stderr.write(`  - ${p}\n`);
    process.exit(1);
  }
  process.stdout.write('\nall anchors and invariants OK\n');
  if (checkOnly) return;

  const dartPath = path.resolve(__dirname, '../../lib/features/calendar/data/sample_tithi.dart');
  fs.writeFileSync(dartPath, dartFile(days, fromYear, toYear));
  process.stdout.write(`\nwrote ${path.relative(path.resolve(__dirname, '../..'), dartPath)}\n`);

  const outDir = path.resolve(__dirname, 'out');
  fs.mkdirSync(outDir, { recursive: true });
  const jsonPath = path.join(outDir, `tithi-${fromYear}-${toYear}.json`);
  fs.writeFileSync(jsonPath, `${JSON.stringify(jsonRows(days), null, 1)}\n`);
  process.stdout.write(`wrote tools/panchang/out/${path.basename(jsonPath)} (Firestore seed)\n`);
}

main();
