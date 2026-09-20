import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent, SwipeEdge;

import '../theme/theme.dart';

/// Where a container transform starts from: the tapped card's on-screen rect.
///
/// Capture it in the tap handler and pass it as the route's `extra`:
/// ```dart
/// onTap: () => context.push(AppRoutes.lyricsFor(id), extra: ContainerOrigin.of(context)),
/// ```
class ContainerOrigin {
  const ContainerOrigin(this.rect, {this.radius = AppRadius.lg});

  final Rect rect;
  final double radius;

  /// Global rect of [context]'s render box, or null before first layout.
  static ContainerOrigin? of(BuildContext context, {double radius = AppRadius.lg}) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return ContainerOrigin(box.localToGlobal(Offset.zero) & box.size, radius: radius);
  }
}

/// Stock-Pixel container transform as a go_router page: the tapped card grows
/// into the full screen on the emphasized curve, and shrinks back into place
/// on close. On Android 14+ the predictive-back gesture scales the screen
/// down under the finger first, then commits by collapsing into the card.
///
/// Without an [origin] (deep link, restored route) it zooms from the centre.
class ContainerTransformPage<T> extends Page<T> {
  const ContainerTransformPage({
    super.key,
    required this.child,
    this.origin,
    this.color,
  });

  final Widget child;
  final ContainerOrigin? origin;

  /// Surface behind the incoming screen while it fades in.
  final Color? color;

  @override
  Route<T> createRoute(BuildContext context) => _ContainerTransformRoute<T>(this);
}

class _ContainerTransformRoute<T> extends PageRoute<T> {
  _ContainerTransformRoute(ContainerTransformPage<T> page) : super(settings: page);

  ContainerTransformPage<T> get _page => settings as ContainerTransformPage<T>;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 450);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 350);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: .35);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  // The card grows over the list; don't let the list fade away underneath.
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _ContainerTransform(
        route: this,
        animation: animation,
        origin: _page.origin,
        color: _page.color ?? Theme.of(context).scaffoldBackgroundColor,
        child: child,
      );
}

class _ContainerTransform extends StatefulWidget {
  const _ContainerTransform({
    required this.route,
    required this.animation,
    required this.origin,
    required this.color,
    required this.child,
  });

  final PageRoute<dynamic> route;
  final Animation<double> animation;
  final ContainerOrigin? origin;
  final Color color;
  final Widget child;

  @override
  State<_ContainerTransform> createState() => _ContainerTransformState();
}

class _ContainerTransformState extends State<_ContainerTransform> with WidgetsBindingObserver {
  // M3 "emphasized" for the open (soft start, long settle) and "standard" for
  // the close (brisk, eases into the card). Running one curve backwards makes
  // the close hesitate, then snap.
  static const Curve _openCurve = Curves.easeInOutCubicEmphasized;
  static const Curve _closeCurve = Easing.standard;

  // Fade windows in container progress (0 = card, 1 = full screen).
  static const _openSurfaceFadeEnd = .2;
  static const _openContentFadeStart = .1;
  static const _openContentFadeEnd = .5;
  static const _closeSurfaceFadeEnd = .12;
  static const _closeContentFadeStart = .6;

  // Eyeballed against the Android full-screen predictive back spec.
  static const _gestureMinScale = .9;
  static const _gestureRadius = 32.0;

  // Predictive back gesture state.
  bool _gesture = false;
  PredictiveBackEvent? _startEvent;
  PredictiveBackEvent? _lastEvent;

