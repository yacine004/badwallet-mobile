import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../auth/auth_provider.dart';
import '../dashboard/wallet_provider.dart';
import '../dashboard/transaction_tile.dart';
import '../../models/transaction.dart';

enum _FilterType { all, deposit, withdraw, transfer, payment }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _FilterType _filter = _FilterType.all;

  static const Map<_FilterType, String> _labels = {
    _FilterType.all: 'Tout',
    _FilterType.deposit: 'Dépôts',
    _FilterType.withdraw: 'Retraits',
    _FilterType.transfer: 'Transferts',
    _FilterType.payment: 'Paiements',
  };

  static const Map<_FilterType, String> _typeMapping = {
    _FilterType.deposit: 'DEPOSIT',
    _FilterType.withdraw: 'WITHDRAW',
    _FilterType.transfer: 'TRANSFER',
    _FilterType.payment: 'PAYMENT',
  };

  List<AppTransaction> _applyFilter(List<AppTransaction> transactions) {
    if (_filter == _FilterType.all) return transactions;
    final type = _typeMapping[_filter];
    return transactions.where((t) => t.type == type).toList();
  }

  Future<void> _onRefresh() async {
    final phone = context.read<AuthProvider>().phone;
    if (phone != null) {
      await context.read<WalletProvider>().silentRefresh(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final myPhone = context.read<AuthProvider>().phone ?? '';
    final filtered = _applyFilter(walletProvider.transactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: walletProvider.status == WalletStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) =>
                                TransactionTile(transaction: filtered[index], myPhone: myPhone),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: _FilterType.values.map((type) {
          final selected = _filter == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_labels[type]!),
              selected: selected,
              onSelected: (_) => setState(() => _filter = type),
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? AppTheme.primary : Colors.black12),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text('Aucune transaction dans cette catégorie', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}