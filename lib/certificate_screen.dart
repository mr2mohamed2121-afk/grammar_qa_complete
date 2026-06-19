
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class CertificateScreen extends StatefulWidget {
  final String studentName;
  final String levelName;
  final DateTime completionDate;
  final int score;
  final int totalQuestions;

  const CertificateScreen({
    super.key,
    required this.studentName,
    required this.levelName,
    required this.completionDate,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isGenerating = false;

  Future<void> _downloadCertificate() async {
    setState(() => _isGenerating = true);

    try {
      // Request storage permission
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      // Capture certificate as image
      final boundary = _certificateKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find certificate boundary');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Could not generate image');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Save to device
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'certificate_${widget.studentName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الشهادة في: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ الشهادة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _shareCertificate() async {
    setState(() => _isGenerating = true);

    try {
      final boundary = _certificateKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/certificate.png';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '🎉 تهانينا! لقد أكملت ${widget.levelName} بنجاح في تطبيق أستاذ النحو العربي!',
        subject: 'شهادة إتمام ${widget.levelName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في المشاركة: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شهادة الإتمام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isGenerating ? null : _downloadCertificate,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isGenerating ? null : _shareCertificate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Certificate
            RepaintBoundary(
              key: _certificateKey,
              child: CertificateWidget(
                studentName: widget.studentName,
                levelName: widget.levelName,
                completionDate: widget.completionDate,
                score: widget.score,
                totalQuestions: widget.totalQuestions,
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _downloadCertificate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('تحميل الشهادة'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _shareCertificate,
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateWidget extends StatelessWidget {
  final String studentName;
  final String levelName;
  final DateTime completionDate;
  final int score;
  final int totalQuestions;

  const CertificateWidget({
    super.key,
    required this.studentName,
    required this.levelName,
    required this.completionDate,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = (score / totalQuestions * 100).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: CertificateBackgroundPainter(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // Top decoration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDecorationLine(),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFD4AF37),
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.menu_book,
                        color: Color(0xFF6C63FF),
                        size: 48,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFD4AF37),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      _buildDecorationLine(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Certificate title
                  const Text(
                    'شهادة إتمام',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Certificate of Completion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Presented to
                  Text(
                    'تُمنح هذه الشهادة إلى',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Student name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Level completion text
                  Text(
                    'لإتمامه بنجاح مستوى',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Level name
                  Text(
                    levelName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Score section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreItem('النقاط', '$score/$totalQuestions', const Color(0xFF6C63FF)),
                        _buildScoreItem('النسبة', '$accuracy%', const Color(0xFF27AE60)),
                        _buildScoreItem('التقييم', _getGrade(double.parse(accuracy)), const Color(0xFFD4AF37)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Date
                  Text(
                    'تاريخ الإصدار: ${_formatDate(completionDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Signature section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App signature
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'أستاذ النحو العربي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'توقيع التطبيق',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Instructor signature
                      Column(
                        children: [
                          Container(
                            width: 180,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'مستر محمد أحمد الوهيدي',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                  Text(
                                    'مدرس النحو العربي',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'توقيع المدرس',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Verification text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'شهادة معتمدة - رقم التحقق: ${completionDate.millisecondsSinceEpoch}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationLine() {
    return Container(
      width: 60,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0),
            const Color(0xFFD4AF37),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getGrade(double accuracy) {
    if (accuracy >= 90) return 'ممتاز';
    if (accuracy >= 80) return 'جيد جداً';
    if (accuracy >= 70) return 'جيد';
    if (accuracy >= 60) return 'مقبول';
    return 'يحتاج تحسين';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CertificateBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
    canvas.drawRect(rect, borderPaint);

    // Draw inner border
    final innerBorderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerRect = Rect.fromLTWH(30, 30, size.width - 60, size.height - 60);
    canvas.drawRect(innerRect, innerBorderPaint);

    // Draw corner decorations
    final cornerPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;

    // Top left corner
    canvas.drawCircle(const Offset(40, 40), 8, cornerPaint);
    // Top right corner
    canvas.drawCircle(Offset(size.width - 40, 40), 8, cornerPaint);
    // Bottom left corner
    canvas.drawCircle(Offset(40, size.height - 40), 8, cornerPaint);
    // Bottom right corner
    canvas.drawCircle(Offset(size.width - 40, size.height - 40), 8, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
