import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import '../models/project.dart';
import '../models/penetration.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';

class PenetrationFormScreen extends StatefulWidget {
  final Project project;
  final Penetration penetration;
  final bool isNew;

  const PenetrationFormScreen({
    super.key,
    required this.project,
    required this.penetration,
    required this.isNew,
  });

  @override
  State<PenetrationFormScreen> createState() => _PenetrationFormScreenState();
}

class _PenetrationFormScreenState extends State<PenetrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();
  final PdfService _pdfService = PdfService();
  final SettingsService _settings = SettingsService();
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  late TextEditingController _locationCtrl;
  late TextEditingController _installerCtrl;
  late TextEditingController _wallOtherCtrl;
  late TextEditingController _floorOtherCtrl;
  late TextEditingController _deflectionCtrl;
  late TextEditingController _insulationOtherCtrl;
  late TextEditingController _insulationThicknessCtrl;
  late TextEditingController _otherServiceCtrl;
  late TextEditingController _notesCtrl;

  late String _wallType;
  late String _floorType;
  late String _fireResistance;
  late String _sides;
  late String _insulation;
  late String _penetrationType;
  late String _notesStatus;
  late bool _hasDeflection;

  late bool _metalPipe, _plasticPipe, _fireDamper, _ductwork, _flue;
  late bool _cableTray, _cableLadder, _cableBasket, _trunking, _busbar, _otherService;
  late bool _infoWallFloor, _infoME, _infoProduct, _infoDamper, _infoDuctwork;

  late List<ServiceSize> _serviceSizes;
  late List<String> _photoPaths;
  String _signaturePath = '';
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final pen = widget.penetration;

    _locationCtrl = TextEditingController(text: pen.location);
    _installerCtrl = TextEditingController(text: pen.installer);
    _wallOtherCtrl = TextEditingController(text: pen.wallTypeOther);
    _floorOtherCtrl = TextEditingController(text: pen.floorTypeOther);
    _deflectionCtrl = TextEditingController(text: pen.deflectionMm);
    _insulationOtherCtrl = TextEditingController(text: pen.insulationOther);
    _insulationThicknessCtrl = TextEditingController(text: pen.insulationThickness);
    _otherServiceCtrl = TextEditingController(text: pen.otherServiceText);
    _notesCtrl = TextEditingController(text: pen.notes);

    _wallType = pen.wallType;
    _floorType = pen.floorType;
    _fireResistance = pen.fireResistance;
    _sides = pen.sides;
    _insulation = pen.insulation;
    _penetrationType = pen.penetrationType;
    _notesStatus = pen.notesStatus;
    _hasDeflection = pen.hasDeflection;

    _metalPipe = pen.metalPipe;
    _plasticPipe = pen.plasticPipe;
    _fireDamper = pen.fireDamper;
    _ductwork = pen.ductwork;
    _flue = pen.flue;
    _cableTray = pen.cableTray;
    _cableLadder = pen.cableLadder;
    _cableBasket = pen.cableBasket;
    _trunking = pen.trunking;
    _busbar = pen.busbar;
    _otherService = pen.otherService;

    _infoWallFloor = pen.infoWallFloorContractor;
    _infoME = pen.infoMEContractor;
    _infoProduct = pen.infoProductSubmissions;
    _infoDamper = pen.infoDamperTech;
    _infoDuctwork = pen.infoDuctworkTech;

    _serviceSizes = List.from(pen.serviceSizes);
    if (_serviceSizes.isEmpty) _serviceSizes.add(ServiceSize());
    _photoPaths = List.from(pen.photoPaths);
    _signaturePath = pen.signaturePath;

    if (pen.date.isNotEmpty) {
      _date = DateTime.tryParse(pen.date) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _locationCtrl.dispose();
    _installerCtrl.dispose();
    _wallOtherCtrl.dispose();
    _floorOtherCtrl.dispose();
    _deflectionCtrl.dispose();
    _insulationOtherCtrl.dispose();
    _insulationThicknessCtrl.dispose();
    _otherServiceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Penetration _buildPenetration() {
    return Penetration(
      id: widget.penetration.id,
      projectId: widget.project.id,
      location: _locationCtrl.text.trim(),
      date: _date.toIso8601String(),
      installer: _installerCtrl.text.trim(),
      wallType: _wallType,
      wallTypeOther: _wallOtherCtrl.text.trim(),
      floorType: _floorType,
      floorTypeOther: _floorOtherCtrl.text.trim(),
      fireResistance: _fireResistance,
      metalPipe: _metalPipe,
      plasticPipe: _plasticPipe,
      fireDamper: _fireDamper,
      ductwork: _ductwork,
      flue: _flue,
      cableTray: _cableTray,
      cableLadder: _cableLadder,
      cableBasket: _cableBasket,
      trunking: _trunking,
      busbar: _busbar,
      otherService: _otherService,
      otherServiceText: _otherServiceCtrl.text.trim(),
      hasDeflection: _hasDeflection,
      deflectionMm: _deflectionCtrl.text.trim(),
      sides: _sides,
      insulation: _insulation,
      insulationOther: _insulationOtherCtrl.text.trim(),
      insulationThickness: _insulationThicknessCtrl.text.trim(),
      serviceSizes: _serviceSizes,
      penetrationType: _penetrationType,
      infoWallFloorContractor: _infoWallFloor,
      infoMEContractor: _infoME,
      infoProductSubmissions: _infoProduct,
      infoDamperTech: _infoDamper,
      infoDuctworkTech: _infoDuctwork,
      photoPaths: _photoPaths,
      signaturePath: _signaturePath,
      notesStatus: _notesStatus,
      notes: _notesCtrl.text.trim(),
    );
  }

  Future<String?> _exportSignature() async {
    if (_signatureController.isEmpty) return _signaturePath.isNotEmpty ? _signaturePath : null;
    final bytes = await _signatureController.toPngBytes();
    if (bytes == null) return null;
    final appDir = await getApplicationDocumentsDirectory();
    final sigDir = Directory('${appDir.path}/signatures');
    if (!await sigDir.exists()) await sigDir.create(recursive: true);
    final file = File('${sigDir.path}/sig_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final sigPath = await _exportSignature();
    if (sigPath != null) _signaturePath = sigPath;
    final pen = _buildPenetration();
    if (widget.isNew) {
      await _storage.addPenetration(widget.project.id, pen);
    } else {
      await _storage.updatePenetration(widget.project.id, pen);
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penetration saved')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _generatePdf({bool share = false}) async {
    setState(() => _saving = true);
    final sigPath = await _exportSignature();
    if (sigPath != null) _signaturePath = sigPath;
    final pen = _buildPenetration();
    // Save first
    if (widget.isNew) {
      await _storage.addPenetration(widget.project.id, pen);
    } else {
      await _storage.updatePenetration(widget.project.id, pen);
    }
    try {
      final logoPath = await _settings.getLogoPath();
      final companyName = await _settings.getCompanyName();
      final file = await _pdfService.generatePenetrationPdf(
        widget.project,
        pen,
        logoPath: logoPath,
        companyName: companyName,
      );
      setState(() => _saving = false);

      if (share) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Fire Stopping Assessment - ${widget.project.name}',
          text: 'Fire Stopping Assessment report for ${pen.location.isNotEmpty ? pen.location : widget.project.name}',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF saved'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Fire Stopping Assessment - ${widget.project.name}',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');
    if (!await photoDir.exists()) await photoDir.create(recursive: true);

    for (final img in images) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(img.path)}';
      final saved = await File(img.path).copy('${photoDir.path}/$fileName');
      setState(() => _photoPaths.add(saved.path));
    }
  }

  Future<void> _takePhoto() async {
    final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (img == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');
    if (!await photoDir.exists()) await photoDir.create(recursive: true);

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(img.path)}';
    final saved = await File(img.path).copy('${photoDir.path}/$fileName');
    setState(() => _photoPaths.add(saved.path));
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Penetration' : 'Edit Penetration'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _sectionHeader('Header'),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location / Area / One Trace pin',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd MMM yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _installerCtrl,
              decoration: const InputDecoration(
                labelText: 'Installer',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            // 1. Supporting Construction
            _sectionHeader('1. Supporting Construction'),
            _dropdown(
              label: 'Wall Type',
              value: _wallType,
              items: ['Concrete', 'Blockwork', 'Drywall', 'Shaftwall', 'Whitewall', 'Other'],
              onChanged: (v) => setState(() => _wallType = v ?? ''),
            ),
            if (_wallType == 'Other')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _wallOtherCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Wall Type – Other',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            _dropdown(
              label: 'Floor Type',
              value: _floorType,
              items: ['Concrete', 'Metal Deck', 'Hollow Core', 'Timber Floor', 'Other'],
              onChanged: (v) => setState(() => _floorType = v ?? ''),
            ),
            if (_floorType == 'Other')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _floorOtherCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Floor Type – Other',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            // 2. Fire Resistance
            _sectionHeader('2. Required Fire Resistance (minutes)'),
            _dropdown(
              label: 'Fire Resistance',
              value: _fireResistance,
              items: ['30', '60', '90', '120', '240'],
              onChanged: (v) => setState(() => _fireResistance = v ?? ''),
            ),

            // 3. Service Types
            _sectionHeader('3. Service Types Passing Through the Opening'),
            const Text('Pipes', style: TextStyle(fontWeight: FontWeight.w500)),
            CheckboxListTile(
              title: const Text('Metal Pipe'),
              value: _metalPipe,
              onChanged: (v) => setState(() => _metalPipe = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Plastic Pipe'),
              value: _plasticPipe,
              onChanged: (v) => setState(() => _plasticPipe = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Text('Ventilation Services', style: TextStyle(fontWeight: FontWeight.w500)),
            CheckboxListTile(
              title: const Text('Fire Damper'),
              value: _fireDamper,
              onChanged: (v) => setState(() => _fireDamper = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Ductwork'),
              value: _ductwork,
              onChanged: (v) => setState(() => _ductwork = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Flue'),
              value: _flue,
              onChanged: (v) => setState(() => _flue = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Text('Electrical Services', style: TextStyle(fontWeight: FontWeight.w500)),
            CheckboxListTile(
              title: const Text('Cable Tray'),
              value: _cableTray,
              onChanged: (v) => setState(() => _cableTray = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Cable Ladder'),
              value: _cableLadder,
              onChanged: (v) => setState(() => _cableLadder = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Cable Basket'),
              value: _cableBasket,
              onChanged: (v) => setState(() => _cableBasket = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Trunking'),
              value: _trunking,
              onChanged: (v) => setState(() => _trunking = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Busbar'),
              value: _busbar,
              onChanged: (v) => setState(() => _busbar = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Other Services'),
              value: _otherService,
              onChanged: (v) => setState(() => _otherService = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (_otherService)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _otherServiceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Other service description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            // 4. Deflection
            _sectionHeader('4. Deflection Requirements'),
            SwitchListTile(
              title: const Text('Deflection required?'),
              value: _hasDeflection,
              onChanged: (v) => setState(() => _hasDeflection = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (_hasDeflection)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _deflectionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deflection (mm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

            // 5. Sides
            _sectionHeader('5. Sides to the Opening'),
            _dropdown(
              label: 'Sides',
              value: _sides,
              items: ['1', '3', '4'],
              onChanged: (v) => setState(() => _sides = v ?? ''),
            ),

            // 6. Insulation
            _sectionHeader('6. Insulation Installed'),
            _dropdown(
              label: 'Insulation Type',
              value: _insulation,
              items: ['None', 'Glass Wool', 'Phenolic', 'PIR', 'Armaflex', 'Rockwool', 'Other'],
              onChanged: (v) => setState(() => _insulation = v ?? ''),
            ),
            if (_insulation == 'Other')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _insulationOtherCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Insulation – Other',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            TextFormField(
              controller: _insulationThicknessCtrl,
              decoration: const InputDecoration(
                labelText: 'Insulation Thickness (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            // 7. Service Sizes
            _sectionHeader('7. Service Sizes'),
            ..._serviceSizes.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: s.description,
                        decoration: const InputDecoration(
                          labelText: 'Service Description',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _serviceSizes[i].description = v,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: s.size,
                        decoration: const InputDecoration(
                          labelText: 'Size / Diameter',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _serviceSizes[i].size = v,
                      ),
                      if (_serviceSizes.length > 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _serviceSizes.removeAt(i)),
                            icon: const Icon(Icons.remove_circle_outline, size: 18),
                            label: const Text('Remove'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () => setState(() => _serviceSizes.add(ServiceSize())),
              icon: const Icon(Icons.add),
              label: const Text('Add another service'),
            ),

            // 8. Penetration Type
            _sectionHeader('8. Penetration Type'),
            _dropdown(
              label: 'Penetration Type',
              value: _penetrationType,
              items: ['Single Service Penetration', 'Multi-Service Penetration'],
              onChanged: (v) => setState(() => _penetrationType = v ?? ''),
            ),

            // Additional Information
            _sectionHeader('Additional Information Sources'),
            CheckboxListTile(
              title: const Text('Wall/Floor Installation Contractor'),
              value: _infoWallFloor,
              onChanged: (v) => setState(() => _infoWallFloor = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('M&E Contractor'),
              value: _infoME,
              onChanged: (v) => setState(() => _infoME = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Product Technical Submissions'),
              value: _infoProduct,
              onChanged: (v) => setState(() => _infoProduct = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Damper Technical Information'),
              value: _infoDamper,
              onChanged: (v) => setState(() => _infoDamper = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Ductwork Technical Information'),
              value: _infoDuctwork,
              onChanged: (v) => setState(() => _infoDuctwork = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // Photos
            _sectionHeader('Site Evidence – Photographs'),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            if (_photoPaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_photoPaths[i]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPaths.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            // Signature
            _sectionHeader('Installer Signature'),
            Container(
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _signatureController.clear(),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                ),
                if (_signaturePath.isNotEmpty && _signatureController.isEmpty)
                  Text(
                    '  Previous signature saved',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
              ],
            ),

            // Notes
            _sectionHeader('Notes'),
            _dropdown(
              label: 'Status',
              value: _notesStatus,
              items: ['Further information required', 'All required information obtained'],
              onChanged: (v) => setState(() => _notesStatus = v ?? ''),
            ),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Additional notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Buttons
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save Penetration'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _generatePdf(share: false),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Save & Generate PDF'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _saving ? null : () => _generatePdf(share: true),
              icon: const Icon(Icons.share),
              label: const Text('Save, Generate & Share PDF'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
