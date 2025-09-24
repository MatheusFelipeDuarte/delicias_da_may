<div align="center">

# Delícias da May 🍰

Organize pedidos, clientes, produtos e finanças de um pequeno negócio de confeitaria em uma única aplicação Flutter, simples e elegante.

Portfólio de: Matheus Duarte

</div>

## Visão geral

Delícias da May é um app multi-plataforma (Android, iOS e Desktop) para gestão do dia a dia de um pequeno negócio de doces:

- Calendário para visualizar pedidos e gastos do dia
- Cadastro e busca de clientes (com controle de selos/fidelidade)
- Cadastro e busca de produtos
- Resumo financeiro com gráfico mensal/anual, total de ganhos, gastos e lucro
- Exportação e importação de backup em JSON

O app é 100% offline-first usando SQLite (sqflite) e segue uma arquitetura leve de camadas (Models → Repositories → ViewModels → Views) com Provider (ChangeNotifier) para gerenciamento de estado.

## Principais telas

- Calendário: adicione rapidamente Pedidos e Gastos, edite/exclua por swipe e visualize detalhes.
- Clientes: cadastre, pesquise, edite e remova clientes. Controle de selos (0–10) com ação rápida para progressão e aviso ao completar.
- Produtos: cadastre, pesquise, edite e remova produtos.
- Financeiro: gráfico de ganhos x gastos (dia a dia ou mês a mês) com cards de estatística e contagem de vendas. Botões para exportar/importar JSON.

Sugestão de navegação (Bottom Navigation):

- Calendário • Clientes • Produtos • Financeiro

## Destaques técnicos (para portfólio)

- Flutter multiplataforma com suporte a Desktop (sqflite_common_ffi)
- Design system centralizado em `AppColors` + UI consistente (inputs, sheets com cantos arredondados, sombras, feedback visual)
- MVVM com Provider: `ViewModels` reativos e testáveis, `Repositories` desacoplados da UI
- Banco local: criação de tabelas idempotente, migrations simples e seed de dados de demonstração
- UX: busca incremental, swipe para editar/excluir, modal sheets responsivas, calendário com seleção de dia e lista ordenada
- Gráfico customizado sem dependências externas (CustomPainter), com escala adaptativa e legenda
- Backup/Restore: exporta/importa toda a base em JSON (`delicias_da_may_backup.json`) para Downloads/Documentos

## Arquitetura (resumo)

- Models: `Client`, `Product`, `Order`, `Expense`
- Repositories: CRUD e agregações (sum/count por dia/mês/ano) usando `sqflite`
- ViewModels (ChangeNotifier): `CalendarViewModel`, `ClientsViewModel`, `ProductsViewModel`, `FinanceViewModel`
- Views: telas de calendário, clientes, produtos e financeiro, além de modais de formulário

Fluxo típico: View → ViewModel (validações e coordenação) → Repository (persistência SQLite) → Notifica UI

## Modelo de dados (SQLite)

- clientes (id, nome, endereco, qtd_selos, phone)
- produtos (id, nome)
- pedidos (id, produto_id, cliente_id, valor, quantidade, pagamento, time)
- gastos (id, categoria, valor, pagamento, time)

Observações:
- `pagamento` e `categoria` são armazenados como texto a partir de enums (`PaymentMethod`, `ExpenseCategory`).
- `time` é salvo como epoch (ms) para fácil ordenação e consultas por dia.

## Backup e restauração

- Exportar: botão “Salvar JSON” na tela Financeiro cria `delicias_da_may_backup.json` (Downloads ou Documentos).
- Importar: botão “Importar JSON” lê o mesmo arquivo e recarrega toda a base (atualiza as telas automaticamente).

## Tecnologias e pacotes

- Flutter, Dart
- Estado: `provider`
- Persistência: `sqflite`, `path_provider`, `sqflite_common_ffi` (Desktop)
- UI/UX: `table_calendar`, `intl` (pt_BR)

## Como executar

Pré-requisitos: Flutter instalado e configurado (canal stable).

```bash
flutter pub get
flutter run
```

Notas de plataforma:
- Desktop (Linux/Windows/macOS): habilitado via `sqflite_common_ffi` no `main.dart`.
- Web: a UI compila, mas a persistência via `sqflite` não está habilitada neste alvo.

## Estrutura de pastas (resumo)

```
lib/
	core/          # Tema, enums
	data/          # LocalDb (SQLite + seed + export/import)
	models/        # Entidades da aplicação
	repositories/  # Acesso a dados/consultas
	viewmodels/    # Lógica de apresentação (ChangeNotifier)
	views/         # Telas e componentes de UI
	main.dart      # Injeção de dependências + tema + rotas
```

## Decisões de design

- Offline-first para simplicidade e performance local
- Enums para manter consistência de rótulos (Pagamento/Categoria) e parsing resiliente
- UI com ênfase em legibilidade e ações rápidas (bottom sheets, FAB com menu)
- Gráfico desenhado à mão (CustomPainter) para controle fino sem libs extras

## Roadmap (ideias futuras)

- Sincronização em nuvem (ex.: Firebase/Firestore) mantendo modo offline
- Exportação CSV/Excel e compartilhamento por e-mail
- Notificações de lembrete de pedidos
- Multi-idioma (i18n) completo
- Mais testes automatizados (unitários e de widget)

## Autor

Feito com carinho por Matheus Duarte. Se quiser bater um papo sobre o projeto, melhorias ou oportunidades, chama lá! 😊

—

Se este repositório te ajudou, considere deixar uma estrela. Isso ajuda muito no portfólio!
