import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/app/app_routes.dart';

class RecentUploadWidget extends StatelessWidget {
  const RecentUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClayCard(
        radius: AppTheme.radiusXl,
        padding: const EdgeInsets.all(18),
        onTap: () => context.push(AppRoutes.uploadHistory),
        child: Row(
          children: [
            // Icon orb
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                    color: AppTheme.tertiary.withValues(alpha: 0.3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近上传',
                    style: AppTheme.body(size: 16).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3道错题未诊断',
                    style: AppTheme.body(size: 13, color: AppTheme.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}
