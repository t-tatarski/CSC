import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sprawdzenie dostępnych aparatów
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    runApp(const NoCameraApp());
  } else {
    runApp(DentalCameraApp(cameras: cameras));
  }
}

class NoCameraApp extends StatelessWidget {
  const NoCameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Brak dostępnych aparatów')),
        body: const Center(
          child: Text('Nie znaleziono żadnego aparatu w urządzeniu.'),
        ),
      ),
    );
  }
}

class DentalCameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const DentalCameraApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  
  // Domyślne ustawienia
  double _currentExposureOffset = 0.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  
  // Ustawienia ISO i przysłony
  double _currentIsoValue = 100;
  double _minIsoValue = 100;
  double _maxIsoValue = 1600;
  
  double _currentApertureValue = 2.8;
  List<double> _availableApertureValues = [1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0];
  
  // Galeria zdjęć
  List<File> _capturedImages = [];
  
  // Aktualnie wybrany aparat
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // Przywrócenie kontrolera aparatu po wyjściu aplikacji z tła
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(widget.cameras[_currentCameraIndex]);
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    
    setState(() {
      _isPermissionGranted = status.isGranted && storageStatus.isGranted;
    });
    
    if (_isPermissionGranted) {
      _initializeCamera(widget.cameras[_currentCameraIndex]);
    }
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    controller = cameraController;

    try {
      await cameraController.initialize();
      
      // Sprawdzenie dostępnych zakresów parametrów aparatu
      _minAvailableExposureOffset = await cameraController.getMinExposureOffset();
      _maxAvailableExposureOffset = await cameraController.getMaxExposureOffset();
      _minAvailableZoom = await cameraController.getMinZoomLevel();
      _maxAvailableZoom = await cameraController.getMaxZoomLevel();
      
      // Ustawienie ISO i przysłony (jeśli dostępne w urządzeniu)
      try {
        await cameraController.setExposureMode(ExposureMode.manual);
        // Próba ustawienia wartości ISO - może nie działać na wszystkich urządzeniach
        // Niektóre API aparatów w Androidzie nie pozwalają na bezpośrednie ustawienie ISO
        // Ta część może wymagać dostosowania w zależności od urządzenia
      } catch (e) {
        print('Nie można ustawić manualnego trybu ekspozycji: $e');
      }
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Błąd podczas inicjalizacji aparatu: $e');
    }
  }

  void _switchCamera() {
    if (widget.cameras.length > 1) {
      setState(() {
        _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
        _isCameraInitialized = false;
      });
      _initializeCamera(widget.cameras[_currentCameraIndex]);
    }
  }

  Future<void> _takePicture() async {
    final CameraController? cameraController = controller;
    
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    try {
      // Ustawienie parametrów przed zrobieniem zdjęcia
      await cameraController.setExposureOffset(_currentExposureOffset);
      await cameraController.setZoomLevel(_currentZoomLevel);
      
      // Próba ustawienia ISO i przysłony (jeśli dostępne)
      try {
        // Ta część może nie działać na wszystkich urządzeniach
        // Niektóre API aparatów w Androidzie nie pozwalają na bezpośrednie ustawienie ISO
        // Możliwe, że będziesz musiał użyć natywnego kodu lub pluginu specyficznego dla platformy
      } catch (e) {
        print('Nie można ustawić manualnego ISO/przysłony: $e');
      }
      
      // Zrobienie zdjęcia
      final XFile photo = await cameraController.takePicture();
      
      // Zapisanie zdjęcia na urządzeniu
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'DENTAL_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
      final String filePath = path.join(directory.path, fileName);
      
      await File(photo.path).copy(filePath);
      
      // Zapisanie zdjęcia w galerii
      await ImageGallerySaver.saveFile(filePath);
      
      setState(() {
        _capturedImages.add(File(filePath));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zdjęcie zapisane: $fileName')),
      );
    } catch (e) {
      print('Błąd podczas robienia zdjęcia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dental Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Aplikacja wymaga dostępu do aparatu i pamięci'),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Udziel uprawnień'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dental Camera')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Camera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Podgląd aparatu
                CameraPreview(controller!),
                
                // Informacje o ustawieniach
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ISO: ${_currentIsoValue.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Przysłona: f/${_currentApertureValue.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Zoom: ${_currentZoomLevel.toStringAsFixed(1)}x',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Siatka ułatwiająca kadrowanie (opcjonalnie)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPainter(),
                  ),
                ),
              ],
            ),
          ),
          
          // Panel kontrolny
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Regulacja ISO
                Row(
                  children: [
                    const Text('ISO:', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _currentIsoValue,
                        min: _minIsoValue,
                        max: _maxIsoValue,
                        divisions: 6,
                        label: _currentIsoValue.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            _currentIsoValue = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      _currentIsoValue.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                
                // Regulacja przysłony
                Row(
                  children: [
                    const Text('Przysłona:', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _availableApertureValues.indexOf(_currentApertureValue).toDouble(),
                        min: 0,
                        max: (_availableApertureValues.length - 1).toDouble(),
                        divisions: _availableApertureValues.length - 1,
                        label: 'f/${_currentApertureValue.toStringAsFixed(1)}',
                        onChanged: (value) {
                          setState(() {
                            _currentApertureValue = _availableApertureValues[value.toInt()];
                          });
                        },
                      ),
                    ),
                    Text(
                      'f/${_currentApertureValue.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                
                // Regulacja zoomu
                Row(
                  children: [
                    const Text('Zoom:', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _currentZoomLevel,
                        min: _minAvailableZoom,
                        max: _maxAvailableZoom,
                        onChanged: (value) {
                          setState(() {
                            _currentZoomLevel = value;
                          });
                          controller?.setZoomLevel(value);
                        },
                      ),
                    ),
                    Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                
                // Przycisk do robienia zdjęć
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // Galeria zdjęć
      bottomNavigationBar: _capturedImages.isNotEmpty
          ? Container(
              height: 100,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imagePath: _capturedImages[index].path,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                        ),
                        child: Image.file(
                          _capturedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}

// Ekran podglądu zdjęcia
class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podgląd zdjęcia')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

// Rysowanie siatki pomocniczej
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Rysowanie linii poziomych
    for (int i = 1; i <= 2; i++) {
      final double dy = size.height / 3 * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    // Rysowanie linii pionowych
    for (int i = 1; i <= 2; i++) {
      final double dx = size.width / 3 * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
