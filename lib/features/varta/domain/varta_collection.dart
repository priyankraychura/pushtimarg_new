/// The two Varta granths — the Chaurasi (84) and Do Sau Bavan (252)
/// Vaishnav ni Varta — chosen on the Varta screen.
enum VartaCollection {
  chaurasi(
    count: 84,
    title: '84 Vaishnav ni Varta',
    titleGu: 'ચોર્યાસી વૈષ્ણવની વાર્તા',
    description: 'Vartas of the 84 Vaishnavs of Shri Mahaprabhuji Vallabhacharya.',
  ),
  doSauBavan(
    count: 252,
    title: '252 Vaishnav ni Varta',
    titleGu: 'બસો બાવન વૈષ્ણવની વાર્તા',
    description: 'Vartas of the 252 Vaishnavs of Shri Gusaiji Vitthalnathji.',
  );

  const VartaCollection({
    required this.count,
    required this.title,
    required this.titleGu,
    required this.description,
  });

  /// Number of vartas in the granth; also the number shown on its card.
  final int count;
  final String title;
  final String titleGu;
  final String description;

  static VartaCollection fromKey(String? key) => values.firstWhere(
        (v) => v.name == key,
        orElse: () => VartaCollection.chaurasi,
      );
}
