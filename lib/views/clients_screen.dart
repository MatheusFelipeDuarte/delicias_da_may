import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/viewmodels/clients_view_model.dart';
import 'package:delicias_da_may/viewmodels/calendar_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delicias_da_may/core/phone_formatter.dart';
import 'package:delicias_da_may/core/whatsapp_launcher.dart';
import 'package:delicias_da_may/models/client.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Clientes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: vm.setQuery,
              decoration: InputDecoration(
                hintText: 'Buscar Cliente',
                prefixIcon: const Icon(Icons.search, color: AppColors.dourado),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.dourado),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.dourado, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: vm.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.filtered.length,
                  itemBuilder: (context, i) {
                  final c = vm.filtered[i];
                  return Dismissible(
                    key: ValueKey('client-${c.id}-${i}'),
                    background: _SwipeEditBg(),
                    secondaryBackground: _SwipeDeleteBg(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir'),
                                content: const Text('Deseja excluir este cliente?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok && c.id != null) {
                          await context.read<ClientsViewModel>().repo.delete(c.id!);
                          await context.read<ClientsViewModel>().refresh();
                          // reflect immediately in order form options
                          await context.read<CalendarViewModel>().externalOptionsUpdated();
                        }
                        return ok;
                      } else {
                        // left-to-right: editar
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          barrierColor: AppColors.rosa.withValues(alpha: 0.35),
                          builder: (_) => _ClientEditSheet(client: c),
                        );
                        return false;
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        onTap: () async {
                          final phone = c.phone.trim();
                          if (phone.isEmpty) return;
                          final ok = await WhatsAppLauncher.open(phone);
                          if (!ok) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o WhatsApp')));
                            }
                          }
                        },
                        title: Text('${c.nome} • ${c.endereco}', overflow: TextOverflow.ellipsis),
                        subtitle: Text(PhoneFormatter.formatBr(c.phone)),
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            if (c.id == null) return;
                            final clientsVm = context.read<ClientsViewModel>();
                            final repo = clientsVm.repo;
                            if (c.qtdSelos >= 10) {
                              final proceed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Selos completos'),
                                      content: const Text('Se continuar, vamos considerar que o cliente já retirou o brinde. Deseja continuar?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuar')),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (!proceed) return;
                              await repo.update(c.copyWith(qtdSelos: 0));
                            } else {
                              final next = (c.qtdSelos + 1).clamp(0, 10);
                              await repo.update(c.copyWith(qtdSelos: next));
                            }
                            await clientsVm.refresh();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: AppColors.dourado),
                              const SizedBox(width: 6),
                              Text('${c.qtdSelos}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: AppColors.rosa.withValues(alpha: 0.35),
            builder: (_) => const _ClientFormSheet(),
          );
        },
        child: const Icon(Icons.add),
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

class _ClientFormSheet extends StatefulWidget {
  const _ClientFormSheet();
  @override
  State<_ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<_ClientFormSheet> {
  final _nome = TextEditingController();
  final _phone = TextEditingController();
  final _endereco = TextEditingController();
  int? _selos;
  bool _saving = false;

  @override
  void dispose() {
    _nome.dispose();
    _phone.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nome.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome')));
      return;
    }
    if (_phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o telefone')));
      return;
    }
    if (_endereco.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o endereço')));
      return;
    }
    final selos = _selos ?? 0;
    setState(() => _saving = true);
    try {
  await context.read<ClientsViewModel>().addClient(
            nome: _nome.text.trim(),
            endereco: _endereco.text.trim(),
            phone: _phone.text.trim(),
            qtdSelos: selos,
          );
  // reflect immediately in order form options
  await context.read<CalendarViewModel>().externalOptionsUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return _RoundedSheet(
      title: 'Cliente',
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      trailing: _SaveButton(onPressed: _saving ? () {} : _save),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Nome', controller: _nome),
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Telefone', controller: _phone),
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Endereço', controller: _endereco),
          const SizedBox(height: 8),
          const Text('Quantidade de Selos'),
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
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selos,
                  hint: const Text('Selecionar'),
                  items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (v) => setState(() => _selos = v),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ClientEditSheet extends StatefulWidget {
  final Client client;
  const _ClientEditSheet({required this.client});
  @override
  State<_ClientEditSheet> createState() => _ClientEditSheetState();
}

class _ClientEditSheetState extends State<_ClientEditSheet> {
  late final TextEditingController _nome = TextEditingController(text: widget.client.nome);
  late final TextEditingController _phone = TextEditingController(text: widget.client.phone);
  late final TextEditingController _endereco = TextEditingController(text: widget.client.endereco);
  late int _selos = widget.client.qtdSelos;
  bool _saving = false;

  @override
  void dispose() {
    _nome.dispose();
    _phone.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nome.text.trim().isEmpty || _phone.text.trim().isEmpty || _endereco.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }
    setState(() => _saving = true);
    try {
      final vm = context.read<ClientsViewModel>();
      await vm.repo.update(widget.client.copyWith(
        nome: _nome.text.trim(),
        phone: _phone.text.trim(),
        endereco: _endereco.text.trim(),
        qtdSelos: _selos,
      ));
      await vm.refresh();
      await context.read<CalendarViewModel>().externalOptionsUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return _RoundedSheet(
      title: 'Editar Cliente',
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      trailing: _SaveButton(onPressed: _saving ? () {} : _save),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Nome', controller: _nome),
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Telefone', controller: _phone),
          const SizedBox(height: 8),
          _LabeledTextField(label: 'Endereço', controller: _endereco),
          const SizedBox(height: 8),
          const Text('Quantidade de Selos'),
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
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selos,
                  items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (v) => setState(() => _selos = v ?? _selos),
                ),
              ),
            ),
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
      decoration: const BoxDecoration(color: Colors.transparent),
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
                // Handle no topo
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

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _LabeledTextField({required this.label, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
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
