import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_formatters.dart';
import '../auth/auth_provider.dart';
import '../dashboard/wallet_provider.dart';
import 'bills_provider.dart';

/// Écran 2 : factures impayées d'un fournisseur donné, sélection multiple + paiement en lot.
class BillProviderDetailScreen extends StatefulWidget {
  final String fournisseur;
  const BillProviderDetailScreen({super.key, required this.fournisseur});

  @override
  State<BillProviderDetailScreen> createState() => _BillProviderDetailScreenState();
}

class _BillProviderDetailScreenState extends State<BillProviderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final walletCode = context.read<AuthProvider>().walletCode;
    if (walletCode != null) {
      context.read<BillsProvider>().loadFactures(walletCode, widget.fournisseur);
    }
  }

  Future<void> _onPayPressed() async {
    final billsProvider = context.read<BillsProvider>();
    final myPhone = context.read<AuthProvider>().phone;
    if (myPhone == null || billsProvider.selectedReferences.isEmpty) return;

    final wallet = context.read<WalletProvider>().wallet;
    if (wallet != null && billsProvider.selectedTotal > wallet.balance) {
      _showSnack('Solde insuffisant pour payer cette sélection', isError: true);
      return;
    }

    final confirmed = await _showConfirmationSheet(billsProvider);
    if (confirmed != true) return;
    if (!mounted) return;

    final count = billsProvider.selectedReferences.length;
    final total = billsProvider.selectedTotal;

    final success = await billsProvider.payFactures(phoneNumber: myPhone, serviceName: widget.fournisseur);
    if (!mounted) return;

    if (success) {
      await context.read<WalletProvider>().silentRefresh(myPhone);
      if (!mounted) return;
      _showSuccessDialog(count, total);
    } else {
      _showSnack(billsProvider.paymentError ?? 'Le paiement a échoué', isError: true);
    }
  }

  Future<bool?> _showConfirmationSheet(BillsProvider provider) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 30),
              ),
              const SizedBox(height: 20),
              Text('Confirmer le paiement', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${provider.selectedReferences.length} facture(s)', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    AppFormatters.currency(provider.selectedTotal),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: const Text('Payer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppTheme.danger : AppTheme.success),
    );
  }

  Future<void> _showSuccessDialog(int count, double total) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text('Paiement réussi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '$count facture(s) payée(s) — ${AppFormatters.currency(total)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Terminé'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillsProvider>();
    final isPaying = provider.paymentStatus == PaymentStatus.loading;

    return Scaffold(
      appBar: AppBar(title: Text('Factures ${widget.fournisseur}')),
      body: SafeArea(child: _buildBody(provider)),
      bottomNavigationBar: provider.selectedReferences.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPaying ? null : _onPayPressed,
                    child: isPaying
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text('Payer ${AppFormatters.currency(provider.selectedTotal)}'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BillsProvider provider) {
    if (provider.status == BillsStatus.loading || provider.status == BillsStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == BillsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.danger),
              const SizedBox(height: 16),
              Text(provider.errorMessage ?? 'Erreur', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    if (provider.factures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Aucune facture impayée', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Vous êtes à jour avec ${widget.fournisseur} pour le mois en cours.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: provider.factures.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final facture = provider.factures[index];
        final selected = provider.selectedReferences.contains(facture.reference);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => provider.toggleSelection(facture.reference),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    activeColor: AppTheme.primary,
                    onChanged: (_) => provider.toggleSelection(facture.reference),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(facture.reference, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 2),
                        if (facture.mois != null)
                          Text('Échéance : ${AppFormatters.date(facture.mois!)}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.currency(facture.montant),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}