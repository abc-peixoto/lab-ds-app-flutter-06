# Offline-First Task Manager

Monorepo com backend Node/Express e app Flutter offline-first para gerenciamento de tarefas.

## 🏗️ Estrutura do Projeto

```
offline-first-task-manager/
├── backend/          # API REST Node/Express com TypeScript
├── task_manager/     # App Flutter offline-first
└── docs/            # Documentação e roteiros de demonstração
```

## 🚀 Quick Start

### Backend

```bash
cd backend
npm install
npm run dev  # Servidor em http://localhost:3000
```

### Mobile (Flutter)

```bash
cd task_manager
flutter pub get
flutter run
```

**Nota:** Configure o IP do backend em `task_manager/lib/utils/constants.dart`:
- Android Emulator: `http://10.0.2.2:3000/api`
- iOS Simulator: `http://localhost:3000/api`
- Dispositivo físico: `http://[IP_DA_MAQUINA]:3000/api`

## ✨ Funcionalidades

### Backend
- ✅ API REST com Express
- ✅ Sincronização incremental (`modifiedSince`)
- ✅ Controle de versão para detecção de conflitos
- ✅ Operações em lote (`/api/sync/batch`)
- ✅ Health check endpoint

### Mobile (Flutter)
- ✅ Persistência local com SQLite
- ✅ Detecção de conectividade (`connectivity_plus`)
- ✅ Fila de sincronização para operações offline
- ✅ Resolução automática de conflitos (Last-Write-Wins)
- ✅ Sincronização automática e manual
- ✅ Indicadores visuais de status de sincronização
- ✅ Tela de status de sincronização

## 📚 Documentação

- [Arquitetura](docs/architecture/overview.md)
- [Roteiro de Demonstração Mobile](docs/demos/mobile_offline_demo.md)
- [Protocolo de Sincronização](docs/sync-protocol.md)

## 🧪 Testando Offline-First

1. **Criar tarefas offline:**
   - Desabilite WiFi/dados no dispositivo
   - Crie tarefas no app
   - Observe badges "⏱ Pendente"

2. **Sincronizar:**
   - Reabilite conexão
   - App sincroniza automaticamente
   - Badges mudam para "✓ Sincronizado"

3. **Testar conflitos:**
   - Edite uma tarefa offline
   - Edite a mesma tarefa no servidor (via Postman)
   - Reabilite conexão
   - Conflito resolvido automaticamente (LWW)

## 📖 Requisitos

- Node.js 16+
- Flutter SDK 3.0+
- Dart 3.0+

## Vídeo

[lab-ds-offline-first](https://drive.google.com/file/d/1-Qa6uEzGXpOrN0v5YSd-CdTBtLFZPTLF/view?usp=drivesdk)

## 📝 Licença

MIT



