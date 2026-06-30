class Facture {
  final int id;
  final String reference;
  final String walletCode;
  final String unite; // ISM, WOYAFAL, RAPIDO, SENELEC...
  final double montant;
  final String statut; // IMPAYEE, PAYEE...
  final DateTime? mois;

  Facture({
    required this.id,
    required this.reference,
    required this.walletCode,
    required this.unite,
    required this.montant,
    required this.statut,
    this.mois,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      walletCode: json['walletCode'] as String? ?? '',
      unite: json['unite'] as String? ?? '',
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      statut: json['statut'] as String? ?? 'IMPAYEE',
      mois: DateTime.tryParse(json['mois'] as String? ?? ''),
    );
  }

  bool get isPaid => statut.toUpperCase() == 'PAYEE';
}