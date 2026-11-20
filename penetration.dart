import 'dart:convert';

class ServiceSize {
  String description;
  String size;

  ServiceSize({this.description = '', this.size = ''});

  Map<String, dynamic> toJson() => {
        'description': description,
        'size': size,
      };

  factory ServiceSize.fromJson(Map<String, dynamic> json) => ServiceSize(
        description: json['description'] ?? '',
        size: json['size'] ?? '',
      );
}

class Penetration {
  String id;
  String projectId;
  String location;
  String date; // ISO string
  String installer;

  // 1. Supporting Construction
  String wallType;
  String wallTypeOther;
  String floorType;
  String floorTypeOther;

  // 2. Fire Resistance
  String fireResistance; // "30", "60", etc.

  // 3. Service Types
  bool metalPipe;
  bool plasticPipe;
  bool fireDamper;
  bool ductwork;
  bool flue;
  bool cableTray;
  bool cableLadder;
  bool cableBasket;
  bool trunking;
  bool busbar;
  bool otherService;
  String otherServiceText;

  // 4. Deflection
  bool hasDeflection;
  String deflectionMm;

  // 5. Sides
  String sides; // "1", "3", "4"

  // 6. Insulation
  String insulation;
  String insulationOther;
  String insulationThickness;

  // 7. Service Sizes
  List<ServiceSize> serviceSizes;

  // 8. Penetration Type
  String penetrationType; // "Single" or "Multi"

  // Additional Information
  bool infoWallFloorContractor;
  bool infoMEContractor;
  bool infoProductSubmissions;
  bool infoDamperTech;
  bool infoDuctworkTech;

  // Site Evidence
  List<String> photoPaths; // local file paths

  // Signature
  String signaturePath; // local file path of drawn signature image

  // Notes
  String notesStatus; // "Further information required" or "All required information obtained"
  String notes;

  Penetration({
    required this.id,
    required this.projectId,
    this.location = '',
    this.date = '',
    this.installer = '',
    this.wallType = '',
    this.wallTypeOther = '',
    this.floorType = '',
    this.floorTypeOther = '',
    this.fireResistance = '',
    this.metalPipe = false,
    this.plasticPipe = false,
    this.fireDamper = false,
    this.ductwork = false,
    this.flue = false,
    this.cableTray = false,
    this.cableLadder = false,
    this.cableBasket = false,
    this.trunking = false,
    this.busbar = false,
    this.otherService = false,
    this.otherServiceText = '',
    this.hasDeflection = false,
    this.deflectionMm = '',
    this.sides = '',
    this.insulation = '',
    this.insulationOther = '',
    this.insulationThickness = '',
    List<ServiceSize>? serviceSizes,
    this.penetrationType = '',
    this.infoWallFloorContractor = false,
    this.infoMEContractor = false,
    this.infoProductSubmissions = false,
    this.infoDamperTech = false,
    this.infoDuctworkTech = false,
    List<String>? photoPaths,
    this.signaturePath = '',
    this.notesStatus = '',
    this.notes = '',
  })  : serviceSizes = serviceSizes ?? [ServiceSize()],
        photoPaths = photoPaths ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'location': location,
        'date': date,
        'installer': installer,
        'wallType': wallType,
        'wallTypeOther': wallTypeOther,
        'floorType': floorType,
        'floorTypeOther': floorTypeOther,
        'fireResistance': fireResistance,
        'metalPipe': metalPipe,
        'plasticPipe': plasticPipe,
        'fireDamper': fireDamper,
        'ductwork': ductwork,
        'flue': flue,
        'cableTray': cableTray,
        'cableLadder': cableLadder,
        'cableBasket': cableBasket,
        'trunking': trunking,
        'busbar': busbar,
        'otherService': otherService,
        'otherServiceText': otherServiceText,
        'hasDeflection': hasDeflection,
        'deflectionMm': deflectionMm,
        'sides': sides,
        'insulation': insulation,
        'insulationOther': insulationOther,
        'insulationThickness': insulationThickness,
        'serviceSizes': serviceSizes.map((e) => e.toJson()).toList(),
        'penetrationType': penetrationType,
        'infoWallFloorContractor': infoWallFloorContractor,
        'infoMEContractor': infoMEContractor,
        'infoProductSubmissions': infoProductSubmissions,
        'infoDamperTech': infoDamperTech,
        'infoDuctworkTech': infoDuctworkTech,
        'photoPaths': photoPaths,
        'signaturePath': signaturePath,
        'notesStatus': notesStatus,
        'notes': notes,
      };

  factory Penetration.fromJson(Map<String, dynamic> json) => Penetration(
        id: json['id'] ?? '',
        projectId: json['projectId'] ?? '',
        location: json['location'] ?? '',
        date: json['date'] ?? '',
        installer: json['installer'] ?? '',
        wallType: json['wallType'] ?? '',
        wallTypeOther: json['wallTypeOther'] ?? '',
        floorType: json['floorType'] ?? '',
        floorTypeOther: json['floorTypeOther'] ?? '',
        fireResistance: json['fireResistance'] ?? '',
        metalPipe: json['metalPipe'] ?? false,
        plasticPipe: json['plasticPipe'] ?? false,
        fireDamper: json['fireDamper'] ?? false,
        ductwork: json['ductwork'] ?? false,
        flue: json['flue'] ?? false,
        cableTray: json['cableTray'] ?? false,
        cableLadder: json['cableLadder'] ?? false,
        cableBasket: json['cableBasket'] ?? false,
        trunking: json['trunking'] ?? false,
        busbar: json['busbar'] ?? false,
        otherService: json['otherService'] ?? false,
        otherServiceText: json['otherServiceText'] ?? '',
        hasDeflection: json['hasDeflection'] ?? false,
        deflectionMm: json['deflectionMm'] ?? '',
        sides: json['sides'] ?? '',
        insulation: json['insulation'] ?? '',
        insulationOther: json['insulationOther'] ?? '',
        insulationThickness: json['insulationThickness'] ?? '',
        serviceSizes: (json['serviceSizes'] as List<dynamic>?)
                ?.map((e) => ServiceSize.fromJson(e))
                .toList() ??
            [ServiceSize()],
        penetrationType: json['penetrationType'] ?? '',
        infoWallFloorContractor: json['infoWallFloorContractor'] ?? false,
        infoMEContractor: json['infoMEContractor'] ?? false,
        infoProductSubmissions: json['infoProductSubmissions'] ?? false,
        infoDamperTech: json['infoDamperTech'] ?? false,
        infoDuctworkTech: json['infoDuctworkTech'] ?? false,
        photoPaths: (json['photoPaths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        signaturePath: json['signaturePath'] ?? '',
        notesStatus: json['notesStatus'] ?? '',
        notes: json['notes'] ?? '',
      );
}
