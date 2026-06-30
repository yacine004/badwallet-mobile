class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  /// Construit un message utilisateur clair à partir d'un code de statut HTTP.
  /// Le backend ne renvoie pas toujours de message métier exploitable
  /// (ex: 500 générique "Internal Server Error" sans détail), donc on
  /// mappe nous-mêmes des messages compréhensibles côté app.
  factory ApiException.fromStatusCode(int statusCode, {String? rawBody}) {
    switch (statusCode) {
      case 400:
        return ApiException('Requête invalide. Vérifiez les informations saisies.', statusCode: statusCode);
      case 404:
        return ApiException('Introuvable. Vérifiez le numéro ou la référence saisie.', statusCode: statusCode);
      case 500:
        return ApiException(
          'Une erreur est survenue. Vérifiez que le numéro existe et que le solde est suffisant.',
          statusCode: statusCode,
        );
      default:
        return ApiException('Erreur réseau (code $statusCode). Réessayez.', statusCode: statusCode);
    }
  }
}