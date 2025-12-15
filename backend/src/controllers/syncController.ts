import { Request, Response } from 'express';
import { syncService } from '../services/syncService';
import { taskService } from '../services/taskService';
import { logger } from '../config/logger';

export class SyncController {
  async syncBatch(req: Request, res: Response): Promise<void> {
    try {
      const { operations } = req.body;

      if (!Array.isArray(operations)) {
        res.status(400).json({
          success: false,
          message: 'Operações devem ser um array',
        });
        return;
      }

      const result = syncService.processBatch(operations);

      res.json(result);
    } catch (error: any) {
      logger.error('Erro na sincronização em lote:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }

  async getStats(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req.query.userId as string) || 'user1';
      const stats = taskService.getStats(userId);

      res.json({
        success: true,
        stats,
      });
    } catch (error: any) {
      logger.error('Erro ao buscar estatísticas:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
      });
    }
  }
}

export const syncController = new SyncController();



