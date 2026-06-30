import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/api_constants.dart';
import 'bill_provider_detail_screen.dart';

/// Écran 1 : liste des fournisseurs (ISM, WOYAFAL, RAPIDO, SENELEC).
class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  static const Map<String, IconData> _icons = {
    'ISM': Icons.school_rounded,
    'WOYAFAL': Icons.bolt_rounded,
    'RAPIDO': Icons.local_shipping_rounded,
    'SENELEC': Icons.flash_on_rounded,
  };

  static const Map<String, Color> _colors = {
    'ISM': Color(0xFF1565C0),
    'WOYAFAL': Color(0xFFE65100),
    'RAPIDO': Color(0xFF6A1B9A),
    'SENELEC': Color(0xFF2E7D32),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payer une facture')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisissez un fournisseur', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: ApiConstants.fournisseurs.length,
                  itemBuilder: (context, index) {
                    final fournisseur = ApiConstants.fournisseurs[index];
                    final color = _colors[fournisseur] ?? AppTheme.primary;
                    final icon = _icons[fournisseur] ?? Icons.receipt_long_rounded;

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BillProviderDetailScreen(fournisseur: fournisseur)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                                child: Icon(icon, color: color, size: 26),
                              ),
                              const SizedBox(height: 12),
                              Text(fournisseur, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}