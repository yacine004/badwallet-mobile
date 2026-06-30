import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../models/facture.dart';

class BillsService {
  Future<List<Facture>> getCurrentFactures(String walletCode, {String? unite}) async {
    final json = await ApiClient.get(ApiConstants.facturesCurrent(walletCode, unite: unite));
    final list = json as List<dynamic>;
    return list.map((e) => Facture.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Paiement en lot par références précises (sujet : sélection multiple + checkboxes).
  Future<void> payFactures({
    required String phoneNumber,
    required String serviceName,
    required List<String> factureReferences,
  }) async {
    await ApiClient.post(ApiConstants.walletPayFactures, body: {
      'phoneNumber': phoneNumber,
      'serviceName': serviceName,
      'factureReferences': factureReferences,
    });
  }
}