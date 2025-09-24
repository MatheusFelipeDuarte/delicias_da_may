import 'package:delicias_da_may/core/app_colors.dart';
import 'dart:ui' as ui;
import 'package:delicias_da_may/viewmodels/calendar_view_model.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: Consumer<CalendarViewModel>(
        builder: (context, vm, _) {
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 360,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.begeClaro,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: TableCalendar(
                          locale: 'pt_BR',
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          focusedDay: vm.selectedDay,
                          sixWeekMonthsEnforced: true,
                          rowHeight: 40,
                          daysOfWeekHeight: 20,
                          selectedDayPredicate: (day) => isSameDay(day, vm.selectedDay),
                          onDaySelected: (selected, focused) {
                            vm.selectDay(selected);
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.dourado),
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.dourado,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            todayTextStyle: const TextStyle(color: AppColors.marromChocolate, fontWeight: FontWeight.w600),
                            weekendTextStyle: const TextStyle(color: AppColors.marromChocolate),
                            defaultTextStyle: const TextStyle(color: AppColors.marromChocolate),
                            outsideTextStyle: TextStyle(
                              color: AppColors.marromChocolate.withValues(alpha: 0.4),
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            headerPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: vm.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            itemCount: vm.items.length,
                            itemBuilder: (context, index) {
                              final item = vm.items[index];
                              return Dismissible(
                                key: ValueKey('day-${item.isExpense ? 'e' : 'o'}-${item.time.millisecondsSinceEpoch}-${item.orderId ?? item.expenseId ?? index}'),
                                background: _SwipeEditBg(), // left-to-right
                                secondaryBackground: _SwipeDeleteBg(), // right-to-left
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Excluir'),
                                            content: const Text('Deseja excluir este registro?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                    if (ok) {
                                      if (item.isExpense && item.expenseId != null) {
                                        await vm.deleteExpense(item.expenseId!);
                                      } else if (!item.isExpense && item.orderId != null) {
                                        await vm.deleteOrder(item.orderId!);
                                      }
                                    }
                                    return ok;
                                  } else {
                                    // left-to-right -> open edit
                                    if (item.isExpense && item.expenseId != null) {
                                      await _openExpenseEdit(context, item.expenseId!);
                                    } else if (!item.isExpense && item.orderId != null) {
                                      await _openOrderEdit(context, item.orderId!);
                                    }
                                    return false; // don't dismiss
                                  }
                                },
                                child: _DayCard(item: item),
                              );
                            },
                          ),
                  ),
                ],
              ),
              if (_menuOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _menuOpen = false),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: Container(
                          color: AppColors.rosa.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _FabMenu(
        open: _menuOpen,
        onMainTap: () => setState(() => _menuOpen = !_menuOpen),
        onAddOrder: () async {
          setState(() => _menuOpen = false);
          // Preload dropdown options before opening the sheet to avoid in-sheet reloads
          await context.read<CalendarViewModel>().reloadOptions();
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: AppColors.rosa.withValues(alpha: 0.35),
            builder: (_) => const OrderFormSheet(),
          );
        },
        onAddExpense: () async {
          setState(() => _menuOpen = false);
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: AppColors.rosa.withValues(alpha: 0.35),
            builder: (_) => const ExpenseFormSheet(),
          );
        },
      ),
    );
  }
}

class _SwipeEditBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar')],
      ),
    );
  }
}

class _SwipeDeleteBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Text('Excluir'), SizedBox(width: 8), Icon(Icons.delete, color: Colors.red)],
      ),
    );
  }
}

Future<void> _openOrderEdit(BuildContext context, int orderId) async {
  final vm = context.read<CalendarViewModel>();
  final order = await vm.getOrder(orderId);
  if (order == null) return;
  // Ensure options are fresh before opening edit sheet
  await vm.reloadOptions();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.rosa.withValues(alpha: 0.35),
    builder: (_) => OrderFormSheet(initialOrder: order),
  );
}

Future<void> _openExpenseEdit(BuildContext context, int expenseId) async {
  final vm = context.read<CalendarViewModel>();
  final expense = await vm.getExpense(expenseId);
  if (expense == null) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.rosa.withValues(alpha: 0.35),
    builder: (_) => ExpenseFormSheet(initialExpense: expense),
  );
}

