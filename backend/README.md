# Backend - Offline-First Task Manager API

API REST Node/Express com TypeScript para suporte a sincronização offline-first.

## 🚀 Instalação

```bash
npm install
```

## 🏃 Executar

### Desenvolvimento
```bash
npm run dev
```

### Produção
```bash
npm run build
npm start
```

## 📡 Endpoints

### Health Check
```
GET /api/health
```

### Tarefas
```
GET    /api/tasks?userId=user1&modifiedSince=1234567890
GET    /api/tasks/:id
POST   /api/tasks
PUT    /api/tasks/:id
DELETE /api/tasks/:id?version=1
```

### Sincronização
```
POST /api/sync/batch
GET  /api/sync/stats?userId=user1
```

## 🔧 Configuração

Crie um arquivo `.env` baseado em `.env.example`:

```env
PORT=3000
NODE_ENV=development
```

## 📝 Estrutura

```
backend/
├── src/
│   ├── server.ts           # Bootstrap do Express
│   ├── config/             # Configurações
│   ├── storage/            # Armazenamento (em memória)
│   ├── models/             # Modelos de dados
│   ├── routes/             # Rotas HTTP
│   ├── controllers/        # Controllers
│   ├── services/           # Lógica de negócio
│   └── middleware/         # Middlewares
└── package.json
```

## 🧪 Testes

```bash
npm test
```

## 📚 Documentação

Ver [docs/sync-protocol.md](../docs/sync-protocol.md) para detalhes do protocolo de sincronização.