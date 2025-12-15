# Roteiro de Demonstração - Offline-First Mobile

## Pré-requisitos

1. ✅ Backend rodando: `cd backend && npm run dev`
2. ✅ App Flutter instalado no dispositivo/emulador
3. ✅ Configurar IP do backend em `lib/utils/constants.dart`

## 🎯 Cenário 1: Criação Offline

**Objetivo:** Demonstrar criação de tarefas sem conexão

### Passos:

1. ✅ Desabilitar WiFi/dados no dispositivo (Modo Avião)
2. ✅ Abrir o app (indicador vermelho deve aparecer: "🔴 Offline")
3. ✅ Criar nova tarefa:
   - Título: "Comprar leite"
   - Descrição: "Leite integral 1L"
   - Prioridade: Média
   - Salvar

4. ✅ **Verificar:**
   - Tarefa aparece na lista
   - Badge mostra "⏱ Pendente" (não sincronizada)
   - Notificação: "📴 Tarefa será sincronizada quando voltar online"

5. ✅ Criar mais 2 tarefas offline:
   - "Estudar para prova"
   - "Fazer exercícios"

6. ✅ Abrir tela "Status de Sincronização" (ícone de info)
   - Verificar: "Não Sincronizadas: 3"
   - Verificar: "Na Fila: 3"

7. ✅ Reabilitar WiFi/dados (sair do Modo Avião)
8. ✅ Observar:
   - Indicador fica verde: "🟢 Online"
   - Notificação: "🟢 Conectado - Sincronizando..."
   - Auto-sync inicia automaticamente
   - Badges mudam para "✓ Sincronizado"

**✅ Resultado esperado:** Todas as 3 tarefas sincronizadas automaticamente

---

## 🎯 Cenário 2: Conflito Last-Write-Wins

**Objetivo:** Demonstrar resolução automática de conflitos

### Parte A: Preparar cenário

1. ✅ Com conexão online, criar tarefa:
   - Título: "Revisar código"
   - Prioridade: Alta
   - Salvar

2. ✅ Aguardar sincronização (badge "✓")

3. ✅ Copiar ID da tarefa (via debug ou logs)

### Parte B: Criar conflito

4. ✅ Desabilitar conexão (Modo Avião)

5. ✅ Editar tarefa localmente:
   - Mudar título para: "Revisar código - Frontend"
   - Salvar

6. ✅ Em outra máquina/Postman, editar mesma tarefa no servidor:
```bash
curl -X PUT http://localhost:3000/api/tasks/[ID_DA_TAREFA] \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Revisar código - Backend",
    "priority": "urgent",
    "version": 1
  }'
```

### Parte C: Resolver conflito

7. ✅ Reabilitar conexão

8. ✅ Observar no console/logs:
```
⚠️ Conflito detectado: [ID]
🏆 LWW: Versão [local/servidor] vence
```

9. ✅ Verificar qual versão venceu baseado no timestamp

**✅ Resultado esperado:** Conflito resolvido automaticamente usando Last-Write-Wins

---

## 🎯 Cenário 3: Fila de Operações

**Objetivo:** Validar enfileiramento de múltiplas operações

1. ✅ Desabilitar conexão

2. ✅ Realizar operações:
   - Criar tarefa "A"
   - Criar tarefa "B"
   - Criar tarefa "C"
   - Editar tarefa "A" (marcar como concluída)
   - Deletar tarefa "B"

3. ✅ Abrir "Status de Sincronização":
   - Verificar: "Na Fila: 5 operações"

4. ✅ Reabilitar conexão

5. ✅ Observar sincronização:
   - Console mostra: "📤 Processando 5 operações pendentes"
   - Operações processadas em ordem (FIFO)
   - Fila limpa após sucesso

**✅ Resultado esperado:** Todas operações processadas em ordem (FIFO)

---

## 🎯 Cenário 4: Persistência Local

**Objetivo:** Garantir que dados persistem após fechar app

1. ✅ Criar 3 tarefas (online ou offline)

2. ✅ Fechar o app completamente (kill process)

3. ✅ Desabilitar conexão (simular sem internet)

4. ✅ Reabrir o app

5. ✅ Verificar:
   - Todas as 3 tarefas ainda visíveis
   - Estado de sincronização preservado
   - Aplicação funcional offline

6. ✅ Reabilitar conexão

7. ✅ Sincronizar

**✅ Resultado esperado:** Dados persistiram no SQLite

---

## 🎯 Cenário 5: Indicadores Visuais

**Objetivo:** Validar feedback visual para o usuário

### Indicadores a verificar:

1. ✅ **Conectividade:**
   - Bolinha verde (online) / vermelha (offline)
   - Texto "Online" / "Offline"

2. ✅ **Sincronização:**
   - Botão "🔄 Sincronizar" / "Sincronizando..."
   - Ícone rotacionando durante sync

3. ✅ **Badges de Tarefa:**
   - ✓ Sincronizado (verde)
   - ⏱ Pendente (amarelo)
   - ⚠ Conflito (vermelho)
   - ✗ Erro (vermelho)

4. ✅ **Notificações:**
   - Sucesso (verde)
   - Aviso (amarelo)
   - Erro (vermelho)
   - Info (azul)

5. ✅ **Tela de Status:**
   - Total de tarefas
   - Não sincronizadas
   - Operações na fila
   - Última sincronização

---

## 🔍 Comandos Úteis para Debug

### No Console do Flutter:

```dart
// Ver todas as tarefas locais
final db = DatabaseService.instance;
final tasks = await db.readAll();

// Ver fila de sincronização
final queue = await db.getPendingSyncOperations();

// Ver estatísticas
final stats = await db.getStats();

// Limpar todos os dados
await db.clearAllData();
```

### Verificar Estado do Servidor:

```bash
# Health check
curl http://localhost:3000/api/health

# Ver todas as tarefas
curl http://localhost:3000/api/tasks?userId=user1

# Ver estatísticas
curl http://localhost:3000/api/sync/stats?userId=user1
```
