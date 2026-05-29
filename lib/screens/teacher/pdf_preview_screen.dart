import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/visitor.dart';
import '../../services/pdf_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/widgets/app_button.dart';
import '../../utils/widgets/info_tile.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Visitor visitor;
  const PdfPreviewScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final pdfSvc = PdfService();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Pass Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => pdfSvc.sharePdf(visitor),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text('Pass generated successfully!',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 22, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF3730A3)],
                    ),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18)),
                  ),
                  child: Column(children: [
                    const Text(AppStrings.collegeName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('VISITOR GATE PASS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: AppColors.primary.withValues(alpha: 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(visitor.passId, style: AppTextStyles.mono),
                      Text(dateFmt.format(visitor.entryTime),
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InfoTile(label: 'Visitor Name', value: visitor.fullName,
                          icon: Icons.person_outline),
                      InfoTile(label: 'Phone',        value: visitor.phone,
                          icon: Icons.phone_outlined),
                      InfoTile(label: 'Type',         value: visitor.visitorType,
                          icon: Icons.category_outlined),
                      InfoTile(label: 'Department',   value: visitor.department,
                          icon: Icons.business_outlined),
                      InfoTile(label: 'Meeting',      value: visitor.personToMeet,
                          icon: Icons.people_outline),
                      InfoTile(label: 'Purpose',      value: visitor.purpose,
                          icon: Icons.info_outline),
                      InfoTile(label: 'Issued By',    value: visitor.issuedBy,
                          icon: Icons.badge_outlined),
                      const SectionDivider(),
                      const InfoTile(label: 'Entry Time',
                          value: '_______________',
                          icon: Icons.login_outlined,
                          valueColor: AppColors.textMuted),
                      const InfoTile(label: 'Exit Time',
                          value: '_______________',
                          icon: Icons.logout_outlined,
                          valueColor: AppColors.textMuted),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _sig('Security Guard'),
                          const Spacer(),
                          _sig('Issuing Teacher'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          AppButton(
            label: 'Print PDF',
            icon: Icons.print_outlined,
            onPressed: () => pdfSvc.printPdf(visitor),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Share PDF',
            icon: Icons.share_outlined,
            color: AppColors.accent,
            onPressed: () => pdfSvc.sharePdf(visitor),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Back to Dashboard',
            icon: Icons.home_outlined,
            color: AppColors.textSub,
            outlined: true,
            onPressed: () => Navigator.pop(context, visitor),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sig(String label) => Column(
        children: [
          Container(width: 100, height: 1, color: AppColors.border),
          const SizedBox(height: 5),
          Text(label, style: AppTextStyles.caption),
        ],
      );
}
