import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Instant Panic Camouflage screen.
///
/// In emergencies (e.g. domestic disputes, family violence inquiry),
/// this screen instantly disguises the app as a realistic, fully functioning
/// basic calculator.
class CalculatorCamoScreen extends StatefulWidget {
  const CalculatorCamoScreen({super.key});

  @override
  State<CalculatorCamoScreen> createState() => _CalculatorCamoScreenState();
}

class _CalculatorCamoScreenState extends State<CalculatorCamoScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  int _acTapCount = 0;
  DateTime? _lastAcTap;

  void _onDigit(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else if (_display.length < 10) {
        _display += digit;
      }
    });
  }

  void _onOperator(String op) {
    HapticFeedback.lightImpact();
    setState(() {
      _firstOperand = double.tryParse(_display);
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onEquals() {
    HapticFeedback.mediumImpact();
    if (_firstOperand == null || _operator == null) return;
    final double? second = double.tryParse(_display);
    if (second == null) return;

    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + second;
        break;
      case '-':
        result = _firstOperand! - second;
        break;
      case '×':
        result = _firstOperand! * second;
        break;
      case '÷':
        result = second != 0 ? _firstOperand! / second : 0;
        break;
    }

    setState(() {
      _display = result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(2);
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    final DateTime now = DateTime.now();
    if (_lastAcTap != null &&
        now.difference(_lastAcTap!).inMilliseconds < 600) {
      _acTapCount++;
      if (_acTapCount >= 3) {
        // Exit camouflage mode cleanly back to app
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        return;
      }
    } else {
      _acTapCount = 1;
    }
    _lastAcTap = now;

    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _press(String key) {
    if (RegExp(r'^[0-9]$').hasMatch(key)) {
      _onDigit(key);
      return;
    }
    switch (key) {
      case 'AC':
        _onClear();
      case '=':
        _onEquals();
      case '+/-':
        setState(
          () => _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display',
        );
      case '%':
        setState(
          () => _display = ((double.tryParse(_display) ?? 0) / 100).toString(),
        );
      case '.':
        if (_shouldResetDisplay) {
          setState(() {
            _display = '0.';
            _shouldResetDisplay = false;
          });
        } else if (!_display.contains('.')) {
          setState(() => _display += '.');
        }
      default:
        _onOperator(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      'AC',
      '+/-',
      '%',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '-',
      '1',
      '2',
      '3',
      '+',
      '0',
      '.',
      '=',
    ];
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _display,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: keys.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent:
                              (constraints.maxHeight * 5 / 7 - 24) / 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 0,
                        ),
                        itemBuilder: (context, index) {
                          final key = keys[index];
                          final operator = [
                            '÷',
                            '×',
                            '-',
                            '+',
                            '=',
                          ].contains(key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: operator
                                    ? const Color(0xFFFF9F0A)
                                    : const Color(0xFF2C2C2E),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => _press(key),
                              child: FittedBox(
                                child: Text(
                                  key,
                                  style: const TextStyle(fontSize: 26),
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
          ),
        ),
      ),
    );
  }
}
