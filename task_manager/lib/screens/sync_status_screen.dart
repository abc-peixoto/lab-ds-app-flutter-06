import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final SyncService _syncService = SyncService();
  final ConnectivityService _connectivity = ConnectivityService.instance;
  bool _isLoading = true;
  SyncStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _syncService.getStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _handleSync() async {
    if (!_connectivity.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📴 Sem conexão com internet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Iniciando sincronização...'),
        duration: Duration(seconds: 1),
      ),
    );

    final result = await _syncService.sync();
    await _loadStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? '✅ Sincronização concluída'
                : '❌ ${result.message}',
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status de Sincronização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Erro ao carregar estatísticas'))
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildStatusCard(
                        title: 'Conectividade',
                        icon: Icons.wifi,
                        value: _stats!.isOnline ? 'Online' : 'Offline',
                        color: _stats!.isOnline ? Colors.green : Colors.red,
                      ),
                      _buildStatusCard(
                        title: 'Status de Sincronização',
                        icon: Icons.sync,
                        value: _stats!.isSyncing
                            ? 'Sincronizando...'
                            : 'Ocioso',
                        color: _stats!.isSyncing ? Colors.blue : Colors.grey,
                      ),
                      _buildStatusCard(
                        title: 'Total de Tarefas',
                        icon: Icons.task,
                        value: '${_stats!.totalTasks}',
                        color: Colors.blue,
                      ),
                      _buildStatusCard(
                        title: 'Tarefas Não Sincronizadas',
                        icon: Icons.cloud_off,
                        value: '${_stats!.unsyncedTasks}',
                        color: _stats!.unsyncedTasks > 0
                            ? Colors.orange
                            : Colors.green,
                      ),
                      _buildStatusCard(
                        title: 'Operações na Fila',
                        icon: Icons.queue,
                        value: '${_stats!.queuedOperations}',
                        color: _stats!.queuedOperations > 0
                            ? Colors.orange
                            : Colors.green,
                      ),
                      _buildStatusCard(
                        title: 'Última Sincronização',
                        icon: Icons.update,
                        value: _stats!.lastSync != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(_stats!.lastSync!)
                            : 'Nunca',
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _stats!.isOnline && !_stats!.isSyncing
                            ? _handleSync
                            : null,
                        icon: const Icon(Icons.sync),
                        label: const Text('Sincronizar Agora'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



