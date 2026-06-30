import 'package:flutter/foundation.dart';
import '../../core/api_exception.dart';
import '../../models/facture.dart';
import 'bills_service.dart';

enum BillsStatus { idle, loading, loaded, error }
enum PaymentStatus { idle, loading, success, error }

class BillsProvider extends ChangeNotifier {
  final BillsService _service = BillsService();

  BillsStatus status = BillsStatus.idle;
  String? errorMessage;
  List<Facture> factures = [];
  final Set<String> selectedReferences = {};

  PaymentStatus paymentStatus = PaymentStatus.idle;
  String? paymentError;

  double get selectedTotal =>
      factures.where((f) => selectedReferences.contains(f.reference)).fold(0.0, (sum, f) => sum + f.montant);

  Future<void> loadFactures(String walletCode, String unite) async {
    status = BillsStatus.loading;
    errorMessage = null;
    selectedReferences.clear();
    notifyListeners();

    try {
      factures = await _service.getCurrentFactures(walletCode, unite: unite);
      status = BillsStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = BillsStatus.error;
    } catch (e) {
      errorMessage = 'Une erreur inattendue est survenue.';
      status = BillsStatus.error;
    }
    notifyListeners();
  }

  void toggleSelection(String reference) {
    if (selectedReferences.contains(reference)) {
      selectedReferences.remove(reference);
    } else {
      selectedReferences.add(reference);
    }
    notifyListeners();
  }

  Future<bool> payFactures({required String phoneNumber, required String serviceName}) async {
    if (selectedReferences.isEmpty) return false;

    paymentStatus = PaymentStatus.loading;
    paymentError = null;
    notifyListeners();

    try {
      await _service.payFactures(
        phoneNumber: phoneNumber,
        serviceName: serviceName,
        factureReferences: selectedReferences.toList(),
      );
      paymentStatus = PaymentStatus.success;
      factures = factures.where((f) => !selectedReferences.contains(f.reference)).toList();
      selectedReferences.clear();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      paymentError = e.message;
      paymentStatus = PaymentStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      paymentError = 'Une erreur inattendue est survenue.';
      paymentStatus = PaymentStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetPaymentStatus() {
    paymentStatus = PaymentStatus.idle;
    paymentError = null;
  }
}