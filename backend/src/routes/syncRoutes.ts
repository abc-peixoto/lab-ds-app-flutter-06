import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

router.post('/batch', (req, res) => syncController.syncBatch(req, res));

router.get('/stats', (req, res) => syncController.getStats(req, res));

export default router;



