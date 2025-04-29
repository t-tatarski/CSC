// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(DentalColorApp());
}

class DentalColorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Color Scales',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DentalColorHomePage(),
    );
  }
}

class DentalColorHomePage extends StatefulWidget {
  @override
  _DentalColorHomePageState createState() => _DentalColorHomePageState();
}

class _DentalColorHomePageState extends State<DentalColorHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedScale = 'VITA-A-D';
  DentalColor? _selectedColor;
  final TextEditingController _redController = TextEditingController(text: "230");
  final TextEditingController _greenController = TextEditingController(text: "205");
  final TextEditingController _blueController = TextEditingController(text: "165");
  final TextEditingController _lController = TextEditingController(text: "80.0");
  final TextEditingController _aController = TextEditingController(text: "2.0");
  final TextEditingController _bController = TextEditingController(text: "22.0");
  
  DentalColor? _closestRgbColor;
  DentalColor? _closestLabColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    _lController.dispose();
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  void _findClosestColorByRgb() {
    try {
      int r = int.parse(_redController.text);
      int g = int.parse(_greenController.text);
      int b = int.parse(_blueController.text);
      
      setState(() {
        _closestRgbColor = findClosestColorByRgb([r, g, b]);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid RGB values'))
      );
    }
  }

  void _findClosestColorByLab() {
    try {
      double l = double.parse(_lController.text);
      double a = double.parse(_aController.text);
      double b = double.parse(_bController.text);
      
      setState(() {
        _closestLabColor = findClosestColorByLab([l, a, b]);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid LAB values'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dental Color Scales'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Color Scales'),
            Tab(text: 'Color Finder'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildColorScalesTab(),
          _buildColorFinderTab(),
        ],
      ),
    );
  }

  Widget _buildColorScalesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _selectedScale,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'VITA-A-D', child: Text('VITA Classical A-D')),
              DropdownMenuItem(value: 'VITA-3D', child: Text('VITA 3D-Master')),
              DropdownMenuItem(value: 'Chromascope', child: Text('Ivoclar Chromascope')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedScale = value!;
                _selectedColor = null;
              });
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: findColorsByScale(_selectedScale).length,
            itemBuilder: (context, index) {
              final color = findColorsByScale(_selectedScale)[index];
              final isSelected = _selectedColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Card(
                  elevation: isSelected ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(color.rgb[0], color.rgb[1], color.rgb[2], 1.0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        color.colorCode,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedColor != null)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedColor!.scaleType} ${_selectedColor!.colorCode}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(
                          _selectedColor!.rgb[0],
                          _selectedColor!.rgb[1],
                          _selectedColor!.rgb[2],
                          1.0,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RGB: (${_selectedColor!.rgb[0]}, ${_selectedColor!.rgb[1]}, ${_selectedColor!.rgb[2]})'),
                          Text('LAB: L*=${_selectedColor!.lab[0]}, a*=${_selectedColor!.lab[1]}, b*=${_selectedColor!.lab[2]}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildColorFinderTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find by RGB',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _redController,
                          decoration: InputDecoration(labelText: 'Red (0-255)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _greenController,
                          decoration: InputDecoration(labelText: 'Green (0-255)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _blueController,
                          decoration: InputDecoration(labelText: 'Blue (0-255)'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            int.tryParse(_redController.text) ?? 0,
                            int.tryParse(_greenController.text) ?? 0,
                            int.tryParse(_blueController.text) ?? 0,
                            1.0,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _findClosestColorByRgb,
                        child: Text('Find Closest Color'),
                      ),
                    ],
                  ),
                  if (_closestRgbColor != null) ...[
                    SizedBox(height: 16),
                    Divider(),
                    Text('Closest Match:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              _closestRgbColor!.rgb[0],
                              _closestRgbColor!.rgb[1],
                              _closestRgbColor!.rgb[2],
                              1.0,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_closestRgbColor!.scaleType} ${_closestRgbColor!.colorCode}'),
                              Text('RGB: (${_closestRgbColor!.rgb[0]}, ${_closestRgbColor!.rgb[1]}, ${_closestRgbColor!.rgb[2]})'),
                              Text('LAB: L*=${_closestRgbColor!.lab[0]}, a*=${_closestRgbColor!.lab[1]}, b*=${_closestRgbColor!.lab[2]}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find by CIELAB',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _lController,
                          decoration: InputDecoration(labelText: 'L* (0-100)'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _aController,
                          decoration: InputDecoration(labelText: 'a* (-128 to 127)'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _bController,
                          decoration: InputDecoration(labelText: 'b* (-128 to 127)'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _findClosestColorByLab,
                    child: Text('Find Closest Color'),
                  ),
                  if (_closestLabColor != null) ...[
                    SizedBox(height: 16),
                    Divider(),
                    Text('Closest Match:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              _closestLabColor!.rgb[0],
                              _closestLabColor!.rgb[1],
                              _closestLabColor!.rgb[2],
                              1.0,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_closestLabColor!.scaleType} ${_closestLabColor!.colorCode}'),
                              Text('RGB: (${_closestLabColor!.rgb[0]}, ${_closestLabColor!.rgb[1]}, ${_closestLabColor!.rgb[2]})'),
                              Text('LAB: L*=${_closestLabColor!.lab[0]}, a*=${_closestLabColor!.lab[1]}, b*=${_closestLabColor!.lab[2]}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Poniżej znajdują się klasy przeniesione z oryginalnego kodu Java
// Klasa reprezentująca pojedynczy kolor dentystyczny
class DentalColor {
  final String scaleType;  // Typ skali (VITA A-D, 3D Master, Chromascope)
  final String colorCode;  // Kod koloru (np. A1, 3M2, 240)
  final List<int> rgb;     // Wartości RGB (red, green, blue)
  final List<double> lab;  // Wartości CIELAB (L*, a*, b*)
  
  DentalColor(this.scaleType, this.colorCode, this.rgb, this.lab);
  
  @override
  String toString() {
    return '$scaleType $colorCode: RGB(${rgb[0]},${rgb[1]},${rgb[2]}), L*=${lab[0]}, a*=${lab[1]}, b*=${lab[2]}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DentalColor && 
           other.scaleType == scaleType && 
           other.colorCode == colorCode;
  }

  @override
  int get hashCode => scaleType.hashCode ^ colorCode.hashCode;
}

// Główna tablica zawierająca wszystkie kolory dentystyczne
final List<DentalColor> DENTAL_COLORS = [
  // VITA Classical A-D
  DentalColor("VITA-A-D", "A1", [242, 222, 194], [86.0, 1.0, 18.0]),
  DentalColor("VITA-A-D", "A2", [238, 213, 183], [84.0, 2.0, 21.0]),
  DentalColor("VITA-A-D", "A3", [233, 204, 167], [82.0, 3.0, 25.0]),
  DentalColor("VITA-A-D", "A3.5", [226, 193, 153], [79.0, 4.0, 27.0]),
  DentalColor("VITA-A-D", "A4", [215, 177, 137], [75.0, 5.0, 29.0]),
  DentalColor("VITA-A-D", "B1", [245, 227, 197], [88.0, 0.0, 16.0]),
  DentalColor("VITA-A-D", "B2", [236, 216, 186], [85.0, 0.0, 19.0]),
  DentalColor("VITA-A-D", "B3", [229, 203, 168], [82.0, 1.0, 23.0]),
  DentalColor("VITA-A-D", "B4", [219, 190, 148], [78.0, 2.0, 25.0]),
  DentalColor("VITA-A-D", "C1", [234, 214, 184], [84.0, 0.0, 16.0]),
  DentalColor("VITA-A-D", "C2", [227, 202, 169], [81.0, 1.0, 18.0]),
  DentalColor("VITA-A-D", "C3", [217, 189, 154], [77.0, 2.0, 20.0]),
  DentalColor("VITA-A-D", "C4", [205, 173, 137], [73.0, 3.0, 22.0]),
  DentalColor("VITA-A-D", "D2", [229, 205, 172], [82.0, 1.0, 17.0]),
  DentalColor("VITA-A-D", "D3", [223, 193, 156], [79.0, 2.0, 19.0]),
  DentalColor("VITA-A-D", "D4", [215, 184, 145], [75.0, 3.0, 21.0]),
  
  // VITA 3D-Master
  DentalColor("VITA-3D", "0M1", [252, 238, 213], [92.0, 0.0, 14.0]),
  DentalColor("VITA-3D", "0M2", [246, 230, 202], [90.0, 0.0, 16.0]),
  DentalColor("VITA-3D", "0M3", [241, 223, 192], [87.0, 0.0, 18.0]),
  DentalColor("VITA-3D", "1M1", [244, 227, 198], [89.0, 0.0, 16.0]),
  DentalColor("VITA-3D", "1M2", [239, 219, 187], [86.0, 1.0, 18.0]),
  DentalColor("VITA-3D", "2L1.5", [237, 215, 183], [85.0, 1.0, 18.0]),
  DentalColor("VITA-3D", "2L2.5", [232, 205, 170], [82.0, 2.0, 20.0]),
  DentalColor("VITA-3D", "2M1", [236, 217, 187], [85.0, 0.0, 17.0]),
  DentalColor("VITA-3D", "2M2", [232, 208, 173], [83.0, 1.0, 20.0]),
  DentalColor("VITA-3D", "2M3", [228, 199, 160], [81.0, 2.0, 22.0]),
  DentalColor("VITA-3D", "2R1.5", [235, 212, 177], [84.0, 2.0, 19.0]),
  DentalColor("VITA-3D", "2R2.5", [230, 202, 164], [81.0, 3.0, 22.0]),
  DentalColor("VITA-3D", "3L1.5", [225, 201, 165], [80.0, 2.0, 20.0]),
  DentalColor("VITA-3D", "3L2.5", [220, 191, 150], [77.0, 3.0, 22.0]),
  DentalColor("VITA-3D", "3M1", [224, 203, 167], [81.0, 1.0, 19.0]),
  DentalColor("VITA-3D", "3M2", [220, 193, 155], [78.0, 2.0, 21.0]),
  DentalColor("VITA-3D", "3M3", [214, 185, 143], [75.0, 3.0, 24.0]),
  DentalColor("VITA-3D", "3R1.5", [223, 196, 157], [79.0, 3.0, 21.0]),
  DentalColor("VITA-3D", "3R2.5", [217, 187, 145], [76.0, 4.0, 24.0]),
  DentalColor("VITA-3D", "4L1.5", [213, 188, 149], [76.0, 2.0, 21.0]),
  DentalColor("VITA-3D", "4L2.5", [207, 178, 137], [72.0, 3.0, 24.0]),
  DentalColor("VITA-3D", "4M1", [211, 186, 147], [75.0, 2.0, 22.0]),
  DentalColor("VITA-3D", "4M2", [205, 177, 134], [72.0, 3.0, 25.0]),
  DentalColor("VITA-3D", "4M3", [200, 168, 126], [69.0, 4.0, 27.0]),
  DentalColor("VITA-3D", "4R1.5", [210, 181, 139], [74.0, 3.0, 23.0]),
  DentalColor("VITA-3D", "4R2.5", [204, 172, 127], [71.0, 4.0, 26.0]),
  DentalColor("VITA-3D", "5M1", [197, 171, 131], [70.0, 2.0, 24.0]),
  DentalColor("VITA-3D", "5M2", [192, 163, 120], [67.0, 3.0, 26.0]),
  DentalColor("VITA-3D", "5M3", [186, 153, 110], [63.0, 4.0, 28.0]),
  
  // Ivoclar Chromascope
  DentalColor("Chromascope", "110", [249, 234, 208], [91.0, 0.0, 15.0]),
  DentalColor("Chromascope", "120", [244, 228, 200], [89.0, 0.0, 16.0]),
  DentalColor("Chromascope", "130", [239, 221, 190], [87.0, 1.0, 18.0]),
  DentalColor("Chromascope", "140", [233, 214, 180], [84.0, 1.0, 19.0]),
  DentalColor("Chromascope", "210", [241, 223, 186], [87.0, 0.0, 20.0]),
  DentalColor("Chromascope", "220", [236, 216, 177], [85.0, 1.0, 22.0]),
  DentalColor("Chromascope", "230", [231, 209, 168], [83.0, 2.0, 24.0]),
  DentalColor("Chromascope", "240", [226, 201, 157], [80.0, 3.0, 26.0]),
  DentalColor("Chromascope", "310", [237, 214, 175], [84.0, 2.0, 22.0]),
  DentalColor("Chromascope", "320", [232, 206, 165], [82.0, 3.0, 24.0]),
  DentalColor("Chromascope", "330", [227, 198, 155], [79.0, 4.0, 26.0]),
  DentalColor("Chromascope", "340", [221, 189, 143], [76.0, 5.0, 28.0]),
  DentalColor("Chromascope", "410", [231, 210, 179], [83.0, 1.0, 18.0]),
  DentalColor("Chromascope", "420", [225, 201, 169], [80.0, 2.0, 20.0]),
  DentalColor("Chromascope", "430", [219, 192, 158], [77.0, 3.0, 22.0]),
  DentalColor("Chromascope", "440", [212, 183, 146], [74.0, 4.0, 24.0]),
  DentalColor("Chromascope", "510", [223, 196, 160], [78.0, 3.0, 22.0]),
  DentalColor("Chromascope", "520", [217, 187, 149], [75.0, 4.0, 24.0]),
  DentalColor("Chromascope", "530", [211, 178, 138], [72.0, 5.0, 26.0]),
  DentalColor("Chromascope", "540", [204, 168, 126], [69.0, 6.0, 28.0])
];

// Metoda do wyszukiwania kolorów według skali
List<DentalColor> findColorsByScale(String scaleType) {
  return DENTAL_COLORS.where((color) => color.scaleType == scaleType).toList();
}

// Metoda do wyszukiwania konkretnego koloru po skali i kodzie
DentalColor? findColor(String scaleType, String colorCode) {
  try {
    return DENTAL_COLORS.firstWhere(
      (color) => color.scaleType == scaleType && color.colorCode == colorCode
    );
  } catch (e) {
    return null;
  }
}

// Metoda do znalezienia najbliższego koloru na podstawie wartości RGB
DentalColor findClosestColorByRgb(List<int> targetRgb) {
  DentalColor? closest;
  double minDistance = double.maxFinite;
  
  for (DentalColor color in DENTAL_COLORS) {
    double distance = calculateRgbDistance(targetRgb, color.rgb);
    if (distance < minDistance) {
      minDistance = distance;
      closest = color;
    }
  }
  
  return closest!;
}

// Metoda do znalezienia najbliższego koloru na podstawie wartości CIELAB
DentalColor findClosestColorByLab(List<double> targetLab) {
  DentalColor? closest;
  double minDistance = double.maxFinite;
  
  for (DentalColor color in DENTAL_COLORS) {
    double distance = calculateLabDistance(targetLab, color.lab);
    if (distance < minDistance) {
      minDistance = distance;
      closest = color;
    }
  }
  
  return closest!;
}

// Obliczanie odległości euklidesowej w przestrzeni RGB
double calculateRgbDistance(List<int> rgb1, List<int> rgb2) {
  return sqrt(
    pow(rgb1[0] - rgb2[0], 2) +
    pow(rgb1[1] - rgb2[1], 2) +
    pow(rgb1[2] - rgb2[2], 2)
  );
}

// Obliczanie odległości euklidesowej w przestrzeni CIELAB (ΔE)
double calculateLabDistance(List<double> lab1, List<double> lab2) {
  return sqrt(
    pow(lab1[0] - lab2[0], 2) +
    pow(lab1[1] - lab2[1], 2) +
    pow(lab1[2] - lab2[2], 2)
  );
}
