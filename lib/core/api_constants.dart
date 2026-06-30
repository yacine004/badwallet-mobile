class ApiConstants {
  // localhost : pour tester sur Chrome (web) en attendant que l'émulateur
  // Android soit disponible. Si je repasses sur émulateur Android,
  // je dois remplacer 'localhost' par '10.0.2.2' dans les deux lignes ci-dessous.
  static const String walletBaseUrl = 'http://localhost:8080';
  static const String paymentBaseUrl = 'http://localhost:8081';

  // --- badwallet-api (8080) ---
  static String walletByPhone(String phone) =>
      '$walletBaseUrl/api/wallets/$phone';
  static String walletBalance(String phone) =>
      '$walletBaseUrl/api/wallets/$phone/balance';
  static String walletTransactions(String phone) =>
      '$walletBaseUrl/api/wallets/$phone/transactions';
  static String get walletTransfer => '$walletBaseUrl/api/wallets/transfer';
  static String get walletWithdraw => '$walletBaseUrl/api/wallets/withdraw';
  static String walletDeposit(int walletId) =>
      '$walletBaseUrl/api/wallets/$walletId/deposit';
  static String get walletPay => '$walletBaseUrl/api/wallets/pay';
  static String get walletPayFactures =>
      '$walletBaseUrl/api/wallets/pay-factures';

  // --- Proxy factures (exposé via 8080) ---
  static String facturesCurrent(String walletCode, {String? unite}) {
    final base = '$walletBaseUrl/api/external/factures/$walletCode/current';
    return unite != null ? '$base?unite=$unite' : base;
  }

  static String facturesPeriode(String walletCode, String debut, String fin) =>
      '$walletBaseUrl/api/external/factures/$walletCode/periode?debut=$debut&fin=$fin';

  // Liste des fournisseurs proposés par l'app (le sujet en cite 4)
  static const List<String> fournisseurs = [
    'ISM',
    'WOYAFAL',
    'RAPIDO',
    'SENELEC'
  ];
}
