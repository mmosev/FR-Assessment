import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/penetration.dart';

class StorageService {
  static const String _key = 'fire_stopping_projects';

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => Project.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(projects.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addProject(Project project) async {
    final projects = await loadProjects();
    projects.add(project);
    await saveProjects(projects);
  }

  Future<void> updateProject(Project project) async {
    final projects = await loadProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await saveProjects(projects);
    }
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == projectId);
    await saveProjects(projects);
  }

  Future<void> addPenetration(String projectId, Penetration penetration) async {
    final projects = await loadProjects();
    final index = projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      projects[index].penetrations.add(penetration);
      await saveProjects(projects);
    }
  }

  Future<void> updatePenetration(String projectId, Penetration penetration) async {
    final projects = await loadProjects();
    final pIndex = projects.indexWhere((p) => p.id == projectId);
    if (pIndex != -1) {
      final penIndex = projects[pIndex]
          .penetrations
          .indexWhere((pen) => pen.id == penetration.id);
      if (penIndex != -1) {
        projects[pIndex].penetrations[penIndex] = penetration;
        await saveProjects(projects);
      }
    }
  }

  Future<void> deletePenetration(String projectId, String penetrationId) async {
    final projects = await loadProjects();
    final pIndex = projects.indexWhere((p) => p.id == projectId);
    if (pIndex != -1) {
      projects[pIndex]
          .penetrations
          .removeWhere((pen) => pen.id == penetrationId);
      await saveProjects(projects);
    }
  }
}
