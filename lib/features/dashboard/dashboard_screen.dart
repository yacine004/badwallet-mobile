import 'package:flutter/material.dart';

/// Version temporaire minimale — sera enrichie au bloc suivant
/// (solde, transactions, actions rapides).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: const Center(child: Text('Dashboard à venir')),
    );
  }
}