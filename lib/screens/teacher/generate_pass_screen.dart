import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/visitor.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/widgets/app_button.dart';
import 'pdf_preview_screen.dart';

class GeneratePassScreen extends StatefulWidget {
  final String teacherName;
  final String teacherId;
  const GeneratePassScreen({super.key, required this.teacherName, required this.teacherId});

  @override
  State<GeneratePassScreen> createState() => _GeneratePassScreenState();
}

const _departments = [
  'Bengali', 'English', 'History', 'Education', 'Political Science',
  'Sociology', 'Physical Education', 'Mass Communication & Journalism',
  'Arabic', 'Sanskrit', 'Mathematics', 'Computer Science and BCA',
  'Chemistry', 'Physics', 'Botany', 'Zoology', 'Geography',
  'Food & Nutrition', 'B.Voc',
];

class _GeneratePassScreenState extends State<GeneratePassScreen> {
  final _nameCtrl         = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _purposeCtrl      = TextEditingController();
  final _personToMeetCtrl = TextEditingController();
  String _visitorType = AppStrings.visitorTypes.first;
  String _department = _departments.first;
  bool _loading           = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl,
        _purposeCtrl, _personToMeetCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if ([_nameCtrl, _phoneCtrl, _purposeCtrl]
        .any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all required fields.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _loading = true);

    final passId =
        'GP-${const Uuid().v4().substring(0, 6).toUpperCase()}';

    final visitor = Visitor(
      passId:       passId,
      fullName:     _nameCtrl.text.trim(),
      phone:        _phoneCtrl.text.trim(),
      email:        _emailCtrl.text.trim(),
      visitorType:  _visitorType,
      purpose:      _purposeCtrl.text.trim(),
      department:   _department,
      personToMeet: _personToMeetCtrl.text.trim(),
      issuedBy:     widget.teacherName,
      entryTime:    DateTime.now(),
      exitTime:     null,
        status:       'PENDING',
        createdBy:    widget.teacherId,
    );

    try {
      await VisitorService.instance.addVisitor(visitor);
    } catch (_) {}
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewScreen(visitor: visitor)),
    ).then((_) {
      if (mounted) Navigator.pop(context, visitor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Generate Gate Pass')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
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
                const _SectionHeader(label: 'Visitor Information',
                    icon: Icons.person_outline),
                const SizedBox(height: 16),
                _field('Full Name *',       Icons.person_outline,   _nameCtrl),
                _field('Phone Number *',    Icons.phone_outlined,   _phoneCtrl,
                    type: TextInputType.phone),
                _field('Email',             Icons.email_outlined,   _emailCtrl,
                    type: TextInputType.emailAddress),
                _typeDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
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
                const _SectionHeader(label: 'Visit Details',
                    icon: Icons.info_outline),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    isExpanded: true,
                    initialValue: _department,
                    items: _departments.map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _department = v);
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Department *',
                    ),
                  ),
                ),
                _field('Purpose of Visit *',Icons.description_outlined, _purposeCtrl),
                _field('Person to Meet',    Icons.people_outline,   _personToMeetCtrl),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextField(
                    enabled: false,
                    controller: TextEditingController(text: widget.teacherName),
                    decoration: const InputDecoration(
                      labelText: 'Issued By',
                      prefixIcon: Icon(Icons.badge_outlined, size: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pass ID and entry date will be auto-generated on submit.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Generate Pass & Preview PDF',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: _submit,
            loading: _loading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 17),
        ),
      ),
    );
  }

  Widget _typeDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DropdownButtonFormField<String>(
          initialValue: _visitorType,
          items: AppStrings.visitorTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _visitorType = v ?? _visitorType),
          decoration: const InputDecoration(
            labelText: 'Visitor Type',
            prefixIcon: Icon(Icons.category_outlined, size: 17),
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: AppTextStyles.label
                .copyWith(color: AppColors.primary)),
      ]);
}
