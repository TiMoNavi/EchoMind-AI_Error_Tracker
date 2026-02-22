import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/app/app_routes.dart';

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
    setState(() { _uploading = true; _error = null; });
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_selectedImage!.path),
        'source': _source,
      });
      await ApiClient().dio.post('/upload/image', data: formData);
      if (mounted) context.go(AppRoutes.uploadHistory);
    } catch (e) {
      setState(() => _error = '上传失败: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('上传错题'), backgroundColor: AppTheme.background, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 图片预览区
            _ImagePreview(image: _selectedImage),
            const SizedBox(height: 16),
            // 拍照 / 相册按钮
            Row(children: [
              Expanded(child: _ActionBtn(icon: Icons.camera_alt, label: '拍照',
                  onTap: () => _pickImage(ImageSource.camera))),
              const SizedBox(width: 12),
              Expanded(child: _ActionBtn(icon: Icons.photo_library, label: '相册',
                  onTap: () => _pickImage(ImageSource.gallery))),
            ]),
            const SizedBox(height: 16),
            // 来源选择
            _SourceSelector(value: _source, onChanged: (v) => setState(() => _source = v)),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
            ],
            const Spacer(),
            // 上传按钮
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_uploading || _selectedImage == null) ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  elevation: 0,
                ),
                child: _uploading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('上传', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File? image;
  const _ImagePreview({this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null
          ? Image.file(image!, fit: BoxFit.cover, width: double.infinity)
          : const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppTheme.textSecondary)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 20, color: AppTheme.primary), const SizedBox(width: 6), Text(label)],
        ),
      ),
    );
  }
}

class _SourceSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SourceSelector({required this.value, required this.onChanged});

  static const _sources = ['拍照上传', '手动录入'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(labelText: '来源', border: InputBorder.none),
        items: [for (final s in _sources) DropdownMenuItem(value: s, child: Text(s))],
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}
