import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_formatters.dart';
import '../auth/auth_provider.dart';
import '../auth/phone_entry_screen.dart';
import 'wallet_provider.dart';
import 'transaction_tile.dart';
import '../transfers/transfer_screen.dart';
import '../bills/bills_screen.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final phone = context.read<AuthProvider>().phone;
    if (phone != null) {
      context.read<WalletProvider>().loadDashboard(phone);
    }
  }

  Future<void> _onRefresh() async {
    final phone = context.read<AuthProvider>().phone;
    if (phone != null) {
      await context.read<WalletProvider>().silentRefresh(phone);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ? Vous devrez ressaisir votre numéro et votre code PIN.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Déconnexion', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneEntryScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final myPhone = context.read<AuthProvider>().phone ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Portefeuille'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(walletProvider, myPhone),
      ),
    );
  }

  Widget _buildBody(WalletProvider provider, String myPhone) {
    if (provider.status == WalletStatus.loading || provider.status == WalletStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == WalletStatus.error) {
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

    final wallet = provider.wallet!;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBalanceCard(wallet.balance),
          const SizedBox(height: 24),
          _buildQuickActions(myPhone),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dernières transactions', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: const Text('Tout voir'),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: provider.recentTransactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Aucune transaction pour le moment')),
                    )
                  : Column(
                      children: provider.recentTransactions
                          .map((tx) => TransactionTile(transaction: tx, myPhone: myPhone))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Solde disponible', style: TextStyle(color: Colors.white70, fontSize: 14)),
              IconButton(
                onPressed: () => setState(() => _balanceHidden = !_balanceHidden),
                icon: Icon(
                  _balanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _balanceHidden ? '••••••' : AppFormatters.currency(balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String myPhone) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.send_rounded,
            label: 'Transférer',
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransferScreen()));
              _onRefresh();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Payer',
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillsScreen()));
              _onRefresh();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.history_rounded,
            label: 'Historique',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}