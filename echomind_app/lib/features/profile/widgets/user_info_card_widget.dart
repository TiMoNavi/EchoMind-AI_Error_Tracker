import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/providers/profile_provider.dart';

class UserInfoCardWidget extends ConsumerWidget {
  const UserInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    if (profile.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final user = profile.student;
    final name = user?.nickname ?? '同学';
    final region = user?.regionId ?? '--';
    final subject = user?.subject ?? '--';
    final avatarUrl = user?.avatarUrl;

    return _buildCard(
      context: context,
      ref: ref,
      name: name,
      region: region,
      subject: subject,
      avatarUrl: avatarUrl,
      uploading: profile.uploading,
      error: profile.error,
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required WidgetRef ref,
    required String name,
    required String region,
    required String subject,
    String? avatarUrl,
    bool uploading = false,
    String? error,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // 头像区域：点击可更换
              GestureDetector(
                onTap: uploading ? null : () => _pickAndUpload(context, ref),
                child: Stack(
                  children: [
                    _buildAvatar(avatarUrl, initial),
                    if (uploading)
                      _buildUploadingOverlay()
                    else
                      _buildCameraIcon(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$region -- $subject', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              )),
            ]),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(fontSize: 12, color: AppTheme.danger)),
            ],
          ],
        ),
      ),
    );
  }

  /// 头像 Widget：有 URL 显示网络图片，否则显示首字母
  Widget _buildAvatar(String? avatarUrl, String initial) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.background,
        shape: BoxShape.circle,
        image: avatarUrl != null
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: avatarUrl == null
          ? Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))
          : null,
    );
  }

  /// 上传中遮罩
  Widget _buildUploadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
      ),
    );
  }

  /// 右下角相机图标
  Widget _buildCameraIcon() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
      ),
    );
  }

  /// 选择图片并上传
  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null) return;
    ref.read(profileProvider.notifier).uploadAvatar(xFile);
  }
}
