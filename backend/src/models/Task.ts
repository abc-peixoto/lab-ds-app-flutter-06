export interface Task {
  id: string;
  title: string;
  description: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  userId: string;
  createdAt: number; // timestamp em milliseconds
  updatedAt: number; // timestamp em milliseconds
  version: number; // controle de versão para conflitos
}

export interface TaskCreateInput {
  id?: string;
  title: string;
  description?: string;
  priority?: 'low' | 'medium' | 'high' | 'urgent';
  userId?: string;
  createdAt?: number;
}

export interface TaskUpdateInput {
  title?: string;
  description?: string;
  completed?: boolean;
  priority?: 'low' | 'medium' | 'high' | 'urgent';
  version?: number;
}

export interface TaskListResponse {
  success: boolean;
  tasks: Task[];
  lastSync: number;
  serverTime: number;
}

export interface TaskResponse {
  success: boolean;
  task?: Task;
  message?: string;
  conflict?: boolean;
  serverTask?: Task;
}



