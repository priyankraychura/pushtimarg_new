// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Regenerate with:  cd tools/panchang && npm install && npm run generate
// Source: mhah-panchang (drik ganita), sampled at Ahmedabad sunrise (23.0225 N,
// 72.5714 E, IST). Range 2026-01-01 to 2027-12-31.
//
// Tithis are computed, not transcribed from a mandir panchang. Vaishnav utsav
// observance can differ from the computed tithi by a day; verify before relying
// on these dates for vrat or utsav.

import '../domain/tithi_day.dart';

/// Computed tithi table for 2026–2027, used in demo mode and as the
/// seed for the Firestore `tithi/{yyyy-MM-dd}` collection.
final List<TithiDay> sampleTithi = _parse(_table);

List<TithiDay> _parse(String table) {
  final days = <TithiDay>[];
  for (final line in table.split('\n')) {
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

/// `date|month|paksha|tithi|ekadashiName|utsav;utsav|E` — a trailing `E` marks
/// the day the Ekadashi vrat is observed.
const String _table = '''
  2026-01-01|Posh|sud|13|||
  2026-01-02|Posh|sud|14|||
  2026-01-03|Posh|sud|15|||
  2026-01-04|Posh|vad|1|||
  2026-01-05|Posh|vad|2|||
  2026-01-06|Posh|vad|3|||
  2026-01-07|Posh|vad|5|||
  2026-01-08|Posh|vad|6|||
  2026-01-09|Posh|vad|7|||
  2026-01-10|Posh|vad|7|||
  2026-01-11|Posh|vad|8|||
  2026-01-12|Posh|vad|9|||
  2026-01-13|Posh|vad|10|||
  2026-01-14|Posh|vad|11|Shattila||E
  2026-01-15|Posh|vad|12|||
  2026-01-16|Posh|vad|13|||
  2026-01-17|Posh|vad|14|||
  2026-01-18|Posh|vad|15|||
  2026-01-19|Maha|sud|1|||
  2026-01-20|Maha|sud|2|||
  2026-01-21|Maha|sud|3|||
  2026-01-22|Maha|sud|4|||
  2026-01-23|Maha|sud|5|||
  2026-01-24|Maha|sud|6|||
  2026-01-25|Maha|sud|7|||
  2026-01-26|Maha|sud|8|||
  2026-01-27|Maha|sud|9|||
  2026-01-28|Maha|sud|10|||
  2026-01-29|Maha|sud|11|Jaya||E
  2026-01-30|Maha|sud|12|||
  2026-01-31|Maha|sud|13|||
  2026-02-01|Maha|sud|15|||
  2026-02-02|Maha|vad|1|||
  2026-02-03|Maha|vad|2|||
  2026-02-04|Maha|vad|3|||
  2026-02-05|Maha|vad|4|||
  2026-02-06|Maha|vad|5|||
  2026-02-07|Maha|vad|6|||
  2026-02-08|Maha|vad|7|||
  2026-02-09|Maha|vad|8|||
  2026-02-10|Maha|vad|8|||
  2026-02-11|Maha|vad|9|||
  2026-02-12|Maha|vad|10|||
  2026-02-13|Maha|vad|11|Vijaya||E
  2026-02-14|Maha|vad|12|||
  2026-02-15|Maha|vad|13||Mahashivratri|
  2026-02-16|Maha|vad|14|||
  2026-02-17|Maha|vad|15|||
  2026-02-18|Fagan|sud|1|||
  2026-02-19|Fagan|sud|2|||
  2026-02-20|Fagan|sud|3|||
  2026-02-21|Fagan|sud|4|||
  2026-02-22|Fagan|sud|5|||
  2026-02-23|Fagan|sud|6|||
  2026-02-24|Fagan|sud|8|||
  2026-02-25|Fagan|sud|9|||
  2026-02-26|Fagan|sud|10|||
  2026-02-27|Fagan|sud|11|Amalaki||E
  2026-02-28|Fagan|sud|12|||
  2026-03-01|Fagan|sud|13|||
  2026-03-02|Fagan|sud|14|||
  2026-03-03|Fagan|sud|15||Holi|
  2026-03-04|Fagan|vad|1||Dhuleti|
  2026-03-05|Fagan|vad|2|||
  2026-03-06|Fagan|vad|3|||
  2026-03-07|Fagan|vad|4|||
  2026-03-08|Fagan|vad|5|||
  2026-03-09|Fagan|vad|6|||
  2026-03-10|Fagan|vad|7|||
  2026-03-11|Fagan|vad|8|||
  2026-03-12|Fagan|vad|9|||
  2026-03-13|Fagan|vad|10|||
  2026-03-14|Fagan|vad|10|||
  2026-03-15|Fagan|vad|11|Papmochani||E
  2026-03-16|Fagan|vad|12|||
  2026-03-17|Fagan|vad|13|||
  2026-03-18|Fagan|vad|14|||
  2026-03-19|Fagan|vad|15|||
  2026-03-20|Chaitra|sud|2|||
  2026-03-21|Chaitra|sud|3|||
  2026-03-22|Chaitra|sud|4|||
  2026-03-23|Chaitra|sud|5|||
  2026-03-24|Chaitra|sud|6|||
  2026-03-25|Chaitra|sud|7|||
  2026-03-26|Chaitra|sud|8|||
  2026-03-27|Chaitra|sud|9||Ram Navami|
  2026-03-28|Chaitra|sud|10|||
  2026-03-29|Chaitra|sud|11|Kamada||E
  2026-03-30|Chaitra|sud|12|||
  2026-03-31|Chaitra|sud|13|||
  2026-04-01|Chaitra|sud|14|||
  2026-04-02|Chaitra|sud|15|||
  2026-04-03|Chaitra|vad|1|||
  2026-04-04|Chaitra|vad|2|||
  2026-04-05|Chaitra|vad|3|||
  2026-04-06|Chaitra|vad|4|||
  2026-04-07|Chaitra|vad|5|||
  2026-04-08|Chaitra|vad|6|||
  2026-04-09|Chaitra|vad|7|||
  2026-04-10|Chaitra|vad|8|||
  2026-04-11|Chaitra|vad|9|||
  2026-04-12|Chaitra|vad|10|||
  2026-04-13|Chaitra|vad|11|Varuthini||E
  2026-04-14|Chaitra|vad|12|||
  2026-04-15|Chaitra|vad|13|||
  2026-04-16|Chaitra|vad|14|||
  2026-04-17|Chaitra|vad|15|||
  2026-04-18|Vaishakh|sud|1|||
  2026-04-19|Vaishakh|sud|2|||
  2026-04-20|Vaishakh|sud|3||Akha Trij|
  2026-04-21|Vaishakh|sud|5|||
  2026-04-22|Vaishakh|sud|6|||
  2026-04-23|Vaishakh|sud|7|||
  2026-04-24|Vaishakh|sud|8|||
  2026-04-25|Vaishakh|sud|9|||
  2026-04-26|Vaishakh|sud|10|||
  2026-04-27|Vaishakh|sud|11|Mohini||E
  2026-04-28|Vaishakh|sud|12|||
  2026-04-29|Vaishakh|sud|13|||
  2026-04-30|Vaishakh|sud|14|||
  2026-05-01|Vaishakh|sud|15|||
  2026-05-02|Vaishakh|vad|1|||
  2026-05-03|Vaishakh|vad|2|||
  2026-05-04|Vaishakh|vad|3|||
  2026-05-05|Vaishakh|vad|4|||
  2026-05-06|Vaishakh|vad|4|||
  2026-05-07|Vaishakh|vad|5|||
  2026-05-08|Vaishakh|vad|6|||
  2026-05-09|Vaishakh|vad|7|||
  2026-05-10|Vaishakh|vad|8|||
  2026-05-11|Vaishakh|vad|9|||
  2026-05-12|Vaishakh|vad|10|||
  2026-05-13|Vaishakh|vad|11|Apara|Shri Vallabhacharya Prakatyotsav|E
  2026-05-14|Vaishakh|vad|12|||
  2026-05-15|Vaishakh|vad|13|||
  2026-05-16|Vaishakh|vad|15|||
  2026-05-17|Jeth|sud|1|||
  2026-05-18|Jeth|sud|2|||
  2026-05-19|Jeth|sud|3|||
  2026-05-20|Jeth|sud|4|||
  2026-05-21|Jeth|sud|5|||
  2026-05-22|Jeth|sud|6|||
  2026-05-23|Jeth|sud|8|||
  2026-05-24|Jeth|sud|9|||
  2026-05-25|Jeth|sud|10|||
  2026-05-26|Jeth|sud|11|||
  2026-05-27|Jeth|sud|11|Nirjala||E
  2026-05-28|Jeth|sud|12|||
  2026-05-29|Jeth|sud|13|||
  2026-05-30|Jeth|sud|14|||
  2026-05-31|Jeth|sud|15|||
  2026-06-01|Jeth|vad|1|||
  2026-06-02|Jeth|vad|2|||
  2026-06-03|Jeth|vad|3|||
  2026-06-04|Jeth|vad|4|||
  2026-06-05|Jeth|vad|5|||
  2026-06-06|Jeth|vad|6|||
  2026-06-07|Jeth|vad|7|||
  2026-06-08|Jeth|vad|8|||
  2026-06-09|Jeth|vad|9|||
  2026-06-10|Jeth|vad|10|||
  2026-06-11|Jeth|vad|11|Yogini||E
  2026-06-12|Jeth|vad|12|||
  2026-06-13|Jeth|vad|13|||
  2026-06-14|Jeth|vad|14|||
  2026-06-15|Jeth|vad|15|||
  2026-06-16|Adhik Ashadh|sud|2|||
  2026-06-17|Adhik Ashadh|sud|3|||
  2026-06-18|Adhik Ashadh|sud|4|||
  2026-06-19|Adhik Ashadh|sud|5|||
  2026-06-20|Adhik Ashadh|sud|6|||
  2026-06-21|Adhik Ashadh|sud|7|||
  2026-06-22|Adhik Ashadh|sud|8|||
  2026-06-23|Adhik Ashadh|sud|9|||
  2026-06-24|Adhik Ashadh|sud|10|||
  2026-06-25|Adhik Ashadh|sud|11|Padmini||E
  2026-06-26|Adhik Ashadh|sud|12|||
  2026-06-27|Adhik Ashadh|sud|13|||
  2026-06-28|Adhik Ashadh|sud|14|||
  2026-06-29|Adhik Ashadh|sud|15|||
  2026-06-30|Adhik Ashadh|vad|1|||
  2026-07-01|Adhik Ashadh|vad|1|||
  2026-07-02|Adhik Ashadh|vad|2|||
  2026-07-03|Adhik Ashadh|vad|3|||
  2026-07-04|Adhik Ashadh|vad|4|||
  2026-07-05|Adhik Ashadh|vad|5|||
  2026-07-06|Adhik Ashadh|vad|6|||
  2026-07-07|Adhik Ashadh|vad|7|||
  2026-07-08|Adhik Ashadh|vad|8|||
  2026-07-09|Adhik Ashadh|vad|9|||
  2026-07-10|Adhik Ashadh|vad|10|||
  2026-07-11|Adhik Ashadh|vad|12|Parama||E
  2026-07-12|Adhik Ashadh|vad|13|||
  2026-07-13|Adhik Ashadh|vad|14|||
  2026-07-14|Adhik Ashadh|vad|15|||
  2026-07-15|Ashadh|sud|1|||
  2026-07-16|Ashadh|sud|2||Rath Yatra|
  2026-07-17|Ashadh|sud|3|||
  2026-07-18|Ashadh|sud|5|||
  2026-07-19|Ashadh|sud|6|||
  2026-07-20|Ashadh|sud|7|||
  2026-07-21|Ashadh|sud|8|||
  2026-07-22|Ashadh|sud|9|||
  2026-07-23|Ashadh|sud|9|||
  2026-07-24|Ashadh|sud|10|||
  2026-07-25|Ashadh|sud|11|Devshayani|Dev Podhi Agiyaras|E
  2026-07-26|Ashadh|sud|12|||
  2026-07-27|Ashadh|sud|13|||
  2026-07-28|Ashadh|sud|14|||
  2026-07-29|Ashadh|sud|15|||
  2026-07-30|Ashadh|vad|1|||
  2026-07-31|Ashadh|vad|2|||
  2026-08-01|Ashadh|vad|3|||
  2026-08-02|Ashadh|vad|4|||
  2026-08-03|Ashadh|vad|5|||
  2026-08-04|Ashadh|vad|6|||
  2026-08-05|Ashadh|vad|7|||
  2026-08-06|Ashadh|vad|8|||
  2026-08-07|Ashadh|vad|9|||
  2026-08-08|Ashadh|vad|10|||
  2026-08-09|Ashadh|vad|11|Kamika||E
  2026-08-10|Ashadh|vad|12|||
  2026-08-11|Ashadh|vad|14|||
  2026-08-12|Ashadh|vad|15|||
  2026-08-13|Shravan|sud|1|||
  2026-08-14|Shravan|sud|2|||
  2026-08-15|Shravan|sud|3|||
  2026-08-16|Shravan|sud|4|||
  2026-08-17|Shravan|sud|5|||
  2026-08-18|Shravan|sud|6|||
  2026-08-19|Shravan|sud|7|||
  2026-08-20|Shravan|sud|8|||
  2026-08-21|Shravan|sud|9|||
  2026-08-22|Shravan|sud|10|||
  2026-08-23|Shravan|sud|11|Pavitra||E
  2026-08-24|Shravan|sud|12|||
  2026-08-25|Shravan|sud|13|||
  2026-08-26|Shravan|sud|13|||
  2026-08-27|Shravan|sud|14|||
  2026-08-28|Shravan|sud|15||Raksha Bandhan|
  2026-08-29|Shravan|vad|1|||
  2026-08-30|Shravan|vad|2|||
  2026-08-31|Shravan|vad|3|||
  2026-09-01|Shravan|vad|4|||
  2026-09-02|Shravan|vad|6|||
  2026-09-03|Shravan|vad|7|||
  2026-09-04|Shravan|vad|8||Janmashtami|
  2026-09-05|Shravan|vad|9||Nandotsav|
  2026-09-06|Shravan|vad|10|||
  2026-09-07|Shravan|vad|11|Aja||E
  2026-09-08|Shravan|vad|12|||
  2026-09-09|Shravan|vad|13|||
  2026-09-10|Shravan|vad|14|||
  2026-09-11|Shravan|vad|15|||
  2026-09-12|Bhadarva|sud|1|||
  2026-09-13|Bhadarva|sud|2|||
  2026-09-14|Bhadarva|sud|3|||
  2026-09-15|Bhadarva|sud|4||Ganesh Chaturthi|
  2026-09-16|Bhadarva|sud|5|||
  2026-09-17|Bhadarva|sud|6|||
  2026-09-18|Bhadarva|sud|7|||
  2026-09-19|Bhadarva|sud|8|||
  2026-09-20|Bhadarva|sud|9|||
  2026-09-21|Bhadarva|sud|10|||
  2026-09-22|Bhadarva|sud|11|Jal Jhilani||E
  2026-09-23|Bhadarva|sud|12|||
  2026-09-24|Bhadarva|sud|13|||
  2026-09-25|Bhadarva|sud|14|||
  2026-09-26|Bhadarva|sud|15|||
  2026-09-27|Bhadarva|vad|1|||
  2026-09-28|Bhadarva|vad|2|||
  2026-09-29|Bhadarva|vad|3|||
  2026-09-30|Bhadarva|vad|4|||
  2026-10-01|Bhadarva|vad|5|||
  2026-10-02|Bhadarva|vad|6|||
  2026-10-03|Bhadarva|vad|7|||
  2026-10-04|Bhadarva|vad|9|||
  2026-10-05|Bhadarva|vad|10|||
  2026-10-06|Bhadarva|vad|11|Indira||E
  2026-10-07|Bhadarva|vad|12|||
  2026-10-08|Bhadarva|vad|13|||
  2026-10-09|Bhadarva|vad|14|||
  2026-10-10|Bhadarva|vad|15|||
  2026-10-11|Aaso|sud|1|||
  2026-10-12|Aaso|sud|2|||
  2026-10-13|Aaso|sud|3|||
  2026-10-14|Aaso|sud|4|||
  2026-10-15|Aaso|sud|5|||
  2026-10-16|Aaso|sud|6|||
  2026-10-17|Aaso|sud|7|||
  2026-10-18|Aaso|sud|7|||
  2026-10-19|Aaso|sud|8|||
  2026-10-20|Aaso|sud|9|||
  2026-10-21|Aaso|sud|10||Dashera|
  2026-10-22|Aaso|sud|11|Pashankusha||E
  2026-10-23|Aaso|sud|12|||
  2026-10-24|Aaso|sud|13|||
  2026-10-25|Aaso|sud|14|||
  2026-10-26|Aaso|sud|15||Sharad Punam|
  2026-10-27|Aaso|vad|1|||
  2026-10-28|Aaso|vad|3|||
  2026-10-29|Aaso|vad|4|||
  2026-10-30|Aaso|vad|5|||
  2026-10-31|Aaso|vad|6|||
  2026-11-01|Aaso|vad|7|||
  2026-11-02|Aaso|vad|8|||
  2026-11-03|Aaso|vad|9|||
  2026-11-04|Aaso|vad|10|||
  2026-11-05|Aaso|vad|11|Rama||E
  2026-11-06|Aaso|vad|12|||
  2026-11-07|Aaso|vad|13||Dhanteras|
  2026-11-08|Aaso|vad|14|||
  2026-11-09|Aaso|vad|15||Diwali|
  2026-11-10|Kartak|sud|1||Bestu Varas;Annakut|
  2026-11-11|Kartak|sud|2||Bhai Bij|
  2026-11-12|Kartak|sud|3|||
  2026-11-13|Kartak|sud|4|||
  2026-11-14|Kartak|sud|5|||
  2026-11-15|Kartak|sud|6|||
  2026-11-16|Kartak|sud|7|||
  2026-11-17|Kartak|sud|8|||
  2026-11-18|Kartak|sud|9|||
  2026-11-19|Kartak|sud|9|||
  2026-11-20|Kartak|sud|10|||
  2026-11-21|Kartak|sud|12|Prabodhini||E
  2026-11-22|Kartak|sud|13|||
  2026-11-23|Kartak|sud|14|||
  2026-11-24|Kartak|sud|15||Dev Diwali|
  2026-11-25|Kartak|vad|1|||
  2026-11-26|Kartak|vad|2|||
  2026-11-27|Kartak|vad|3|||
  2026-11-28|Kartak|vad|5|||
  2026-11-29|Kartak|vad|6|||
  2026-11-30|Kartak|vad|7|||
  2026-12-01|Kartak|vad|8|||
  2026-12-02|Kartak|vad|9|||
  2026-12-03|Kartak|vad|10|||
  2026-12-04|Kartak|vad|11|Utpanna||E
  2026-12-05|Kartak|vad|12|||
  2026-12-06|Kartak|vad|13|||
  2026-12-07|Kartak|vad|14|||
  2026-12-08|Kartak|vad|15|||
  2026-12-09|Magshar|sud|1|||
  2026-12-10|Magshar|sud|1|||
  2026-12-11|Magshar|sud|2|||
  2026-12-12|Magshar|sud|3|||
  2026-12-13|Magshar|sud|4|||
  2026-12-14|Magshar|sud|5|||
  2026-12-15|Magshar|sud|6|||
  2026-12-16|Magshar|sud|7|||
  2026-12-17|Magshar|sud|8|||
  2026-12-18|Magshar|sud|9|||
  2026-12-19|Magshar|sud|10|||
  2026-12-20|Magshar|sud|11|Mokshada||E
  2026-12-21|Magshar|sud|12|||
  2026-12-22|Magshar|sud|13|||
  2026-12-23|Magshar|sud|14|||
  2026-12-24|Magshar|vad|1|||
  2026-12-25|Magshar|vad|2|||
  2026-12-26|Magshar|vad|3|||
  2026-12-27|Magshar|vad|4|||
  2026-12-28|Magshar|vad|5|||
  2026-12-29|Magshar|vad|6|||
  2026-12-30|Magshar|vad|7|||
  2026-12-31|Magshar|vad|8|||
  2027-01-01|Magshar|vad|9|||
  2027-01-02|Magshar|vad|10|||
  2027-01-03|Magshar|vad|11|Saphala||E
  2027-01-04|Magshar|vad|12|||
  2027-01-05|Magshar|vad|13|||
  2027-01-06|Magshar|vad|14|||
  2027-01-07|Magshar|vad|15|||
  2027-01-08|Posh|sud|1|||
  2027-01-09|Posh|sud|2|||
  2027-01-10|Posh|sud|3|||
  2027-01-11|Posh|sud|3|||
  2027-01-12|Posh|sud|4|||
  2027-01-13|Posh|sud|5|||
  2027-01-14|Posh|sud|6|||
  2027-01-15|Posh|sud|7|||
  2027-01-16|Posh|sud|8|||
  2027-01-17|Posh|sud|9|||
  2027-01-18|Posh|sud|10|||
  2027-01-19|Posh|sud|11|Putrada||E
  2027-01-20|Posh|sud|13|||
  2027-01-21|Posh|sud|14|||
  2027-01-22|Posh|sud|15|||
  2027-01-23|Posh|vad|1|||
  2027-01-24|Posh|vad|2|||
  2027-01-25|Posh|vad|3|||
  2027-01-26|Posh|vad|5|||
  2027-01-27|Posh|vad|6|||
  2027-01-28|Posh|vad|7|||
  2027-01-29|Posh|vad|8|||
  2027-01-30|Posh|vad|9|||
  2027-01-31|Posh|vad|10|||
  2027-02-01|Posh|vad|10|||
  2027-02-02|Posh|vad|11|Shattila||E
  2027-02-03|Posh|vad|12|||
  2027-02-04|Posh|vad|13|||
  2027-02-05|Posh|vad|14|||
  2027-02-06|Posh|vad|15|||
  2027-02-07|Maha|sud|1|||
  2027-02-08|Maha|sud|2|||
  2027-02-09|Maha|sud|3|||
  2027-02-10|Maha|sud|4|||
  2027-02-11|Maha|sud|5|||
  2027-02-12|Maha|sud|6|||
  2027-02-13|Maha|sud|7|||
  2027-02-14|Maha|sud|8|||
  2027-02-15|Maha|sud|9|||
  2027-02-16|Maha|sud|10|||
  2027-02-17|Maha|sud|11|Jaya||E
  2027-02-18|Maha|sud|12|||
  2027-02-19|Maha|sud|13|||
  2027-02-20|Maha|sud|14|||
  2027-02-21|Maha|vad|1|||
  2027-02-22|Maha|vad|2|||
  2027-02-23|Maha|vad|3|||
  2027-02-24|Maha|vad|4|||
  2027-02-25|Maha|vad|5|||
  2027-02-26|Maha|vad|6|||
  2027-02-27|Maha|vad|7|||
  2027-02-28|Maha|vad|8|||
  2027-03-01|Maha|vad|9|||
  2027-03-02|Maha|vad|10|||
  2027-03-03|Maha|vad|11|||
  2027-03-04|Maha|vad|11|Vijaya||E
  2027-03-05|Maha|vad|12|||
  2027-03-06|Maha|vad|13||Mahashivratri|
  2027-03-07|Maha|vad|14|||
  2027-03-08|Maha|vad|15|||
  2027-03-09|Fagan|sud|1|||
  2027-03-10|Fagan|sud|2|||
  2027-03-11|Fagan|sud|3|||
  2027-03-12|Fagan|sud|4|||
  2027-03-13|Fagan|sud|5|||
  2027-03-14|Fagan|sud|6|||
  2027-03-15|Fagan|sud|7|||
  2027-03-16|Fagan|sud|8|||
  2027-03-17|Fagan|sud|10|||
  2027-03-18|Fagan|sud|11|Amalaki||E
  2027-03-19|Fagan|sud|12|||
  2027-03-20|Fagan|sud|13|||
  2027-03-21|Fagan|sud|14|||
  2027-03-22|Fagan|sud|15||Holi|
  2027-03-23|Fagan|vad|1||Dhuleti|
  2027-03-24|Fagan|vad|2|||
  2027-03-25|Fagan|vad|3|||
  2027-03-26|Fagan|vad|4|||
  2027-03-27|Fagan|vad|5|||
  2027-03-28|Fagan|vad|6|||
  2027-03-29|Fagan|vad|7|||
  2027-03-30|Fagan|vad|8|||
  2027-03-31|Fagan|vad|9|||
  2027-04-01|Fagan|vad|10|||
  2027-04-02|Fagan|vad|11|Papmochani||E
  2027-04-03|Fagan|vad|12|||
  2027-04-04|Fagan|vad|13|||
  2027-04-05|Fagan|vad|14|||
  2027-04-06|Fagan|vad|15|||
  2027-04-07|Chaitra|sud|1|||
  2027-04-08|Chaitra|sud|2|||
  2027-04-09|Chaitra|sud|3|||
  2027-04-10|Chaitra|sud|4|||
  2027-04-11|Chaitra|sud|5|||
  2027-04-12|Chaitra|sud|6|||
  2027-04-13|Chaitra|sud|7|||
  2027-04-14|Chaitra|sud|8|||
  2027-04-15|Chaitra|sud|9||Ram Navami|
  2027-04-16|Chaitra|sud|10|||
  2027-04-17|Chaitra|sud|11|Kamada||E
  2027-04-18|Chaitra|sud|12|||
  2027-04-19|Chaitra|sud|14|||
  2027-04-20|Chaitra|sud|15|||
  2027-04-21|Chaitra|vad|1|||
  2027-04-22|Chaitra|vad|2|||
  2027-04-23|Chaitra|vad|3|||
  2027-04-24|Chaitra|vad|4|||
  2027-04-25|Chaitra|vad|5|||
  2027-04-26|Chaitra|vad|5|||
  2027-04-27|Chaitra|vad|6|||
  2027-04-28|Chaitra|vad|7|||
  2027-04-29|Chaitra|vad|8|||
  2027-04-30|Chaitra|vad|9|||
  2027-05-01|Chaitra|vad|10|||
  2027-05-02|Chaitra|vad|11|Varuthini||E
  2027-05-03|Chaitra|vad|12|||
  2027-05-04|Chaitra|vad|13|||
  2027-05-05|Chaitra|vad|14|||
  2027-05-06|Chaitra|vad|15|||
  2027-05-07|Vaishakh|sud|1|||
  2027-05-08|Vaishakh|sud|2|||
  2027-05-09|Vaishakh|sud|3||Akha Trij|
  2027-05-10|Vaishakh|sud|4|||
  2027-05-11|Vaishakh|sud|6|||
  2027-05-12|Vaishakh|sud|7|||
  2027-05-13|Vaishakh|sud|8|||
  2027-05-14|Vaishakh|sud|9|||
  2027-05-15|Vaishakh|sud|10|||
  2027-05-16|Vaishakh|sud|11|Mohini||E
  2027-05-17|Vaishakh|sud|12|||
  2027-05-18|Vaishakh|sud|13|||
  2027-05-19|Vaishakh|sud|14|||
  2027-05-20|Vaishakh|sud|15|||
  2027-05-21|Vaishakh|vad|1|||
  2027-05-22|Vaishakh|vad|2|||
  2027-05-23|Vaishakh|vad|3|||
  2027-05-24|Vaishakh|vad|4|||
  2027-05-25|Vaishakh|vad|5|||
  2027-05-26|Vaishakh|vad|6|||
  2027-05-27|Vaishakh|vad|7|||
  2027-05-28|Vaishakh|vad|7|||
  2027-05-29|Vaishakh|vad|8|||
  2027-05-30|Vaishakh|vad|9|||
  2027-05-31|Vaishakh|vad|10|||
  2027-06-01|Vaishakh|vad|11|Apara|Shri Vallabhacharya Prakatyotsav|E
  2027-06-02|Vaishakh|vad|12|||
  2027-06-03|Vaishakh|vad|13|||
  2027-06-04|Vaishakh|vad|15|||
  2027-06-05|Jeth|sud|1|||
  2027-06-06|Jeth|sud|2|||
  2027-06-07|Jeth|sud|3|||
  2027-06-08|Jeth|sud|4|||
  2027-06-09|Jeth|sud|5|||
  2027-06-10|Jeth|sud|6|||
  2027-06-11|Jeth|sud|8|||
  2027-06-12|Jeth|sud|9|||
  2027-06-13|Jeth|sud|10|||
  2027-06-14|Jeth|sud|11|Nirjala||E
  2027-06-15|Jeth|sud|12|||
  2027-06-16|Jeth|sud|13|||
  2027-06-17|Jeth|sud|14|||
  2027-06-18|Jeth|sud|15|||
  2027-06-19|Jeth|sud|15|||
  2027-06-20|Jeth|vad|1|||
  2027-06-21|Jeth|vad|2|||
  2027-06-22|Jeth|vad|3|||
  2027-06-23|Jeth|vad|4|||
  2027-06-24|Jeth|vad|5|||
  2027-06-25|Jeth|vad|6|||
  2027-06-26|Jeth|vad|7|||
  2027-06-27|Jeth|vad|8|||
  2027-06-28|Jeth|vad|9|||
  2027-06-29|Jeth|vad|10|||
  2027-06-30|Jeth|vad|11|Yogini||E
  2027-07-01|Jeth|vad|12|||
  2027-07-02|Jeth|vad|13|||
  2027-07-03|Jeth|vad|14|||
  2027-07-04|Jeth|vad|15|||
  2027-07-05|Ashadh|sud|2||Rath Yatra|
  2027-07-06|Ashadh|sud|3|||
  2027-07-07|Ashadh|sud|4|||
  2027-07-08|Ashadh|sud|5|||
  2027-07-09|Ashadh|sud|6|||
  2027-07-10|Ashadh|sud|7|||
  2027-07-11|Ashadh|sud|8|||
  2027-07-12|Ashadh|sud|9|||
  2027-07-13|Ashadh|sud|10|||
  2027-07-14|Ashadh|sud|11|Devshayani|Dev Podhi Agiyaras|E
  2027-07-15|Ashadh|sud|12|||
  2027-07-16|Ashadh|sud|13|||
  2027-07-17|Ashadh|sud|14|||
  2027-07-18|Ashadh|sud|15|||
  2027-07-19|Ashadh|vad|1|||
  2027-07-20|Ashadh|vad|2|||
  2027-07-21|Ashadh|vad|3|||
  2027-07-22|Ashadh|vad|4|||
  2027-07-23|Ashadh|vad|4|||
  2027-07-24|Ashadh|vad|5|||
  2027-07-25|Ashadh|vad|6|||
  2027-07-26|Ashadh|vad|7|||
  2027-07-27|Ashadh|vad|8|||
  2027-07-28|Ashadh|vad|9|||
  2027-07-29|Ashadh|vad|10|||
  2027-07-30|Ashadh|vad|12|Kamika||E
  2027-07-31|Ashadh|vad|13|||
  2027-08-01|Ashadh|vad|14|||
  2027-08-02|Ashadh|vad|15|||
  2027-08-03|Shravan|sud|1|||
  2027-08-04|Shravan|sud|2|||
  2027-08-05|Shravan|sud|4|||
  2027-08-06|Shravan|sud|5|||
  2027-08-07|Shravan|sud|6|||
  2027-08-08|Shravan|sud|7|||
  2027-08-09|Shravan|sud|8|||
  2027-08-10|Shravan|sud|9|||
  2027-08-11|Shravan|sud|10|||
  2027-08-12|Shravan|sud|11|Pavitra||E
  2027-08-13|Shravan|sud|12|||
  2027-08-14|Shravan|sud|13|||
  2027-08-15|Shravan|sud|13|||
  2027-08-16|Shravan|sud|14|||
  2027-08-17|Shravan|sud|15||Raksha Bandhan|
  2027-08-18|Shravan|vad|1|||
  2027-08-19|Shravan|vad|2|||
  2027-08-20|Shravan|vad|3|||
  2027-08-21|Shravan|vad|4|||
  2027-08-22|Shravan|vad|5|||
  2027-08-23|Shravan|vad|6|||
  2027-08-24|Shravan|vad|7|||
  2027-08-25|Shravan|vad|8||Janmashtami|
  2027-08-26|Shravan|vad|9||Nandotsav|
  2027-08-27|Shravan|vad|10|||
  2027-08-28|Shravan|vad|11|Aja||E
  2027-08-29|Shravan|vad|12|||
  2027-08-30|Shravan|vad|14|||
  2027-08-31|Shravan|vad|15|||
  2027-09-01|Bhadarva|sud|1|||
  2027-09-02|Bhadarva|sud|2|||
  2027-09-03|Bhadarva|sud|3|||
  2027-09-04|Bhadarva|sud|4||Ganesh Chaturthi|
  2027-09-05|Bhadarva|sud|5|||
  2027-09-06|Bhadarva|sud|6|||
  2027-09-07|Bhadarva|sud|7|||
  2027-09-08|Bhadarva|sud|8|||
  2027-09-09|Bhadarva|sud|9|||
  2027-09-10|Bhadarva|sud|10|||
  2027-09-11|Bhadarva|sud|11|Jal Jhilani||E
  2027-09-12|Bhadarva|sud|12|||
  2027-09-13|Bhadarva|sud|13|||
  2027-09-14|Bhadarva|sud|14|||
  2027-09-15|Bhadarva|sud|15|||
  2027-09-16|Bhadarva|vad|1|||
  2027-09-17|Bhadarva|vad|2|||
  2027-09-18|Bhadarva|vad|2|||
  2027-09-19|Bhadarva|vad|3|||
  2027-09-20|Bhadarva|vad|4|||
  2027-09-21|Bhadarva|vad|5|||
  2027-09-22|Bhadarva|vad|7|||
  2027-09-23|Bhadarva|vad|8|||
  2027-09-24|Bhadarva|vad|9|||
  2027-09-25|Bhadarva|vad|10|||
  2027-09-26|Bhadarva|vad|11|Indira||E
  2027-09-27|Bhadarva|vad|12|||
  2027-09-28|Bhadarva|vad|13|||
  2027-09-29|Bhadarva|vad|14|||
  2027-09-30|Bhadarva|vad|15|||
  2027-10-01|Aaso|sud|2|||
  2027-10-02|Aaso|sud|3|||
  2027-10-03|Aaso|sud|4|||
  2027-10-04|Aaso|sud|5|||
  2027-10-05|Aaso|sud|6|||
  2027-10-06|Aaso|sud|7|||
  2027-10-07|Aaso|sud|8|||
  2027-10-08|Aaso|sud|9|||
  2027-10-09|Aaso|sud|9|||
  2027-10-10|Aaso|sud|10||Dashera|
  2027-10-11|Aaso|sud|11|Pashankusha||E
  2027-10-12|Aaso|sud|12|||
  2027-10-13|Aaso|sud|13|||
  2027-10-14|Aaso|sud|14|||
  2027-10-15|Aaso|sud|15||Sharad Punam|
  2027-10-16|Aaso|vad|1|||
  2027-10-17|Aaso|vad|2|||
  2027-10-18|Aaso|vad|3|||
  2027-10-19|Aaso|vad|4|||
  2027-10-20|Aaso|vad|5|||
  2027-10-21|Aaso|vad|6|||
  2027-10-22|Aaso|vad|7|||
  2027-10-23|Aaso|vad|8|||
  2027-10-24|Aaso|vad|9|||
  2027-10-25|Aaso|vad|11|Rama||E
  2027-10-26|Aaso|vad|12|||
  2027-10-27|Aaso|vad|13||Dhanteras|
  2027-10-28|Aaso|vad|14|||
  2027-10-29|Aaso|vad|15||Diwali|
  2027-10-30|Kartak|sud|1||Bestu Varas;Annakut|
  2027-10-31|Kartak|sud|2||Bhai Bij|
  2027-11-01|Kartak|sud|3|||
  2027-11-02|Kartak|sud|4|||
  2027-11-03|Kartak|sud|5|||
  2027-11-04|Kartak|sud|6|||
  2027-11-05|Kartak|sud|7|||
  2027-11-06|Kartak|sud|8|||
  2027-11-07|Kartak|sud|9|||
  2027-11-08|Kartak|sud|10|||
  2027-11-09|Kartak|sud|10|||
  2027-11-10|Kartak|sud|11|Prabodhini|Dev Uthi Agiyaras|E
  2027-11-11|Kartak|sud|12|||
  2027-11-12|Kartak|sud|13|||
  2027-11-13|Kartak|sud|14|||
  2027-11-14|Kartak|sud|15||Dev Diwali|
  2027-11-15|Kartak|vad|1|||
  2027-11-16|Kartak|vad|3|||
  2027-11-17|Kartak|vad|4|||
  2027-11-18|Kartak|vad|5|||
  2027-11-19|Kartak|vad|6|||
  2027-11-20|Kartak|vad|7|||
  2027-11-21|Kartak|vad|8|||
  2027-11-22|Kartak|vad|9|||
  2027-11-23|Kartak|vad|10|||
  2027-11-24|Kartak|vad|11|Utpanna||E
  2027-11-25|Kartak|vad|12|||
  2027-11-26|Kartak|vad|13|||
  2027-11-27|Kartak|vad|14|||
  2027-11-28|Kartak|vad|15|||
  2027-11-29|Magshar|sud|1|||
  2027-11-30|Magshar|sud|2|||
  2027-12-01|Magshar|sud|3|||
  2027-12-02|Magshar|sud|4|||
  2027-12-03|Magshar|sud|5|||
  2027-12-04|Magshar|sud|6|||
  2027-12-05|Magshar|sud|7|||
  2027-12-06|Magshar|sud|8|||
  2027-12-07|Magshar|sud|9|||
  2027-12-08|Magshar|sud|10|||
  2027-12-09|Magshar|sud|11|Mokshada||E
  2027-12-10|Magshar|sud|12|||
  2027-12-11|Magshar|sud|13|||
  2027-12-12|Magshar|sud|14|||
  2027-12-13|Magshar|sud|15|||
  2027-12-14|Magshar|vad|1|||
  2027-12-15|Magshar|vad|2|||
  2027-12-16|Magshar|vad|3|||
  2027-12-17|Magshar|vad|4|||
  2027-12-18|Magshar|vad|5|||
  2027-12-19|Magshar|vad|7|||
  2027-12-20|Magshar|vad|8|||
  2027-12-21|Magshar|vad|9|||
  2027-12-22|Magshar|vad|10|||
  2027-12-23|Magshar|vad|11|Saphala||E
  2027-12-24|Magshar|vad|12|||
  2027-12-25|Magshar|vad|13|||
  2027-12-26|Magshar|vad|14|||
  2027-12-27|Magshar|vad|15|||
  2027-12-28|Posh|sud|1|||
  2027-12-29|Posh|sud|2|||
  2027-12-30|Posh|sud|3|||
  2027-12-31|Posh|sud|3|||
''';
