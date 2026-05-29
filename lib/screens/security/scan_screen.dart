import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/visitor.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/widgets/info_tile.dart';
import '../../utils/widgets/app_button.dart';
import '../../utils/widgets/status_badge.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _vs = VisitorService.instance;
  MobileScannerController? _camCtrl;
  String? _scannedPassId;
  Visitor? _found;
  bool _processing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _camCtrl = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _saving) return;
    final barcode = capture.barcodes.firstOrNull;
    final data = barcode?.rawValue;
    if (data == null || data.isEmpty) return;
    _processing = true;
    _camCtrl?.stop();
    final found = await _vs.getByPassId(data);
    if (!mounted) return;
    setState(() {
      _scannedPassId = data;
      _found = found;
    });
  }

  Future<void> _confirmEntry() async {
    if (_found == null) return;
    setState(() => _saving = true);
    await _vs.confirmEntry(_found!.passId);
    if (!mounted) return;
    setState(() {
      _found!.status = 'ACTIVE';
      _saving = false;
    });
    _snack('Entry confirmed for ${_found!.fullName}', ok: true);
  }

  Future<void> _markExit() async {
    if (_found == null) return;
    setState(() => _saving = true);
    await _vs.markExit(_found!.passId);
    if (!mounted) return;
    setState(() {
      _found!.status = 'EXITED';
      _saving = false;
    });
    _snack('Exit confirmed for ${_found!.fullName}', ok: true);
  }

  void _reset() {
    setState(() {
      _scannedPassId = null;
      _found = null;
      _processing = false;
    });
    _camCtrl?.start();
  }

  void _snack(String msg, {bool ok = true}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Scan Gate Pass')),
      body: _found != null ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() => Stack(
        children: [
          MobileScanner(
            controller: _camCtrl,
            onDetect: _onDetect,
          ),
          if (_processing)
            const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            )
          else
            Center(
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.qr_code_scanner,
                    size: 80, color: Colors.white54),
              ),
            ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text('Point the camera at the QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14)),
          ),
        ],
      );

  Color _headerColor() {
    switch (_found?.status) {
      case 'PENDING': return AppColors.warning;
      case 'ACTIVE': return AppColors.success;
      case 'EXITED': return AppColors.textMuted;
      default: return AppColors.primary;
    }
  }

  List<Color> _headerGradient() {
    switch (_found?.status) {
      case 'PENDING':
        return const [AppColors.warning, Color(0xFFD97706)];
      case 'ACTIVE':
        return const [AppColors.primary, Color(0xFF3730A3)];
      case 'EXITED':
        return const [AppColors.textMuted, Color(0xFF6B7280)];
      default:
        return const [AppColors.primary, Color(0xFF3730A3)];
    }
  }

  Widget _buildResult() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_found == null) ...[
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Pass not found',
                style: AppTextStyles.title,
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('No pass found with ID: $_scannedPassId',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: _headerGradient()),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: _headerColor().withValues(alpha: 0.25),
                      blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _found!.fullName.substring(0, 1).toUpperCase(),
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
                        Text(_found!.fullName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text(_found!.passId,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  StatusBadge(_found!.status),
                ]),
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
                  InfoTile(label: 'Phone', value: _found!.phone),
                  InfoTile(label: 'Department', value: _found!.department),
                  InfoTile(label: 'Purpose', value: _found!.purpose),
                  InfoTile(label: 'Meeting', value: _found!.personToMeet),
                  InfoTile(label: 'Issued By', value: _found!.issuedBy),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_found!.status == 'PENDING')
              AppButton(
                label: 'Confirm Entry',
                icon: Icons.login_outlined,
                color: AppColors.success,
                onPressed: _saving ? null : _confirmEntry,
                loading: _saving,
              )
            else if (_found!.status == 'ACTIVE')
              AppButton(
                label: 'Confirm Exit',
                icon: Icons.logout_outlined,
                color: AppColors.error,
                onPressed: _saving ? null : _markExit,
                loading: _saving,
              )
            else
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
                  Text('Visit already completed.',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ]),
              ),

            const SizedBox(height: 12),
            AppButton(
              label: 'Scan Another',
              icon: Icons.qr_code_scanner_outlined,
              color: AppColors.accent,
              outlined: true,
              onPressed: _reset,
            ),
          ],
        ],
      );
}
