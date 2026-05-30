import 'package:flutter/material.dart';
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
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  final _descriptionController = TextEditingController();
  final _obNumberController = TextEditingController();
  bool _consentChecked = false;
  String _uploadedPhotoName = "No file chosen";
  String _uploadedAbstractName = "No file chosen";

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _obNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty ||
          _ageController.text.trim().isEmpty ||
          _selectedGender == null ||
          _descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all details to proceed.'),
            backgroundColor: TacticalTheme.errorContainer,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_uploadedPhotoName == "No file chosen") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or upload a recent photo.'),
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

  void _submitForm() {
    if (_obNumberController.text.trim().isEmpty || !_consentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A valid Police OB Number and legal declaration consent are required.'),
          backgroundColor: TacticalTheme.errorContainer,
        ),
      );
      return;
    }

    // Submit Action
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
          'Case file for "${_nameController.text}" has been queued for police verification under OB No: ${_obNumberController.text.toUpperCase()}.\n\nFamily will be notified upon moderator approval.',
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
                _obNumberController.clear();
                _consentChecked = false;
                _uploadedPhotoName = "No file chosen";
                _uploadedAbstractName = "No file chosen";
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
            actions: const [
              SizedBox(width: 48), // Symmetry spacer
            ],
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
                    // Title section
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

                    // Progress indicators
                    _buildStepIndicators(),
                    const Divider(height: 32, color: TacticalTheme.outlineVariant),

                    // Step Contents
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

  // Visual Step Progress Header
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

  // STEP 1 DETAILS FORM
  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: TacticalTheme.primary, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 12),
          child: const Text(
            'Personal Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TacticalTheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Full Name Field
        _buildLabel('FULL NAME'),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. John Doe'),
        ),
        const SizedBox(height: 16),

        // Age & Gender
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('AGE'),
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
                  _buildLabel('GENDER'),
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

        // Physical Description
        _buildLabel('PHYSICAL DESCRIPTION'),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('Height, weight, distinguishing marks, clothing last seen wearing...'),
        ),

        const SizedBox(height: 24),

        // Next Button
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

  // STEP 2 PHOTO UPLOAD FORM
  Widget _buildStep2Photo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: TacticalTheme.primary, width: 4)),
          ),
          padding: const EdgeInsets.only(left: 12),
          child: const Text(
            'Recent Photo',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TacticalTheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Custom File Picker Box
        GestureDetector(
          onTap: () {
            setState(() {
              _uploadedPhotoName = "maya_photo_scan.png";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selected: maya_photo_scan.png (4.2 MB)'),
                backgroundColor: TacticalTheme.surfaceContainer,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: TacticalTheme.surfaceLowest,
              border: Border.all(
                color: TacticalTheme.outline,
                style: BorderStyle.solid,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: TacticalTheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose high-resolution photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TacticalTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap here to browse files (Max 5MB)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: TacticalTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: TacticalTheme.primary),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'SELECT FILE',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: TacticalTheme.primary,
                    ),
                  ),
                ),
                if (_uploadedPhotoName != "No file chosen") ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: TacticalTheme.successGreen),
                      const SizedBox(width: 6),
                      Text(
                        _uploadedPhotoName,
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: TacticalTheme.successGreen),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Navigation Actions
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

  // STEP 3 POLICE VERIFICATION FORM
  Widget _buildStep3Police() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mandatory Alert Banner
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
                      'Police Verification Required',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.error,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'A valid Police OB (Occurrence Book) Number is mandatory to prevent false alarms.',
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
        const SizedBox(height: 20),

        // OB Number input
        _buildLabel('POLICE OB NUMBER'),
        TextFormField(
          controller: _obNumberController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. OB/12/34/56/2023').copyWith(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TacticalTheme.error, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TacticalTheme.errorContainer.withOpacity(0.5), width: 1.0),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Police Abstract Upload
        _buildLabel('UPLOAD POLICE ABSTRACT'),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: TacticalTheme.surfaceLowest,
            border: Border.all(color: TacticalTheme.outlineVariant),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description, size: 20, color: TacticalTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    _uploadedAbstractName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: TacticalTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TacticalTheme.surfaceHigh,
                  foregroundColor: TacticalTheme.onSurface,
                  elevation: 0,
                  side: const BorderSide(color: TacticalTheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                onPressed: () {
                  setState(() {
                    _uploadedAbstractName = "ob_abstract_signed.pdf";
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selected Abstract PDF file.'),
                      backgroundColor: TacticalTheme.surfaceContainer,
                    ),
                  );
                },
                icon: const Icon(Icons.upload, size: 14),
                label: const Text(
                  'UPLOAD',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Legal Consent checkbox
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

        // Bottom Navigation Buttons
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

  // HELPER WIDGETS
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
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