class _DayCard extends StatelessWidget {
  final DayCardItem item;
  const _DayCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(item.valor),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.isExpense ? Colors.red[600] : AppColors.marromChocolate,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.rosa,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (item.isExpense) {
                        if (item.expenseId == null) return;
                        final exp = await context.read<CalendarViewModel>().getExpense(item.expenseId!);
                        if (exp == null) return;
                        final dt = DateFormat('dd/MM/yyyy HH:mm').format(exp.time);
                        // Show expense details
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Detalhes do Gasto'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _kv('ID', exp.id?.toString() ?? '-'),
                                  _kv('Categoria', exp.categoria.label),
                                  _kv('Valor', currency.format(exp.valor)),
                                  _kv('Pagamento', exp.pagamento.label),
                                  _kv('Data/Hora', dt),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
                              ],
                            ),
                          );
                        }
                      } else {
                        if (item.orderId == null) return;
                        final details = await context.read<CalendarViewModel>().getOrderDetails(item.orderId!);
                        if (details == null) return;
                        final o = details.order;
                        final client = details.client;
                        final product = details.product;
                        final dt = DateFormat('dd/MM/yyyy HH:mm').format(o.time);
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Detalhes do Pedido'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _kv('ID', o.id?.toString() ?? '-'),
                                    _kv('Cliente', client != null ? '${client.nome} • ${client.endereco}' : '#${o.clienteId}'),
                                    _kv('Produto', product?.nome ?? '#${o.produtoId}'),
                                    _kv('Quantidade', o.quantidade.toString()),
                                    _kv('Valor', currency.format(o.valor)),
                                    _kv('Pagamento', o.pagamento.label),
                                    _kv('Data/Hora', dt),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Detalhes',
                      style: TextStyle(color: AppColors.marromChocolate, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _kv(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(v)),
      ],
    ),
  );
}

