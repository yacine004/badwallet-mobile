import 'package:flutter/foundation.dart';
import '../../core/api_exception.dart';
import '../../models/wallet.dart';
import 'auth_service.dart';

enum AuthStatus { idle, loading, loaded, error }

/// Provider Auth : expose l'état Loading/Loaded/Error attendu par le sujet,
/// et garde en mémoire la session active (phone, code, id) pendant
/// toute la durée de vie de l'app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;
  Wallet? currentWallet;

  String? get phone => currentWallet?.phoneNumber;
  String? get walletCode => currentWallet?.code;
  int? get walletId => currentWallet?.id;

  /// Étape 1 : vérifie le numéro auprès du backend.
  Future<bool> verifyPhone(String phone) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final wallet = await _authService.verifyPhoneNumber(phone);
      currentWallet = wallet;
      await _authService.saveSession(wallet);
      status = AuthStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Une erreur inattendue est survenue.';
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    await _authService.savePin(pin);
  }

  Future<bool> checkPin(String pin) async {
    return _authService.verifyPin(pin);
  }

  Future<bool> hasPin() => _authService.hasPin();

  /// Restaure une session existante (au démarrage de l'app, après Splash).
  Future<bool> restoreSession() async {
    final hasSession = await _authService.hasSession();
    if (!hasSession) return false;

    final phone = await _authService.getPhone();
    final code = await _authService.getWalletCode();
    final id = await _authService.getWalletId();
    if (phone == null || code == null || id == null) return false;

    // On reconstruit un Wallet minimal depuis le stockage local ;
    // le solde sera re-fetché par le Dashboard au chargement.
    currentWallet = Wallet(id: id, phoneNumber: phone, email: '', balance: 0, code: code, currency: 'XOF');
    status = AuthStatus.loaded;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    currentWallet = null;
    status = AuthStatus.idle;
    notifyListeners();
  }
}