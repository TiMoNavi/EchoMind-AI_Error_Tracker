import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityDetailPage extends StatelessWidget {
  const CommunityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(title: Text('需求详情', style: AppTheme.heading(size: 18))),
      body: Stack(
        children: [
          const ClayBackgroundBlobs(),
          ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(20),
            children: [
              ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('希望增加错题导出PDF功能',
                        style: AppTheme.heading(size: 18)),
                    const SizedBox(height: 8),
                    Text('可以把错题按模型分组导出打印，方便线下复习使用。',
                        style: AppTheme.body(size: 14)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 18, color: AppTheme.accent),
                        const SizedBox(width: 4),
                        Text('23票',
                            style: GoogleFonts.nunito(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppTheme.accent)),
                        const SizedBox(width: 16),
                        Text('功能请求 · 3天前',
                            style: AppTheme.label(size: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
