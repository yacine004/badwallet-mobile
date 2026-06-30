import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_formatters.dart';
import '../../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction transaction;
  final String myPhone;

  const TransactionTile({super.key, required this.transaction, required this.myPhone});

  IconData get _icon {
    switch (transaction.type) {
      case 'DEPOSIT':
        return Icons.arrow_downward_rounded;
      case 'WITHDRAW':
        return Icons.arrow_upward_rounded;
      case 'PAYMENT':
        return Icons.receipt_long_rounded;
      case 'TRANSFER':
        return transaction.isOutgoing(myPhone) ? Icons.north_east_rounded : Icons.south_west_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String get _label {
    switch (transaction.type) {
      case 'DEPOSIT':
        return 'Dépôt';
      case 'WITHDRAW':
        return 'Retrait';
      case 'PAYMENT':
        return 'Paiement ${transaction.receiverPhone}';
      case 'TRANSFER':
        final outgoing = transaction.isOutgoing(myPhone);
        return outgoing ? 'Envoyé à ${transaction.receiverPhone}' : 'Reçu de ${transaction.senderPhone}';
      default:
        return transaction.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outgoing = transaction.isOutgoing(myPhone);
    final color = outgoing ? AppTheme.danger : AppTheme.success;
    final sign = outgoing ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(AppFormatters.dateTime(transaction.createdAt), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            '$sign${AppFormatters.currency(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}