  // Where the shrink-to-card starts from: full screen normally, or the
  // gesture-shrunk rect when the user commits a back swipe mid-gesture.
  Rect? _fromRect;
  double _fromRadius = 0;
  double _fromValue = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.animation.addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _gesture = false;
        _startEvent = _lastEvent = null;
        _fromRect = null;
        _fromValue = 1;
      });
    }
  }

  // ---- WidgetsBindingObserver (predictive back) ----------------------------

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent || !widget.route.isCurrent || !widget.route.popGestureEnabled) return false;
    widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    setState(() {
      _gesture = true;
      _startEvent = _lastEvent = backEvent;
    });
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (!_gesture) return;
    widget.route.handleUpdateBackGestureProgress(progress: 1 - backEvent.progress);
    setState(() => _lastEvent = backEvent);
  }

  @override
  void handleCancelBackGesture() {
    if (!_gesture) return;
    // Stay in gesture mode while the controller animates back to 1; _onStatus
    // resets once it completes.
    widget.route.handleCancelBackGesture();
  }

  @override
  void handleCommitBackGesture() {
    if (!_gesture) return;
    final size = MediaQuery.sizeOf(context);
    final value = widget.animation.value;
    setState(() {
      _fromRect = _gestureRect(size, 1 - value);
      _fromRadius = _gestureRadius * (1 - value);
      _fromValue = value;
      _gesture = false;
      _startEvent = _lastEvent = null;
    });
    widget.route.handleCommitBackGesture();
  }

  // ---- geometry ------------------------------------------------------------

  /// Screen shrunk toward the swipe edge, following the finger vertically.
  Rect _gestureRect(Size size, double progress) {
    final scale = 1 - (1 - _gestureMinScale) * progress;
    final xShift = (size.width / 20 - 8) * progress * (_startEvent?.swipeEdge == SwipeEdge.right ? -1 : 1);
    final startY = _startEvent?.touchOffset?.dy;
    final lastY = _lastEvent?.touchOffset?.dy;
    final yShift = startY != null && lastY != null ? (lastY - startY) * .15 : 0.0;
    final w = size.width * scale, h = size.height * scale;
    return Rect.fromLTWH((size.width - w) / 2 + xShift, (size.height - h) / 2 + yShift, w, h);
  }

  Rect _centreZoom(Size size) => Rect.fromCenter(center: size.center(Offset.zero), width: size.width * .85, height: size.height * .85);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final full = Offset.zero & size;
    final origin = widget.origin?.rect ?? _centreZoom(size);
    final originRadius = widget.origin?.radius ?? AppRadius.card;

    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder: (context, child) {
        final value = widget.animation.value;
        final Rect rect;
        final double radius;
        final double surfaceOpacity;
        final double contentOpacity;
        final double contentScale;

        if (_gesture) {
          // Whole screen shrinks under the finger.
          final p = 1 - value;
          rect = _gestureRect(size, p);
          radius = _gestureRadius * p;
          surfaceOpacity = contentOpacity = 1;
          contentScale = rect.width / size.width;
        } else {
          // Expand / collapse: the surface reveals 1:1 content (no zoom).
          final closing = widget.animation.status == AnimationStatus.reverse;
          final raw = (value / _fromValue).clamp(0.0, 1.0);
          final t = closing ? 1 - _closeCurve.transform(1 - raw) : _openCurve.transform(raw);
          rect = Rect.lerp(origin, _fromRect ?? full, t)!;
          radius = _lerp(originRadius, _fromRect == null ? 0 : _fromRadius, t);
          if (closing) {
            // Content drops out early; the surface stays solid until it is
            // nearly back on the card, then crossfades into it.
            surfaceOpacity = _ramp(t, 0, _closeSurfaceFadeEnd);
            contentOpacity = _ramp(t, _closeContentFadeStart, 1);
          } else {
            // Card crossfades into the surface first, then content fades in.
            surfaceOpacity = _ramp(t, 0, _openSurfaceFadeEnd);
            contentOpacity = _ramp(t, _openContentFadeStart, _openContentFadeEnd);
          }
          // Only scaled when collapsing from a gesture-shrunk screen, so the
          // hand-off from the gesture is seamless.
          contentScale = _lerp(1, _fromRect == null ? 1 : _fromRect!.width / size.width, t);
        }

        final settled = value == 1 && !_gesture;
        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                clipBehavior: settled ? Clip.none : Clip.antiAlias,
                // Alpha on the colour rather than an Opacity widget: no
                // full-screen saveLayer per frame for the surface.
                child: ColoredBox(
                  color: widget.color.withValues(alpha: widget.color.a * surfaceOpacity),
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Transform.scale(
                      scale: contentScale,
                      alignment: Alignment.topLeft,
                      // Boundary so the reader is painted once and only its
                      // layer's opacity/transform/offset change per frame.
                      child: RepaintBoundary(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: size.width,
                          maxWidth: size.width,
                          minHeight: size.height,
                          maxHeight: size.height,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// 0 → 1 as [t] goes from [from] to [to], clamped.
double _ramp(double t, double from, double to) => ((t - from) / (to - from)).clamp(0.0, 1.0);
