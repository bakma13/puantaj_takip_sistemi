import 'package:flutter/material.dart';
import 'package:puantaj_takip_sistemi/user_model.dart';
import 'package:puantaj_takip_sistemi/job_submission_model.dart';
import 'package:puantaj_takip_sistemi/mock_data.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectCodeController = TextEditingController(); // Was _jobDescriptionController
  final _operationNameController = TextEditingController(); // Was _jobTitleController
  final _operationCodeController = TextEditingController();
  final _machineUsedController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

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

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newSubmission = JobSubmission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectCode: _projectCodeController.text,
      operationName: _operationNameController.text,
      operationCode: _operationCodeController.text,
      machineUsed: _machineUsedController.text,
      submittedBy: widget.user.username,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      status: SubmissionStatus.pending,
    );

    mockSubmissions.add(newSubmission);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form başarıyla onaya gönderildi.'),
        backgroundColor: Colors.green,
      ),
    );

    // Puantaj formu gönderildikten sonra bir önceki ekrana (Dashboard) dön.
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Puantaj Formu'),
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
                readOnly: true, // Saati elle yazmayı engeller
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
                readOnly: true, // Saati elle yazmayı engeller
                onTap: () => _selectTime(context, false),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Bitiş saati seçiniz' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Onaya Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}