import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';

class EditSubmissionScreen extends StatefulWidget {
  final JobSubmission submission;

  const EditSubmissionScreen({super.key, required this.submission});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jobTitleController;
  late TextEditingController _projectCodeController; // Was _jobDescriptionController
  late TextEditingController _operationNameController; // Was _jobTitleController
  late TextEditingController _operationCodeController;
  late TextEditingController _machineUsedController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _projectCodeController = TextEditingController(text: widget.submission.projectCode);
    _operationNameController = TextEditingController(text: widget.submission.operationName);
    _operationCodeController = TextEditingController(text: widget.submission.operationCode);
    _machineUsedController = TextEditingController(text: widget.submission.machineUsed);
    _startTimeController = TextEditingController(text: widget.submission.startTime);
    _endTimeController = TextEditingController(text: widget.submission.endTime);

    // Parse initial times if they exist
    _selectedStartTime = _parseTimeOfDay(widget.submission.startTime);
    _selectedEndTime = _parseTimeOfDay(widget.submission.endTime);
  }

  @override
  void dispose() {
    _projectCodeController.dispose();
    _operationNameController.dispose();
    _operationCodeController.dispose();
    _machineUsedController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      // Ana listedeki orijinal kaydı bul ve güncelle.
      final index =
          mockSubmissions.indexWhere((s) => s.id == widget.submission.id);
      if (index != -1) {
        // Bu widget'ın state'ini değil, global bir listeyi güncellediğimiz için
        // setState() çağrısına gerek yoktur. Değişiklik doğrudan yapılır.
        mockSubmissions[index].projectCode = _projectCodeController.text;
        mockSubmissions[index].operationName = _operationNameController.text;
        mockSubmissions[index].operationCode = _operationCodeController.text;
        mockSubmissions[index].machineUsed = _machineUsedController.text;
        mockSubmissions[index].startTime = _startTimeController.text;
        mockSubmissions[index].endTime = _endTimeController.text;

        // Eğer form reddedilmiş durumdaysa, düzenlendikten sonra tekrar "Beklemede" durumuna alınır.
        if (mockSubmissions[index].status == SubmissionStatus.rejected) {
          mockSubmissions[index].status = SubmissionStatus.pending;
        }

        // `Navigator.pop` çağrısından önce context kullanmak tehlikeli olabileceğinden
        // widget'ın hala "mounted" olduğunu kontrol etmek iyi bir pratiktir.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değişiklikler başarıyla kaydedildi.'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.of(context).pop(); // Onay ekranına geri dön.
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_selectedStartTime ?? TimeOfDay.now())
          : (_selectedEndTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        // Saati "HH:MM" formatında sakla
        final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStartTime) {
          _selectedStartTime = picked;
          _startTimeController.text = formattedTime;
        } else {
          _selectedEndTime = picked;
          _endTimeController.text = formattedTime;
        }
      });
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length == 2) return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşi Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _projectCodeController,
                decoration: const InputDecoration(labelText: 'PROJE KODU'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Proje kodu boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _operationNameController,
                decoration: const InputDecoration(labelText: 'OPERASYON ADI'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Operasyon adı boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _operationCodeController,
                decoration: const InputDecoration(labelText: 'OPERASYON KODU'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Operasyon kodu boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _machineUsedController,
                decoration: const InputDecoration(labelText: 'KULLANDIĞI TEZGAH'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Tezgah bilgisi boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: 'BAŞLAMA SAATİ',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, true),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Başlama saati seçiniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'BİTİŞ SAATİ',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, false),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Bitiş saati seçiniz' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Değişiklikleri Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}