class _FabMenu extends StatelessWidget {
  final bool open;
  final VoidCallback onMainTap;
  final VoidCallback onAddOrder;
  final VoidCallback onAddExpense;
  const _FabMenu({
    required this.open,
    required this.onMainTap,
    required this.onAddOrder,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: open ? 180 : 64,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (open)
            Positioned(
              right: 10,
              bottom: 110,
              child: _ActionChip(label: 'Gastos', icon: Icons.attach_money, onTap: onAddExpense),
            ),
          if (open)
            Positioned(
              right: 10,
              bottom: 60,
              child: _ActionChip(label: 'Pedidos', icon: Icons.add, onTap: onAddOrder),
            ),
          FloatingActionButton(
            onPressed: onMainTap,
            child: Icon(open ? Icons.close : Icons.add, size: 30),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.dourado,
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class OrderFormSheet extends StatefulWidget {
  final Order? initialOrder;
  const OrderFormSheet({super.key, this.initialOrder});

  @override
  State<OrderFormSheet> createState() => _OrderFormSheetState();
}

class _OrderFormSheetState extends State<OrderFormSheet> {
  int? _clienteId;
  int? _produtoId;
  PaymentMethod? _pagamento;
  final _valorCtrl = TextEditingController();
  final _qtdCtrl = TextEditingController(text: '1');
  final _horaCtrl = TextEditingController();
  final FocusNode _valorFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Prefill when editing; avoid calling setState here to not drop focus later
    final o = widget.initialOrder;
    if (o != null) {
      _clienteId = o.clienteId;
      _produtoId = o.produtoId;
      _pagamento = o.pagamento;
      _valorCtrl.text = o.valor.toStringAsFixed(2).replaceAll('.', ',');
      _qtdCtrl.text = o.quantidade.toString();
      final tod = TimeOfDay(hour: o.time.hour, minute: o.time.minute);
      // Defer format until context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _horaCtrl.text = tod.format(context);
      });
      _timeInitialized = true; // prevent overwriting
    }
  }

  bool _timeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_timeInitialized) {
      final now = TimeOfDay.now();
      // Safe to access Localizations here
      _horaCtrl.text = now.format(context);
      _timeInitialized = true;
    }
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _qtdCtrl.dispose();
    _horaCtrl.dispose();
    _valorFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final initial = _parseTime(_horaCtrl.text) ?? now;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      _horaCtrl.text = picked.format(context);
    }
  }

  TimeOfDay? _parseTime(String input) {
    try {
      // Try formats like 14:30 or localized from format()
      final parts = input.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0].trim());
        final m = int.parse(parts[1].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        return TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    return null;
  }

  double? _parseValor(String input) {
    final s = input.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(s);
  }

  Future<void> _onSave() async {
    final vm = context.read<CalendarViewModel>();
    if (_clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um cliente')));
      return;
    }
    if (_produtoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um produto')));
      return;
    }
    if (_pagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a forma de pagamento')));
      return;
    }
    final parsedValor = _parseValor(_valorCtrl.text);
    if (parsedValor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido')));
      return;
    }
    final valor = parsedValor;
    final qtd = int.tryParse(_qtdCtrl.text) ?? 1;
    final tod = _parseTime(_horaCtrl.text) ?? TimeOfDay.now();
    final d = vm.selectedDay;
    final when = DateTime(d.year, d.month, d.day, tod.hour, tod.minute);
    setState(() => _loading = true);
    try {
      if (widget.initialOrder == null) {
        await vm.addOrder(
          clienteId: _clienteId!,
          produtoId: _produtoId!,
          valor: valor,
          quantidade: qtd,
          pagamento: _pagamento!,
          time: when,
        );
      } else {
        final updated = Order(
          id: widget.initialOrder!.id,
          produtoId: _produtoId!,
          clienteId: _clienteId!,
          valor: valor,
          quantidade: qtd,
          pagamento: _pagamento!,
          time: when,
        );
        await vm.updateOrder(updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar pedido: $e')));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avoid rebuilding the whole sheet on every VM notifyListeners while typing
    final vm = context.read<CalendarViewModel>();
    final media = MediaQuery.of(context);
    return _RoundedSheet(
      title: 'Pedido',
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      trailing: _SaveButton(onPressed: _loading ? () {} : _onSave),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DropdownContainer<int>(
            label: 'Cliente',
            value: _clienteId,
            items: vm.clients
                .map((c) => DropdownMenuItem<int>(value: c.id, child: Text('${c.nome} • ${c.endereco}', overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _clienteId = v),
          ),
          _DropdownContainer<int>(
            label: 'Produto',
            value: _produtoId,
            items: vm.products
                .map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.nome, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _produtoId = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TextField(label: 'Valor', controller: _valorCtrl, focusNode: _valorFocus, keyboardType: TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: _TextField(label: 'Quantidade', controller: _qtdCtrl, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DropdownContainer<PaymentMethod>(
                  label: 'Pagamento',
                  value: _pagamento,
                  items: vm.paymentMethods
                      .map((m) => DropdownMenuItem<PaymentMethod>(value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _pagamento = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TextField(
                  label: 'Horário',
                  controller: _horaCtrl,
                  readOnly: true,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ExpenseFormSheet extends StatefulWidget {
  final Expense? initialExpense;
  const ExpenseFormSheet({super.key, this.initialExpense});
  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  ExpenseCategory? _categoria;
  PaymentMethod? _pagamento;
  final _valorCtrl = TextEditingController();
  final FocusNode _valorFocus = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initialExpense;
    if (e != null) {
      _categoria = e.categoria;
      _pagamento = e.pagamento;
      _valorCtrl.text = e.valor.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _valorFocus.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  double? _parseValor(String input) {
    final s = input.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(s);
  }

  Future<void> _onSave() async {
    final vm = context.read<CalendarViewModel>();
    if (_categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a categoria')));
      return;
    }
    if (_pagamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a forma de pagamento')));
      return;
    }
    final parsedValor = _parseValor(_valorCtrl.text);
    if (parsedValor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido')));
      return;
    }
    final valor = parsedValor;
    final d = vm.selectedDay;
    setState(() => _loading = true);
    try {
      if (widget.initialExpense == null) {
        await vm.addExpense(
          categoria: _categoria!,
          valor: valor,
          pagamento: _pagamento!,
          time: DateTime(d.year, d.month, d.day),
        );
      } else {
        final updated = Expense(
          id: widget.initialExpense!.id,
          categoria: _categoria!,
          valor: valor,
          pagamento: _pagamento!,
          time: DateTime(d.year, d.month, d.day),
        );
        await vm.updateExpense(updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar gasto: $e')));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
  // Do not watch here to avoid rebuilds that may dismiss the keyboard
  final vm = context.read<CalendarViewModel>();
    final media = MediaQuery.of(context);
    return _RoundedSheet(
      title: 'Gasto',
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      trailing: _SaveButton(onPressed: _loading ? () {} : _onSave),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DropdownContainer<ExpenseCategory>(
            label: 'Categoria',
            value: _categoria,
            items: vm.expenseCategories
                .map((c) => DropdownMenuItem<ExpenseCategory>(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) => setState(() => _categoria = v),
          ),
          const SizedBox(height: 8),
          _TextField(label: 'Valor', controller: _valorCtrl, focusNode: _valorFocus, keyboardType: TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 8),
          _DropdownContainer<PaymentMethod>(
            label: 'Forma de Pagamento',
            value: _pagamento,
            items: vm.paymentMethods
                .map((m) => DropdownMenuItem<PaymentMethod>(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) => setState(() => _pagamento = v),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RoundedSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;
  const _RoundedSheet({required this.title, required this.child, this.trailing, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: AppColors.begeClaro,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle on the very top center
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.marromChocolate.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 12),
                if (padding != null) Padding(padding: padding!, child: child) else child,
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownContainer<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownContainer({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.dourado.withValues(alpha: 0.7)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                items: items,
                onChanged: onChanged,
                hint: const Text('Selecione'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  const _TextField({required this.label, this.controller, this.keyboardType, this.readOnly = false, this.onTap, this.focusNode});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          readOnly: readOnly,
          onTap: () {
            onTap?.call();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.dourado),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.dourado, width: 1.5),
            ),
            hintText: 'Preencher',
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rosa,
        foregroundColor: AppColors.marromChocolate,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
