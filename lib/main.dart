import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const AdvancedCalculatorApp());
}

class AdvancedCalculatorApp extends StatelessWidget {
  const AdvancedCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'آلة حاسبة علمية',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _result = "0";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "0";
      } else if (value == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "=") {
        _calculateResult();
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      String parsed = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', math.pi.toString())
          .replaceAll('e', math.e.toString());

      parsed = parsed.replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) {
        double val = double.parse(match.group(1)!);
        return math.sin(val * math.pi / 180).toString();
      });

      parsed = parsed.replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) {
        double val = double.parse(match.group(1)!);
        return math.cos(val * math.pi / 180).toString();
      });

      parsed = parsed.replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) {
        double val = double.parse(match.group(1)!);
        return math.tan(val * math.pi / 180).toString();
      });

      parsed = parsed.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (match) {
        double val = double.parse(match.group(1)!);
        return math.sqrt(val).toString();
      });

      parsed = parsed.replaceAllMapped(RegExp(r'ln\(([^)]+)\)'), (match) {
        double val = double.parse(match.group(1)!);
        return math.log(val).toString();
      });

      _result = _simpleEvaluate(parsed);
    } catch (e) {
      _result = "خطأ في المعادلة";
    }
  }

  String _simpleEvaluate(String expr) {
    try {
      List<String> tokens = [];
      String numberBuffer = "";

      for (int i = 0; i < expr.length; i++) {
        String char = expr[i];
        if ("+-*/^".contains(char)) {
          if (numberBuffer.isNotEmpty) {
            tokens.add(numberBuffer);
            numberBuffer = "";
          }
          tokens.add(char);
        } else {
          numberBuffer += char;
        }
      }
      if (numberBuffer.isNotEmpty) tokens.add(numberBuffer);

      if (tokens.isEmpty) return "0";

      double res = double.parse(tokens[0]);
      for (int i = 1; i < tokens.length; i += 2) {
        String op = tokens[i];
        double nextNum = double.parse(tokens[i + 1]);
        if (op == "+") res += nextNum;
        if (op == "-") res -= nextNum;
        if (op == "*") res *= nextNum;
        if (op == "/") res = nextNum != 0 ? res / nextNum : 0;
        if (op == "^") res = math.pow(res, nextNum).toDouble();
      }

      String resStr = res.toString();
      if (resStr.endsWith(".0")) {
        resStr = resStr.substring(0, resStr.length - 2);
      }
      return resStr;
    } catch (e) {
      return "خطأ";
    }
  }

  Widget _buildCapsuleButton(String text, {bool isGold = false, bool isAccent = false}) {
    List<Color> borderGradient = isGold
        ? [const Color(0xFFD4AF37), const Color(0xFF8B6508)]
        : [const Color(0xFFB8860B), const Color(0xFF553C00)];

    Color btnColor = isGold
        ? const Color(0xFF8B6508)
        : isAccent
            ? const Color(0xFF1E293B)
            : const Color(0xFF111827);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: borderGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(28.5),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _onButtonPressed(text),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isGold ? Colors.amber[100] : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('آلة حاسبة علمية',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? "0" : _expression,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCapsuleButton("sin(", isAccent: true),
                      _buildCapsuleButton("cos(", isAccent: true),
                      _buildCapsuleButton("tan(", isAccent: true),
                      _buildCapsuleButton("^", isAccent: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("√(", isAccent: true),
                      _buildCapsuleButton("ln(", isAccent: true),
                      _buildCapsuleButton("π", isAccent: true),
                      _buildCapsuleButton("e", isAccent: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("C", isGold: true),
                      _buildCapsuleButton("⌫", isGold: true),
                      _buildCapsuleButton("÷", isAccent: true),
                      _buildCapsuleButton("×", isAccent: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("7"),
                      _buildCapsuleButton("8"),
                      _buildCapsuleButton("9"),
                      _buildCapsuleButton("-", isAccent: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("4"),
                      _buildCapsuleButton("5"),
                      _buildCapsuleButton("6"),
                      _buildCapsuleButton("+", isAccent: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("1"),
                      _buildCapsuleButton("2"),
                      _buildCapsuleButton("3"),
                      _buildCapsuleButton("=", isGold: true),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCapsuleButton("0"),
                      _buildCapsuleButton("."),
                      _buildCapsuleButton("("),
                      _buildCapsuleButton(")"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
