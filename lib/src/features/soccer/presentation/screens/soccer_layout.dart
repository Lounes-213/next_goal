import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:next_goal/src/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:next_goal/src/config/app_route.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';
import 'package:next_goal/src/core/layout/adaptive_layout.dart';

import '../../../../core/l10n/app_l10n.dart';

class SoccerLayout extends StatefulWidget {
  const SoccerLayout({super.key, required this.child});

  final Widget child;

  @override
  State<SoccerLayout> createState() => _SoccerLayoutState();
}

class _SoccerLayoutState extends State<SoccerLayout> {
  bool _showBottomNav = true;

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.dragDetails?.primaryDelta ?? 0;
      final newOffset = notification.metrics.pixels;

      if (delta < 0 && _showBottomNav) {
        setState(() => _showBottomNav = false);
      } else if (delta > 0 && !_showBottomNav) {
        setState(() => _showBottomNav = true);
      }

      if (newOffset <= 0 && !_showBottomNav) {
        setState(() => _showBottomNav = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final l10n = context.l10n;
    final useRailNavigation = !context.isCompactWindow;

    final int currentIndex = switch (location) {
      Routes.soccer => 0,
      Routes.fixtures => 1,
      Routes.standings => 2,
      Routes.channels => 3,
      _ => 0,
    };

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: context.colors.surface.withValues(alpha: 0.6),
            ),
          ),
        ),
        leading: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.push(Routes.profile);
                break;
              case 'settings':
                context.push(Routes.settings);
                break;
            }
          },
          icon: const Icon(Icons.menu_rounded, color: Color(0xFFD4A843), size: 26),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
                  const SizedBox(width: 12),
                  Text('البروفايل', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface, size: 20),
                  const SizedBox(width: 12),
                  Text('الإعدادات', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.colorsExt.dividerSubtle,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GOLDEN GOAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: context.colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                'assets/images/app_logo.png',
                height: 26,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.sports_soccer,
                  color: Color(0xFFD4A843),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: () => context.push(Routes.search),
              icon: const Icon(Icons.search_rounded, color: Color(0xFFD4A843)),
              tooltip: 'بحث',
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: Row(
          children: [
            if (useRailNavigation) ...[
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => _onTap(context, index),
                extended: context.isExpandedWindow,
                backgroundColor: Colors.transparent,
                labelType:
                    context.isExpandedWindow
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: Text(l10n.home),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.sports_soccer_outlined),
                    selectedIcon: const Icon(Icons.sports_soccer),
                    label: Text(l10n.fixtures),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.bar_chart_rounded),
                    selectedIcon: const Icon(Icons.bar_chart_rounded),
                    label: Text(l10n.standings),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.live_tv_outlined),
                    selectedIcon: const Icon(Icons.live_tv),
                    label: Text(l10n.channels),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(child: AdaptiveContentArea(child: widget.child)),
          ],
        ),
      ),
      bottomNavigationBar:
          useRailNavigation
              ? null
              : AnimatedSlide(
                  offset: _showBottomNav ? Offset.zero : const Offset(0, 1.2),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showBottomNav ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: _FloatingBottomNav(
                      currentIndex: currentIndex,
                      onTap: (index) => _onTap(context, index),
                    ),
                  ),
                ),
    );
  }

  void _onTap(BuildContext context, int index) => switch (index) {
    0 => context.go(Routes.soccer),
    1 => context.go(Routes.fixtures),
    2 => context.go(Routes.standings),
    3 => context.go(Routes.channels),
    _ => null,
  };
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          bottom: AppSpacing.l,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: context.colorsExt.dividerSubtle,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: l10n.home,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.sports_soccer_outlined,
                    activeIcon: Icons.sports_soccer,
                    label: l10n.fixtures,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    activeIcon: Icons.bar_chart_rounded,
                    label: l10n.standings,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.live_tv_outlined,
                    activeIcon: Icons.live_tv,
                    label: l10n.channels,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
              color: isSelected ? context.colors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? context.colors.primary : context.colorsExt.textMuted,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
