import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';

/// A single donation platform entry.
@immutable
class DonateOption {
  final String label;
  final IconData icon;
  final Color color;
  final String url;

  const DonateOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });
}

/// Animated floating menu that reveals donation options
/// with staggered slide + fade animations.
///
/// Uses [Overlay] so the expanded items render above all
/// other widgets and receive hit-tests correctly even when
/// the FAB sits inside a constrained parent like
/// [NavigationRail]'s trailing slot.
class DonateMenu extends StatefulWidget {
  /// Whether the parent rail is in extended mode.
  final bool isExtended;

  /// The donation platforms to display.
  final List<DonateOption> options;

  const DonateMenu({
    super.key,
    required this.isExtended,
    required this.options,
  });

  @override
  State<DonateMenu> createState() => _DonateMenuState();
}

class _DonateMenuState extends State<DonateMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backdropAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  /// Key on the FAB so we can find its position on screen.
  final _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _backdropAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(DonateMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the rail collapses/expands while the menu is
    // open, wait for the NavigationRail animation to
    // finish, then reposition the overlay at the new
    // FAB location so the menu stays visible.
    if (oldWidget.isExtended != widget.isExtended && _isOpen) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isOpen) _showOverlay();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  // ── Overlay helpers ────────────────────────────────────

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final fabOffset = renderBox.localToGlobal(Offset.zero);
    final fabSize = renderBox.size;
    final fabCenterX = fabOffset.dx + fabSize.width / 2;
    final fabTop = fabOffset.dy;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _DonateOverlay(
          controller: _controller,
          backdropAnimation: _backdropAnimation,
          options: widget.options,
          isDark: isDark,
          isExtended: widget.isExtended,
          fabCenterX: fabCenterX,
          fabTop: fabTop,
          onClose: _close,
          onLaunch: _openUrl,
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // ── State helpers ──────────────────────────────────────

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      setState(() => _isOpen = true);
      _showOverlay();
      _controller.forward();
    }
  }

  void _close() {
    if (!_isOpen) return;
    _controller.reverse().whenComplete(() {
      _removeOverlay();
      if (mounted) setState(() => _isOpen = false);
    });
  }

  Future<void> _openUrl(String url) async {
    _close();
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildFab(),
    );
  }

  Widget _buildFab() {
    final rotation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Widget buildIcon() => AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: _isOpen
          ? const Icon(HugeIcons.strokeRoundedCancel01, key: ValueKey('close'))
          : RotationTransition(
              turns: rotation,
              child: const Icon(
                HugeIcons.strokeRoundedGift,
                key: ValueKey('gift'),
              ),
            ),
    );

    return widget.isExtended
        ? FloatingActionButton.extended(
            key: _fabKey,
            onPressed: _toggle,
            icon: buildIcon(),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(_isOpen ? 'Close' : 'Donate', key: ValueKey(_isOpen)),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          )
        : FloatingActionButton(
            key: _fabKey,
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            child: buildIcon(),
          );
  }
}

// ── Overlay widget ─────────────────────────────────────────────────────────────

/// The overlay content: backdrop + staggered option chips.
class _DonateOverlay extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> backdropAnimation;
  final List<DonateOption> options;
  final bool isDark;
  final bool isExtended;
  final double fabCenterX;
  final double fabTop;
  final VoidCallback onClose;
  final Future<void> Function(String) onLaunch;

  // Chip dimensions (must match _DonateOptionChip padding).
  static const double _chipHeight = 52.0;
  static const double _chipSpacing = 8.0;
  static const double _gap = 12.0;

  // Chip widths for positioning.
  // icon(32) + padding(2×10) + border(2×1) = 54 → 58 with margin
  static const double _chipWidthCompact = 62.0;
  // icon(32) + gap(10) + text + padding(2×12) + border(2) → generous
  static const double _chipWidthExtended = 148.0;

  const _DonateOverlay({
    required this.controller,
    required this.backdropAnimation,
    required this.options,
    required this.isDark,
    required this.isExtended,
    required this.fabCenterX,
    required this.fabTop,
    required this.onClose,
    required this.onLaunch,
  });

  Animation<double> _itemAnimation(int index) {
    final count = options.length;
    final start = index * (0.5 / count);
    final end = (start + 0.6).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: controller,
      curve: Interval(start.clamp(0.0, 1.0), end, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chipWidth = isExtended ? _chipWidthExtended : _chipWidthCompact;

    return Stack(
      children: [
        // ── Backdrop ───────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: FadeTransition(
              opacity: backdropAnimation,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // ── Option chips ───────────────────────────────
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Stack(
              children: List.generate(options.length, (i) {
                final option = options[i];
                final anim = _itemAnimation(i);

                // Items are ordered top→bottom in the list.
                // The first item sits furthest from the FAB.
                final itemTop =
                    fabTop -
                    _gap -
                    (options.length - i) * (_chipHeight + _chipSpacing);

                // Left-align chips on the FAB's left edge.
                final left = fabCenterX - chipWidth / 2;

                return Positioned(
                  top: itemTop,
                  left: left,
                  width: chipWidth,
                  child: FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(anim),
                      // Material resets DefaultTextStyle so
                      // the label never gets an underline.
                      child: Material(
                        color: Colors.transparent,
                        child: _DonateOptionChip(
                          option: option,
                          isDark: isDark,
                          isExtended: isExtended,
                          onTap: () => onLaunch(option.url),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

// ── Chip widget ────────────────────────────────────────────────────────────────

/// Individual donate option pill/chip button.
class _DonateOptionChip extends StatefulWidget {
  final DonateOption option;
  final bool isDark;
  final bool isExtended;
  final VoidCallback onTap;

  const _DonateOptionChip({
    required this.option,
    required this.isDark,
    required this.isExtended,
    required this.onTap,
  });

  @override
  State<_DonateOptionChip> createState() => _DonateOptionChipState();
}

class _DonateOptionChipState extends State<_DonateOptionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkCard : AppColors.lightCard;
    final hoverBg = widget.option.color.withValues(alpha: 0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExtended ? 12 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _hovered ? hoverBg : bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.option.color.withValues(alpha: 0.4)
                  : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? widget.option.color.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _hovered ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.option.color.withValues(
                    alpha: _hovered ? 0.2 : 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.option.icon,
                  size: 16,
                  color: widget.option.color,
                ),
              ),
              if (widget.isExtended) ...[
                const SizedBox(width: 10),
                Text(
                  widget.option.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    color: _hovered
                        ? widget.option.color
                        : (widget.isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
