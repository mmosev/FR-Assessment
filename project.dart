import 'dart:convert';
import 'penetration.dart';

class Project {
  String id;
  String name;
  String createdAt; // ISO string
  List<Penetration> penetrations;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    List<Penetration>? penetrations,
  }) : penetrations = penetrations ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
        'penetrations': penetrations.map((e) => e.toJson()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        createdAt: json['createdAt'] ?? '',
        penetrations: (json['penetrations'] as List<dynamic>?)
                ?.map((e) => Penetration.fromJson(e))
                .toList() ??
            [],
      );
}
