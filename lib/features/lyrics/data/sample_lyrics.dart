import '../../bhajans/data/sample_bhajans.dart';
import '../domain/lyrics.dart';

/// Sample lyrics for demo mode. Only Yamunashtak has real text; every other
/// sample bhajan reuses it so each list row opens something.
/// Seed: `for (final l in sampleLyrics.values) col.doc(l.bhajanId).set(l.toMap())`.
final Map<String, Lyrics> sampleLyrics = {
  for (final b in sampleBhajans) b.id: Lyrics(bhajanId: b.id, byScript: _yamunashtak),
};

// One string per line; '' separates stanzas.
const Map<Script, List<String>> _yamunashtak = {
  Script.gujarati: [
    'નમામિ યમુનામહં સકલ સિદ્ધિ હેતું મુદા,',
    'મુરારિ પદ પંકજ સ્ફુરદમંદ રેણૂત્કટામ્ ।',
    'તટસ્થ નવ કાનન પ્રકટ મોદ પુષ્પામ્બુના,',
    'સુરાસુર સુપૂજિત સ્મર પિતુઃ શ્રિયં બિભ્રતીમ્ ॥',
    '',
    'કલિંદ ગિરિ મસ્તકે પતદમંદ પૂરોજ્જ્વલા,',
    'વિલાસ ગમનોલ્લસત્ પ્રકટ ગંડ શૈલોન્નતા ।',
    'સઘોષ ગતિ દંતુરા સમધિરૂઢ દોલોત્તમા,',
    'મુકુંદ રતિ વર્ધિની જયતિ પદ્મ બંધોઃ સુતા ॥',
    '',
    'ભુવં ભુવન પાવનીમધિગતામનેકસ્વનૈઃ,',
    'પ્રિયાભિરિવ સેવિતાં શુક મયૂર હંસાદિભિઃ ।',
    'તરંગ ભુજ કંકણ પ્રકટ મુક્તિકા વાલુકા,',
    'નિતંબ તટ સુંદરીં નમત કૃષ્ણ તુર્ય પ્રિયામ્ ॥',
    '',
    'અનંત ગુણ ભૂષિતે શિવ વિરંચિ દેવ સ્તુતે,',
    'ઘનાઘન નિભે સદા ધ્રુવ પરાશરાભીષ્ટદે ।',
    'વિશુદ્ધ મથુરા તટે સકલ ગોપ ગોપી વૃતે,',
    'કૃપા જલધિ સંશ્રિતે મમ મનઃ સુખં ભાવય ॥',
    '',
    'યયા ચરણ પદ્મજા મુરરિપોઃ પ્રિયં ભાવુકા,',
    'સમાગમનતો ભવત્ સકલ સિદ્ધિદા સેવતામ્ ।',
    'તયા સદૃશતામિયાત્ કમલજા સપત્નીવ યત્,',
    'હરિપ્રિય કલિંદયા મનસિ મે સદા સ્થીયતામ્ ॥',
  ],
  Script.hindi: [
    'नमामि यमुनामहं सकल सिद्धि हेतुं मुदा,',
    'मुरारि पद पंकज स्फुरदमंद रेणूत्कटाम् ।',
    'तटस्थ नव कानन प्रकट मोद पुष्पाम्बुना,',
    'सुरासुर सुपूजित स्मर पितुः श्रियं बिभ्रतीम् ॥',
    '',
    'कलिंद गिरि मस्तके पतदमंद पूरोज्ज्वला,',
    'विलास गमनोल्लसत् प्रकट गंड शैलोन्नता ।',
    'सघोष गति दंतुरा समधिरूढ दोलोत्तमा,',
    'मुकुंद रति वर्धिनी जयति पद्म बंधोः सुता ॥',
  ],
  Script.english: [
    'Namami Yamunam aham sakala siddhi hetum muda,',
    'Murari pada pankaja sphurad amanda renutkatam.',
    'Tatastha nava kanana prakata moda pushpambuna,',
    'Surasura supujita smara pituh shriyam bibhratim.',
    '',
    'Kalinda giri mastake patad amanda purojjvala,',
    'Vilasa gamanollasat prakata ganda shailonnata.',
    'Saghosha gati dantura samadhirudha dolottama,',
    'Mukunda rati vardhini jayati padma bandhoh suta.',
  ],
};
