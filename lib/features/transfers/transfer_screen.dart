import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_formatters.dart';
import '../auth/auth_provider.dart';
import '../dashboard/wallet_provider.dart';
import 'transfer_provider.dart';

enum _TransferStep { phone, amount }

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  _TransferStep _step = _TransferStep.phone;
  final _phoneController = TextEditingController(text: '+221');
  final _formKey = GlobalKey<FormState>();
  String _amountInput = '';

  static const int _maxAmountDigits = 9;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateRecipient(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le numéro du destinataire est requis';
    final regex = RegExp(r'^\+221\d{9}$');
    if (!regex.hasMatch(value.trim())) return 'Format attendu : +221XXXXXXXXX';

    final myPhone = context.read<AuthProvider>().phone;
    if (value.trim() == myPhone) return 'Vous ne pouvez pas vous transférer à vous-même';
    return null;
  }

  void _goToAmountStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = _TransferStep.amount);
  }

  void _onDigit(String digit) {
    if (_amountInput.length >= _maxAmountDigits) return;
    setState(() => _amountInput += digit);
  }

  void _onBackspace() {
    if (_amountInput.isEmpty) return;
    setState(() => _amountInput = _amountInput.substring(0, _amountInput.length - 1));
  }

  double get _amountValue => double.tryParse(_amountInput.isEmpty ? '0' : _amountInput) ?? 0;

  Future<void> _onContinuePressed() async {
    final wallet = context.read<WalletProvider>().wallet;
    final amount = _amountValue;

    if (amount <= 0) {
      _showSnack('Entrez un montant valide', isError: true);
      return;
    }
    if (wallet != null && amount > wallet.balance) {
      _showSnack('Solde insuffisant pour ce transfert', isError: true);
      return;
    }

    final confirmed = await _showConfirmationSheet(amount);
    if (confirmed != true) return;
    if (!mounted) return;

    await _executeTransfer(amount);
  }

  Future<bool?> _showConfirmationSheet(double amount) {
    final recipient = _phoneController.text.trim();
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
                child: const Icon(Icons.send_rounded, color: AppTheme.primary, size: 30),
              ),
              const SizedBox(height: 20),
              Text('Confirmer le transfert', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildSummaryRow('Destinataire', recipient),
              const Divider(height: 28),
              _buildSummaryRow('Montant', AppFormatters.currency(amount), highlight: true),
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
                      child: const Text('Confirmer'),
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

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: highlight ? 20 : 15,
            color: highlight ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _executeTransfer(double amount) async {
    final authProvider = context.read<AuthProvider>();
    final transferProvider = context.read<TransferProvider>();
    final myPhone = authProvider.phone!;
    final recipient = _phoneController.text.trim();

    final success = await transferProvider.sendTransfer(
      senderPhone: myPhone,
      receiverPhone: recipient,
      amount: amount,
    );

    if (!mounted) return;

    if (success) {
      await context.read<WalletProvider>().silentRefresh(myPhone);
      if (!mounted) return;
      _showSuccessDialog(amount, recipient);
    } else {
      _showSnack(transferProvider.errorMessage ?? 'Le transfert a échoué', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppTheme.danger : AppTheme.success),
    );
  }

  Future<void> _showSuccessDialog(double amount, String recipient) async {
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
            Text('Transfert réussi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${AppFormatters.currency(amount)} envoyés à $recipient',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Terminé'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transferProvider = context.watch<TransferProvider>();
    final isLoading = transferProvider.status == TransferStatus.loading;
    final wallet = context.watch<WalletProvider>().wallet;

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == _TransferStep.phone ? 'Transférer' : 'Montant à envoyer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step == _TransferStep.amount) {
              setState(() => _step = _TransferStep.phone);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: _step == _TransferStep.phone ? _buildPhoneStep() : _buildAmountStep(wallet?.balance, isLoading),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('À qui voulez-vous envoyer de l\'argent ?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _validateRecipient,
              decoration: const InputDecoration(
                labelText: 'Numéro du destinataire',
                hintText: '+221770000002',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _goToAmountStep, child: const Text('Suivant')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountStep(double? balance, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text('Envoi à ${_phoneController.text.trim()}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            _amountInput.isEmpty ? '0 XOF' : AppFormatters.currency(_amountValue),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -1),
          ),
          if (balance != null) ...[
            const SizedBox(height: 6),
            Text('Solde disponible : ${AppFormatters.currency(balance)}', style: Theme.of(context).textTheme.bodyMedium),
          ],
          const Spacer(),
          _buildNumpad(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onContinuePressed,
              child: isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Continuer'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 60);
              final isBackspace = key == '⌫';
              return SizedBox(
                width: 72,
                height: 60,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () => isBackspace ? _onBackspace() : _onDigit(key),
                    child: Center(
                      child: isBackspace
                          ? const Icon(Icons.backspace_outlined, size: 22)
                          : Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}