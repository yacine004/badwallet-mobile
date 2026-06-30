import 'package:flutter/foundation.dart';
import '../../core/api_exception.dart';
import '../dashboard/wallet_service.dart';

enum TransferStatus { idle, loading, success, error }

class TransferProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  TransferStatus status = TransferStatus.idle;
  String? errorMessage;

  Future<bool> sendTransfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    status = TransferStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.transfer(senderPhone: senderPhone, receiverPhone: receiverPhone, amount: amount);
      status = TransferStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = TransferStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Une erreur inattendue est survenue.';
      status = TransferStatus.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    status = TransferStatus.idle;
    errorMessage = null;
  }
}