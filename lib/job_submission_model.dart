// Onay durumlarını temsil eden enum.
enum SubmissionStatus { pending, pendingSuperAdminApproval, approved, rejected }

class JobSubmission {
  final String id;
  String projectCode; // PROJE KODU (was description)
  String operationName; // OPERASYON ADI (was jobTitle)
  String operationCode; // OPERASYON KODU
  String machineUsed; // KULLANDIĞI TEZGAH
  final String submittedBy; // İşi gönderen kullanıcının adı
  String startTime; // BAŞLAMA SAATİ
  String endTime; // BİTİŞ SAATİ
  SubmissionStatus status; // İşin mevcut durumu

  JobSubmission({
    required this.id,
    required this.projectCode,
    required this.operationName,
    required this.operationCode,
    required this.machineUsed,
    required this.submittedBy,
    required this.startTime,
    required this.endTime,
    this.status = SubmissionStatus.pending,
  });
}