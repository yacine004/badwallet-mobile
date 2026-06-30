import 'package:flutter/foundation.dart';
import '../../core/api_exception.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import 'wallet_service.dart';

enum WalletStatus { idle, loading, loaded, error }

/// Provider central du Dashboard : solde + transactions.
/// Exposé à toute l'app pour que Transfert/Factures puissent
/// déclencher un refresh après une opération réussie.
class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  WalletStatus status = WalletStatus.idle;
  String? errorMessage;
  Wallet? wallet;
  List<AppTransaction> transactions = [];

  List<AppTransaction> get recentTransactions => transactions.take(5).toList();

  Future<void> loadDashboard(String phone) async {
    status = WalletStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getWallet(phone),
        _service.getTransactions(phone),
      ]);
      wallet = results[0] as Wallet;
      final txs = results[1] as List<AppTransaction>;
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      transactions = txs;
      status = WalletStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = WalletStatus.error;
    } catch (e) {
      errorMessage = 'Une erreur inattendue est survenue.';
      status = WalletStatus.error;
    }
    notifyListeners();
  }

  /// Rafraîchit juste le solde + transactions sans repasser par l'état loading
  /// (utile après une opération réussie pour ne pas faire clignoter l'UI).
  Future<void> silentRefresh(String phone) async {
    try {
      final results = await Future.wait([
        _service.getWallet(phone),
        _service.getTransactions(phone),
      ]);
      wallet = results[0] as Wallet;
      final txs = results[1] as List<AppTransaction>;
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      transactions = txs;
      notifyListeners();
    } catch (_) {
      // silencieux : on ne casse pas l'UI sur un refresh en arrière-plan
    }
  }
}