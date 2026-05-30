import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/tactical_theme.dart';

class ReportMissingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ReportMissingScreen({super.key, this.onBackToHome});

  @override
  State<ReportMissingScreen> createState() => _ReportMissingScreenState();
}

class _ReportMissingScreenState extends State<ReportMissingScreen> {
  int _currentStep = 1;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Child details
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  final _descriptionController = TextEditingController();
  
  // Step 1: Last Seen details
  final _lastSeenLocationController = TextEditingController();
  DateTime _lastSeenDateTime = DateTime.now();
  
  // Step 1: Guardian / Reporter details
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  String _guardianRelationship = 'GUARDIAN';

  // Step 2: Photo upload
  String _uploadedPhotoName = "No file chosen";
  String? _photoUploadUrl;
  bool _isUploadingPhoto = false;

  // Step 3: Police details
  final _obNumberController = TextEditingController();
  final _policeStationController = TextEditingController();
  final _policeOfficerNameController = TextEditingController();
  final _policeOfficerIdController = TextEditingController();
  String _uploadedAbstractName = "No file chosen";
  String? _abstractUploadUrl;
  bool _isUploadingAbstract = false;
  bool _consentChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _lastSeenLocationController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _obNumberController.dispose();
    _policeStationController.dispose();
    _policeOfficerNameController.dispose();
    _policeOfficerIdController.dispose();
    super.dispose();
  }

  // Pick Date & Time for last seen
  Future<void> _selectLastSeenDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _lastSeenDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: TacticalTheme.primary,
              onPrimary: TacticalTheme.onPrimary,
              surface: TacticalTheme.surfaceContainer,
              onSurface: TacticalTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    if (!mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_lastSeenDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: TacticalTheme.primary,
              onPrimary: TacticalTheme.onPrimary,
              surface: TacticalTheme.surfaceContainer,
              onSurface: TacticalTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _lastSeenDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // Upload file helper
  Future<String> _uploadFileToBackend(String filePath, String fileName) async {
    const String uploadUrl = 'http://10.0.2.2:3000/cases/upload';
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String relativeUrl = data['url'];
      // Return full local network URL
      return 'http://10.0.2.2:3000$relativeUrl';
    } else {
      throw Exception('Server returned status ${response.statusCode}: ${response.body}');
    }
  }

  // Pick Child Photo using camera or gallery
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _uploadedPhotoName = image.name;
        _isUploadingPhoto = true;
        _photoUploadUrl = null;
      });

      final url = await _uploadFileToBackend(image.path, image.name);
      setState(() {
        _photoUploadUrl = url;
        _isUploadingPhoto = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo uploaded: ${image.name}'),
          backgroundColor: TacticalTheme.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload photo: $e'),
          backgroundColor: TacticalTheme.error,
        ),
      );
    }
  }

  // Choose photo source dialog
  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECT PHOTO SOURCE',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: TacticalTheme.primary),
                title: const Text('Camera', style: TextStyle(fontFamily: 'Inter')),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: TacticalTheme.primary),
                title: const Text('Gallery', style: TextStyle(fontFamily: 'Inter')),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick Police Abstract file picker
  Future<void> _pickAbstractFile() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      setState(() {
        _uploadedAbstractName = file.name;
        _isUploadingAbstract = true;
        _abstractUploadUrl = null;
      });

      final url = await _uploadFileToBackend(file.path!, file.name);
      setState(() {
        _abstractUploadUrl = url;
        _isUploadingAbstract = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abstract document uploaded: ${file.name}'),
          backgroundColor: TacticalTheme.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploadingAbstract = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload abstract: $e'),
          backgroundColor: TacticalTheme.error,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty ||
          _ageController.text.trim().isEmpty ||
          _selectedGender == null ||
          _descriptionController.text.trim().isEmpty ||
          _guardianNameController.text.trim().isEmpty ||
          _guardianPhoneController.text.trim().isEmpty ||
          _lastSeenLocationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all child, last seen location, and guardian details.'),
            backgroundColor: TacticalTheme.errorContainer,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_photoUploadUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select and upload a recent photo first.'),
            backgroundColor: TacticalTheme.errorContainer,
          ),
        );
        return;
      }
    }

    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_obNumberController.text.trim().isEmpty || 
        _policeStationController.text.trim().isEmpty ||
        _policeOfficerNameController.text.trim().isEmpty ||
        _policeOfficerIdController.text.trim().isEmpty ||
        _abstractUploadUrl == null || 
        !_consentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all police details, upload the abstract document, and consent.'),
          backgroundColor: TacticalTheme.errorContainer,
        ),
      );
      return;
    }

    // 1. Show loading progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: TacticalTheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: TacticalTheme.outlineVariant),
          ),
          content: Row(
            children: const [
              CircularProgressIndicator(color: TacticalTheme.primary),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'SYNCING WITH TACTICAL BACKEND...',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TacticalTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final String genderLabel = _selectedGender == 'm' 
          ? 'MALE' 
          : (_selectedGender == 'f' ? 'FEMALE' : 'OTHER');

      final Map<String, dynamic> payload = {
        "child": {
          "name": _nameController.text.trim(),
          "age": int.tryParse(_ageController.text.trim()) ?? 0,
          "gender": genderLabel,
          "description": _descriptionController.text.trim(),
          "photo_url": _photoUploadUrl
        },
        "reporter": {
          "name": _guardianNameController.text.trim(),
          "phone": _guardianPhoneController.text.trim(),
          "email": _guardianEmailController.text.trim().isEmpty ? null : _guardianEmailController.text.trim(),
          "relationship": _guardianRelationship
        },
        "police": {
          "police_ob_number": _obNumberController.text.trim().toUpperCase(),
          "station_name": _policeStationController.text.trim(),
          "officer_id": _policeOfficerIdController.text.trim(),
          "officer_name": _policeOfficerNameController.text.trim(),
          "abstract_image_url": _abstractUploadUrl
        },
        "last_seen_location": _lastSeenLocationController.text.trim(),
        "last_seen_lat": -1.2921,
        "last_seen_lng": 36.8219,
        "last_seen_time": _lastSeenDateTime.toUtc().toIso8601String()
      };

      const String backendUrl = 'http://10.0.2.2:3000/cases';
      
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (!mounted) return;
      // Dismiss loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String caseId = responseData['id'] ?? 'N/A';

        // Show success dialogue
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: TacticalTheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: TacticalTheme.outlineVariant),
            ),
            title: Row(
              children: const [
                Icon(Icons.verified_user, color: TacticalTheme.primary),
                SizedBox(width: 12),
                Text(
                  'SUBMISSION REGISTERED',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 16),
                ),
              ],
            ),
            content: Text(
              'Case file has been successfully sent and committed to the backend!\n\nCase ID: $caseId\nOB No: ${_obNumberController.text.toUpperCase()}\nChild: ${_nameController.text}\nGuardian: ${_guardianNameController.text}\n\nCase is now queued for moderation approval.',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Reset state
                  setState(() {
                    _currentStep = 1;
                    _nameController.clear();
                    _ageController.clear();
                    _selectedGender = null;
                    _descriptionController.clear();
                    _guardianNameController.clear();
                    _guardianPhoneController.clear();
                    _guardianEmailController.clear();
                    _lastSeenLocationController.clear();
                    _obNumberController.clear();
                    _policeStationController.clear();
                    _policeOfficerNameController.clear();
                    _policeOfficerIdController.clear();
                    _consentChecked = false;
                    _uploadedPhotoName = "No file chosen";
                    _uploadedAbstractName = "No file chosen";
                    _photoUploadUrl = null;
                    _abstractUploadUrl = null;
                  });
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  }
                },
                child: const Text(
                  'DISMISS',
                  style: TextStyle(fontFamily: 'JetBrains Mono', color: TacticalTheme.primary),
                ),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog(
          'SERVER ERROR (${response.statusCode})',
          'Failed to register case with server. Details:\n\n${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(
        'CONNECTION ERROR',
        'Could not establish link with server at http://10.0.2.2:3000.\n\nMake sure the backend NestJS server is running.\n\nDetail: $e',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalTheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: TacticalTheme.error),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: TacticalTheme.error),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 16,
                color: TacticalTheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: TacticalTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'DISMISS',
              style: TextStyle(fontFamily: 'JetBrains Mono', color: TacticalTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: TacticalTheme.background,
            border: Border(
              bottom: BorderSide(
                color: TacticalTheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: TacticalTheme.onSurfaceVariant),
              onPressed: widget.onBackToHome,
            ),
            title: const Text(
              'RECOVERY_OPS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: TacticalTheme.primary,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: TacticalTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: TacticalTheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Missing Person',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please provide accurate information. False reporting is a criminal offense.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: TacticalTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildStepIndicators(),
                    const Divider(height: 32, color: TacticalTheme.outlineVariant),

                    if (_currentStep == 1) _buildStep1Details(),
                    if (_currentStep == 2) _buildStep2Photo(),
                    if (_currentStep == 3) _buildStep3Police(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSingleIndicator(1, 'DETAILS'),
        _buildLineSeparator(1),
        _buildSingleIndicator(2, 'PHOTO'),
        _buildLineSeparator(2),
        _buildSingleIndicator(3, 'POLICE'),
      ],
    );
  }

  Widget _buildSingleIndicator(int stepNum, String label) {
    final bool isCompleted = stepNum < _currentStep;
    final bool isActive = stepNum == _currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? TacticalTheme.primary : TacticalTheme.surfaceHighest,
            border: Border.all(
              color: isActive ? TacticalTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: TacticalTheme.onPrimary)
                : Text(
                    '$stepNum',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted || isActive ? TacticalTheme.onPrimary : TacticalTheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isCompleted || isActive ? TacticalTheme.primary : TacticalTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLineSeparator(int segment) {
    final bool isPassed = segment < _currentStep;
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 16),
        color: isPassed ? TacticalTheme.primary : TacticalTheme.outlineVariant,
      ),
    );
  }

  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Child Personal Details
        _buildSectionHeader('1. CHILD INFORMATION'),
        const SizedBox(height: 16),

        _buildLabel('FULL NAME *'),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Maya Lin'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('AGE *'),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('Years'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GENDER *'),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    dropdownColor: TacticalTheme.surfaceContainer,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('Select'),
                    items: const [
                      DropdownMenuItem(value: 'm', child: Text('Male')),
                      DropdownMenuItem(value: 'f', child: Text('Female')),
                      DropdownMenuItem(value: 'o', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedGender = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildLabel('PHYSICAL DESCRIPTION *'),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('Height, distinguishing clothing, landmarks last seen wearing...'),
        ),
        const SizedBox(height: 24),

        // Section: Last Seen Details
        _buildSectionHeader('2. LAST SEEN METADATA'),
        const SizedBox(height: 16),

        _buildLabel('LAST SEEN LOCATION NAME *'),
        TextFormField(
          controller: _lastSeenLocationController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Westlands Market entrance'),
        ),
        const SizedBox(height: 16),

        _buildLabel('LAST SEEN DATE & TIME *'),
        InkWell(
          onTap: _selectLastSeenDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: TacticalTheme.surfaceLowest,
              border: Border.all(color: TacticalTheme.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _lastSeenDateTime.toString().substring(0, 16),
                  style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
                ),
                const Icon(Icons.calendar_month, color: TacticalTheme.primary, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section: Guardian details
        _buildSectionHeader('3. GUARDIAN / REPORTER DETAILS'),
        const SizedBox(height: 16),

        _buildLabel('GUARDIAN FULL NAME *'),
        TextFormField(
          controller: _guardianNameController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Jane Lin'),
        ),
        const SizedBox(height: 16),

        _buildLabel('GUARDIAN PHONE NUMBER (MSISDN) *'),
        TextFormField(
          controller: _guardianPhoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. +254711223344'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GUARDIAN EMAIL'),
                  TextFormField(
                    controller: _guardianEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('Optional'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('RELATIONSHIP *'),
                  DropdownButtonFormField<String>(
                    value: _guardianRelationship,
                    dropdownColor: TacticalTheme.surfaceContainer,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('Relationship'),
                    items: const [
                      DropdownMenuItem(value: 'MOTHER', child: Text('Mother')),
                      DropdownMenuItem(value: 'FATHER', child: Text('Father')),
                      DropdownMenuItem(value: 'GUARDIAN', child: Text('Guardian')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _guardianRelationship = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalTheme.primary,
              foregroundColor: TacticalTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'NEXT',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Photo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('UPLOAD CHILD PORTRAIT'),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _isUploadingPhoto ? null : _showPhotoSourceSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: TacticalTheme.surfaceLowest,
              border: Border.all(
                color: _photoUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Icon(
                  _photoUploadUrl != null ? Icons.photo : Icons.add_photo_alternate,
                  size: 48,
                  color: _photoUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  _photoUploadUrl != null ? 'Portrait Selected' : 'Choose child photo',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TacticalTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _photoUploadUrl != null ? 'Successfully synced file' : 'Tap to trigger Camera or Gallery',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: TacticalTheme.onSurfaceVariant,
                  ),
                ),
                if (_isUploadingPhoto) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: TacticalTheme.primary),
                  const SizedBox(height: 8),
                  const Text(
                    'UPLOADING PORTRAIT FILE...',
                    style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TacticalTheme.primary),
                  ),
                ] else if (_photoUploadUrl != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: TacticalTheme.successGreen),
                      const SizedBox(width: 6),
                      Text(
                        _uploadedPhotoName,
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: TacticalTheme.successGreen),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: TacticalTheme.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              onPressed: _prevStep,
              child: const Text(
                'BACK',
                style: TextStyle(fontFamily: 'JetBrains Mono', color: TacticalTheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalTheme.primary,
                foregroundColor: TacticalTheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text(
                'NEXT',
                style: TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Police() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: TacticalTheme.errorContainer.withOpacity(0.15),
            border: const Border(left: BorderSide(color: TacticalTheme.error, width: 4)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning, color: TacticalTheme.error, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Police Authentication Mandatory',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.error,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Provide authentic police details and the signed physical Occurrence Book (OB) abstract.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: TacticalTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader('POLICE OFFICIAL FILING'),
        const SizedBox(height: 16),

        _buildLabel('POLICE STATION NAME *'),
        TextFormField(
          controller: _policeStationController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Westlands Police Station'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('RECORDING OFFICER NAME *'),
                  TextFormField(
                    controller: _policeOfficerNameController,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('e.g. Sgt. Njoroge'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('OFFICER BADGE ID *'),
                  TextFormField(
                    controller: _policeOfficerIdController,
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('e.g. AP_8842'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildLabel('OCCURRENCE BOOK (OB) NUMBER *'),
        TextFormField(
          controller: _obNumberController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. OB/1024/2026').copyWith(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TacticalTheme.error, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TacticalTheme.errorContainer, width: 1.0),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('UPLOAD POLICE ABSTRACT ABSTRACT *'),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: TacticalTheme.surfaceLowest,
            border: Border.all(color: _abstractUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.outlineVariant),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 20, color: TacticalTheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadedAbstractName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: TacticalTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isUploadingAbstract)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: TacticalTheme.primary, strokeWidth: 2),
                )
              else if (_abstractUploadUrl != null)
                const Icon(Icons.check_circle, size: 22, color: TacticalTheme.successGreen)
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TacticalTheme.surfaceHigh,
                    foregroundColor: TacticalTheme.onSurface,
                    elevation: 0,
                    side: const BorderSide(color: TacticalTheme.outlineVariant),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                  onPressed: _pickAbstractFile,
                  icon: const Icon(Icons.upload, size: 14),
                  label: const Text(
                    'CHOOSE',
                    style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _consentChecked,
                activeColor: TacticalTheme.primary,
                checkColor: TacticalTheme.onPrimary,
                onChanged: (val) {
                  setState(() {
                    _consentChecked = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _consentChecked = !_consentChecked;
                  });
                },
                child: Text(
                  'I declare under penalty of perjury that the information provided is true and correct. I consent to the processing of this data in accordance with the Data Protection Act (DPA) 2019. I understand that submitting false reports is a criminal offense punishable by law.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 1.3,
                    color: TacticalTheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _prevStep,
              child: const Text(
                'BACK',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: TacticalTheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalTheme.secondaryContainer,
                foregroundColor: TacticalTheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                elevation: 4,
                shadowColor: TacticalTheme.secondaryContainer.withOpacity(0.3),
              ),
              onPressed: _submitForm,
              icon: const Icon(Icons.security, size: 16),
              label: const Text(
                'SUBMIT FOR MODERATION',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: TacticalTheme.surfaceHighest,
        border: const Border(left: BorderSide(color: TacticalTheme.primary, width: 2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: TacticalTheme.primary,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: TacticalTheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: TacticalTheme.onSurfaceVariant.withOpacity(0.4),
      ),
      fillColor: TacticalTheme.surfaceLowest,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TacticalTheme.primary, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: TacticalTheme.outlineVariant, width: 1.0),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: TacticalTheme.outlineVariant, width: 1.0),
      ),
    );
  }
}
