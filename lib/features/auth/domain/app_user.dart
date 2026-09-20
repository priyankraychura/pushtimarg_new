import 'package:flutter/foundation.dart';

/// Minimal user model so the UI never touches `firebase_auth.User` directly.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.provider = AuthProviderKind.email,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final AuthProviderKind provider;

  String get name {
    if (displayName != null && displayName!.trim().isNotEmpty) return displayName!;
    if (email != null && email!.contains('@')) return email!.split('@').first;
    return isAnonymous ? 'Guest' : 'Vaishnav';
  }

  String get providerLabel => switch (provider) {
        AuthProviderKind.google => 'Signed in with Google',
        AuthProviderKind.email => email ?? 'Signed in',
        AuthProviderKind.anonymous => 'Not signed in',
      };
}

enum AuthProviderKind { email, google, anonymous }

/// Thrown by repositories with a message already written for humans.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}
