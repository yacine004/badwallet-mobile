import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // --- IMPORTANT : adresse de la machine hôte (ton PC) selon la plateforme ---
  // - Web (Chrome) : 'localhost' fonctionne directement.
  // - Android (émulateur OU téléphone physique en Wi-Fi) : il faut l'IP locale
  //   du PC sur le réseau, car 'localhost' pointerait vers le téléphone lui-même.
  //   Trouve cette IP avec `ipconfig` (ligne "Adresse IPv4" de ta carte Wi-Fi),
  //   assure-toi que ton PC ET ton téléphone sont sur le MÊME réseau Wi-Fi,
  //   et que le pare-feu Windows autorise les connexions entrantes sur 8080/8081.
  static const String _androidHostIp = '192.168.1.57';

  static String get _host => kIsWeb ? 'localhost' : _androidHostIp;

  static String get walletBaseUrl => 'http://$_host:8080';
  static String get paymentBaseUrl => 'http://$_host:8081';

  // --- badwallet-api (8080) ---
  static String walletByPhone(String phone) => '$walletBaseUrl/api/wallets/$phone';
  static String walletBalance(String phone) => '$walletBaseUrl/api/wallets/$phone/balance';
  static String walletTransactions(String phone) => '$walletBaseUrl/api/wallets/$phone/transactions';
  static String get walletTransfer => '$walletBaseUrl/api/wallets/transfer';
  static String get walletWithdraw => '$walletBaseUrl/api/wallets/withdraw';
  static String walletDeposit(int walletId) => '$walletBaseUrl/api/wallets/$walletId/deposit';
  static String get walletPay => '$walletBaseUrl/api/wallets/pay';
  static String get walletPayFactures => '$walletBaseUrl/api/wallets/pay-factures';

  // --- Proxy factures (exposé via 8080) ---
  static String facturesCurrent(String walletCode, {String? unite}) {
    final base = '$walletBaseUrl/api/external/factures/$walletCode/current';
    return unite != null ? '$base?unite=$unite' : base;
  }

  static String facturesPeriode(String walletCode, String debut, String fin) =>
      '$walletBaseUrl/api/external/factures/$walletCode/periode?debut=$debut&fin=$fin';

  // Liste des fournisseurs proposés par l'app (le sujet en cite 4)
  static const List<String> fournisseurs = ['ISM', 'WOYAFAL', 'RAPIDO', 'SENELEC'];
}