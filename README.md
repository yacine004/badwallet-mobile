# BadWallet Mobile

Application mobile Flutter pour la gestion d'un portefeuille électronique BadWallet — consultation du solde, transferts d'argent, paiement de factures et historique des transactions.

## Stack technique

- **Flutter** / **Dart**
- **Provider** pour la gestion d'état (Loading / Loaded / Error)
- **http** pour la communication avec l'API REST
- **flutter_secure_storage** pour la session locale (téléphone, code wallet, PIN)
- **intl** pour le formatage des montants (XOF) et des dates en français

## Backend requis

L'application consomme deux microservices Spring Boot qui doivent être lancés en local avant d'utiliser l'app :

| Service | Port | Rôle |
|---|---|---|
| `badwallet-api` | 8080 | Wallets, transactions, transferts, paiements |
| `payment-service` | 8081 | Factures (ISM, WOYAFAL, RAPIDO, SENELEC) |

## Architecture du projet
lib/
├── core/                    # Constantes API, client HTTP, thème, formatters
├── models/                  # Wallet, AppTransaction, Facture
├── features/
│   ├── auth/                 # Splash, saisie téléphone, création/vérification PIN
│   ├── dashboard/             # Solde, actions rapides, dernières transactions
│   ├── transfers/             # Transfert d'argent (pavé numérique + confirmation)
│   ├── bills/                 # Paiement de factures (sélection multiple)
│   └── history/               # Historique complet avec filtres par type
└── main.dart                 # Point d'entrée, configuration des Providers

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

## Numéros de test

Les numéros suivants existent dans la base de données seedée et permettent de tester l'ensemble des fonctionnalités (solde suffisant, factures ISM et WOYAFAL impayées disponibles) :

- `+221770000005`
- `+221770000007`