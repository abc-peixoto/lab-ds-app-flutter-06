# Arquitetura - Visão Geral

## Diagrama de Arquitetura

```
┌────────────────────────────────────────────────────────────┐
│                    Flutter App (Mobile)                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │  Providers   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              SyncService (Motor de Sync)             │  │
│  │  • Push (Cliente → Servidor)                         │  │
│  │  • Pull (Servidor → Cliente)                         │  │
│  │  • Resolução de Conflitos (LWW)                      │  │
│  └──────┬───────────────────────────────┬───────────────┘  │
│         │                               │                  │
│  ┌──────▼───────┐            ┌─────────▼──────────┐        │
│  │ ApiService   │            │ DatabaseService    │        │
│  │ (HTTP REST)  │            │ (SQLite)           │        │
│  └──────┬───────┘            └─────────┬──────────┘        │
│         │                              │                   │
│         │                              │                   │
│  ┌──────▼──────────────────────────────▼───────────┐       │
│  │         ConnectivityService                     │       │
│  │         (Monitor de Rede)                       │       │
│  └─────────────────────────────────────────────────┘       │
└───────────────────────────┬────────────────────────────────┘
                            │
                    ┌───────▼────────┐
                    │   HTTP REST    │
                    └───────┬────────┘
                            │
┌───────────────────────────▼────────────────────────────────┐
│              Backend (Node/Express)                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Routes     │  │ Controllers  │  │   Services   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                │
│  ┌───────────────────────▼──────────────────────────────┐  │
│  │            TaskStorage (In-Memory)                   │  │
│  │  • Versionamento                                     │  │
│  │  • Sync Incremental                                  │  │
│  │  • Detecção de Conflitos                             │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

## Componentes Principais

### Backend

- **TaskStorage**: Armazenamento em memória com versionamento
- **Routes**: Endpoints REST (`/api/tasks`, `/api/sync`, `/api/health`)
- **Controllers**: Lógica de requisições HTTP
- **Services**: Regras de negócio e sincronização

### Mobile

- **SyncService**: Motor de sincronização offline-first
- **DatabaseService**: Persistência local SQLite
- **ApiService**: Comunicação HTTP com backend
- **ConnectivityService**: Monitoramento de rede

## Fluxo de Sincronização

1. **Operação Offline:**
   - Usuário cria/edita/deleta tarefa
   - Salva localmente no SQLite
   - Adiciona à fila de sincronização
   - Marca como `pending`

2. **Volta Online:**
   - `ConnectivityService` detecta conexão
   - `SyncService` inicia sincronização automática
   - Processa fila (FIFO)
   - Pull de atualizações do servidor

3. **Resolução de Conflitos:**
   - Detecta conflito (versões diferentes)
   - Aplica Last-Write-Wins (timestamp mais recente vence)
   - Atualiza banco local e servidor

## Estratégia de Sincronização

- **Last-Write-Wins (LWW)**: Última modificação prevalece
- **Sync Incremental**: Busca apenas mudanças desde última sync
- **Fila FIFO**: Operações processadas em ordem
- **Retry**: 3 tentativas antes de marcar como failed
