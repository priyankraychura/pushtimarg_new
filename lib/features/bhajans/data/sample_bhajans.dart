import '../domain/bhajan.dart';
import 'yamunaji_41_pad_bhajans.dart';

/// Bundled sample content so the app runs before Firestore has data.
/// Also the seed: Settings > "Seed sample data" pushes this to Firestore.
/// Lyrics for these live in `sample_lyrics.dart`.
/// Also includes `yamunaji41PadBhajans`.
const List<Bhajan> sampleBhajans = [
  Bhajan(
    id: 'aarti-shrinathji-mangala',
    title: 'આરતી શ્રીનાથજીની (મંગળા)',
    category: BhajanCategory.aarti,
    poet: 'Traditional',
    seva: 'Mangala',
    video: 'nL6guAGD-Mk',
  ),
  Bhajan(
    id: 'jai-jai-shri-yamuna-ma',
    title: 'જય જય શ્રી યમુના મા',
    category: BhajanCategory.aarti,
    poet: 'Traditional',
    seva: 'Sandhya Aarti',
  ),
  Bhajan(
    id: 'krushnashray',
    title: 'શ્રી કૃષ્ણાશ્રય',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya',
    seva: '',
  ),
  Bhajan(
    id: 'giriraj-dharyashtakam',
    title: 'શ્રી ગિરિરાજધાર્યાષ્ટકમ્',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya',
    seva: '',
  ),
  Bhajan(
    id: 'vaake-ambode-shrinathji',
    title: 'વાંકે અંબોડે શ્રીનાથજી',
    category: BhajanCategory.kirtan,
    poet: 'Madhavdas',
    seva: 'Shringar',
    video: 'nL6guAGD-Mk',
  ),
  Bhajan(
    id: 'yamunajini-stuti',
    title: 'શ્રી યમુનાજીની સ્તુતિ',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya (Gujarati anuvad)',
    seva: '',
    video: 'cI2e6bLgeiM',
  ),
  Bhajan(
    id: 'yamunashtak',
    title: 'શ્રી યમુનાષ્ટક',
    category: BhajanCategory.kirtan,
    poet: 'Shri Vallabhacharya',
    seva: 'Rajbhog',
    video: 'nL6guAGD-Mk',
  ),
  ...yamunaji41PadBhajans,
];
