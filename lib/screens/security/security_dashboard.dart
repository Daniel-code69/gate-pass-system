import 'package:flutter/material.dart';
import '../../models/visitor.dart';
import '../../services/auth_service.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/widgets/status_badge.dart';
import '../login_screen.dart';
import 'entry_exit_screen.dart';
import 'scan_screen.dart';

class SecurityDashboard extends StatefulWidget {
  final String userName;
  final String userId;
  const SecurityDashboard({super.key, required this.userName, required this.userId});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  final _vs = VisitorService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: StreamBuilder<List<Visitor>>(
        stream: _vs.getActiveStream(),
        builder: (context, snap) {
          final active = snap.data ?? [];
          final count = active.length;

          return CustomScrollView(
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
                        colors: [Color(0xFF065F46), Color(0xFF059669)],
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
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(widget.userName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          '$count Active Pass${count != 1 ? 'es' : ''} Inside',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner_outlined,
                        color: Colors.white),
                    tooltip: 'Scan Pass',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    ),
                  ),
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
                    const Text('Active Visitors', style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    const Text('Tap a pass to mark exit.',
                        style: AppTextStyles.caption),
                  ]),
                ),
              ),

              if (snap.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (active.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _emptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ActivePassCard(
                        key: ValueKey(active[index].passId),
                        visitor: active[index],
                      ),
                      childCount: active.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState() => Container(
        margin: const EdgeInsets.only(top: 40),
        child: const Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.success),
            SizedBox(height: 12),
            Text('All clear! No active visitors.',
                style: AppTextStyles.body),
          ],
        ),
      );
}

class _ActivePassCard extends StatelessWidget {
  final Visitor visitor;
  const _ActivePassCard({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EntryExitScreen(visitor: visitor)),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      visitor.fullName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visitor.fullName, style: AppTextStyles.label),
                      const SizedBox(height: 2),
                      Text(
                        '${visitor.passId}  ·  ${visitor.purpose}',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(visitor.status),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.textMuted),
                  ],
                ),
              ]),
            ),
          ),
        ),
      );
}
