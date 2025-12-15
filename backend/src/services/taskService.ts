import { taskStorage } from '../storage/taskStorage';
import { Task, TaskCreateInput, TaskUpdateInput } from '../models/Task';

export class TaskService {

  createTask(taskData: TaskCreateInput): Task {
    if (!taskData.title?.trim()) {
      throw new Error('Título é obrigatório');
    }

    return taskStorage.createTask(taskData);
  }

  getTask(id: string): Task | null {
    return taskStorage.getTask(id);
  }

  listTasks(userId: string, modifiedSince?: number): Task[] {
    return taskStorage.listTasks(userId, modifiedSince || null);
  }

  updateTask(
    id: string,
    updates: TaskUpdateInput,
    clientVersion?: number
  ): { success: boolean; task?: Task; error?: 'NOT_FOUND' | 'CONFLICT'; serverTask?: Task } {
    return taskStorage.updateTask(id, updates, clientVersion);
  }

  deleteTask(id: string, clientVersion?: number): {
    success: boolean;
    error?: 'NOT_FOUND' | 'CONFLICT';
    serverTask?: Task;
  } {
    return taskStorage.deleteTask(id, clientVersion);
  }

  getStats(userId: string) {
    return taskStorage.getStats(userId);
  }
}

export const taskService = new TaskService();



