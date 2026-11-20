import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/penetration.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';
import 'penetration_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final StorageService _storage = StorageService();
  final PdfService _pdfService = PdfService();
  final SettingsService _settings = SettingsService();
  Project? _project;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await _storage.loadProjects();
    final project = projects.where((p) => p.id == widget.projectId).firstOrNull;
    setState(() {
      _project = project;
      _loading = false;
    });
  }

  Future<void> _addPenetration() async {
    if (_project == null) return;
    final newPen = Penetration(
      id: const Uuid().v4(),
      projectId: _project!.id,
      date: DateTime.now().toIso8601String(),
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PenetrationFormScreen(
          project: _project!,
          penetration: newPen,
          isNew: true,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _editPenetration(Penetration pen) async {
    if (_project == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PenetrationFormScreen(
          project: _project!,
          penetration: pen,
          isNew: false,
        ),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _deletePenetration(Penetration pen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Penetration?'),
        content: Text('Delete penetration at "${pen.location}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && _project != null) {
      await _storage.deletePenetration(_project!.id, pen.id);
      _load();
    }
  }

  Future<void> _generateProjectPdf({bool share = false}) async {
    if (_project == null || _project!.penetrations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one penetration first')),
      );
      return;
    }
    setState(() => _generating = true);
    try {
      final logoPath = await _settings.getLogoPath();
      final companyName = await _settings.getCompanyName();
      final file = await _pdfService.generateProjectPdf(
        _project!,
        logoPath: logoPath,
        companyName: companyName,
      );
      setState(() => _generating = false);
      if (share) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Fire Stopping Project Report - ${_project!.name}',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Project PDF saved'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _generating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project'),
        actions: [
          if (_project != null && _project!.penetrations.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'pdf') _generateProjectPdf(share: false);
                if (value == 'share') _generateProjectPdf(share: true);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Generate Project PDF'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Generate & Share Project PDF'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _project == null
              ? const Center(child: Text('Project not found'))
              : _project!.penetrations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.construction, size: 72, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No penetrations yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          const Text('Tap + New Penetration to add one'),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _project!.penetrations.length,
                          itemBuilder: (context, index) {
                            final pen = _project!.penetrations[index];
                            final date = pen.date.isNotEmpty
                                ? DateFormat('dd MMM yyyy').format(DateTime.parse(pen.date))
                                : '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  pen.location.isEmpty ? 'No location set' : pen.location,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '$date  •  ${pen.fireResistance.isNotEmpty ? "${pen.fireResistance} min" : "No FR"}  •  ${pen.penetrationType}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') _editPenetration(pen);
                                    if (value == 'delete') _deletePenetration(pen);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                                onTap: () => _editPenetration(pen),
                              ),
                            );
                          },
                        ),
                        if (_generating)
                          Container(
                            color: Colors.black26,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPenetration,
        icon: const Icon(Icons.add),
        label: const Text('New Penetration'),
      ),
    );
  }
}
