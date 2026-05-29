import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../main.dart' show firebaseAvailable;
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/widgets/app_button.dart';
import 'teacher/teacher_dashboard.dart';
import 'security/security_dashboard.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _authService = AuthService();
  bool _obscure      = true;
  bool _loading      = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please enter your email and password.', ok: false);
      return;
    }
    setState(() => _loading = true);
    final res = await _authService.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['ok'] == true) {
      final user = res['user'] as AppUser;
      final Widget dest;
      if (user.role == AppStrings.roleTeacher) {
        dest = TeacherDashboard(userName: user.name, userId: user.id);
      } else {
        dest = SecurityDashboard(userName: user.name, userId: user.id);
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => dest));
    } else {
      _snack(res['message'] as String, ok: false);
    }
  }

  Future<void> _onGoogleSignIn() async {
    if (!firebaseAvailable) {
      _showGoogleSignInDialog();
      return;
    }
    setState(() => _loading = true);
    final res = await _authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['needsRoleSelection'] == true) {
      _showRoleSelectionDialog(
        name: res['name'] as String? ?? '',
        email: res['email'] as String? ?? '',
      );
      return;
    }
    _handleAuthResult(res);
  }

  void _showRoleSelectionDialog({required String name, required String email}) {
    final nameCtrl = TextEditingController(text: name);
    String role = 'teacher';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Complete Registration',
              style: AppTextStyles.title),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome! Choose your role to continue.',
                    style: AppTextStyles.caption.copyWith(fontSize: 12)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge_outlined, size: 17),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      isDense: true,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'teacher',
                            child: Text('Teacher')),
                        DropdownMenuItem(value: 'security',
                            child: Text('Security')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => role = v ?? 'teacher'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                setState(() => _loading = true);
                final res = await _authService.completeGoogleSignUp(
                  name: nameCtrl.text.trim(),
                  email: email,
                  role: role,
                );
                if (!mounted) return;
                setState(() => _loading = false);
                _handleAuthResult(res);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoogleSignInDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'teacher';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Complete Sign In',
              style: AppTextStyles.title),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Firebase is not configured yet.\n'
                    'Enter your details to sign in locally.',
                    style: AppTextStyles.caption.copyWith(fontSize: 12)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge_outlined, size: 17),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      isDense: true,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'teacher',
                            child: Text('Teacher')),
                        DropdownMenuItem(value: 'security',
                            child: Text('Security')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => role = v ?? 'teacher'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(ctx);
                setState(() => _loading = true);
                final res = await _authService.signInWithGoogle(
                  nameOverride: nameCtrl.text.trim(),
                  emailOverride: emailCtrl.text.trim(),
                  roleOverride: role,
                );
                if (!mounted) return;
                setState(() => _loading = false);
                _handleAuthResult(res);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuthResult(Map<String, dynamic> res) {
    if (res['ok'] == true) {
      final user = res['user'] as AppUser;
      final Widget dest;
      if (user.role == AppStrings.roleTeacher) {
        dest = TeacherDashboard(userName: user.name, userId: user.id);
      } else {
        dest = SecurityDashboard(userName: user.name, userId: user.id);
      }
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFF3730A3), AppColors.bg],
            stops: [0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24, offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/logo.png',
                fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Text('Gate Pass System',
            style: AppTextStyles.heading.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        const Text(AppStrings.collegeName,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: Colors.white70),
            textAlign: TextAlign.center),
      ]);

  Widget _buildLoginCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30, offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sign in to your account',
                style: AppTextStyles.title),
            const SizedBox(height: 24),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon:
                    const Icon(Icons.lock_outline, size: 18),
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
            const SizedBox(height: 26),

            AppButton(
              label: 'Sign In',
              icon: Icons.login_outlined,
              onPressed: _login,
              loading: _loading,
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted, fontSize: 11)),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 20),

            _buildGoogleButton(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ",
                    style: AppTextStyles.caption),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SignUpScreen()),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Sign Up',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildGoogleButton() => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.bg,
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onPressed: _onGoogleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20, height: 20,
                alignment: Alignment.center,
                child: const Text('G',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    )),
              ),
              const SizedBox(width: 10),
              const Text('Continue with Google'),
            ],
          ),
        ),
      );

}
