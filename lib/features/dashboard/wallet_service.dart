import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

class WalletService {
  Future<Wallet> getWallet(String phone) async {
    final json = await ApiClient.get(ApiConstants.walletByPhone(phone));
    return Wallet.fromJson(json as Map<String, dynamic>);
  }

  Future<List<AppTransaction>> getTransactions(String phone) async {
    final json = await ApiClient.get(ApiConstants.walletTransactions(phone));
    final list = json as List<dynamic>;
    return list.map((e) => AppTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> transfer({required String senderPhone, required String receiverPhone, required double amount}) async {
    await ApiClient.post(ApiConstants.walletTransfer, body: {
      'senderPhone': senderPhone,
      'receiverPhone': receiverPhone,
      'amount': amount,
    });
  }
}