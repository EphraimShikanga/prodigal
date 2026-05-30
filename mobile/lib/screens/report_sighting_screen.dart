import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/tactical_theme.dart';

class ReportSightingScreen extends StatefulWidget {
  final String? caseId;

  const ReportSightingScreen({super.key, this.caseId});

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
  final _reporterNameController = TextEditingController();
  final _reporterPhoneController = TextEditingController();

  // File Upload State
  String _photoFileName = "No file chosen";
  String? _photoUploadUrl;
  bool _isUploadingPhoto = false;

  String _audioFileName = "No file chosen";
  String? _audioUploadUrl;
  bool _isUploadingAudio = false;

  // Auto-captured location (simulated device coordinates)
  final double _autoLat = -1.3733;
  final double _autoLng = 36.8583;
  late final DateTime _autoTime;

  // Map Picker State (Past Sighting Mode)
  LatLng _mapPinLatLng = const LatLng(-1.2825, 36.8219); // Default Nairobi coordinate
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _autoTime = DateTime.now();
    _timeController.text = _formatDateTime(_autoTime);
    _latController.text = _mapPinLatLng.latitude.toStringAsFixed(5);
    _lngController.text = _mapPinLatLng.longitude.toStringAsFixed(5);
    _locationNameController.text = "Ngong Road Junction";
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationNameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _timeController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  // Pick Date & Time via system pickers
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
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

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
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

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _timeController.text = _formatDateTime(fullDateTime);
        });
      }
    }
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
      return 'http://10.0.2.2:3000$relativeUrl';
    } else {
      throw Exception('Server returned status ${response.statusCode}: ${response.body}');
    }
  }

  // Sighting Photo picker camera/gallery choice
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _photoFileName = image.name;
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
          content: Text('Sighting photo uploaded: ${image.name}'),
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
          content: Text('Failed to upload sighting photo: $e'),
          backgroundColor: TacticalTheme.error,
        ),
      );
    }
  }

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
                'SELECT SIGHTING PHOTO SOURCE',
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

  // Sighting Audio file picker
  Future<void> _pickAudioFile() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      setState(() {
        _audioFileName = file.name;
        _isUploadingAudio = true;
        _audioUploadUrl = null;
      });

      final url = await _uploadFileToBackend(file.path!, file.name);
      setState(() {
        _audioUploadUrl = url;
        _isUploadingAudio = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio file uploaded: ${file.name}'),
          backgroundColor: TacticalTheme.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploadingAudio = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload audio: $e'),
          backgroundColor: TacticalTheme.error,
        ),
      );
    }
  }

  Future<void> _submitSighting() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe what you saw.'),
          backgroundColor: TacticalTheme.errorContainer,
        ),
      );
      return;
    }

    if (_photoUploadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select and upload a sighting photo first (mandatory for ML matching verification).'),
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
                  'SYNCING SIGHTING TIP...',
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
      final double lat = _isImmediate ? _autoLat : (double.tryParse(_latController.text) ?? 0.0);
      final double lng = _isImmediate ? _autoLng : (double.tryParse(_lngController.text) ?? 0.0);

      final Map<String, dynamic> payload = {
        "case_id": widget.caseId,
        "latitude": lat,
        "longitude": lng,
        "location_description": _isImmediate ? "Auto-Telemetry Location" : _locationNameController.text.trim(),
        "photo_url": _photoUploadUrl,
        "audio_url": _audioUploadUrl,
        "reporter_name": _reporterNameController.text.trim().isEmpty ? null : _reporterNameController.text.trim(),
        "reporter_phone": _reporterPhoneController.text.trim().isEmpty ? null : _reporterPhoneController.text.trim()
      };

      const String backendUrl = 'http://10.0.2.2:3000/sightings';
      
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String sightingId = responseData['id'] ?? 'N/A';
        final String status = responseData['status'] ?? 'PENDING';

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
                  'Sighting tip successfully transmitted and committed to Neon cloud database!',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                _buildDialogParam('SIGHTING ID', sightingId),
                _buildDialogParam('COORDINATES', '$lat, $lng'),
                _buildDialogParam('STATUS', status),
                _buildDialogParam('REPORTER', _reporterNameController.text.trim().isEmpty ? "Anonymous Citizen" : _reporterNameController.text.trim()),
                if (_audioUploadUrl != null)
                  _buildDialogParam('AUDIO LINK', 'Uploaded wav file'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss dialogue
                  Navigator.of(context).pop(); // Back to Home
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
          'Failed to record sighting on server. Details:\n\n${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(
        'CONNECTION ERROR',
        'Could not establish link with server at http://10.0.2.2:3000.\n\nMake sure the backend is running.\n\nDetail: $e',
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

                    _buildModeToggle(),
                    const SizedBox(height: 20),

                    if (_isImmediate) _buildImmediateTelemetry() else _buildPastManualFields(),

                    const SizedBox(height: 20),

                    _buildLabel('1. SIGHTING PHOTO (MANDATORY)'),
                    _buildPhotoUploader(),
                    const SizedBox(height: 20),

                    _buildLabel('2. AUDIO VOICE NOTE (OPTIONAL)'),
                    _buildAudioUploader(),
                    const SizedBox(height: 20),

                    _buildLabel('3. SIGHTING DETAILS / OBSERVATIONS *'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
                      decoration: _buildInputDecoration(
                        'Describe clothing, direction traveling, physical state...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('4. CONTACT DETAILS (OPTIONAL / LEAVE EMPTY TO BE ANONYMOUS)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _reporterNameController,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
                            decoration: _buildInputDecoration('Your Name'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _reporterPhoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
                            decoration: _buildInputDecoration('Your Phone'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

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

  Widget _buildPastManualFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('SIGHTING DATE & TIME'),
        TextFormField(
          controller: _timeController,
          readOnly: true,
          onTap: _pickDateTime,
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('Tap to select date & time').copyWith(
            suffixIcon: const Icon(Icons.calendar_month, color: TacticalTheme.primary, size: 20),
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('LOCATION / CORNER DESCRIPTION'),
        TextFormField(
          controller: _locationNameController,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: TacticalTheme.onSurface),
          decoration: _buildInputDecoration('e.g. Near Westlands Mall entry gate'),
        ),
        const SizedBox(height: 16),

        _buildLabel('SELECT SIGHTING LOCATION (TAP MAP TO PINPOINT)'),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TacticalTheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _mapPinLatLng,
                  initialZoom: 14.0,
                  onTap: (tapPosition, latLng) {
                    setState(() {
                      _mapPinLatLng = latLng;
                      _latController.text = latLng.latitude.toStringAsFixed(5);
                      _lngController.text = latLng.longitude.toStringAsFixed(5);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.prodigal.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _mapPinLatLng,
                        width: 32,
                        height: 32,
                        child: const Icon(
                          Icons.location_pin,
                          color: TacticalTheme.secondaryContainer,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 8,
                right: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.black.withOpacity(0.75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PINPOINTED COORDS:',
                        style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: TacticalTheme.primary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_latController.text}°S, ${_lngController.text}°E',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: TacticalTheme.secondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploader() {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _showPhotoSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TacticalTheme.surfaceLowest,
          border: Border.all(color: _photoUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _photoUploadUrl != null ? Icons.photo : Icons.add_a_photo,
                    size: 20,
                    color: _photoUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _photoFileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _photoUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploadingPhoto)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: TacticalTheme.primary, strokeWidth: 2),
              )
            else if (_photoUploadUrl != null)
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
                onPressed: _showPhotoSourceSheet,
                icon: const Icon(Icons.photo_library, size: 14),
                label: const Text(
                  'CHOOSE',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioUploader() {
    return GestureDetector(
      onTap: _isUploadingAudio ? null : _pickAudioFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TacticalTheme.surfaceLowest,
          border: Border.all(color: _audioUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _audioUploadUrl != null ? Icons.audiotrack : Icons.volume_up,
                    size: 20,
                    color: _audioUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _audioFileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _audioUploadUrl != null ? TacticalTheme.successGreen : TacticalTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploadingAudio)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: TacticalTheme.primary, strokeWidth: 2),
              )
            else if (_audioUploadUrl != null)
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
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.audiotrack, size: 14),
                label: const Text(
                  'CHOOSE',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
