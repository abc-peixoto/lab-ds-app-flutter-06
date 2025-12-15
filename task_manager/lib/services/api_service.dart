import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  final String userId;

  ApiService({
    String? baseUrl,
    this.userId = AppConstants.defaultUserId,
  }) : baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> getTasks({int? modifiedSince}) async {
    try {
      final uri = Uri.parse('$baseUrl/tasks').replace(
        queryParameters: {
          'userId': userId,
          if (modifiedSince != null) 'modifiedSince': modifiedSince.toString(),
        },
      );

      print('📡 GET $uri');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📥 Tasks recebidas: ${(data['tasks'] as List).length}');
        
        final tasks = (data['tasks'] as List)
            .map((json) {
              try {
                return Task.fromJson(json);
              } catch (e) {
                print('❌ Erro ao converter task: $e');
                print('❌ JSON: $json');
                rethrow;
              }
            })
            .toList();
        
        return {
          'success': true,
          'tasks': tasks,
          'lastSync': data['lastSync'],
          'serverTime': data['serverTime'],
        };
      } else {
        throw Exception('Erro ao buscar tarefas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro na requisição getTasks: $e');
      rethrow;
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Task.fromJson(data['task']);
      } else {
        throw Exception('Erro ao criar tarefa: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição createTask: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...task.toJson(),
          'version': task.version,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'task': Task.fromJson(data['task']),
        };
      } else if (response.statusCode == 409) {
        // Conflito detectado
        final data = json.decode(response.body);
        return {
          'success': false,
          'conflict': true,
          'serverTask': Task.fromJson(data['serverTask']),
        };
      } else {
        throw Exception('Erro ao atualizar tarefa: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição updateTask: $e');
      rethrow;
    }
  }

  Future<bool> deleteTask(String id, int version) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id?version=$version'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('❌ Erro na requisição deleteTask: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> syncBatch(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync/batch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'operations': operations}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro no sync em lote: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição syncBatch: $e');
      rethrow;
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final healthUrl = baseUrl.replaceAll('/api', '') + '/health';
      print('🏥 Health check: $healthUrl');
      
      final response = await http.get(
        Uri.parse(healthUrl),
      ).timeout(const Duration(seconds: 5));

      print('🏥 Health check status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('🏥 Health check erro: $e');
      return false;
    }
  }
}



