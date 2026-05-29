import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/visitor.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/widgets/info_tile.dart';
import '../../utils/widgets/status_badge.dart';

class PassHistoryScreen extends StatefulWidget {
  final String userId;
  final Visitor? newVisitor;
  const PassHistoryScreen({super.key, required this.userId, this.newVisitor});

  @override
  State<PassHistoryScreen> createState() => _PassHistoryScreenState();
}

class _PassHistoryScreenState extends State<PassHistoryScreen> {
  final _searchCtrl = TextEditingController();
  final _vs = VisitorService.instance;
  String _filter = 'ALL';
  List<Visitor> _all = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final all = await _vs.getAll();
      final mine = all.where((v) => v.createdBy == widget.userId).toList();
      if (!mounted) return;
      setState(() {
        _all = mine;
        if (widget.newVisitor != null &&
            !_all.any((v) => v.passId == widget.newVisitor!.passId)) {
          _all.insert(0, widget.newVisitor!);
        }
      });
    } catch (_) {}
  }

  List<Visitor> get _filtered {
    final q = _searchCtrl.text.toLowerCase().trim();
    return _all.where((v) {
      final matchSearch = q.isEmpty ||
          v.fullName.toLowerCase().contains(q) ||
          v.phone.contains(q) ||
          v.passId.toLowerCase().contains(q);
      final matchFilter = _filter == 'ALL' || v.status == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pass History')),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, phone or pass ID…',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.7), size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(children: [
              _chip('ALL', 'All'),
              const SizedBox(width: 8),
              _chip('PENDING', 'Pending'),
              const SizedBox(width: 8),
              _chip('ACTIVE', 'Active'),
              const SizedBox(width: 8),
              _chip('EXITED', 'Exited'),
              const Spacer(),
              Text('${list.length} results',
                  style: AppTextStyles.caption),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 40, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text('No passes found.',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _PassCard(
                        key: ValueKey(list[i].passId),
                        visitor: list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.textSub)),
      ),
    );
  }
}

class _PassCard extends StatefulWidget {
  final Visitor visitor;
  const _PassCard({super.key, required this.visitor});

  @override
  State<_PassCard> createState() => _PassCardState();
}

class _PassCardState extends State<_PassCard> {
  bool _expanded = false;

  Color _colorFor(String status) {
    switch (status) {
      case 'PENDING': return AppColors.warning;
      case 'ACTIVE': return AppColors.primary;
      case 'EXITED': return AppColors.success;
      default: return AppColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v   = widget.visitor;
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
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
        children: [
          InkWell(
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _colorFor(v.status)
                      .withValues(alpha: 0.1),
                  child: Text(
                    v.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _colorFor(v.status)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.fullName, style: AppTextStyles.label),
                      const SizedBox(height: 2),
                      Text(
                        '${v.passId}  ·  ${DateFormat('dd MMM').format(v.entryTime)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                StatusBadge(v.status),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textMuted, size: 20,
                ),
              ]),
            ),
          ),

          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              child: Column(children: [
                const SectionDivider(),
                InfoTile(label: 'Phone',       value: v.phone),
                InfoTile(label: 'Department',  value: v.department),
                InfoTile(label: 'Purpose',     value: v.purpose),
                InfoTile(label: 'Issued By',   value: v.issuedBy),
                InfoTile(label: 'Entry',
                    value: fmt.format(v.entryTime),
                    valueColor: AppColors.success),
                InfoTile(
                  label: 'Exit',
                  value: v.exitTime != null
                      ? fmt.format(v.exitTime!)
                      : 'Not yet',
                  valueColor: v.exitTime != null
                      ? AppColors.error
                      : AppColors.textMuted,
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
