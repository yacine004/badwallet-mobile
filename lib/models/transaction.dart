class AppTransaction {
  final int id;
  final String type; // TRANSFER, DEPOSIT, WITHDRAW, PAYMENT
  final double amount;
  final String senderPhone;
  final String receiverPhone;
  final String? description;
  final DateTime createdAt;

  AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.senderPhone,
    required this.receiverPhone,
    required this.createdAt,
    this.description,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'UNKNOWN',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      senderPhone: json['senderPhone'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String?,
    );
  }

  /// Vrai si l'opération réduit le solde du compte connecté (myPhone).
  /// DEPOSIT = toujours entrant. WITHDRAW/PAYMENT = toujours sortant.
  /// TRANSFER = sortant si je suis l'émetteur (sender == myPhone), entrant sinon.
  bool isOutgoing(String myPhone) {
    switch (type) {
      case 'DEPOSIT':
        return false;
      case 'WITHDRAW':
      case 'PAYMENT':
        return true;
      case 'TRANSFER':
        return senderPhone == myPhone;
      default:
        return true;
    }
  }

  /// Le numéro / nom à afficher comme "correspondant" de l'opération.
  String counterparty(String myPhone) {
    switch (type) {
      case 'DEPOSIT':
      case 'WITHDRAW':
        return 'Mon compte';
      case 'PAYMENT':
        return receiverPhone; // ex: "ISM"
      case 'TRANSFER':
        return senderPhone == myPhone ? receiverPhone : senderPhone;
      default:
        return receiverPhone;
    }
  }
}