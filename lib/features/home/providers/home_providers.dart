import 'package:flutter_riverpod/flutter_riverpod.dart';

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
