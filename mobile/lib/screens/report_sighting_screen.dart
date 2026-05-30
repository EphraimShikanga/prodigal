import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/tactical_theme.dart';

class ReportSightingScreen extends StatefulWidget {
  const ReportSightingScreen({super.key});

  @override
  State<ReportSightingScreen> createState() => _ReportSightingScreenState();
}

class _ReportSightingScreenState extends State<ReportSightingScreen> {
  // Mode: true = Immediate (auto-capture), false = Past Sighting (manual)
  bool _isImmediate = true;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _timeController = TextEditingController();

  // Media Mock State
  String _photoFileName = "No file chosen";
  String _audioFileName = "No file chosen";
  bool _isRecordingAudio = false;
  int _recordDuration = 0;
  Timer? _recordTimer;

  // Auto-captured location (simulated device coordinates)
  final double _autoLat = -1.3733;
  final double _autoLng = 36.8583;
  late final DateTime _autoTime;

  @override
  void initState() {
    super.initState();
    _autoTime = DateTime.now();
    _timeController.text = _formatDateTime(_autoTime);
    _latController.text = _autoLat.toString();
    _lngController.text = _autoLng.toString();
    _locationNameController.text = "Nairobi National Park Perimeter";
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationNameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _timeController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  void _toggleAudioRecording() {
    if (_isRecordingAudio) {
      // Stop recording
      _recordTimer?.cancel();
      setState(() {
        _isRecordingAudio = false;
        _audioFileName = "audio_tip_${_recordDuration}s.wav";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio clip recorded: $_audioFileName'),
          backgroundColor: TacticalTheme.surfaceContainer,
        ),
      );
    } else {
      // Start recording
      setState(() {
        _isRecordingAudio = true;
        _recordDuration = 0;
        _audioFileName = "No file chosen";
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });
      });
    }
  }

  void _submitSighting() {
    if (_photoFileName == "No file chosen") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sighting photo is required.'),
          backgroundColor: TacticalTheme.errorContainer,
        ),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe what you saw.'),
          backgroundColor: TacticalTheme.errorContainer,
        ),
      );
      return;
    }

    final double lat = _isImmediate ? _autoLat : (double.tryParse(_latController.text) ?? 0.0);
    final double lng = _isImmediate ? _autoLng : (double.tryParse(_lngController.text) ?? 0.0);
    final String timestamp = _isImmediate ? _autoTime.toIso8601String() : _timeController.text;

    // Show high-fidelity submission dialog
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
            Icon(Icons.radar, color: TacticalTheme.secondaryContainer),
            SizedBox(width: 12),
            Text(
              'SIGHTING REGISTERED',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your anonymous sighting tip has been filed under moderate review:',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _buildDialogParam('COORDINATES', '$lat, $lng'),
            _buildDialogParam('TIMESTAMP', timestamp),
            _buildDialogParam('PHOTO ATTACHED', _photoFileName),
            if (_audioFileName != "No file chosen")
              _buildDialogParam('AUDIO NOTE', _audioFileName),
            _buildDialogParam('DESCRIPTION', _descriptionController.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss Dialog
              Navigator.of(context).pop(); // Back to Dashboard
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

  Widget _buildDialogParam(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: TacticalTheme.secondary),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: TacticalTheme.onSurface),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'REPORT SIGHTING',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
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
                    // Title section
                    const Text(
                      'Submit Sighting Report',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TacticalTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Help locate the missing child by providing verified sighting cues.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: TacticalTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Button Mode (Immediate vs Past)
                    _buildModeToggle(),
                    const SizedBox(height: 20),

                    // Location / Time dynamic inputs based on mode
                    if (_isImmediate) _buildImmediateTelemetry() else _buildPastManualFields(),

                    const SizedBox(height: 20),

                    // Media upload sections
                    _buildLabel('1. SIGHTING PHOTO (REQUIRED)'),
                    _buildPhotoUploader(),
                    const SizedBox(height: 20),

                    _buildLabel('2. AUDIO VOICE NOTE (OPTIONAL)'),
                    _buildAudioRecorder(),
                    const SizedBox(height: 20),

                    // Sighting description details
                    _buildLabel('3. SIGHTING DETAILS / OBSERVATIONS'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
                      decoration: _buildInputDecoration(
                        'Describe what the child was wearing, direction they were heading, physical state, or anyone they were with...',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TacticalTheme.secondaryContainer,
                          foregroundColor: TacticalTheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          elevation: 4,
                          shadowColor: TacticalTheme.secondaryContainer.withOpacity(0.3),
                        ),
                        onPressed: _submitSighting,
                        icon: const Icon(Icons.security, size: 18),
                        label: const Text(
                          'SUBMIT SIGHTING TIP',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Toggle Mode Selection
  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: TacticalTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TacticalTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isImmediate = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isImmediate ? TacticalTheme.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'IMMEDIATE SIGHTING',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isImmediate ? TacticalTheme.onPrimary : TacticalTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isImmediate = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isImmediate ? TacticalTheme.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'REPORT PAST SIGHTING',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: !_isImmediate ? TacticalTheme.onPrimary : TacticalTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Automatic Immediate Mode telemetry display
  Widget _buildImmediateTelemetry() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalTheme.primary.withOpacity(0.05),
        border: Border.all(color: TacticalTheme.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.gps_fixed, color: TacticalTheme.primary, size: 14),
              SizedBox(width: 8),
              Text(
                'AUTO-TELEMETRY CAPTURED',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: TacticalTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTelemetryRow('DEVICE LATITUDE', '$_autoLat° S'),
          const SizedBox(height: 6),
          _buildTelemetryRow('DEVICE LONGITUDE', '$_autoLng° E'),
          const SizedBox(height: 6),
          _buildTelemetryRow('GPS ACCURACY', '± 4.8 meters'),
          const SizedBox(height: 6),
          _buildTelemetryRow('CURRENT TIME', _formatDateTime(_autoTime)),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: TacticalTheme.outline),
        ),
        Text(
          val,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: TacticalTheme.onSurface),
        ),
      ],
    );
  }

  // Manual Past Mode inputs
  Widget _buildPastManualFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sighting Time input
        _buildLabel('SIGHTING DATE & TIME'),
        TextFormField(
          controller: _timeController,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('YYYY-MM-DD HH:MM:SS'),
        ),
        const SizedBox(height: 12),

        // Sighting Location Description input
        _buildLabel('LOCATION / CORNER DESCRIPTION'),
        TextFormField(
          controller: _locationNameController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Near Westlands Mall entry gate'),
        ),
        const SizedBox(height: 12),

        // Coordinates row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('LATITUDE'),
                  TextFormField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('-1.2682'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('LONGITUDE'),
                  TextFormField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
                    decoration: _buildInputDecoration('36.8044'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Photo Uploader Box
  Widget _buildPhotoUploader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _photoFileName = "sighting_snap_nairobi.jpg";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected: sighting_snap_nairobi.jpg'),
            backgroundColor: TacticalTheme.surfaceContainer,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TacticalTheme.surfaceLowest,
          border: Border.all(color: TacticalTheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.add_a_photo, size: 20, color: TacticalTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _photoFileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _photoFileName == "No file chosen" ? TacticalTheme.onSurfaceVariant : TacticalTheme.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
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
                  _photoFileName = "sighting_snap_nairobi.jpg";
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera snapped: sighting_snap_nairobi.jpg'),
                    backgroundColor: TacticalTheme.surfaceContainer,
                  ),
                );
              },
              icon: const Icon(Icons.photo_library, size: 14),
              label: const Text(
                'BROWSE',
                style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Audio Recorder controller
  Widget _buildAudioRecorder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalTheme.surfaceLowest,
        border: Border.all(color: TacticalTheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isRecordingAudio ? Icons.mic : Icons.volume_up,
                    size: 16,
                    color: _isRecordingAudio ? TacticalTheme.error : TacticalTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRecordingAudio ? 'Recording voice note...' : _audioFileName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _isRecordingAudio ? TacticalTheme.error : TacticalTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleAudioRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isRecordingAudio ? TacticalTheme.errorContainer : TacticalTheme.surfaceHigh,
                    border: Border.all(color: _isRecordingAudio ? TacticalTheme.error : TacticalTheme.outlineVariant),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecordingAudio ? Icons.stop : Icons.fiber_manual_record,
                        size: 12,
                        color: _isRecordingAudio ? Colors.white : TacticalTheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isRecordingAudio ? 'STOP (${_recordDuration}s)' : 'RECORD',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _isRecordingAudio ? Colors.white : TacticalTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isRecordingAudio) ...[
            const SizedBox(height: 10),
            // Mock Audio Waveform
            SizedBox(
              height: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(15, (index) {
                  final height = 4.0 + (index % 3 == 0 ? 10.0 : (index % 2 == 0 ? 6.0 : 2.0));
                  return Container(
                    width: 3,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    color: TacticalTheme.error,
                  );
                }),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Helpers
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
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
