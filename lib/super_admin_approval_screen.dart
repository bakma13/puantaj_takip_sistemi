import 'dart:typed_data';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';
import 'package:share_plus/share_plus.dart';

class SuperAdminApprovalScreen extends StatefulWidget {
  const SuperAdminApprovalScreen({super.key});

  @override
  State<SuperAdminApprovalScreen> createState() =>
      _SuperAdminApprovalScreenState();
}

class _SuperAdminApprovalScreenState extends State<SuperAdminApprovalScreen> {
  late List<JobSubmission> _pendingSubmissions;

  @override
  void initState() {
    super.initState();
    _loadPendingSubmissions();
  }

  void _loadPendingSubmissions() {
    setState(() {
      _pendingSubmissions = mockSubmissions
          .where((s) => s.status == SubmissionStatus.pendingSuperAdminApproval)
          .toList();
    });
  }

  void _updateSubmissionStatus(String id, SubmissionStatus newStatus) {
    final index = mockSubmissions.indexWhere((s) => s.id == id);
    if (index != -1) {
      setState(() {
        mockSubmissions[index].status = newStatus;
        _loadPendingSubmissions();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == SubmissionStatus.approved
              ? 'İş başarıyla onaylandı.'
              : 'İş reddedildi.'),
          backgroundColor:
              newStatus == SubmissionStatus.approved ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel() async {
    final excelInstance = excel.Excel.createExcel();
    final excel.Sheet sheetObject = excelInstance['Onaylanmış İşler'];

    // Başlıkları ekle. Lütfen 'TextCellValue' isminin doğru yazıldığından emin olun.
    // Baş harfleri büyük olmalı: T, C, V.
    final List<excel.CellValue> header = [
      excel.TextCellValue('ID'),
      excel.TextCellValue('PROJE KODU'),
      excel.TextCellValue('OPERASYON ADI'),
      excel.TextCellValue('OPERASYON KODU'),
      excel.TextCellValue('KULLANDIĞI TEZGAH'),
      excel.TextCellValue('Gönderen'),
      excel.TextCellValue('BAŞLAMA SAATİ'),
      excel.TextCellValue('BİTİŞ SAATİ'),
      excel.TextCellValue('Durum'),
    ];
    sheetObject.appendRow(header);

    // Sadece onaylanmış işleri filtrele
    final approvedSubmissions =
        mockSubmissions.where((s) => s.status == SubmissionStatus.approved).toList();

    if (approvedSubmissions.isEmpty) {
      // context kullanmadan önce widget'ın hala ekranda olduğundan emin ol.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak onaylanmış iş bulunmuyor.')),
      );
      return;
    }

    // Verileri ekle
    for (var submission in approvedSubmissions) {
      sheetObject.appendRow([
        excel.TextCellValue(submission.id),
        excel.TextCellValue(submission.projectCode),
        excel.TextCellValue(submission.operationName),
        excel.TextCellValue(submission.operationCode),
        excel.TextCellValue(submission.machineUsed),
        excel.TextCellValue(submission.submittedBy),
        excel.TextCellValue(submission.startTime),
        excel.TextCellValue(submission.endTime),
        excel.TextCellValue(submission.status.toString().split('.').last),
      ]);
    }

    // Dosyayı kaydet ve paylaş
    final fileBytes = excelInstance.save();
    if (fileBytes != null) {
      final xfile = XFile.fromData(
        Uint8List.fromList(fileBytes),
        name: 'onaylanmis_isler.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      // Paylaşım sırasında oluşabilecek hataları yakalamak için try-catch kullan.
      try {
        await Share.shareXFiles([xfile], text: 'Onaylanmış İşler Raporu');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya paylaşılamadı: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nihai Onay Ekranı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Onaylanmış İşleri Excel\'e Aktar',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: _pendingSubmissions.isEmpty
          ? const Center(child: Text('Nihai onay bekleyen iş bulunmuyor.'))
          : ListView.builder(
              itemCount: _pendingSubmissions.length,
              itemBuilder: (context, index) {
                final submission = _pendingSubmissions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(submission.operationName, style: Theme.of(context).textTheme.titleLarge), // Changed from jobTitle
                        const SizedBox(height: 4),
                        Text('Gönderen: ${submission.submittedBy}', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('Proje Kodu: ${submission.projectCode}'),
                        Text('Operasyon Kodu: ${submission.operationCode}'),
                        Text('Tezgah: ${submission.machineUsed}'),
                        Text('Saatler: ${submission.startTime} - ${submission.endTime}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _updateSubmissionStatus(submission.id, SubmissionStatus.rejected),
                              child: const Text('Reddet', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateSubmissionStatus(submission.id, SubmissionStatus.approved),
                              child: const Text('Nihai Onay Ver'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}