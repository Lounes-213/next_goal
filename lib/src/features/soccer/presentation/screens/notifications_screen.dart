import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_ext.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'الإشعارات',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _NotificationItem(
            icon: Icons.sports_soccer,
            iconColor: const Color(0xFFD4A843),
            title: 'مباراة مباشرة الآن',
            subtitle: 'ليفربول ضد مانشستر سيتي — مباشر',
            time: 'منذ 5 دقائق',
            isLive: true,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFFF59E0B),
            title: 'تنبيه مباراة',
            subtitle: 'ريال مدريد ضد برشلونة يبدأ خلال ساعة',
            time: 'منذ 30 دقيقة',
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFF6366F1),
            title: 'نتيجة المباراة',
            subtitle: 'بايرن ميونخ 3 - 1 بوروسيا دورتموند',
            time: 'منذ ساعة',
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.transfer_within_a_station,
            iconColor: const Color(0xFF3B82F6),
            title: 'انتقال اللاعب',
            subtitle: 'تم تأكيد انتقال كيليان مبابي إلى ريال مدريد',
            time: 'منذ 3 ساعات',
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            icon: Icons.sports_soccer,
            iconColor: const Color(0xFFD4A843),
            title: 'بداية المباراة',
            subtitle: 'إنتر ميلان ضد يوفنتوس — ديربي إيطاليا',
            time: 'منذ 5 ساعات',
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isLive;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'مباشر',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
