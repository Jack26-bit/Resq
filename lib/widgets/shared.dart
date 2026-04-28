import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ─── News Ticker ────────────────────────────────────────────────────────────
class NewsTicker extends StatefulWidget {
  final String text;
  final Color bg;
  final Color fg;
  const NewsTicker({
    super.key,
    required this.text,
    this.bg = C.surfaceLowest,
    this.fg = C.outline,
  });
  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
    _anim = Tween<double>(begin: 1.0, end: -1.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      color: widget.bg,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, child) => FractionalTranslation(
            translation: Offset(_anim.value, 0),
            child: child,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: widget.fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top App Bar ─────────────────────────────────────────────────────────────
class ResQAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onMenu;
  final double height;

  const ResQAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.onMenu,
    this.height = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              C.surfaceLowest.withValues(alpha: 0.96),
              C.surfaceLowest.withValues(alpha: 0.88),
            ],
          ),
          border: Border(bottom: BorderSide(color: C.outlineVar.withValues(alpha: 0.6))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkResponse(
                    onTap: showBack ? () => Navigator.of(context).pop() : onMenu,
                    radius: 22,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        showBack ? Icons.arrow_back : Icons.menu,
                        color: C.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: C.onSurface,
                          ),
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────
class ResQBottomNav extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const ResQBottomNav({super.key, required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'HOME'},
      {'icon': Icons.sos_outlined, 'activeIcon': Icons.sos, 'label': 'SOS'},
      {'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'label': 'MESH'},
      {'icon': Icons.smart_toy_outlined, 'activeIcon': Icons.smart_toy, 'label': 'AI'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: C.surfaceLowest.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: C.outlineVar.withValues(alpha: 0.6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = activeIndex == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? C.surfaceMid : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? C.primary.withValues(alpha: 0.35)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isActive
                                ? item['activeIcon'] as IconData
                                : item['icon'] as IconData,
                            color: isActive ? C.primary : C.onSurfaceVar,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: isActive ? C.primary : C.onSurfaceVar,
                            ),
                            child: Text(item['label'] as String),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Hybrid Link Header ─────────────────────────────────────────────────────
class HybridLinkHeader extends StatelessWidget {
  const HybridLinkHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final statusIcons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, color: C.green, size: 16),
            const SizedBox(width: 4),
            Icon(Icons.signal_cellular_alt, color: C.info, size: 16),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: C.surfaceLowest.withValues(alpha: 0.92),
            border: Border(bottom: BorderSide(color: C.outlineVar.withValues(alpha: 0.6))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: isCompact ? 64 : 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => InkResponse(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        radius: 22,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.menu, color: C.onSurface, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wifi_tethering, color: C.info, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'RESQ HYBRID LINK',
                                  style: const TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    color: C.info,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: C.info.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: C.info.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group, color: C.info, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    '14 PEERS NEARBY',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: C.info,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCompact) statusIcons,
                          ],
                        ),
                      ),
                    ),
                    if (!isCompact) statusIcons,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Pulse dot ────────────────────────────────────────────────────────────────
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, this.color = Colors.white, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.4 + _ctrl.value * 0.6),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 3,
              color: C.onSurfaceVar,
            ),
      );
}
