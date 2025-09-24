import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/viewmodels/products_view_model.dart';
import 'package:delicias_da_may/viewmodels/calendar_view_model.dart';
import 'package:delicias_da_may/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Produtos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: vm.setQuery,
              decoration: InputDecoration(
                hintText: 'Buscar Produto',
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
              child: ListView.builder(
                itemCount: vm.filtered.length,
                itemBuilder: (context, i) {
                  final p = vm.filtered[i];
                  return Dismissible(
                    key: ValueKey('product-${p.id}-${i}'),
                    background: const _SwipeEditBg(),
                    secondaryBackground: const _SwipeDeleteBg(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir'),
                                content: const Text('Deseja excluir este produto?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok && p.id != null) {
                          await context.read<ProductsViewModel>().repo.delete(p.id!);
                          await context.read<ProductsViewModel>().refresh();
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
                          builder: (_) => _EditProductSheet(productId: p.id!, initialName: p.nome),
                        );
                        return false;
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(p.nome),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showGeneralDialog(
            context: context,
            barrierColor: AppColors.rosa.withValues(alpha: 0.35),
            barrierDismissible: true,
            barrierLabel: 'Fechar',
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, a1, a2) {
              return const _AddProductDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog();
  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _EditProductSheet extends StatefulWidget {
  final int productId;
  final String initialName;
  const _EditProductSheet({required this.productId, required this.initialName});
  @override
  State<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<_EditProductSheet> {
  late final TextEditingController _nomeCtrl = TextEditingController(text: widget.initialName);
  bool _saving = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nomeCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do produto')));
      return;
    }
    setState(() => _saving = true);
    try {
      // update product
      final repo = context.read<ProductsViewModel>().repo;
      await repo.update(Product(id: widget.productId, nome: name));
      await context.read<ProductsViewModel>().refresh();
      await context.read<CalendarViewModel>().externalOptionsUpdated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: AppColors.begeClaro,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: media.viewInsets.bottom + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // handle
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.marromChocolate.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Nome'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nomeCtrl,
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
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosa,
                    foregroundColor: AppColors.marromChocolate,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saving ? null : _save,
                  child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _nomeCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nomeCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do produto')));
      return;
    }
    setState(() => _saving = true);
    try {
  await context.read<ProductsViewModel>().addProduct(name);
  await context.read<CalendarViewModel>().externalOptionsUpdated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: AppColors.begeClaro,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dourado, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.marromChocolate.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Nome'),
              const SizedBox(height: 6),
              TextField(
                controller: _nomeCtrl,
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
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosa,
                  foregroundColor: AppColors.marromChocolate,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saving ? null : _save,
                child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeEditBg extends StatelessWidget {
  const _SwipeEditBg();
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
  const _SwipeDeleteBg();
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
