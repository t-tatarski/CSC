import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const DentalShadeApp());
}

class DentalShadeApp extends StatelessWidget {
  const DentalShadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Shade Comparison',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Strona pojedynczego systemu
class SingleSystemPage extends StatefulWidget {
  final String title;
  final ShadeSystem system;

  const SingleSystemPage({
    Key? key,
    required this.title,
    required this.system,
  }) : super(key: key);

  @override
  _SingleSystemPageState createState() => _SingleSystemPageState();
}

class _SingleSystemPageState extends State<SingleSystemPage> {
  late ShadeColor? selectedShade;
  late List<ShadeColor> shades;
  List<Map<String, dynamic>> comparisonResults = [];

  @override
  void initState() {
    super.initState();
    selectedShade = null;
    shades = ShadeData.getShades(widget.system);
  }

  void _updateComparisonResults() {
    if (selectedShade == null) {
      setState(() {
        comparisonResults = [];
      });
      return;
    }

    List<Map<String, dynamic>> results = [];
    
    // Calculate deltaE for all shades relative to selected shade
    for (var shade in shades) {
      if (shade.id != selectedShade!.id) {
        double deltaE = calculateDeltaE(
          selectedShade!.labValues,
          shade.labValues,
        );
        
        results.add({
          'shade': shade,
          'deltaE': deltaE,
          'description': _getDeltaEDescription(deltaE),
        });
      }
    }
    
    // Sort by delta E
    results.sort((a, b) => (a['deltaE'] as double).compareTo(b['deltaE'] as double));
    
    setState(() {
      comparisonResults = results;
    });
  }

