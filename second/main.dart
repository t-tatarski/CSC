// main.dart
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Porównywarka Odcieni Zębów',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo aplikacji
            Icon(
              Icons.colorize,
              size: 100,
              color: Colors.blue.shade800,
            ),
            const SizedBox(height: 20),
            // Nazwa aplikacji
            const Text(
              'DentalShade',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Podtytuł
            const Text(
              'Porównywarka Odcieni Zębowych',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            // Wskaźnik ładowania
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Systemy kolorów
  final List<String> systems = ['Vita Classical', '3D Master', 'Chromascop'];
  String selectedSystem = 'Vita Classical';
  String? selectedShade;

  // Dane kolorów dla każdego systemu
  final Map<String, List<String>> shades = {
    'Vita Classical': ['A1', 'A2', 'A3', 'A3.5', 'A4', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 'C4', 'D2', 'D3', 'D4'],
    '3D Master': ['0M1', '0M2', '0M3', '1M1', '1M2', '2L1.5', '2L2.5', '2M1', '2M2', '2M3', '2R1.5', '2R2.5', '3L1.5', '3L2.5', '3M1', '3M2', '3M3', '3R1.5', '3R2.5', '4L1.5', '4L2.5', '4M1', '4M2', '4M3', '4R1.5', '4R2.5', '5M1', '5M2', '5M3'],
    'Chromascop': ['110', '120', '130', '140', '210', '220', '230', '240', '310', '320', '330', '340', '410', '420', '430', '440', '510', '520', '530', '540'],
  };

  // Mapowanie podobnych kolorów między systemami
  final Map<String, Map<String, List<String>>> similarShades = {
    'Vita Classical': {
      'A1': ['1M1', '1M2', '120'],
      'A2': ['2M2', '130'],
      'A3': ['3M2', '3L1.5', '140'],
      'A3.5': ['3M3', '210'],
      'A4': ['4M2', '220'],
      'B1': ['1M1', '110'],
      'B2': ['2L1.5', '140'],
      'B3': ['3L1.5', '210'],
      'B4': ['4L1.5', '220'],
      'C1': ['2M1', '130'],
      'C2': ['3M1', '220'],
      'C3': ['4M1', '320'],
      'C4': ['5M1', '420'],
      'D2': ['2L1.5', '310'],
      'D3': ['3L2.5', '320'],
      'D4': ['4L2.5', '410'],
    },
    '3D Master': {
      '0M1': ['B1', '110'],
      '0M2': ['A1', '110'],
      '0M3': ['A1', '120'],
      '1M1': ['B1', '110'],
      '1M2': ['A1', '120'],
      '2L1.5': ['B2', '140'],
      '2L2.5': ['D2', '220'],
      '2M1': ['C1', '130'],
      '2M2': ['A2', '130'],
      '2M3': ['A3', '140'],
      '2R1.5': ['A2', '130'],
      '2R2.5': ['A3', '140'],
      '3L1.5': ['B3', '210'],
      '3L2.5': ['D3', '320'],
      '3M1': ['C2', '210'],
      '3M2': ['A3', '210'],
      '3M3': ['A3.5', '220'],
      '3R1.5': ['C2', '220'],
      '3R2.5': ['A3.5', '230'],
      '4L1.5': ['B4', '320'],
      '4L2.5': ['D4', '410'],
      '4M1': ['C3', '320'],
      '4M2': ['A4', '330'],
      '4M3': ['A4', '340'],
      '4R1.5': ['C3', '330'],
      '4R2.5': ['A4', '340'],
      '5M1': ['C4', '420'],
      '5M2': ['C4', '430'],
      '5M3': ['C4', '440'],
    },
    'Chromascop': {
      '110': ['B1', '0M1'],
      '120': ['A1', '1M2'],
      '130': ['A2', '2M2'],
      '140': ['A3', '2M3'],
      '210': ['A3.5', '3M2'],
      '220': ['A4', '3M3'],
      '230': ['A4', '3R2.5'],
      '240': ['A4', '4R2.5'],
      '310': ['D2', '2L1.5'],
      '320': ['D3', '3L2.5'],
      '330': ['C3', '4M2'],
      '340': ['C3', '4M3'],
      '410': ['D4', '4L2.5'],
      '420': ['C4', '5M1'],
      '430': ['C4', '5M2'],
      '440': ['C4', '5M3'],
      '510': ['C4', '5M3'],
      '520': ['C4', '5M3'],
      '530': ['C4', '5M3'],
      '540': ['C4', '5M3'],
    },
  };

  // Kolory dla każdego systemu
  final Map<String, Map<String, Color>> shadeColors = {
    'Vita Classical': {
      'A1': const Color(0xFFE6DAC9),
      'A2': const Color(0xFFE0D0B7),
      'A3': const Color(0xFFDBCA9E),
      'A3.5': const Color(0xFFD6C091),
      'A4': const Color(0xFFCEB77F),
      'B1': const Color(0xFFE9E3D0),
      'B2': const Color(0xFFE2DABF),
      'B3': const Color(0xFFD8C9A9),
      'B4': const Color(0xFFCEB995),
      'C1': const Color(0xFFE1D4C9),
      'C2': const Color(0xFFD8C8B8),
      'C3': const Color(0xFFCBB8A2),
      'C4': const Color(0xFFBDA78E),
      'D2': const Color(0xFFD9CCBE),
      'D3': const Color(0xFFCFC0AE),
      'D4': const Color(0xFFC2B19D),
    },
    '3D Master': {
      '0M1': const Color(0xFFF1EDE4),
      '0M2': const Color(0xFFEEE8DC),
      '0M3': const Color(0xFFEAE2D4),
      '1M1': const Color(0xFFEDE5D3),
      '1M2': const Color(0xFFE8DEC8),
      '2L1.5': const Color(0xFFE6D9C8),
      '2L2.5': const Color(0xFFE1D2BC),
      '2M1': const Color(0xFFE1D1BB),
      '2M2': const Color(0xFFDCCBAF),
      '2M3': const Color(0xFFD7C5A4),
      '2R1.5': const Color(0xFFD9C8AB),
      '2R2.5': const Color(0xFFD4C19F),
      '3L1.5': const Color(0xFFDAC9B2),
      '3L2.5': const Color(0xFFD5C2A5),
      '3M1': const Color(0xFFD3BEA5),
      '3M2': const Color(0xFFCDB899),
      '3M3': const Color(0xFFC7B18D),
      '3R1.5': const Color(0xFFCDB698),
      '3R2.5': const Color(0xFFC7AF8B),
      '4L1.5': const Color(0xFFCBB89E),
      '4L2.5': const Color(0xFFC5B191),
      '4M1': const Color(0xFFC3B091),
      '4M2': const Color(0xFFBEA985),
      '4M3': const Color(0xFFB8A279),
      '4R1.5': const Color(0xFFBBA884),
      '4R2.5': const Color(0xFFB5A177),
      '5M1': const Color(0xFFAF9D7F),
      '5M2': const Color(0xFFA99673),
      '5M3': const Color(0xFFA48F67),
    },
    'Chromascop': {
      '110': const Color(0xFFEEE6D6),
      '120': const Color(0xFFE6DBB8),
      '130': const Color(0xFFDCD0AB),
      '140': const Color(0xFFD3C59E),
      '210': const Color(0xFFDDC9A7),
      '220': const Color(0xFFD5BE9A),
      '230': const Color(0xFFCCB38D),
      '240': const Color(0xFFC4A980),
      '310': const Color(0xFFDBCBB9),
      '320': const Color(0xFFD2C0AC),
      '330': const Color(0xFFC9B59F),
      '340': const Color(0xFFC0AB92),
      '410': const Color(0xFFCCC0AF),
      '420': const Color(0xFFC3B5A2),
      '430': const Color(0xFFBBAA95),
      '440': const Color(0xFFB2A088),
      '510': const Color(0xFFBFB09E),
      '520': const Color(0xFFB6A591),
      '530': const Color(0xFFAD9B84),
      '540': const Color(0xFFA59077),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DentalShade'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System selektor
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wybierz system kolorów:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSystem,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: systems.map((String system) {
                        return DropdownMenuItem<String>(
                          value: system,
                          child: Text(system),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSystem = newValue!;
                          selectedShade = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Grid kolorów
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wybierz odcień:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: shades[selectedSystem]!.length,
                        itemBuilder: (context, index) {
                          String shade = shades[selectedSystem]![index];
                          Color? shadeColor = shadeColors[selectedSystem]![shade];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedShade = shade;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: shadeColor ?? Colors.grey,
                                border: Border.all(
                                  color: selectedShade == shade
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade300,
                                  width: selectedShade == shade ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  shade,
                                  style: TextStyle(
                                    color: _contrastColor(shadeColor ?? Colors.grey),
                                    fontWeight: FontWeight.bold,
                                  ),
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
            
            const SizedBox(height: 16),
            
            // Podobne odcienie
            if (selectedShade != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Podobne odcienie:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildShadeBox(
                            selectedSystem,
                            selectedShade!,
                            shadeColors[selectedSystem]![selectedShade!] ?? Colors.grey,
                          ),
                          const Icon(Icons.compare_arrows, size: 24),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: similarShades[selectedSystem]![selectedShade]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  String similarShade = similarShades[selectedSystem]![selectedShade]![index];
                                  String similarSystem = _getSimilarSystem(similarShade);
                                  Color? similarColor = shadeColors[similarSystem]![similarShade] ?? Colors.grey;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: _buildShadeBox(
                                      similarSystem,
                                      similarShade,
                                      similarColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSimilarSystem(String shade) {
    if (shades['Vita Classical']!.contains(shade)) {
      return 'Vita Classical';
    } else if (shades['3D Master']!.contains(shade)) {
      return '3D Master';
    } else {
      return 'Chromascop';
    }
  }

  Widget _buildShadeBox(String system, String shade, Color color) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              shade,
              style: TextStyle(
                color: _contrastColor(color),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          system,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  // Funkcja zwracająca kontrastowy kolor tekstu
  Color _contrastColor(Color backgroundColor) {
    int d = 0;
    double luminance = (0.299 * backgroundColor.red + 0.587 * backgroundColor.green + 0.114 * backgroundColor.blue) / 255;
    
    if (luminance > 0.5) {
      d = 0; // czarny tekst dla jasnych tła
    } else {
      d = 255; // biały tekst dla ciemnych tła
    }
    
    return Color.fromARGB(255, d, d, d);
  }
}
