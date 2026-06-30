## Fonctionnalités

- **Authentification simulée** : saisie du numéro de téléphone (vérifié auprès du backend), puis création d'un code PIN local à 4 chiffres pour sécuriser l'accès à l'application.
- **Tableau de bord** : solde du portefeuille (masquable), accès rapide aux transferts, paiements et historique, liste des 5 dernières transactions.
- **Transfert d'argent** : saisie du destinataire, pavé numérique pour le montant, vérification du solde, BottomSheet de confirmation avant envoi.
- **Paiement de factures** : sélection d'un fournisseur, liste des factures impayées du mois en cours, sélection multiple par cases à cocher, paiement en lot.
- **Historique** : liste complète des transactions avec filtres par type (Dépôts, Retraits, Transferts, Paiements) et code couleur (vert pour les entrées, rouge pour les sorties).

## Configuration réseau

L'URL de base de l'API s'adapte automatiquement selon la plateforme (`lib/core/api_constants.dart`) :

- **Web (Chrome)** : `http://localhost:8080`
- **Android (émulateur ou appareil physique)** : adresse IP locale du PC sur le réseau Wi-Fi

Pour tester sur un appareil Android physique, le téléphone et l'ordinateur hébergeant le backend doivent être connectés au même réseau Wi-Fi, et le pare-feu doit autoriser les connexions entrantes sur les ports 8080 et 8081.

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Générer l'APK

```bash
flutter build apk --release
```

L'exécutable est généré dans `build/app/outputs/flutter-apk/app-release.apk`.