//*************************************************************************
// Fichier          : main.dart
// Description      : Calculer promos Frais Malin.
// Auteur           : MikEarpp@gmail.com
// Date             : 2024-08-09
// Version          : 0.1
// License          : BSD 3-Clause License
//*************************************************************************
import "package:flutter/material.dart";
import "package:flutter/services.dart";

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
        title: "Frais Malin",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
        darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
        themeMode: ThemeMode.system,
        home: const ReductionCalculator(),
        routes: {"/about": (context) => const AboutPage()});
  }
}

class ReductionCalculator extends StatefulWidget {
  const ReductionCalculator({super.key});

  @override
  ReductionCalculatorState createState() => ReductionCalculatorState();
}

class ReductionCalculatorState extends State<ReductionCalculator> {
  final TextEditingController _priceController = TextEditingController();
  final double _fontSize = 20;
  final List<double> _discountOptions = [30, 40, 50, 68, 75];
  double _selectedDiscount = 50;
  double _prixproduit = 0;
  double _prix2produits = 0;
  double _saving = 0;

  void _calculate() {
    FocusScope.of(context).unfocus();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    setState(() {
      _saving = price * _selectedDiscount / 100;
      _prixproduit = price - _saving;
      _prix2produits = price * 2 - _saving;
    });
  }

  List<Widget> printValue(String prefix, double value, [Color? color]) => [
        Padding(
            padding: EdgeInsets.only(top: _fontSize, bottom: _fontSize),
            child: Text("$prefix: ${value.toStringAsFixed(2).replaceFirst(".00", "")} €",
                style:
                    TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: color ?? const Color.fromRGBO(255, 255, 255, 1.0))))
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text("Frais Malin"),
          actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: () => Navigator.pushNamed(context, "/about"))]),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_fontSize),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(_fontSize * 4, _fontSize, _fontSize * 4, _fontSize),
                  child: TextField(
                      controller: _priceController,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]")), _DecimalTextInputFormatter()],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Prix du produit",
                          labelStyle: TextStyle(fontSize: 18.0),
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      style: TextStyle(fontSize: _fontSize * 1.3, fontWeight: FontWeight.bold),
                      onSubmitted: (value) => _calculate())),
              DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                    iconSize: 50,
                    itemHeight: 100.0,
                    alignment: AlignmentDirectional.center,
                    value: _selectedDiscount,
                    onChanged: (double? newValue) => setState(() {
                          _selectedDiscount = newValue!;
                          _calculate();
                        }),
                    items: _discountOptions
                        .map<DropdownMenuItem<double>>((double value) => DropdownMenuItem<double>(
                            value: value,
                            child: Text("-${value.round().toString()}%",
                                style: TextStyle(
                                    color: const Color.fromRGBO(21, 60, 137, 1.0),
                                    fontSize: _fontSize * 1.6,
                                    fontWeight: FontWeight.bold))))
                        .toList()),
              ),
              ...printValue("Promo un produit", _prixproduit),
              ...printValue("Sur le deuxieme", _prix2produits),
              ...printValue("Économie", _saving, const Color.fromRGBO(230, 0, 100, 1.0))
            ]),
            Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/logo.png"), fit: BoxFit.cover))),
          ]),
        ),
      ));
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(",", ".");
    final match = RegExp(r"(\d*\.?\d{0,2})").firstMatch(newText);
    if (match != null) newText = match.group(0) ?? "";
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("À propos")),
      body: const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Frais Malin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(
                    "Calculer facilement les réductions sur les produits en promotion.\n\n"
                    "Auteur: MikEarpp@gmail.com\nDate: 2024-08-09\nVersion: 0.1\nLicense: BSD 3-Clause",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16))
              ]))));
}
