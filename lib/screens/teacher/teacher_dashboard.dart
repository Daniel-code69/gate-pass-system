import 'package:flutter/material.dart';
import '../../models/visitor.dart';
import '../../services/auth_service.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/widgets/status_badge.dart';
import '../login_screen.dart';
import 'generate_pass_screen.dart';
import 'pass_history_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String userName;
  final String userId;
  const TeacherDashboard({super.key, required this.userName, required this.userId});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _vs = VisitorService.instance;
  int _total = 0, _pending = 0, _active = 0, _exited = 0;
  List<Visitor> _recent = [];
  Visitor? _lastNewVisitor;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final all = await _vs.getAll();
      final mine = all.where((v) => v.createdBy == widget.userId).toList();
      if (!mounted) return;
      int t = 0, p = 0, a = 0, e = 0;
      for (final v in mine) {
        t++;
        switch (v.status) {
          case 'PENDING': p++;
          case 'ACTIVE': a++;
          case 'EXITED': e++;
        }
      }
      setState(() {
        _total = t; _pending = p; _active = a; _exited = e;
        _recent = mine.take(3).toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF3730A3)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset('assets/images/logo.png',
                                width: 32, height: 32, fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 10),
                          Text('Welcome',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(widget.userName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await AuthService().logout();
                    nav.pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(children: [
                    _StatCard(label: 'Total', value: '$_total',
                        icon: Icons.badge_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Pending', value: '$_pending',
                        icon: Icons.hourglass_empty_outlined, color: AppColors.warning),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Active', value: '$_active',
                        icon: Icons.person_outline, color: AppColors.success),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Exited', value: '$_exited',
                        icon: Icons.exit_to_app_outlined, color: AppColors.textSub),
                  ]),
                  const SizedBox(height: 24),

                  const Text('Quick Actions', style: AppTextStyles.title),
                  const SizedBox(height: 12),
                  Row(children: [
                    _ActionCard(
                      icon: Icons.add_card_outlined,
                      label: 'Generate\nGate Pass',
                      color: AppColors.primary,
                      onTap: () async {
                        final newVisitor = await Navigator.push<Visitor>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GeneratePassScreen(
                                    teacherName: widget.userName,
                                    teacherId: widget.userId)));
                        if (newVisitor != null) {
                          _lastNewVisitor = newVisitor;
                          setState(() {
                            _total++;
                            _pending++;
                            _recent.insert(0, newVisitor);
                            if (_recent.length > 3) {
                              _recent = _recent.sublist(0, 3);
                            }
                          });
                        } else {
                          _refresh();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.history_outlined,
                      label: 'Pass\nHistory',
                      color: AppColors.accent,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => PassHistoryScreen(
                                userId: widget.userId,
                                newVisitor: _lastNewVisitor))),
                  ),
                  ]),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Passes', style: AppTextStyles.title),
                      TextButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => PassHistoryScreen(
                                    userId: widget.userId,
                                    newVisitor: _lastNewVisitor))),
                        child: const Text('See all',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_recent.isEmpty
                      ? [const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No passes yet', style: AppTextStyles.caption)))]
                      : _recent.map((v) => _RecentTile(visitor: v))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label, required this.value,
       required this.icon,   required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon, required this.label,
       required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.75)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3)),
            ]),
          ),
        ),
      );
}

class _RecentTile extends StatelessWidget {
  final Visitor visitor;
  const _RecentTile({required this.visitor});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(visitor.fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visitor.fullName, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text('${visitor.purpose} · ${visitor.department}',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          StatusBadge(visitor.status),
        ]),
      );
}
