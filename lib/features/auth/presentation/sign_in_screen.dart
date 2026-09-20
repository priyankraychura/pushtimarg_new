import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';
import 'widgets/google_logo.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).submit(_email.text, _password.text);
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      context.showSnack('Enter your email first, then tap Forgot password.');
      return;
    }
    final ok = await ref.read(authControllerProvider.notifier).resetPassword(email);
    if (ok && mounted) context.showSnack('Reset link sent to $email.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = ref.watch(authControllerProvider);
    final isRegister = state.mode == AuthMode.register;

    ref.listen(authControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) context.showSnack(error);
    });

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(top: -140, right: -120, child: _BrandGlow()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 44, AppSpacing.xxl, AppSpacing.xxl),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: c.brand,
                          borderRadius: AppRadius.r(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(color: c.brand.withValues(alpha: .5), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -12),
                          ],
                        ),
                        child: Icon(Icons.spa_outlined, color: c.brandInk, size: 28),
                      ),
                      const SizedBox(height: 22),
                      Text('Jai Shree Krushna', style: AppTypography.displayLarge.copyWith(color: c.ink)),
                      Gap.sm,
                      Text(
                        isRegister
                            ? 'Create an account to keep your favourites and reading spot on every phone.'
                            : 'Sign in to keep your favourites and reading spot on every phone.',
                        style: AppTypography.bodyMedium.copyWith(color: c.ink2),
                      ),
                      const SizedBox(height: 30),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Enter a valid email address.' : null,
                      ),
                      Gap.md,
                      AppTextField(
                        label: 'Password',
                        controller: _password,
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters.' : null,
                      ),
                      if (!isRegister) ...[
                        Gap.sm,
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: state.busy ? null : _forgot,
                            child: Text('Forgot password?',
                                style: AppTypography.labelMedium.copyWith(fontSize: 13.5, color: c.brandText)),
                          ),
                        ),
                      ],
                      Gap.lg,
                      AppButton(
                        label: isRegister ? 'Create account' : 'Sign in',
                        trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
                        loading: state.busy,
                        onPressed: state.busy ? null : _submit,
                      ),
                      const SizedBox(height: 22),
                      _OrDivider(label: 'or continue with'),
                      Gap.lg,
                      AppButton(
                        label: 'Google',
                        variant: AppButtonVariant.outlined,
                        leading: const GoogleLogo(size: 20),
                        onPressed: state.busy ? null : () => ref.read(authControllerProvider.notifier).google(),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: GestureDetector(
                          onTap: () => ref.read(authControllerProvider.notifier).toggleMode(),
                          child: Text.rich(
                            TextSpan(
                              style: AppTypography.bodyMedium.copyWith(fontSize: 14, color: c.ink2),
                              children: [
                                TextSpan(text: isRegister ? 'Already have an account? ' : 'New here? '),
                                TextSpan(
                                  text: isRegister ? 'Sign in' : 'Create an account',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: c.brandText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.md,
                      Center(
                        child: GestureDetector(
                          onTap: state.busy ? null : () => ref.read(authControllerProvider.notifier).guest(),
                          child: Text('Continue without an account',
                              style: AppTypography.labelMedium.copyWith(fontSize: 14, color: c.ink3)),
                        ),
                      ),
                      Gap.lg,
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: AppTypography.caption.copyWith(fontSize: 11.5, color: c.ink3),
                            children: [
                              const TextSpan(text: 'By continuing you agree to the '),
                              TextSpan(text: 'Terms', style: TextStyle(fontWeight: FontWeight.w600, color: c.ink2)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, color: c.ink2)),
                              const TextSpan(text: '.'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ].animate(interval: 40.ms).fadeIn(duration: 350.ms).slideY(begin: .06, curve: AppMotion.standard),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft blurred marigold → rose → teal glow behind the top-right corner.
class _BrandGlow extends StatelessWidget {
  const _BrandGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: 360,
          height: 360,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppPalette.marigold.withValues(alpha: .45),
                AppPalette.rose.withValues(alpha: .35),
                AppPalette.teal.withValues(alpha: .25),
                Colors.transparent,
              ],
              stops: const [0, .35, .6, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(child: Divider(color: c.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: AppTypography.caption.copyWith(fontSize: 12.5, color: c.ink3)),
        ),
        Expanded(child: Divider(color: c.line)),
      ],
    );
  }
}
