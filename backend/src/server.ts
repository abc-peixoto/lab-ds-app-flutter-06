import express, { Express } from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { config } from './config/env';
import { logger } from './config/logger';
import { requestLogger } from './middleware/requestLogger';
import { errorHandler } from './middleware/errorHandler';

import healthRoutes from './routes/healthRoutes';
import taskRoutes from './routes/taskRoutes';
import syncRoutes from './routes/syncRoutes';

const app: Express = express();

app.use(cors());
app.use(bodyParser.json());
app.use(requestLogger);

app.use('/api/health', healthRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/sync', syncRoutes);

app.use(errorHandler);

const PORT = config.port;

app.listen(PORT, () => {
  logger.info('🚀 =====================================');
  logger.info(`🚀 Servidor Offline-First iniciado`);
  logger.info(`🚀 Porta: ${PORT}`);
  logger.info(`🚀 URL: http://localhost:${PORT}`);
  logger.info('🚀 Recursos:');
  logger.info('🚀   - Sync incremental');
  logger.info('🚀   - Controle de versão');
  logger.info('🚀   - Detecção de conflitos');
  logger.info('🚀   - Operações em lote');
  logger.info('🚀 =====================================');
});

export default app;