  String _getDeltaEDescription(double deltaE) {
    if (deltaE < 1.0) {
      return 'Niezauważalna różnica';
    } else if (deltaE < 2.0) {
      return 'Zauważalna tylko przez doświadczone oko';
    } else if (deltaE < 3.5) {
      return 'Zauważalna przez przeciętne oko';
    } else if (deltaE < 5.0) {
      return 'Wyraźnie zauważalna różnica';
    } else {
      return 'Dwa różne kolory';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wybierz odcień do analizy:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildShadeGrid(),
              const SizedBox(height: 24),
              if (selectedShade != null) _buildSelectedShadeInfo(),
              const SizedBox(height: 16),
              if (comparisonResults.isNotEmpty) _buildComparisonResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShadeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: shades.length,
      itemBuilder: (context, index) {
        final shade = shades[index];
        final isSelected = selectedShade?.id == shade.id;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedShade = shade;
            });
            _updateComparisonResults();
          },
          child: Container(
            decoration: BoxDecoration(
              color: shade.color,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                  child: Text(
                    shade.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedShadeInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wybrany odcień: ${selectedShade!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selectedShade!.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wartości CIE Lab:'),
                    const SizedBox(height: 4),
                    Text('L*: ${selectedShade!.labValues['L']!.toStringAsFixed(1)} (jasność)'),
                    Text('a*: ${selectedShade!.labValues['a']!.toStringAsFixed(1)} (czerwony-zielony)'),
                    Text('b*: ${selectedShade!.labValues['b']!.toStringAsFixed(1)} (żółty-niebieski)'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _updateComparisonResults,
              icon: const Icon(Icons.compare),
              label: const Text('Porównaj z innymi odcieniami'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analiza porównawcza odcieni',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Odcienie posortowane od najbardziej podobnego:'),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comparisonResults.length,
          itemBuilder: (context, index) {
            final result = comparisonResults[index];
            final shade = result['shade'] as ShadeColor;
            final deltaE = result['deltaE'] as double;
            final description = result['description'] as String;
            
            // Określenie koloru indykatora na podstawie deltaE
            Color indicatorColor;
            if (deltaE < 2.0) {
              indicatorColor = Colors.green;
            } else if (deltaE < 3.5) {
              indicatorColor = Colors.amber;
            } else {
              indicatorColor = Colors.red;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: shade.color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shade.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: indicatorColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Delta E: ${deltaE.toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Strona kalkulatora Delta E
class DeltaECalculatorPage extends StatefulWidget {
  const DeltaECalculatorPage({Key? key}) : super(key: key);

  @override
  _DeltaECalculatorPageState createState() => _DeltaECalculatorPageState();
}

class _DeltaECalculatorPageState extends State<DeltaECalculatorPage> {
  final TextEditingController l1Controller = TextEditingController();
  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController b1Controller = TextEditingController();
  final TextEditingController l2Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();
  final TextEditingController b2Controller = TextEditingController();
  
  double? deltaE;
  String? deltaEDescription;
  
  @override
  void dispose() {
    l1Controller.dispose();
    a1Controller.dispose();
    b1Controller.dispose();
    l2Controller.dispose();
    a2Controller.dispose();
    b2Controller.dispose();
    super.dispose();
  }
  
  void _calculateDeltaE() {
    try {
      final l1 = double.parse(l1Controller.text);
      final a1 = double.parse(a1Controller.text);
      final b1 = double.parse(b1Controller.text);
      final l2 = double.parse(l2Controller.text);
      final a2 = double.parse(a2Controller.text);
      final b2 = double.parse(b2Controller.text);
      
      final Map<String, double> lab1 = {'L': l1, 'a': a1, 'b': b1};
      final Map<String, double> lab2 = {'L': l2, 'a': a2, 'b': b2};
      
      final result = calculateDeltaE(lab1, lab2);
      
      setState(() {
        deltaE = result;
        deltaEDescription = _getDeltaEDescription(result);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wprowadź prawidłowe wartości liczbowe!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  String _getDeltaEDescription(double deltaE) {
    if (deltaE < 1.0) {
      return 'Niezauważalna różnica';
    } else if (deltaE < 2.0) {
      return 'Zauważalna tylko przez doświadczone oko';
    } else if (deltaE < 3.5) {
      return 'Zauważalna przez przeciętne oko';
    } else if (deltaE < 5.0) {
      return 'Wyraźnie zauważalna różnica';
    } else {
      return 'Dwa różne kolory';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Delta E'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wprowadź wartości CIE Lab',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wprowadź wartości L*, a*, b* dla obu kolorów, aby obliczyć różnicę między nimi.',
            ),
            const SizedBox(height: 24),
            _buildColorInputSection(
              title: 'Kolor 1',
              lController: l1Controller,
              aController: a1Controller,
              bController: b1Controller,
            ),
            const SizedBox(height: 24),
            _buildColorInputSection(
              title: 'Kolor 2',
              lController: l2Controller,
              aController: a2Controller,
              bController: b2Controller,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateDeltaE,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Oblicz Delta E',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (deltaE != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wynik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Delta E = ${deltaE!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              deltaEDescription!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Interpretacja Delta E:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildDeltaEInterpretationRow('< 1', 'Niezauważalna różnica', Colors.green),
                      _buildDeltaEInterpretationRow('1-2', 'Zauważalna tylko przez doświadczone oko', Colors.lightGreen),
                      _buildDeltaEInterpretationRow('2-3.5', 'Zauważalna przez przeciętne oko', Colors.amber),
                      _buildDeltaEInterpretationRow('3.5-5', 'Wyraźnie zauważalna różnica', Colors.orange),
                      _buildDeltaEInterpretationRow('> 5', 'Dwa różne kolory', Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorInputSection({
    required String title,
    required TextEditingController lController,
    required TextEditingController aController,
    required TextEditingController bController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: lController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'L*',
                  hintText: '0-100',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: aController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'a*',
                  hintText: '-128 to +127',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bController,
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed:

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.colorize,
              size: 80,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 24),
            const Text(
              'Dental Shade Comparison',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compare dental shade guides with deltaE values',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Shade Comparison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Wybierz opcję porównania',
              child: Column(
                children: [
                  _buildComparisonButton(
                    'VITA Classical vs VITA 3D Master',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComparisonPage(
                          title: 'VITA Classical vs VITA 3D Master',
                          firstSystem: ShadeSystem.vitaClassical,
                          secondSystem: ShadeSystem.vita3DMaster,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonButton(
                    'VITA Classical vs Ivoclar Chromascop',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComparisonPage(
                          title: 'VITA Classical vs Ivoclar Chromascop',
                          firstSystem: ShadeSystem.vitaClassical,
                          secondSystem: ShadeSystem.ivoclarChromascop,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonButton(
                    'VITA 3D Master vs Ivoclar Chromascop',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ComparisonPage(
                          title: 'VITA 3D Master vs Ivoclar Chromascop',
                          firstSystem: ShadeSystem.vita3DMaster,
                          secondSystem: ShadeSystem.ivoclarChromascop,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Przeglądaj pojedyncze systemy kolorów',
              child: Column(
                children: [
                  _buildComparisonButton(
                    'VITA Classical',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SingleSystemPage(
                          title: 'VITA Classical',
                          system: ShadeSystem.vitaClassical,
                        ),
                      ),
                    ),
                    color: Colors.green[700],
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonButton(
                    'VITA 3D Master',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SingleSystemPage(
                          title: 'VITA 3D Master',
                          system: ShadeSystem.vita3DMaster,
                        ),
                      ),
                    ),
                    color: Colors.green[700],
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonButton(
                    'Ivoclar Chromascop',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SingleSystemPage(
                          title: 'Ivoclar Chromascop',
                          system: ShadeSystem.ivoclarChromascop,
                        ),
                      ),
                    ),
                    color: Colors.green[700],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Narzędzia',
              child: Column(
                children: [
                  _buildComparisonButton(
                    'Kalkulator Delta E',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeltaECalculatorPage(),
                      ),
                    ),
                    color: Colors.purple[700],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildComparisonButton(String text, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O aplikacji'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aplikacja do porównywania odcieni zębów',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Ta aplikacja pozwala na porównywanie kolorów zębów pomiędzy trzema popularnymi systemami:'
              ),
              SizedBox(height: 8),
              Text('• VITA Classical'),
              Text('• VITA 3D Master'),
              Text('• Ivoclar Chromascop'),
              SizedBox(height: 16),
              Text(
                'Wartości Delta E oznaczają różnice między kolorami. Im niższa wartość, tym bliższe są kolory.',
              ),
              SizedBox(height: 8),
              Text('• Delta E < 1: Niezauważalna różnica'),
              Text('• Delta E 1-2: Zauważalna tylko przez doświadczone oko'),
              Text('• Delta E 2-3.5: Zauważalna przez przeciętne oko'),
              Text('• Delta E 3.5-5: Wyraźnie zauważalna różnica'),
              Text('• Delta E > 5: Dwa różne kolory'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }
}

// Model danych kolorów
enum ShadeSystem {
  vitaClassical,
  vita3DMaster,
  ivoclarChromascop,
}

class ShadeColor {
  final String id;
  final String name;
  final Color color;
  final Map<String, double> labValues;

  const ShadeColor({
    required this.id,
    required this.name,
    required this.color,
    required this.labValues,
  });
}

// Dane kolorów dla wszystkich systemów
class ShadeData {
  static List<ShadeColor> getShades(ShadeSystem system) {
    switch (system) {
      case ShadeSystem.vitaClassical:
        return vitaClassicalShades;
      case ShadeSystem.vita3DMaster:
        return vita3DMasterShades;
      case ShadeSystem.ivoclarChromascop:
        return ivoclarChromascopShades;
    }
  }

  static String getSystemName(ShadeSystem system) {
    switch (system) {
      case ShadeSystem.vitaClassical:
        return 'VITA Classical';
      case ShadeSystem.vita3DMaster:
        return 'VITA 3D Master';
      case ShadeSystem.ivoclarChromascop:
        return 'Ivoclar Chromascop';
    }
  }

  // VITA Classical shades
  static const List<ShadeColor> vitaClassicalShades = [
    ShadeColor(
      id: 'A1',
      name: 'A1',
      color: Color(0xFFE6D4C0),
      labValues: {'L': 76.0, 'a': 1.5, 'b': 15.0},
    ),
    ShadeColor(
      id: 'A2',
      name: 'A2',
      color: Color(0xFFE0C9AF),
      labValues: {'L': 73.0, 'a': 2.5, 'b': 17.0},
    ),
    ShadeColor(
      id: 'A3',
      name: 'A3',
      color: Color(0xFFD9BEA0),
      labValues: {'L': 72.0, 'a': 3.5, 'b': 19.0},
    ),
    ShadeColor(
      id: 'A3.5',
      name: 'A3.5',
      color: Color(0xFFD1B393),
      labValues: {'L': 69.0, 'a': 4.0, 'b': 21.0},
    ),
    ShadeColor(
      id: 'A4',
      name: 'A4',
      color: Color(0xFFC19A7E),
      labValues: {'L': 66.0, 'a': 5.0, 'b': 22.0},
    ),
    ShadeColor(
      id: 'B1',
      name: 'B1',
      color: Color(0xFFE9D9C8),
      labValues: {'L': 78.0, 'a': 0.5, 'b': 12.0},
    ),
    ShadeColor(
      id: 'B2',
      name: 'B2',
      color: Color(0xFFDECBB7),
      labValues: {'L': 74.0, 'a': 1.0, 'b': 14.0},
    ),
    ShadeColor(
      id: 'B3',
      name: 'B3',
      color: Color(0xFFD5BEA3),
      labValues: {'L': 71.0, 'a': 2.0, 'b': 16.5},
    ),
    ShadeColor(
      id: 'B4',
      name: 'B4',
      color: Color(0xFFC8AC93),
      labValues: {'L': 68.0, 'a': 3.0, 'b': 18.0},
    ),
    ShadeColor(
      id: 'C1',
      name: 'C1',
      color: Color(0xFFE1D6C6),
      labValues: {'L': 76.5, 'a': 0.0, 'b': 11.0},
    ),
    ShadeColor(
      id: 'C2',
      name: 'C2',
      color: Color(0xFFD6C4B5),
      labValues: {'L': 73.0, 'a': 0.5, 'b': 13.0},
    ),
    ShadeColor(
      id: 'C3',
      name: 'C3',
      color: Color(0xFFC6B5A1),
      labValues: {'L': 69.0, 'a': 1.0, 'b': 14.5},
    ),
    ShadeColor(
      id: 'C4',
      name: 'C4',
      color: Color(0xFFBCA58E),
      labValues: {'L': 65.0, 'a': 1.5, 'b': 16.0},
    ),
    ShadeColor(
      id: 'D2',
      name: 'D2',
      color: Color(0xFFD9CDBE),
      labValues: {'L': 74.0, 'a': -0.5, 'b': 9.0},
    ),
    ShadeColor(
      id: 'D3',
      name: 'D3',
      color: Color(0xFFCBBBA6),
      labValues: {'L': 71.0, 'a': 0.0, 'b': 11.0},
    ),
    ShadeColor(
      id: 'D4',
      name: 'D4',
      color: Color(0xFFC4B29A),
      labValues: {'L': 68.0, 'a': 0.5, 'b': 13.0},
    ),
  ];

  // VITA 3D Master shades
  static const List<ShadeColor> vita3DMasterShades = [
    ShadeColor(
      id: '0M1',
      name: '0M1',
      color: Color(0xFFF1E8D7),
      labValues: {'L': 81.5, 'a': -0.5, 'b': 10.0},
    ),
    ShadeColor(
      id: '0M2',
      name: '0M2',
      color: Color(0xFFEADFC9),
      labValues: {'L': 80.0, 'a': 0.0, 'b': 12.0},
    ),
    ShadeColor(
      id: '0M3',
      name: '0M3',
      color: Color(0xFFE5D6C0),
      labValues: {'L': 78.5, 'a': 0.5, 'b': 14.0},
    ),
    ShadeColor(
      id: '1M1',
      name: '1M1',
      color: Color(0xFFE7DDCD),
      labValues: {'L': 77.0, 'a': 0.0, 'b': 11.0},
    ),
    ShadeColor(
      id: '1M2',
      name: '1M2',
      color: Color(0xFFE2D4C0),
      labValues: {'L': 75.5, 'a': 0.5, 'b': 13.0},
    ),
    ShadeColor(
      id: '2L1.5',
      name: '2L1.5',
      color: Color(0xFFDED1BF),
      labValues: {'L': 74.0, 'a': -0.5, 'b': 12.0},
    ),
    ShadeColor(
      id: '2L2.5',
      name: '2L2.5',
      color: Color(0xFFD8C8B4),
      labValues: {'L': 72.5, 'a': 0.0, 'b': 14.0},
    ),
    ShadeColor(
      id: '2M1',
      name: '2M1',
      color: Color(0xFFDACCBB),
      labValues: {'L': 73.0, 'a': 0.5, 'b': 12.0},
    ),
    ShadeColor(
      id: '2M2',
      name: '2M2',
      color: Color(0xFFD6C4AF),
      labValues: {'L': 71.5, 'a': 1.0, 'b': 14.0},
    ),
    ShadeColor(
      id: '2M3',
      name: '2M3',
      color: Color(0xFFD1BCA5),
      labValues: {'L': 70.0, 'a': 1.5, 'b': 16.0},
    ),
    ShadeColor(
      id: '2R1.5',
      name: '2R1.5',
      color: Color(0xFFD8C6B2),
      labValues: {'L': 72.0, 'a': 1.5, 'b': 13.0},
    ),
    ShadeColor(
      id: '2R2.5',
      name: '2R2.5',
      color: Color(0xFFD3BDA8),
      labValues: {'L': 70.5, 'a': 2.0, 'b': 15.0},
    ),
    ShadeColor(
      id: '3L1.5',
      name: '3L1.5',
      color: Color(0xFFCFC0AD),
      labValues: {'L': 69.0, 'a': 0.0, 'b': 13.0},
    ),
    ShadeColor(
      id: '3L2.5',
      name: '3L2.5',
      color: Color(0xFFC9B7A2),
      labValues: {'L': 67.5, 'a': 0.5, 'b': 15.0},
    ),
    ShadeColor(
      id: '3M1',
      name: '3M1',
      color: Color(0xFFCCBDAA),
      labValues: {'L': 68.0, 'a': 1.0, 'b': 13.0},
    ),
    ShadeColor(
      id: '3M2',
      name: '3M2',
      color: Color(0xFFC7B5A0),
      labValues: {'L': 66.5, 'a': 1.5, 'b': 15.0},
    ),
    ShadeColor(
      id: '3M3',
      name: '3M3',
      color: Color(0xFFC2AC95),
      labValues: {'L': 65.0, 'a': 2.0, 'b': 17.0},
    ),
    ShadeColor(
      id: '3R1.5',
      name: '3R1.5',
      color: Color(0xFFC9B7A2),
      labValues: {'L': 67.0, 'a': 2.0, 'b': 14.0},
    ),
    ShadeColor(
      id: '3R2.5',
      name: '3R2.5',
      color: Color(0xFFC4AF97),
      labValues: {'L': 65.5, 'a': 2.5, 'b': 16.0},
    ),
    ShadeColor(
      id: '4L1.5',
      name: '4L1.5',
      color: Color(0xFFBFB19F),
      labValues: {'L': 64.0, 'a': 0.5, 'b': 14.0},
    ),
    ShadeColor(
      id: '4L2.5',
      name: '4L2.5',
      color: Color(0xFFB9A894),
      labValues: {'L': 62.5, 'a': 1.0, 'b': 16.0},
    ),
    ShadeColor(
      id: '4M1',
      name: '4M1',
      color: Color(0xFFBDAE9C),
      labValues: {'L': 63.0, 'a': 1.5, 'b': 14.0},
    ),
    ShadeColor(
      id: '4M2',
      name: '4M2',
      color: Color(0xFFB8A592),
      labValues: {'L': 61.5, 'a': 2.0, 'b': 16.0},
    ),
    ShadeColor(
      id: '4M3',
      name: '4M3',
      color: Color(0xFFB39C87),
      labValues: {'L': 60.0, 'a': 2.5, 'b': 18.0},
    ),
    ShadeColor(
      id: '4R1.5',
      name: '4R1.5',
      color: Color(0xFFB9A894),
      labValues: {'L': 62.0, 'a': 2.5, 'b': 15.0},
    ),
    ShadeColor(
      id: '4R2.5',
      name: '4R2.5',
      color: Color(0xFFB4A089),
      labValues: {'L': 60.5, 'a': 3.0, 'b': 17.0},
    ),
    ShadeColor(
      id: '5M1',
      name: '5M1',
      color: Color(0xFFAC9E8C),
      labValues: {'L': 58.0, 'a': 2.0, 'b': 15.0},
    ),
    ShadeColor(
      id: '5M2',
      name: '5M2',
      color: Color(0xFFA79582),
      labValues: {'L': 56.5, 'a': 2.5, 'b': 17.0},
    ),
    ShadeColor(
      id: '5M3',
      name: '5M3',
      color: Color(0xFFA28C78),
      labValues: {'L': 55.0, 'a': 3.0, 'b': 19.0},
    ),
  ];

  // Ivoclar Chromascop shades
  static const List<ShadeColor> ivoclarChromascopShades = [
    ShadeColor(
      id: '110',
      name: '110',
      color: Color(0xFFEEDFD1),
      labValues: {'L': 79.5, 'a': 0.5, 'b': 10.0},
    ),
    ShadeColor(
      id: '120',
      name: '120',
      color: Color(0xFFE7D5C5),
      labValues: {'L': 77.0, 'a': 1.0, 'b': 12.0},
    ),
    ShadeColor(
      id: '130',
      name: '130',
      color: Color(0xFFDECBB9),
      labValues: {'L': 74.5, 'a': 1.5, 'b': 14.0},
    ),
    ShadeColor(
      id: '140',
      name: '140',
      color: Color(0xFFD5C1AE),
      labValues: {'L': 72.0, 'a': 2.0, 'b': 16.0},
    ),
    ShadeColor(
      id: '210',
      name: '210',
      color: Color(0xFFE5D8C8),
      labValues: {'L': 78.0, 'a': 0.0, 'b': 11.0},
    ),
    ShadeColor(
      id: '220',
      name: '220',
      color: Color(0xFFDCCEBC),
      labValues: {'L': 75.5, 'a': 0.5, 'b': 13.0},
    ),
    ShadeColor(
      id: '230',
      name: '230',
      color: Color(0xFFD3C4B0),
      labValues: {'L': 73.0, 'a': 1.0, 'b': 15.0},
    ),
    ShadeColor(
      id: '240',
      name: '240',
      color: Color(0xFFCABAA5),
      labValues: {'L': 70.5, 'a': 1.5, 'b': 17.0},
    ),
    ShadeColor(
      id: '310',
      name: '310',
      color: Color(0xFFDFCFBF),
      labValues: {'L': 76.0, 'a': -0.5, 'b': 12.0},
    ),
    ShadeColor(
      id: '320',
      name: '320',
      color: Color(0xFFD6C5B3),
      labValues: {'L': 73.5, 'a': 0.0, 'b': 14.0},
    ),
    ShadeColor(
      id: '330',
      name: '330',
      color: Color(0xFFCDBAA7),
      labValues: {'L': 71.0, 'a': 0.5, 'b': 16.0},
    ),
    ShadeColor(
      id: '340',
      name: '340',
      color: Color(0xFFC4B19C),
      labValues: {'L': 68.5, 'a': 1.0, 'b': 18.0},
    ),
    ShadeColor(
      id: '410',
      name: '410',
      color: Color(0xFFD8C8B9),
      labValues: {'L': 74.0, 'a': -1.0, 'b': 13.0},
    ),
    ShadeColor(
      id: '420',
      name: '420',
      color: Color(0xFFCFBEAD),
      labValues: {'L': 71.5, 'a': -0.5, 'b': 15.0},
    ),
    ShadeColor(
      id: '430',
      name: '430',
      color: Color(0xFFC6B4A1),
      labValues: {'L': 69.0, 'a': 0.0, 'b': 17.0},
    ),
    ShadeColor(
      id: '440',
      name: '440',
      color: Color(0xFFBDAA96),
      labValues: {'L': 66.5, 'a': 0.5, 'b': 19.0},
    ),
    ShadeColor(
      id: '510',
      name: '510',
      color: Color(0xFFD1C1B1),
      labValues: {'L': 72.0, 'a': -1.5, 'b': 14.0},
    ),
    ShadeColor(
      id: '520',
      name: '520',
      color: Color(0xFFC8B7A5),
      labValues: {'L': 69.5, 'a': -1.0, 'b': 16.0},
    ),
    ShadeColor(
      id: '530',
      name: '530',
      color: Color(0xFFBFAD9A),
      labValues: {'L': 67.0, 'a': -0.5, 'b': 18.0},
    ),
    ShadeColor(
      id: '540',
      name: '540',
      color: Color(0xFFB6A38F),
      labValues: {'L': 64.5, 'a': 0.0, 'b': 20.0},
    ),
  ];
}

// Kalkulator Delta E
double calculateDeltaE(Map<String, double> lab1, Map<String, double> lab2) {
  double deltaL = lab1['L']! - lab2['L']!;
  double deltaA = lab1['a']! - lab2['a']!;
  double deltaB = lab1['b']! - lab2['b']!;
  
  return sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB);
}

// Strona porównywania systemów
class ComparisonPage extends StatefulWidget {
  final String title;
  final ShadeSystem firstSystem;
  final ShadeSystem secondSystem;

  const ComparisonPage({
    Key? key,
    required this.title,
    required this.firstSystem,
    required this.secondSystem,
  }) : super(key: key);

  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late ShadeColor? selectedFirstShade;
  late ShadeColor? selectedSecondShade;
  List<Map<String, dynamic>> comparisonResults = [];

  @override
  void initState() {
    super.initState();
    selectedFirstShade = null;
    selectedSecondShade = null;
  }

  void _updateComparisonResults() {
    if (selectedFirstShade == null || selectedSecondShade == null) {
      setState(() {
        comparisonResults = [];
      });
      return;
    }

    // Calculate delta E
    double deltaE = calculateDeltaE(
      selectedFirstShade!.labValues,
      selectedSecondShade!.labValues,
    );

    // Update results
    setState(() {
      comparisonResults = [
        {
          'label': 'Delta E',
          'value': deltaE.toStringAsFixed(2),
          'description': _getDeltaEDescription(deltaE),
        },
        {
          'label': 'L* (jasność)',
          'value1': selectedFirstShade!.labValues['L']!.toStringAsFixed(1),
          'value2': selectedSecondShade!.labValues['L']!.toStringAsFixed(1),
          'diff': (selectedFirstShade!.labValues['L']! - selectedSecondShade!.labValues['L']!).abs().toStringAsFixed(1),
        },
        {
          'label': 'a* (czerwony-zielony)',
          'value1': selectedFirstShade!.labValues['a']!.toStringAsFixed(1),
          'value2': selectedSecondShade!.labValues['a']!.toStringAsFixed(1),
          'diff': (selectedFirstShade!.labValues['a']! - selectedSecondShade!.labValues['a']!).abs().toStringAsFixed(1),
        },
        {
          'label': 'b* (żółty-niebieski)',
          'value1': selectedFirstShade!.labValues['b']!.toStringAsFixed(1),
          'value2': selectedSecondShade!.labValues['b']!.toStringAsFixed(1),
          'diff': (selectedFirstShade!.labValues['b']! - selectedSecondShade!.labValues['b']!).abs().toStringAsFixed(1),
        },
      ];
    });
  }

  String _getDeltaEDescription(double deltaE) {
    if (deltaE < 1.0) {
      return 'Niezauważalna różnica';
    } else if (deltaE < 2.0) {
      return 'Zauważalna tylko przez doświadczone oko';
    } else if (deltaE < 3.5) {
      return 'Zauważalna przez przeciętne oko';
    } else if (deltaE < 5.0) {
      return 'Wyraźnie zauważalna różnica';
    } else {
      return 'Dwa różne kolory';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstSystemName = ShadeData.getSystemName(widget.firstSystem);
    final secondSystemName = ShadeData.getSystemName(widget.secondSystem);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSystemSelection(
                title: firstSystemName,
                system: widget.firstSystem,
                selectedShade: selectedFirstShade,
                onSelected: (shade) {
                  setState(() {
                    selectedFirstShade = shade;
                  });
                  _updateComparisonResults();
                },
              ),
              const SizedBox(height: 24),
              _buildSystemSelection(
                title: secondSystemName,
                system: widget.secondSystem,
                selectedShade: selectedSecondShade,
                onSelected: (shade) {
                  setState(() {
                    selectedSecondShade = shade;
                  });
                  _updateComparisonResults();
                },
              ),
              const SizedBox(height: 32),
              if (comparisonResults.isNotEmpty) _buildComparisonResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemSelection({
    required String title,
    required ShadeSystem system,
    required ShadeColor? selectedShade,
    required Function(ShadeColor) onSelected,
  }) {
    final shades = ShadeData.getShades(system);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Wybierz odcień:',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shades.length,
            itemBuilder: (context, index) {
              final shade = shades[index];
              final isSelected = selectedShade?.id == shade.id;
              
              return GestureDetector(
                onTap: () => onSelected(shade),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: shade.color,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Text(
                          shade.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedShade != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedShade.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wybrany odcień: ${selectedShade.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'L*: ${selectedShade.labValues['L']!.toStringAsFixed(1)}, ' +
                    'a*: ${selectedShade.labValues['a']!.toStringAsFixed(1)}, ' +
                    'b*: ${selectedShade.labValues['b']!.toStringAsFixed(1)}',
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildComparisonResults() {
    final firstSystemName = ShadeData.getSystemName(widget.firstSystem);
    final secondSystemName = ShadeData.getSystemName(widget.secondSystem);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Porównanie',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: selectedFirstShade!.color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$firstSystemName\n${selectedFirstShade!.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.compare_arrows, size: 32),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: selectedSecondShade!.color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$secondSystemName\n${selectedSecondShade!.name}',
                        textAlign: TextAlign.center, 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delta E: ${comparisonResults[0]['value']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(comparisonResults[0]['description']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(comparisonResults.length - 1, (index) {
              final result = comparisonResults[index + 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(result['label']),
                    ),
                    Expanded(
                      child: Text(
                        result['value1'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        result['value2'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Δ ${result['diff']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
