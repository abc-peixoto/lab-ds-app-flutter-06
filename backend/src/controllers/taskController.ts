import { Request, Response } from 'express';
import { taskService } from '../services/taskService';
import { logger } from '../config/logger';

export class TaskController {
  async listTasks(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req.query.userId as string) || 'user1';
      const modifiedSince = req.query.modifiedSince
        ? parseInt(req.query.modifiedSince as string, 10)
        : undefined;

      const tasks = taskService.listTasks(userId, modifiedSince);
      const lastSync = taskService.getStats(userId).lastSync;

      res.json({
        success: true,
        tasks,
        lastSync,
        serverTime: Date.now(),
      });
    } catch (error: any) {
      logger.error('Erro ao listar tarefas:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }

  async getTask(req: Request, res: Response): Promise<void> {
    try {
      const task = taskService.getTask(req.params.id);

      if (!task) {
        res.status(404).json({
          success: false,
          message: 'Tarefa não encontrada',
        });
        return;
      }

      res.json({
        success: true,
        task,
      });
    } catch (error: any) {
      logger.error('Erro ao buscar tarefa:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }

  async createTask(req: Request, res: Response): Promise<void> {
    try {
      const { title, description, priority, userId, id, createdAt } = req.body;

      if (!title?.trim()) {
        res.status(400).json({
          success: false,
          message: 'Título é obrigatório',
        });
        return;
      }

      const task = taskService.createTask({
        id,
        title: title.trim(),
        description: description?.trim() || '',
        priority: priority || 'medium',
        userId: userId || 'user1',
        createdAt,
      });

      res.status(201).json({
        success: true,
        message: 'Tarefa criada com sucesso',
        task,
      });
    } catch (error: any) {
      logger.error('Erro ao criar tarefa:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Erro interno do servidor',
      });
    }
  }


  async updateTask(req: Request, res: Response): Promise<void> {
    try {
      const { title, description, completed, priority, version } = req.body;

      const result = taskService.updateTask(req.params.id, {
        title,
        description,
        completed,
        priority,
      }, version);

      if (!result.success) {
        if (result.error === 'NOT_FOUND') {
          res.status(404).json({
            success: false,
            message: 'Tarefa não encontrada',
          });
          return;
        }

        if (result.error === 'CONFLICT') {
          res.status(409).json({
            success: false,
            message: 'Conflito detectado',
            conflict: true,
            serverTask: result.serverTask,
          });
          return;
        }
      }

      res.json({
        success: true,
        message: 'Tarefa atualizada com sucesso',
        task: result.task,
      });
    } catch (error: any) {
      logger.error('Erro ao atualizar tarefa:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }

  async deleteTask(req: Request, res: Response): Promise<void> {
    try {
      const version = req.query.version
        ? parseInt(req.query.version as string, 10)
        : undefined;

      const result = taskService.deleteTask(req.params.id, version);

      if (!result.success) {
        if (result.error === 'NOT_FOUND') {
          res.status(404).json({
            success: false,
            message: 'Tarefa não encontrada',
          });
          return;
        }

        if (result.error === 'CONFLICT') {
          res.status(409).json({
            success: false,
            message: 'Conflito detectado',
            conflict: true,
            serverTask: result.serverTask,
          });
          return;
        }
      }

      res.json({
        success: true,
        message: 'Tarefa deletada com sucesso',
      });
    } catch (error: any) {
      logger.error('Erro ao deletar tarefa:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }
}

export const taskController = new TaskController();



