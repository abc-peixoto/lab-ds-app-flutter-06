import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'database_service.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription? _connectivitySubscription;

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  void start() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.connectivityStream.listen((status) {
      if (status.contains(ConnectivityResult.mobile) || status.contains(ConnectivityResult.wifi)) {
        debugPrint('[SyncService] Connectivity detected, starting sync process.');
        processSyncQueue();
      }
    });
    // Initial check
    processSyncQueue();
  }

  Future<void> processSyncQueue() async {
    if (!await _connectivityService.isConnected) {
      debugPrint('[SyncService] No internet connection, skipping sync.');
      return;
    }

    final pendingActions = await _dbService.getPendingSync();
    if (pendingActions.isEmpty) {
      debugPrint('[SyncService] Sync queue is empty.');
      return;
    }

    debugPrint('[SyncService] Found ${pendingActions.length} pending actions.');

    for (final action in pendingActions) {
      final actionId = action['id'] as int;
      final taskId = action['taskId'] as String;
      final operation = action['operation'] as String;
      final payload = action['payload'] != null ? jsonDecode(action['payload'] as String) : null;

      try {
        switch (operation) {
          case 'CREATE':
            final task = Task.fromMap(payload);
            await _apiService.createTask(task);
            break;
          case 'UPDATE':
            final localTask = Task.fromMap(payload);
            try {
              // LWW: Get server version first
              final serverTask = await _apiService.getTask(taskId); // Assumes getTask exists
              if (localTask.updatedAt.isAfter(serverTask.updatedAt)) {
                await _apiService.updateTask(localTask);
              } else {
                // Server version is newer, update local
                await _dbService.update(serverTask.copyWith(isSynced: true));
              }
            } catch (e) {
              // If task doesn't exist on server (e.g., was deleted), just create it.
              await _apiService.createTask(localTask);
            }
            break;
          case 'DELETE':
            await _apiService.deleteTask(taskId);
            break;
        }

        // Mark as synced and remove from queue
        final originalTask = await _dbService.read(taskId);
        if (originalTask != null) {
          await _dbService.update(originalTask.copyWith(isSynced: true));
        }
        await _dbService.removeFromSyncQueue(actionId);
        debugPrint('[SyncService] Action ID $actionId ($operation $taskId) processed successfully.');

      } catch (e) {
        debugPrint('[SyncService] Error processing action ID $actionId: $e');
        // Optionally, implement a retry mechanism or error logging
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

// Extension on ApiService to add getTask method if it doesn't exist
// This is a placeholder, you might need to implement this for real in ApiService
extension on ApiService {
  Future<Task> getTask(String id) async {
    // This is a mock. You should implement this in your actual ApiService.
    // It might involve filtering from getTasks or having a dedicated endpoint.
    final tasks = await getTasks();
    return tasks.firstWhere((task) => task.id == id);
  }
}
