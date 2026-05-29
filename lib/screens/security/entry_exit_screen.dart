import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/visitor.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/widgets/app_button.dart';
import '../../utils/widgets/info_tile.dart';

class EntryExitScreen extends StatefulWidget {
  final Visitor visitor;
  const EntryExitScreen({super.key, required this.visitor});

  @override
  State<EntryExitScreen> createState() => _EntryExitScreenState();
}

class _EntryExitScreenState extends State<EntryExitScreen> {
  late DateTime  _entryTime;
  late DateTime? _exitTime;
  late String    _status;
  late bool      _saving;

  @override
  void initState() {
    super.initState();
    _entryTime = widget.visitor.entryTime;
    _exitTime  = widget.visitor.exitTime;
    _status    = widget.visitor.status;
    _saving    = false;
  }

  void _markExit() {
    setState(() => _saving = true);
    VisitorService.instance.markExit(widget.visitor.passId).then((_) {
      if (!mounted) return;
      setState(() {
        _exitTime = DateTime.now();
        _status   = 'EXITED';
        _saving   = false;
      });
      _snack('Exit marked. Visit completed!', ok: true);
    });
  }

  void _snack(String msg, {required bool ok}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));

  @override
  Widget build(BuildContext context) {
    final v        = widget.visitor;
    final fmt      = DateFormat('hh:mm a, dd MMM yyyy');
    final exitDone = _exitTime != null;
    final completed = _status == 'EXITED';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Entry / Exit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF3730A3)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    v.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.fullName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(v.passId,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  completed ? 'Exited' : 'Active',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pass Details', style: AppTextStyles.label),
                const SectionDivider(),
                InfoTile(label: 'Phone',       value: v.phone),
                InfoTile(label: 'Department',  value: v.department),
                InfoTile(label: 'Purpose',     value: v.purpose),
                InfoTile(label: 'Meeting',     value: v.personToMeet),
                InfoTile(label: 'Issued By',   value: v.issuedBy),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Visit Timing', style: AppTextStyles.label),
                const SectionDivider(),
                _timeRow(
                  icon: Icons.login_outlined,
                  label: 'Entry',
                  time: fmt.format(_entryTime),
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                _timeRow(
                  icon: Icons.logout_outlined,
                  label: 'Exit',
                  time: exitDone ? fmt.format(_exitTime!) : 'Not yet',
                  color: exitDone ? AppColors.error : AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!completed) ...[
            AppButton(
              label: 'Mark Exit',
              icon: Icons.logout_outlined,
              color: AppColors.error,
              onPressed: _markExit,
              loading: _saving,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Text('Visit completed successfully.',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _timeRow({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) =>
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          Text(time,
              style: AppTextStyles.label.copyWith(color: color)),
        ]),
      ]);
}
