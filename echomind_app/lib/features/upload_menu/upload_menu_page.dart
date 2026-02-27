import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_background_blobs.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';

class UploadMenuPage extends ConsumerStatefulWidget {
  const UploadMenuPage({super.key});

  @override
  ConsumerState<UploadMenuPage> createState() => _UploadMenuPageState();
}

class _UploadMenuPageState extends ConsumerState<UploadMenuPage> {
  final _picker = ImagePicker();
  String _source = '拍照上传';
  bool _uploading = false;
  String? _error;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource src) async {
    final xFile = await _picker.pickImage(source: src, imageQuality: 80);
    if (xFile == null) return;
    setState(() {
      _selectedImage = File(xFile.path);
      _error = null;
    });
  }

  Future<void> _upload() async {
    if (_selectedImage == null) return;

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_selectedImage!.path),
        'source': _source,
      });

      await ApiClient().dio.post('/upload/image', data: formData);

      if (mounted) {
        context.go(AppRoutes.uploadHistory);
      }
    } catch (e) {
      setState(() => _error = '上传失败：$e');
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Stack(
                children: [
                  const ClayBackgroundBlobs(),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewCard(),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.camera_alt_rounded,
                                label: '拍照',
                                onTap: () => _pickImage(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.photo_library_rounded,
                                label: '相册',
                                onTap: () => _pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSourceSelector(),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: AppTheme.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: AppTheme.danger)),
                        ],
                        const SizedBox(height: 22),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Text('上传错题',
              style: AppTheme.heading(size: 22, weight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: _selectedImage != null
              ? Image.file(_selectedImage!,
                  fit: BoxFit.cover, width: double.infinity)
              : Container(
                  color: AppTheme.canvas,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: AppTheme.muted),
                      const SizedBox(height: 10),
                      Text('点击拍照或从相册选择图片',
                          style: AppTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: AppTheme.muted)),
                      const SizedBox(height: 4),
                      Text('支持 JPG / PNG，建议画面清晰',
                          style: AppTheme.label(size: 12)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ClayCard(
      onTap: onTap,
      radius: AppTheme.radiusLg,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.body(size: 14, weight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    const sources = ['拍照上传', '手动录入'];

    return ClayCard(
      radius: AppTheme.radiusLg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonFormField<String>(
        initialValue: _source,
        decoration: InputDecoration(
          labelText: '来源类型',
          labelStyle: AppTheme.label(size: 12),
          border: InputBorder.none,
        ),
        items: [
          for (final source in sources)
            DropdownMenuItem(
                value: source,
                child: Text(source,
                    style: AppTheme.body(size: 14, weight: FontWeight.w700))),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => _source = value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowClayButton,
        ),
        child: ElevatedButton(
          onPressed: (_uploading || _selectedImage == null) ? null : _upload,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
            elevation: 0,
          ),
          child: _uploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: Colors.white),
                )
              : Text('开始上传',
                  style: AppTheme.body(
                      size: 16, weight: FontWeight.w800, color: Colors.white)),
        ),
      ),
    );
  }
}
