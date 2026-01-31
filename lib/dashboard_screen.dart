import 'dart:typed_data';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/approval_screen.dart';
import 'package:puantaj_takip_sistemi/home_screen.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/login_screen.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:puantaj_takip_sistemi/super_admin_approval_screen.dart';
import 'package:puantaj_takip_sistemi/user_forms.dart';
import 'package:puantaj_takip_sistemi/user_model.dart';

class DashboardScreen extends StatelessWidget {
  final User user;
  const DashboardScreen({super.key, required this.user});

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _exportAllSubmissionsToExcel(BuildContext context) async {
    if (mockSubmissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak form bulunmuyor.')),
      );
      return;
    }

    final excelInstance = excel.Excel.createExcel();
    final excel.Sheet sheetObject = excelInstance['Tüm Formlar'];

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

    // En yeni kayıtların en üstte olması için listeyi kopyalayıp ters çevirelim.
    final sortedSubmissions = List<JobSubmission>.from(mockSubmissions).reversed;

    for (var submission in sortedSubmissions) {
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

    final fileBytes = excelInstance.save();
    if (fileBytes != null) {
      final xfile = XFile.fromData(
        Uint8List.fromList(fileBytes),
        name: 'tum_formlar_raporu.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      try {
        await Share.shareXFiles([xfile], text: 'Tüm Formlar Raporu');
      } catch (e) {
        // A stateless widget does not have a 'mounted' property. We show the snackbar anyway.
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
        title: Text('Hoş Geldin, ${user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (user.role == UserRole.regular) {
      return _buildUserDashboard(context);
    } else {
      return _buildApproverDashboard(context);
    }
  }

  Widget _buildUserDashboard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_card),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
            );
          },
          label: const Text('Puantaj Formu'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: const Icon(Icons.list_alt),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserFormsScreen(user: user)),
            );
          },
          label: const Text('Formlarım'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildApproverDashboard(BuildContext context) {
    if (user.role == UserRole.superAdmin) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperAdminApprovalScreen()));
            },
            label: const Text('Nihai Onay Bekleyenler'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: () => _exportAllSubmissionsToExcel(context),
            label: const Text('Tüm Formları Dışa Aktar'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      );
    } else { // Admin role
      return ElevatedButton.icon(
        icon: const Icon(Icons.checklist),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ApprovalScreen()));
        },
        label: const Text('Onay Bekleyen Formlar'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
      );
    }
  }
}