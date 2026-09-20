import '../domain/bhajan.dart';

/// Bundled sample content so the app runs before Firestore has data.
/// Also handy as a seed: `for (final b in sampleBhajans) col.doc(b.id).set(b.toMap())`.
///
/// Lyrics for these live in `sample_lyrics.dart`.
const List<Bhajan> sampleBhajans = [
  Bhajan(
    id: 'yamunashtak',
    title: 'શ્રી યમુનાષ્ટક',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya',
    seva: 'Rajbhog',
  ),
  Bhajan(
    id: 'madhurashtakam',
    title: 'મધુરાષ્ટકમ્',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya',
    seva: 'Rajbhog',
  ),
  Bhajan(
    id: 'chalo-sakhi-yamuna-tat',
    title: 'ચલો સખી યમુના તટ',
    category: BhajanCategory.kirtan,
    poet: 'Surdas',
    seva: 'Gwal',
  ),
  Bhajan(
    id: 'aarti-yamunaji',
    title: 'આરતી શ્રી યમુનાજી ની',
    category: BhajanCategory.aarti,
    poet: 'Paramananddas',
    seva: 'Sandhya Aarti',
  ),
  Bhajan(
    id: 'aarti-shrinathji',
    title: 'આરતી શ્રીનાથજી ની',
    category: BhajanCategory.aarti,
    poet: 'Paramananddas',
    seva: 'Sandhya Aarti',
  ),
  Bhajan(
    id: 'jago-mohan-pyare',
    title: 'જાગો મોહન પ્યારે',
    category: BhajanCategory.kirtan,
    poet: 'Surdas',
    seva: 'Mangala',
  ),
  Bhajan(
    id: 'jai-jai-shri-vallabh',
    title: 'જય જય શ્રી વલ્લભ',
    category: BhajanCategory.varta,
    poet: 'Traditional',
    seva: 'Shayan',
    tags: ['vadhai'],
  ),
  Bhajan(
    id: 'maiya-mori',
    title: 'મૈયા મોરી મૈં નહીં માખન ખાયો',
    category: BhajanCategory.pad,
    poet: 'Surdas',
    seva: 'Gwal',
  ),
  Bhajan(
    id: 'sarvottam-stotra',
    title: 'શ્રી સર્વોત્તમ સ્તોત્ર',
    category: BhajanCategory.kirtan,
    poet: 'Shri Gusainji',
    seva: 'Rajbhog',
  ),
];
