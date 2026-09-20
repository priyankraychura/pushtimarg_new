import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bhajans/domain/bhajan.dart';
import '../../bhajans/providers/bhajan_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../domain/seva.dart';

final sevaScheduleProvider = Provider<SevaSchedule>(
  (ref) => SevaSchedule(ref.watch(sevaTimesProvider)),
);

/// Re-evaluated every minute so the "now" chip and rail move on their own.
final currentSevaProvider = StreamProvider<Seva>((ref) async* {
  final schedule = ref.watch(sevaScheduleProvider);
  yield schedule.current();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => schedule.current());
});

/// Ashtachhap poets shown on Home.
const ashtachhapPoets = [
  ('सू', 'Surdas'),
  ('प', 'Paramananddas'),
  ('कु', 'Kumbhandas'),
  ('कृ', 'Krishnadas'),
  ('न', 'Nanddas'),
  ('गो', 'Govindswami'),
  ('छी', 'Chhitswami'),
  ('च', 'Chaturbhujdas'),
];

/// All bhajans sung at a seva, in list order.
final bhajansForSevaProvider = Provider.family<List<Bhajan>, Seva>((ref, seva) {
  final bhajans = ref.watch(allBhajansProvider).value ?? const <Bhajan>[];
  return bhajans.where((b) => b.seva == seva.name).toList();
});

/// The bhajan a seva card / "Read" button opens: the first one for that seva.
final bhajanForSevaProvider = Provider.family<Bhajan?, Seva>(
  (ref, seva) => ref.watch(bhajansForSevaProvider(seva)).firstOrNull,
);
