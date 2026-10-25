import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_ext.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'البروفايل',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD4A843), Color(0xFF6366F1)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A843).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/app_logo.png',
              height: 48,
              errorBuilder: (_, __, ___) => Text(
                'GOLDEN GOAL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تتبع المباريات مباشرة',
              style: TextStyle(
                color: context.colorsExt.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'المعلومات الشخصية',
              subtitle: 'تعديل اسمك وصورتك',
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.favorite_outline_rounded,
              title: 'الفريق المفضل',
              subtitle: 'اختر فريقك المفضل',
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'تفضيلات الإشعارات',
              subtitle: 'إدارة الإشعارات',
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.star_outline_rounded,
              title: 'البطولات المفضلة',
              subtitle: 'اختر البطولات التي تتابعها',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A843).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD4A843), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }
}
