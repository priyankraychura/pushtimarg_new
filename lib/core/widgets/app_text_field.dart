import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Tall filled input with the label tucked *inside* the field above the
/// value — the sign-in field from the mockup. Wraps [TextFormField] so
/// validators and autofill work; the error shows beneath the box.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;
  final _focus = FocusNode();
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    _controller.addListener(_onText);
    _hasText = _controller.text.isNotEmpty;
  }

  void _refresh() => setState(() {});

  void _onText() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.removeListener(_onText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final focused = _focus.hasFocus;
    // Label floats up when the field is active or filled; otherwise it sits
    // in the middle as the placeholder.
    final floating = focused || _hasText;

    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller?.text,
      builder: (field) {
        final hasError = field.hasError;
        final borderColor = hasError
            ? context.scheme.error
            : focused
                ? c.brand
                : c.line;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _focus.requestFocus,
              child: AnimatedContainer(
                duration: AppMotion.fast,
                height: AppSizes.input,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadius.r(AppRadius.xl),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: focused
                      ? [BoxShadow(color: c.brand.withValues(alpha: .10), spreadRadius: 4)]
                      : const [],
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: c.ink3),
                      Gap.md,
                    ],
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.none,
                        children: [
                          // Value — sits in the lower half once the label has floated.
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              obscureText: _hidden,
                              keyboardType: widget.keyboardType,
                              textInputAction: widget.textInputAction,
                              autofillHints: widget.autofillHints,
                              onChanged: field.didChange,
                              onSubmitted: widget.onSubmitted,
                              cursorColor: c.brand,
                              style: AppTypography.bodyMedium.copyWith(fontSize: 15.5, height: 1.2, color: c.ink),
                              decoration: const InputDecoration(
                                isDense: true,
                                isCollapsed: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          // Floating label: centred placeholder → small label at the top.
                          IgnorePointer(
                            child: AnimatedAlign(
                              duration: AppMotion.fast,
                              curve: AppMotion.standard,
                              alignment: floating ? const Alignment(-1, -1) : Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(top: floating ? 11 : 0),
                                child: AnimatedDefaultTextStyle(
                                  duration: AppMotion.fast,
                                  curve: AppMotion.standard,
                                  style: floating
                                      ? AppTypography.labelSmall.copyWith(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: .2,
                                          height: 1,
                                          color: focused ? c.brandText : c.ink3,
                                        )
                                      : AppTypography.bodyMedium.copyWith(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w400,
                                          height: 1,
                                          color: c.ink3,
                                        ),
                                  child: Text(widget.label),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.obscure)
                      GestureDetector(
                        onTap: () => setState(() => _hidden = !_hidden),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Icon(
                            _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: c.ink3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, top: AppSpacing.xs),
                child: Text(field.errorText!,
                    style: AppTypography.caption.copyWith(fontSize: 12, color: context.scheme.error)),
              ),
          ],
        );
      },
    );
  }
}
