import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Scroll physics that snaps between two resting points — 0 (expanded header)
/// and [snapOffset] (header in its compact state). Beyond [snapOffset] the
/// list scrolls with the platform's normal physics (the [parent]).
///
/// Any release inside the zone resolves to one end: a flick upward goes to
/// [snapOffset], a flick downward goes to 0, a slow drag goes to whichever is
/// nearer. A fling from the list that would coast to a halt inside the zone
/// is redirected to the nearest end so the header never parks half-open.
///
/// Always give it the platform physics as [parent] (see
/// [SnapHeaderScrollPhysics.of]); without one, releases outside the zone
/// have no ballistic simulation and the list stops dead.
class SnapHeaderScrollPhysics extends ScrollPhysics {
  const SnapHeaderScrollPhysics({required this.snapOffset, super.parent});

  /// Snap physics layered over the platform default for [context].
  factory SnapHeaderScrollPhysics.of(BuildContext context, {required double snapOffset}) =>
      SnapHeaderScrollPhysics(
        snapOffset: snapOffset,
        parent: ScrollConfiguration.of(context).getScrollPhysics(context),
      );

  final double snapOffset;

  @override
  SnapHeaderScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      SnapHeaderScrollPhysics(snapOffset: snapOffset, parent: buildParent(ancestor));

  static const double _flickVelocity = 250;

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final pixels = position.pixels;
    final min = position.minScrollExtent;
    final inZone = pixels > min && pixels < snapOffset;

    if (inZone) return _snap(pixels, velocity, min);

    // Outside the zone: run the platform simulation, but if it would coast
    // to a halt inside the zone, snap instead so the header never parks
    // half-open.
    final sim = super.createBallisticSimulation(position, velocity);
    if (sim == null) return null;
    final end = sim.x(20);
    if (end > min && end < snapOffset) return _snap(pixels, velocity, min);
    return sim;
  }

  Simulation _snap(double pixels, double velocity, double min) {
    final double target;
    if (velocity > _flickVelocity) {
      target = snapOffset;
    } else if (velocity < -_flickVelocity) {
      target = min;
    } else {
      target = pixels > (min + snapOffset) / 2 ? snapOffset : min;
    }
    return _SnapSimulation(start: pixels, end: target, velocity: velocity);
  }
}

/// Ease-out glide from [start] to [end]. Duration scales with distance and
/// release speed, and the curve guarantees it lands exactly on [end] with no
/// overshoot — unlike a spring, which bounces past the target on a hard flick.
class _SnapSimulation extends Simulation {
  _SnapSimulation({required this.start, required this.end, required double velocity})
      : duration = _durationFor((end - start).abs(), velocity.abs());

  final double start;
  final double end;
  final double duration;

  static const Curve _curve = Curves.easeOutCubic;

  static double _durationFor(double distance, double speed) {
    if (distance == 0) return 0.001;
    // Faster flick → shorter glide, but never snappier than 220ms or lazier than 420ms.
    final byVelocity = distance / math.max(speed, 1200);
    return byVelocity.clamp(0.22, 0.42);
  }

  double _p(double t) => (t / duration).clamp(0.0, 1.0);

  @override
  double x(double time) => start + (end - start) * _curve.transform(_p(time));

  @override
  double dx(double time) {
    if (time >= duration) return 0;
    const step = 0.001;
    return (x(time + step) - x(time)) / step;
  }

  @override
  bool isDone(double time) => time >= duration;
}
