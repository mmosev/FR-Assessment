import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _companyCtrl = TextEditingController();

  bool _isDark = false;
  String? _logoPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isDark = await _settings.isDarkMode();
    final logo = await _settings.getLogoPath();
    final name = await _settings.getCompanyName();
    setState(() {
      _isDark = isDark;
      _logoPath = logo;
      _companyCtrl.text = name;
      _loading = false;
    });
  }

  Future<void> _pickLogo() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (img == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final logoDir = Directory('${appDir.path}/logo');
    if (!await logoDir.exists()) await logoDir.create(recursive: true);

    final fileName = 'company_logo${p.extension(img.path)}';
    final saved = await File(img.path).copy('${logoDir.path}/$fileName');
    await _settings.setLogoPath(saved.path);
    setState(() => _logoPath = saved.path);
  }

  Future<void> _removeLogo() async {
    await _settings.setLogoPath(null);
    setState(() => _logoPath = null);
  }

  Future<void> _saveCompanyName() async {
    await _settings.setCompanyName(_companyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name saved')),
      );
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Dark mode
                SwitchListTile(
                  title: const Text('Dark mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _isDark,
                  onChanged: (v) {
                    setState(() => _isDark = v);
                    widget.onThemeChanged(v);
                  },
                ),
                const Divider(),

                // Company name
                const SizedBox(height: 8),
                const Text('Company name (shown on PDF)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _companyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _saveCompanyName,
                    child: const Text('Save name'),
                  ),
                ),
                const Divider(height: 32),

                // Logo
                const Text('Company logo (shown on PDF)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_logoPath != null && File(_logoPath!).existsSync())
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_logoPath!),
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _removeLogo,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove logo'),
                      ),
                    ],
                  )
                else
                  const Text('No logo set', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image),
                  label: Text(_logoPath == null ? 'Choose logo' : 'Change logo'),
                ),
              ],
            ),
    );
  }
}
