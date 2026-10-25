import 'package:flutter/material.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';

import '../../../../core/l10n/app_l10n.dart';

class ViewAllTile extends StatelessWidget {
  final VoidCallback onTap;

  const ViewAllTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          foregroundColor: context.colors.primary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text(
              context.l10n.viewAll,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
