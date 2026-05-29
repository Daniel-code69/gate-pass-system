import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/widgets/app_button.dart';
import 'teacher/teacher_dashboard.dart';
import 'security/security_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _auth      = AuthService();
  bool _obscure    = true;
  bool _loading    = false;
  String _role     = 'teacher';

  Future<void> _signUp() async {
    if ([_nameCtrl, _emailCtrl, _passCtrl].any((c) => c.text.trim().isEmpty)) {
      _snack('Please fill in all fields.', ok: false);
      return;
    }
    setState(() => _loading = true);
    final res = await _auth.signUp(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      role: _role,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['ok'] == true) {
      final user = res['user'] as AppUser;
      final dest = user.role == AppStrings.roleTeacher
          ? TeacherDashboard(userName: user.name, userId: user.id)
          : SecurityDashboard(userName: user.name, userId: user.id);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => dest));
    } else {
      _snack(res['message'] as String, ok: false);
    }
  }

  void _snack(String msg, {bool ok = true}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign Up', style: AppTextStyles.title),
                const SizedBox(height: 4),
                const Text('Create your account to get started.',
                    style: AppTextStyles.subtitle),
                const SizedBox(height: 24),

                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signUp(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.textSub),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _role,
                  items: const [
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                    DropdownMenuItem(value: 'security', child: Text('Security')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'teacher'),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge_outlined, size: 17),
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: 'Create Account',
                  icon: Icons.person_add_outlined,
                  onPressed: _signUp,
                  loading: _loading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? ',
                  style: AppTextStyles.caption),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sign In',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
