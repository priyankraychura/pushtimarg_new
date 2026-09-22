import 'package:flutter_test/flutter_test.dart';
import 'package:pushti_kirtan/features/auth/data/auth_repository.dart';
import 'package:pushti_kirtan/features/auth/data/guest_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<GuestSessionStore> store([Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    return GuestSessionStore(await SharedPreferences.getInstance());
  }

  test('starts inactive and survives a restart once started', () async {
    final s = await store();
    expect(s.active, isFalse);

    await s.start();
    expect(s.active, isTrue);

    // A fresh store over the same prefs — i.e. the next app launch.
    expect((await store({'auth.local_guest': true})).active, isTrue);
  });

  test('announces every flip so the auth stream can re-publish', () async {
    final s = await store();
    final seen = <bool>[];
    final sub = s.changes.listen(seen.add);

    await s.start();
    await s.clear();
    await s.clear(); // already cleared — nothing to announce

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(seen, [true, false]);
  });

  test('signing in clears the guest', () async {
    final s = await store({'auth.local_guest': true});
    await s.clear();
    expect(s.active, isFalse);
  });

  test('the fallback guest is anonymous and device-local', () {
    const guest = FirebaseAuthRepository.localGuest;
    expect(guest.isAnonymous, isTrue);
    expect(guest.isLocalGuest, isTrue);
    expect(guest.name, 'Guest');
  });
}
