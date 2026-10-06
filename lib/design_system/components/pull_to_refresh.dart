import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';
import 'app_loading_spinner.dart';

/// Zero-Material pull-to-refresh wrapper.
///
/// Listens to scroll notifications and reveals an animated loading spinner
/// when dragged past threshold, triggering [onRefresh].
class PullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  static const double _refreshThreshold = 65.0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore == 0 &&
          (notification.scrollDelta ?? 0) < 0) {
        setState(() {
          _pullDistance =
              (_pullDistance - (notification.scrollDelta ?? 0) * 0.5).clamp(
                0.0,
                100.0,
              );
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullDistance >= _refreshThreshold) {
        _triggerRefresh();
      } else {
        setState(() => _pullDistance = 0.0);
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _pullDistance = (_pullDistance - notification.overscroll * 0.5).clamp(
            0.0,
            100.0,
          );
        });
      }
    }

    return false;
  }

  Future<void> _triggerRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullDistance = _refreshThreshold;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _pullDistance = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          // Pull-down indicator container
          if (_pullDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _pullDistance,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.cardHover,
                  ),
                  child: Center(
                    child: _isRefreshing
                        ? const AppLoadingSpinner(size: 18)
                        : Transform.rotate(
                            angle:
                                (_pullDistance / _refreshThreshold) *
                                math.pi *
                                2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.primaryInk,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),

          // Main scrollable child transformed down
          AnimatedContainer(
            duration: _isRefreshing ? AppMotion.durationFast : Duration.zero,
            curve: AppMotion.springGentle,
            transform: Matrix4.translationValues(0, _pullDistance, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
