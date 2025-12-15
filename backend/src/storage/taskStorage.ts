import { Task, TaskCreateInput, TaskUpdateInput } from '../models/Task';

export class TaskStorage {
  private tasks: Map<string, Task> = new Map();
  private lastModified: Map<string, number> = new Map();

  createTask(taskData: TaskCreateInput): Task {
    const now = Date.now();
    const task: Task = {
      id: taskData.id || this.generateId(),
      title: taskData.title.trim(),
      description: taskData.description?.trim() || '',
      completed: false,
      priority: taskData.priority || 'medium',
      userId: taskData.userId || 'user1',
      createdAt: taskData.createdAt || now,
      updatedAt: now,
      version: 1,
    };

    this.tasks.set(task.id, task);
    this.lastModified.set(task.id, task.updatedAt);
    
    return task;
  }

  getTask(id: string): Task | null {
    return this.tasks.get(id) || null;
  }

  listTasks(userId: string, modifiedSince: number | null = null): Task[] {
    let tasks = Array.from(this.tasks.values())
      .filter(task => task.userId === userId);

    if (modifiedSince) {
      tasks = tasks.filter(task => task.updatedAt > modifiedSince);
    }

    return tasks.sort((a, b) => b.updatedAt - a.updatedAt);
  }

  updateTask(
    id: string,
    updates: TaskUpdateInput,
    clientVersion?: number
  ): { success: boolean; task?: Task; error?: 'NOT_FOUND' | 'CONFLICT'; serverTask?: Task } {
    const task = this.tasks.get(id);
    
    if (!task) {
      return { success: false, error: 'NOT_FOUND' };
    }

    if (clientVersion !== undefined && task.version !== clientVersion) {
      return {
        success: false,
        error: 'CONFLICT',
        serverTask: task,
      };
    }

    const updatedTask: Task = {
      ...task,
      ...updates,
      id: task.id,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: Date.now(),
      version: task.version + 1,
    };

    this.tasks.set(id, updatedTask);
    this.lastModified.set(id, updatedTask.updatedAt);

    return { success: true, task: updatedTask };
  }

  deleteTask(id: string, clientVersion?: number): {
    success: boolean;
    error?: 'NOT_FOUND' | 'CONFLICT';
    serverTask?: Task;
  } {
    const task = this.tasks.get(id);
    
    if (!task) {
      return { success: false, error: 'NOT_FOUND' };
    }

    if (clientVersion !== undefined && task.version !== clientVersion) {
      return {
        success: false,
        error: 'CONFLICT',
        serverTask: task,
      };
    }

    this.tasks.delete(id);
    this.lastModified.delete(id);
    
    return { success: true };
  }

  getLastSyncTimestamp(userId: string): number {
    const userTasks = this.listTasks(userId);
    if (userTasks.length === 0) return 0;
    
    return Math.max(...userTasks.map(task => task.updatedAt));
  }

  getStats(userId: string): {
    total: number;
    completed: number;
    pending: number;
    lastSync: number;
  } {
    const tasks = this.listTasks(userId);
    const completed = tasks.filter(task => task.completed).length;

    return {
      total: tasks.length,
      completed,
      pending: tasks.length - completed,
      lastSync: this.getLastSyncTimestamp(userId),
    };
  }

  private generateId(): string {
    return `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  clearAll(): void {
    this.tasks.clear();
    this.lastModified.clear();
  }
}

export const taskStorage = new TaskStorage();



