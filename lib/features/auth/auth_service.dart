import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../../models/wallet.dart';

/// Service Auth : gère la session locale (téléphone + code wallet + PIN).
/// Le PIN est simulé en local uniquement, il n'y a pas d'endpoint backend
/// dédié à l'authentification — la "vérité" reste GET /api/wallets/{phone}.
class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _keyPhone = 'user_phone';
  static const _keyWalletCode = 'user_wallet_code';
  static const _keyWalletId = 'user_wallet_id';
  static const _keyPin = 'user_pin';

  /// Vérifie que le numéro existe côté backend et retourne le Wallet associé.
  /// Lève une ApiException si le numéro n'existe pas (404/500).
  Future<Wallet> verifyPhoneNumber(String phone) async {
    final json = await ApiClient.get(ApiConstants.walletByPhone(phone));
    return Wallet.fromJson(json as Map<String, dynamic>);
  }

  /// Sauvegarde la session locale après vérification réussie du numéro.
  Future<void> saveSession(Wallet wallet) async {
    await _storage.write(key: _keyPhone, value: wallet.phoneNumber);
    await _storage.write(key: _keyWalletCode, value: wallet.code);
    await _storage.write(key: _keyWalletId, value: wallet.id.toString());
  }

  Future<void> savePin(String pin) async {
    await _storage.write(key: _keyPin, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final saved = await _storage.read(key: _keyPin);
    return saved != null && saved == pin;
  }

  Future<bool> hasPin() async {
    final saved = await _storage.read(key: _keyPin);
    return saved != null;
  }

  Future<String?> getPhone() => _storage.read(key: _keyPhone);
  Future<String?> getWalletCode() => _storage.read(key: _keyWalletCode);
  Future<int?> getWalletId() async {
    final raw = await _storage.read(key: _keyWalletId);
    return raw != null ? int.tryParse(raw) : null;
  }

  /// Vrai si une session existe déjà (numéro déjà vérifié une fois).
  Future<bool> hasSession() async {
    final phone = await getPhone();
    return phone != null && phone.isNotEmpty;
  }

  /// Déconnexion complète : efface tout (numéro, code wallet, PIN).
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}