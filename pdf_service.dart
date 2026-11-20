import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/penetration.dart';
import '../models/project.dart';

class PdfService {
  Future<pw.ImageProvider?> _loadImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return pw.MemoryImage(bytes);
  }

  Future<File> generatePenetrationPdf(
    Project project,
    Penetration pen, {
    String? logoPath,
    String? companyName,
  }) async {
    final pdf = pw.Document();
    final logo = await _loadImage(logoPath);
    final signature = await _loadImage(pen.signaturePath.isNotEmpty ? pen.signaturePath : null);

    final dateStr = pen.date.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(pen.date))
        : '';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(logo, companyName),
        build: (context) => _buildPenetrationContent(project, pen, dateStr, signature),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = '${project.name}_${pen.location}'.replaceAll(RegExp(r'[^\w]'), '_');
    final file = File('${dir.path}/FireStopping_${safeName}_$dateStr.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> generateProjectPdf(
    Project project, {
    String? logoPath,
    String? companyName,
  }) async {
    final pdf = pw.Document();
    final logo = await _loadImage(logoPath);

    // Cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Center(child: pw.Image(logo, height: 70)),
                pw.SizedBox(height: 16),
              ],
              if (companyName != null && companyName.isNotEmpty) ...[
                pw.Center(
                  child: pw.Text(
                    companyName,
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 24),
              ],
              pw.Center(
                child: pw.Text(
                  'Fire Stopping Assessment',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Project Report',
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 32),
              pw.Divider(),
              pw.SizedBox(height: 16),
              _row('Project', project.name),
              _row(
                'Created',
                project.createdAt.isNotEmpty
                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(project.createdAt))
                    : '',
              ),
              _row('Total Penetrations', '${project.penetrations.length}'),
              pw.SizedBox(height: 24),
              pw.Text(
                'Contents',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              ...project.penetrations.asMap().entries.map((e) {
                final i = e.key + 1;
                final pen = e.value;
                final loc = pen.location.isNotEmpty ? pen.location : 'Unnamed';
                final fr = pen.fireResistance.isNotEmpty ? '${pen.fireResistance} min' : '';
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('$i. $loc  $fr', style: const pw.TextStyle(fontSize: 11)),
                );
              }),
            ],
          );
        },
      ),
    );

    // One section per penetration
    for (final pen in project.penetrations) {
      final signature = await _loadImage(pen.signaturePath.isNotEmpty ? pen.signaturePath : null);
      final dateStr = pen.date.isNotEmpty
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(pen.date))
          : '';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader(logo, companyName),
          build: (context) => _buildPenetrationContent(project, pen, dateStr, signature),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final safeName = project.name.replaceAll(RegExp(r'[^\w]'), '_');
    final file = File('${dir.path}/FireStopping_Project_$safeName.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(pw.ImageProvider? logo, String? companyName) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null)
              pw.Image(logo, height: 40)
            else
              pw.SizedBox(),
            if (companyName != null && companyName.isNotEmpty)
              pw.Text(
                companyName,
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  List<pw.Widget> _buildPenetrationContent(
    Project project,
    Penetration pen,
    String dateStr,
    pw.ImageProvider? signature,
  ) {
    return [
      pw.Text(
        'Fire Stopping Assessment Report',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 12),

      _sectionTitle('Project Information'),
      _row('Project', project.name),
      _row('Location / Area / One Trace pin', pen.location),
      _row('Date', dateStr),
      _row('Installer', pen.installer),
      pw.SizedBox(height: 14),

      _sectionTitle('1. Supporting Construction'),
      _row('Wall Type', _displayOther(pen.wallType, pen.wallTypeOther)),
      _row('Floor Type', _displayOther(pen.floorType, pen.floorTypeOther)),
      pw.SizedBox(height: 10),

      _sectionTitle('2. Required Fire Resistance'),
      _row('Minutes', pen.fireResistance.isNotEmpty ? '${pen.fireResistance} minutes' : ''),
      pw.SizedBox(height: 10),

      _sectionTitle('3. Service Types Passing Through the Opening'),
      _servicesList(pen),
      pw.SizedBox(height: 10),

      _sectionTitle('4. Deflection Requirements'),
      _row('Deflection', pen.hasDeflection ? 'YES - ${pen.deflectionMm} mm' : 'NO'),
      pw.SizedBox(height: 10),

      _sectionTitle('5. Sides to the Opening'),
      _row('Sides', pen.sides == '1' ? '1 (Circular)' : pen.sides),
      pw.SizedBox(height: 10),

      _sectionTitle('6. Insulation Installed'),
      _row('Type', _displayOther(pen.insulation, pen.insulationOther)),
      _row('Thickness', pen.insulationThickness.isNotEmpty ? '${pen.insulationThickness} mm' : ''),
      pw.SizedBox(height: 10),

      _sectionTitle('7. Service Sizes'),
      if (pen.serviceSizes.any((s) => s.description.isNotEmpty || s.size.isNotEmpty))
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _cell('Service Description', bold: true),
                _cell('Size / Diameter', bold: true),
              ],
            ),
            ...pen.serviceSizes
                .where((s) => s.description.isNotEmpty || s.size.isNotEmpty)
                .map((s) => pw.TableRow(children: [_cell(s.description), _cell(s.size)])),
          ],
        )
      else
        pw.Text('None recorded', style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 10),

      _sectionTitle('8. Penetration Type'),
      _row('Type', pen.penetrationType),
      pw.SizedBox(height: 10),

      _sectionTitle('Additional Information Sources'),
      _bulletList([
        if (pen.infoWallFloorContractor) 'Wall/Floor Installation Contractor',
        if (pen.infoMEContractor) 'M&E Contractor',
        if (pen.infoProductSubmissions) 'Product Technical Submissions',
        if (pen.infoDamperTech) 'Damper Technical Information',
        if (pen.infoDuctworkTech) 'Ductwork Technical Information',
      ]),
      pw.SizedBox(height: 10),

      _sectionTitle('Site Evidence – Photographs'),
      pw.Text(
        pen.photoPaths.isNotEmpty
            ? '${pen.photoPaths.length} photograph(s) attached'
            : 'No photographs provided',
        style: const pw.TextStyle(fontSize: 11),
      ),
      pw.SizedBox(height: 10),

      _sectionTitle('Notes'),
      _row('Status', pen.notesStatus),
      if (pen.notes.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(pen.notes, style: const pw.TextStyle(fontSize: 11)),
      ],
      pw.SizedBox(height: 24),

      // Signature
      pw.Text('Installer Signature:', style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 6),
      if (signature != null)
        pw.Container(
          height: 60,
          child: pw.Image(signature, fit: pw.BoxFit.contain),
        )
      else
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.black,
          margin: const pw.EdgeInsets.only(top: 30),
        ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Date: $dateStr',
        style: const pw.TextStyle(fontSize: 11),
      ),
    ];
  }

  String _displayOther(String value, String other) {
    if (value == 'Other' && other.isNotEmpty) return 'Other: $other';
    return value;
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(value.isEmpty ? '—' : value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _servicesList(Penetration pen) {
    final items = <String>[];
    if (pen.metalPipe) items.add('Metal Pipe');
    if (pen.plasticPipe) items.add('Plastic Pipe');
    if (pen.fireDamper) items.add('Fire Damper');
    if (pen.ductwork) items.add('Ductwork');
    if (pen.flue) items.add('Flue');
    if (pen.cableTray) items.add('Cable Tray');
    if (pen.cableLadder) items.add('Cable Ladder');
    if (pen.cableBasket) items.add('Cable Basket');
    if (pen.trunking) items.add('Trunking');
    if (pen.busbar) items.add('Busbar');
    if (pen.otherService) {
      items.add(pen.otherServiceText.isNotEmpty ? 'Other: ${pen.otherServiceText}' : 'Other');
    }
    if (items.isEmpty) return pw.Text('None selected', style: const pw.TextStyle(fontSize: 11));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((e) => pw.Text('• $e', style: const pw.TextStyle(fontSize: 11))).toList(),
    );
  }

  pw.Widget _bulletList(List<String> items) {
    if (items.isEmpty) return pw.Text('None selected', style: const pw.TextStyle(fontSize: 11));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((e) => pw.Text('• $e', style: const pw.TextStyle(fontSize: 11))).toList(),
    );
  }
}
