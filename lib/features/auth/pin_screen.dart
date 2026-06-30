import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import 'auth_provider.dart';
import '../dashboard/dashboard_screen.dart';

enum PinMode { create, verify }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  const PinScreen({super.key, required this.mode});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String? _firstPin; // pour la double saisie en mode création
  String? _error;
  bool _confirming = false;

  static const int _pinLength = 4;

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == _pinLength) {
      _handleComplete();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _handleComplete() async {
    if (widget.mode == PinMode.verify) {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.checkPin(_pin);
      if (!mounted) return;
      if (ok) {
        _goToDashboard();
      } else {
        setState(() {
          _error = 'Code PIN incorrect';
          _pin = '';
        });
      }
      return;
    }

    // Mode création : première saisie puis confirmation
    if (!_confirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _confirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.setPin(_pin);
        if (!mounted) return;
        _goToDashboard();
      } else {
        setState(() {
          _error = 'Les codes ne correspondent pas, réessayez';
          _pin = '';
          _firstPin = null;
          _confirming = false;
        });
      }
    }
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  String get _title {
    if (widget.mode == PinMode.verify) return 'Entrez votre code PIN';
    return _confirming ? 'Confirmez votre code PIN' : 'Créez votre code PIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(_title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Code à 4 chiffres pour sécuriser votre application',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppTheme.primary : Colors.transparent,
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600)),
              ],
              const Spacer(),
              _buildNumpad(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 64);
              final isBackspace = key == '⌫';
              return SizedBox(
                width: 72,
                height: 64,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(36),
                    onTap: () => isBackspace ? _onBackspace() : _onDigit(key),
                    child: Center(
                      child: isBackspace
                          ? const Icon(Icons.backspace_outlined, size: 24)
                          : Text(key, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}