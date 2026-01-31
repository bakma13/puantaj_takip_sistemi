import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';
import 'package:puantaj_takip_sistemi/edit_submission_screen.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  late List<JobSubmission> _pendingSubmissions;

  @override
  void initState() {
    super.initState();
    _loadPendingSubmissions();
  }

  // Sadece beklemede olan işleri filtreleyip listeyi günceller.
  void _loadPendingSubmissions() {
    setState(() {
      _pendingSubmissions = mockSubmissions
          .where((s) => s.status == SubmissionStatus.pending)
          .toList();
    });
  }

  // Bir işin durumunu günceller (Onay veya Red).
  void _updateSubmissionStatus(String id, SubmissionStatus newStatus) {
    // Ana listedeki orijinal kaydı bul ve güncelle.
    final index = mockSubmissions.indexWhere((s) => s.id == id);
    if (index != -1) {
      setState(() {
        mockSubmissions[index].status = newStatus;
        // Değişikliği ekranda göstermek için beklemedeki işler listesini yeniden yükle.
        _loadPendingSubmissions();
      });

      String message;
      if (newStatus == SubmissionStatus.pendingSuperAdminApproval) {
        message = 'İş, nihai onay için gönderildi.';
      } else if (newStatus == SubmissionStatus.approved) {
        message = 'İş başarıyla onaylandı.';
      } else {
        message = 'İş reddedildi.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Düzenleme ekranına yönlendirir ve geri dönüldüğünde listeyi günceller.
  void _navigateToEditScreen(JobSubmission submission) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubmissionScreen(submission: submission),
      ),
    );
    // Düzenleme ekranından geri dönüldüğünde, veriler değişmiş olabileceğinden listeyi yenile.
    _loadPendingSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onay Bekleyen İşler'),
      ),
      body: _pendingSubmissions.isEmpty
          ? const Center(
              child: Text('Onay bekleyen iş bulunmuyor.'),
            )
          : ListView.builder(
              itemCount: _pendingSubmissions.length,
              itemBuilder: (context, index) {
                final submission = _pendingSubmissions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(submission.operationName, // Changed from jobTitle
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Gönderen: ${submission.submittedBy}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('Proje Kodu: ${submission.projectCode}'),
                        Text('Operasyon Kodu: ${submission.operationCode}'),
                        Text('Tezgah: ${submission.machineUsed}'),
                        Text('Saatler: ${submission.startTime} - ${submission.endTime}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _navigateToEditScreen(submission),
                              child: const Text('Düzenle'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateSubmissionStatus(
                                  submission.id, SubmissionStatus.pendingSuperAdminApproval),
                              child: const Text('Üst Onaya Gönder'),
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