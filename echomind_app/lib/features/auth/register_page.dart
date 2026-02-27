import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:echomind_app/shared/theme/app_theme.dart';
import 'package:echomind_app/app/app_routes.dart';
import 'package:echomind_app/providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  String _regionId = 'tianjin';
  String _subject = 'physics';
  int _targetScore = 70;

  // 中文显示 → 英文 API 值映射
  static const _regionMap = {
    '天津': 'tianjin',
    '北京': 'beijing',
    '上海': 'shanghai',
    '全国卷': 'national',
  };
  static const _subjectMap = {
    '物理': 'physics',
    '数学': 'math',
    '化学': 'chemistry',
  };
  // 反向映射：英文 → 中文（用于 Dropdown 显示）
  static final _regionDisplayMap = {for (final e in _regionMap.entries) e.value: e.key};
  static final _subjectDisplayMap = {for (final e in _subjectMap.entries) e.value: e.key};

  Future<void> _register() async {
    final ok = await ref.read(authProvider.notifier).register(
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
          regionId: _regionId,
          subject: _subject,
          targetScore: _targetScore,
          nickname: _nicknameCtrl.text.trim().isEmpty ? null : _nicknameCtrl.text.trim(),
        );
    if (ok && mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('注册'), backgroundColor: AppTheme.background, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _Input(controller: _phoneCtrl, hint: '手机号', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _Input(controller: _passwordCtrl, hint: '密码', obscure: true),
          const SizedBox(height: 12),
          _Input(controller: _nicknameCtrl, hint: '昵称（选填）'),
          const SizedBox(height: 12),
          _DropdownField(
              label: '地区',
              value: _regionDisplayMap[_regionId] ?? '天津',
              items: const ['天津', '北京', '上海', '全国卷'],
              onChanged: (v) => setState(() => _regionId = _regionMap[v!] ?? 'tianjin')),
          const SizedBox(height: 12),
          _DropdownField(
              label: '科目',
              value: _subjectDisplayMap[_subject] ?? '物理',
              items: const ['物理', '数学', '化学'],
              onChanged: (v) => setState(() => _subject = _subjectMap[v!] ?? 'physics')),
          const SizedBox(height: 12),
          _ScoreSlider(value: _targetScore, onChanged: (v) => setState(() => _targetScore = v)),
          if (auth.error != null) ...[
            const SizedBox(height: 8),
            Text(auth.error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)), elevation: 0,
              ),
              child: auth.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('注册', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  const _Input({required this.controller, required this.hint, this.obscure = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: DropdownButtonFormField<String>(
        value: value, decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
        onChanged: onChanged,
      ),
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _ScoreSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('目标分数: $value', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Slider(value: value.toDouble(), min: 30, max: 100, divisions: 14,
              label: '$value', onChanged: (v) => onChanged(v.round())),
        ],
      ),
    );
  }
}
