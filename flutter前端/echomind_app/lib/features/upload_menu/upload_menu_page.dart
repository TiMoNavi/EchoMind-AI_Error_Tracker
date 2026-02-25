import 'package:flutter/material.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/shared/widgets/clay_card.dart';
import 'package:go_router/go_router.dart';

class UploadMenuPage extends StatefulWidget {
  const UploadMenuPage({super.key});

  @override
  State<UploadMenuPage> createState() => _UploadMenuPageState();
}

class _UploadMenuPageState extends State<UploadMenuPage> {
  int _mode = 0; // 0=拍照, 1=文本
  String _selectedSubject = '物理';
  final _textController = TextEditingController();
  final List<String> _subjects = ['物理', '数学', '化学', '生物', '英语'];
  bool _uploading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_mode == 1 && _textController.text.trim().isEmpty) return;
    setState(() => _uploading = true);
    // Simulate upload
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _uploading = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        title: const Text('上传成功'),
        content: const Text('错题已提交，AI 将在后台进行诊断分析。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('返回首页'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续上传'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModeSwitch(),
                    const SizedBox(height: 20),
                    if (_mode == 0) _buildPhotoUpload(),
                    if (_mode == 1) _buildTextUpload(),
                    const SizedBox(height: 24),
                    _buildSubjectSelector(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Text('上传错题', style: AppTheme.heading(size: 22)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return ClayCard(
      radius: AppTheme.radiusXl,
      padding: const EdgeInsets.all(6),
      color: AppTheme.canvas,
      shadows: AppTheme.shadowClayPressed,
      child: Row(
        children: [
          _modeTab(0, Icons.camera_alt_rounded, '拍照上传'),
          const SizedBox(width: 6),
          _modeTab(1, Icons.edit_note_rounded, '文本输入'),
        ],
      ),
    );
  }

  Widget _modeTab(int index, IconData icon, String label) {
    final active = _mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: active ? AppTheme.shadowClayCard : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18,
                color: active ? AppTheme.accent : AppTheme.muted),
              const SizedBox(width: 6),
              Text(label, style: AppTheme.label(
                size: 14,
                color: active ? AppTheme.accent : AppTheme.muted,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                size: 32,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text('点击拍照或从相册选择',
              style: AppTheme.body(size: 15, color: AppTheme.muted)),
            const SizedBox(height: 8),
            Text('支持 JPG / PNG，最多 5 张',
              style: AppTheme.label(size: 12, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextUpload() {
    return ClayCard(
      radius: AppTheme.radiusCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('题目内容', style: AppTheme.label(
            size: 13, color: AppTheme.foreground)),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            maxLines: 6,
            style: AppTheme.body(size: 14),
            decoration: InputDecoration(
              hintText: '粘贴或输入题目内容...',
              hintStyle: AppTheme.body(size: 14, color: AppTheme.muted),
              filled: true,
              fillColor: AppTheme.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),
          Text('你的答案（选填）', style: AppTheme.label(
            size: 13, color: AppTheme.foreground)),
          const SizedBox(height: 10),
          TextField(
            maxLines: 2,
            style: AppTheme.body(size: 14),
            decoration: InputDecoration(
              hintText: '输入你的作答...',
              hintStyle: AppTheme.body(size: 14, color: AppTheme.muted),
              filled: true,
              fillColor: AppTheme.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择科目', style: AppTheme.heading(size: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _subjects.map((s) => _subjectChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _subjectChip(String subject) {
    final active = _selectedSubject == subject;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = subject),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: active
              ? AppTheme.shadowClayButton
              : AppTheme.shadowClayCard,
        ),
        child: Text(subject, style: AppTheme.label(
          size: 14,
          color: active ? Colors.white : AppTheme.foreground,
        )),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowClayButton,
        ),
        child: ElevatedButton(
          onPressed: _uploading ? null : _onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
          ),
          child: _uploading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
              : Text('提交诊断',
                  style: AppTheme.heading(size: 16).copyWith(
                    color: Colors.white)),
        ),
      ),
    );
  }
}
