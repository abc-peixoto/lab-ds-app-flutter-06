import { taskStorage } from '../storage/taskStorage';
import { Task, TaskCreateInput, TaskUpdateInput } from '../models/Task';

export interface SyncOperation {
  type: 'CREATE' | 'UPDATE' | 'DELETE';
  id?: string;
  taskId: string;
  data?: TaskCreateInput | TaskUpdateInput;
  version?: number;
}

export interface SyncBatchResult {
  success: boolean;
  results: Array<{
    operation: SyncOperation;
    success: boolean;
    task?: Task;
    error?: string;
    conflict?: boolean;
    serverTask?: Task;
  }>;
  serverTime: number;
}

export class SyncService {
  processBatch(operations: SyncOperation[]): SyncBatchResult {
    const results = operations.map((op) => {
      try {
        switch (op.type) {
          case 'CREATE':
            if (!op.data) {
              return {
                operation: op,
                success: false,
                error: 'Dados não fornecidos para CREATE',
              };
            }
            const createdTask = taskStorage.createTask(op.data as TaskCreateInput);
            return {
              operation: op,
              success: true,
              task: createdTask,
            };

          case 'UPDATE':
            if (!op.data) {
              return {
                operation: op,
                success: false,
                error: 'Dados não fornecidos para UPDATE',
              }
            }
            const updateResult = taskStorage.updateTask(
              op.taskId,
              op.data as TaskUpdateInput,
              op.version
            );
            
            if (!updateResult.success) {
              return {
                operation: op,
                success: false,
                error: updateResult.error,
                conflict: updateResult.error === 'CONFLICT',
                serverTask: updateResult.serverTask,
              };
            }
            
            return {
              operation: op,
              success: true,
              task: updateResult.task,
            };

          case 'DELETE':
            const deleteResult = taskStorage.deleteTask(op.taskId, op.version);
            
            if (!deleteResult.success) {
              return {
                operation: op,
                success: false,
                error: deleteResult.error,
                conflict: deleteResult.error === 'CONFLICT',
                serverTask: deleteResult.serverTask,
              };
            }
            
            return {
              operation: op,
              success: true,
            };

          default:
            return {
              operation: op,
              success: false,
              error: `Tipo de operação desconhecido: ${(op as any).type}`,
            };
        }
      } catch (error: any) {
        return {
          operation: op,
          success: false,
          error: error.message || 'Erro desconhecido',
        };
      }
    });

    return {
      success: true,
      results,
      serverTime: Date.now(),
    };
  }
}

export const syncService = new SyncService();



