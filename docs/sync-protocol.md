# Protocolo de Sincronização

## Visão Geral

O protocolo de sincronização implementa o paradigma **Offline-First** com estratégia **Last-Write-Wins (LWW)** para resolução de conflitos.

## Estrutura de Dados

### Task (Tarefa)

```typescript
interface Task {
  id: string;                    // UUID único
  title: string;
  description: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  userId: string;
  createdAt: number;            // Timestamp (ms)
  updatedAt: number;            // Timestamp (ms)
  version: number;              // Controle de versão
}
```

### SyncOperation (Operação de Sincronização)

```dart
class SyncOperation {
  String id;
  OperationType type;           // CREATE, UPDATE, DELETE
  String taskId;
  Map<String, dynamic> data;
  DateTime timestamp;
  int retries;
  SyncOperationStatus status;   // pending, processing, completed, failed
  String? error;
}
```

## Fluxo de Sincronização

### 1. Push (Cliente → Servidor)

```
Cliente:
  1. Busca operações pendentes da fila (sync_queue)
  2. Para cada operação:
     - CREATE: POST /api/tasks
     - UPDATE: PUT /api/tasks/:id
     - DELETE: DELETE /api/tasks/:id
  3. Se sucesso: remove da fila
  4. Se erro: incrementa retries (máx 3)
```

### 2. Pull (Servidor → Cliente)

```
Cliente:
  1. Busca lastSyncTimestamp dos metadados
  2. GET /api/tasks?userId=user1&modifiedSince=[timestamp]
  3. Para cada tarefa recebida:
     - Se não existe localmente: criar
     - Se existe e está sincronizada: atualizar
     - Se existe e está pendente: resolver conflito
```

### 3. Resolução de Conflitos (LWW)

```
Algoritmo Last-Write-Wins:
  1. Comparar timestamps:
     - localTime = localTask.localUpdatedAt ?? localTask.updatedAt
     - serverTime = serverTask.updatedAt
  2. Se localTime > serverTime:
     - Versão local vence
     - Enviar versão local para servidor
  3. Se serverTime >= localTime:
     - Versão servidor vence
     - Atualizar banco local
```

## Endpoints da API

### GET /api/tasks

Lista tarefas com suporte a sync incremental.

**Query Parameters:**
- `userId` (string): ID do usuário
- `modifiedSince` (number, opcional): Timestamp da última sync

**Response:**
```json
{
  "success": true,
  "tasks": [...],
  "lastSync": 1234567890,
  "serverTime": 1234567890
}
```

### POST /api/tasks

Cria nova tarefa.

**Body:**
```json
{
  "id": "task_123",
  "title": "Tarefa",
  "description": "Descrição",
  "priority": "medium",
  "userId": "user1",
  "createdAt": 1234567890
}
```

### PUT /api/tasks/:id

Atualiza tarefa com controle de versão.

**Body:**
```json
{
  "title": "Título atualizado",
  "version": 1
}
```

**Response (Conflito):**
```json
{
  "success": false,
  "conflict": true,
  "serverTask": {...}
}
```

### DELETE /api/tasks/:id

Deleta tarefa.

**Query Parameters:**
- `version` (number, opcional): Versão da tarefa

### POST /api/sync/batch

Sincronização em lote.

**Body:**
```json
{
  "operations": [
    {
      "type": "CREATE",
      "taskId": "task_123",
      "data": {...}
    },
    {
      "type": "UPDATE",
      "taskId": "task_456",
      "data": {...},
      "version": 1
    }
  ]
}
```

## Estados de Sincronização

### SyncStatus (Tarefa)

- `synced`: Sincronizada com servidor
- `pending`: Pendente de sincronização
- `conflict`: Conflito detectado
- `error`: Erro na sincronização

### SyncOperationStatus (Operação)

- `pending`: Aguardando processamento
- `processing`: Em processamento
- `completed`: Concluída com sucesso
- `failed`: Falhou após 3 tentativas

## Tratamento de Erros

### Retry Logic

- Máximo de 3 tentativas por operação
- Após 3 falhas, marca como `failed`
- Operações failed podem ser retentadas manualmente

### Conflitos

- Detectados via controle de versão
- Resolvidos automaticamente usando LWW
- Logs detalhados para debugging

## Otimizações

1. **Sync Incremental**: Busca apenas mudanças desde última sync
2. **Fila FIFO**: Operações processadas em ordem
3. **Batch Operations**: Suporte a operações em lote
4. **Auto-sync**: Sincronização automática quando volta online