import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';
import 'package:puantaj_takip_sistemi/user_model.dart';
import 'package:puantaj_takip_sistemi/edit_submission_screen.dart';

class UserFormsScreen extends StatefulWidget {
  final User user;
  const UserFormsScreen({super.key, required this.user});

  @override
  State<UserFormsScreen> createState() => _UserFormsScreenState();
}

class _UserFormsScreenState extends State<UserFormsScreen> {
  List<JobSubmission> _userSubmissions = [];

  @override
  void initState() {
    super.initState();
    _loadUserSubmissions();
  }

  void _loadUserSubmissions() {
    setState(() {
      _userSubmissions = mockSubmissions
          .where((s) => s.submittedBy == widget.user.username)
          .toList()
          .reversed // En yeni olanı en üstte göster
          .toList();
    });
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
    _loadUserSubmissions();
  }

  // Duruma göre renkli etiketler oluşturan yardımcı metot
  Widget _buildStatusChip(SubmissionStatus status) {
    String text;
    Color color;
    switch (status) {
      case SubmissionStatus.pending:
        text = 'Beklemede';
        color = Colors.orange;
        break;
      case SubmissionStatus.pendingSuperAdminApproval:
        text = 'Üst Onay Bekliyor';
        color = Colors.blue;
        break;
      case SubmissionStatus.approved:
        text = 'Onaylandı';
        color = Colors.green;
        break;
      case SubmissionStatus.rejected:
        text = 'Reddedildi';
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formlarım'),
      ),
      body: _userSubmissions.isEmpty
          ? const Center(
              child: Text('Daha önce gönderilmiş form bulunmuyor.'),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadUserSubmissions(),
              child: ListView.builder(
                itemCount: _userSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = _userSubmissions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(submission.operationName),
                      subtitle: Text('Proje: ${submission.projectCode} | Saatler: ${submission.startTime} - ${submission.endTime}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusChip(submission.status),
                          // Durumu "Beklemede" veya "Reddedildi" ise düzenle butonunu göster.
                          if (submission.status == SubmissionStatus.pending ||
                              submission.status == SubmissionStatus.rejected)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Düzenle',
                              onPressed: () => _navigateToEditScreen(submission),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}