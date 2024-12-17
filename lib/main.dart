import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:io';

void main() {
  runApp(const CellCountingApp());
}

class CellCountingApp extends StatelessWidget {
  const CellCountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hücre Sayma Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const CellCountingPage(),
    );
  }
}

class CellCountingPage extends StatefulWidget {
  const CellCountingPage({super.key});

  @override
  _CellCountingPageState createState() => _CellCountingPageState();
}

class _CellCountingPageState extends State<CellCountingPage> {
  File? _imageFile;
  int _cellCount = 0;
  String _debugInfo = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _debugInfo = ''; // Hata ayıklama bilgisini sıfırla
      });
      _countCells();
    }
  }

  void _countCells() {
    if (_imageFile == null) return;

    try {
      // Resmi OpenCV formatına dönüştür
      cv.Mat? originalImage = cv.imread(_imageFile!.path);

      // Görüntüyü yeniden boyutlandır (performans ve tutarlılık için)
      cv.Mat image = cv.resize(originalImage, (1500, 1500));

      // Gri tona çevir
      cv.Mat grayImage = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

      // Gürültüyü azalt
      cv.Mat blurredImage = cv.gaussianBlur(grayImage, (5, 5), 0);

      // Adaptif eşikleme (tersten thresholding)
      cv.Mat binaryImage = cv.adaptiveThreshold(blurredImage, 255,
          cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 11, 2);

      // Morfolojik işlemlerle küçük nesneleri temizle ve büyükleri birbirinden ayır
      cv.Mat kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (5, 5));

      // Açma ve kapama işlemleri
      cv.Mat openedImage = cv.morphologyEx(binaryImage, cv.MORPH_OPEN, kernel);
      cv.Mat closedImage = cv.morphologyEx(openedImage, cv.MORPH_CLOSE, kernel);

      // Bağlantılı bileşen analizi
      cv.Mat labels =
          cv.Mat.zeros(closedImage.rows, closedImage.cols, cv.MatType.CV_32SC1);
      cv.Mat stats =
          cv.Mat.zeros(closedImage.rows, closedImage.cols, cv.MatType.CV_32SC1);
      cv.Mat centroids =
          cv.Mat.zeros(closedImage.rows, closedImage.cols, cv.MatType.CV_32FC2);

      // Bağlantılı bileşenleri bul
      int numLabels = cv.connectedComponentsWithStats(
        closedImage,
        labels,
        stats,
        centroids,
        8, // Bağlantı tipi
        cv.MatType.CV_32S,
        0, // TODO CHECK
      );

      // Hücre sayısını hesapla
      int cellCount = 0;
      for (int i = 1; i < numLabels; i++) {
        // 0 arka plan, 1'den başla
        // İstatistikleri al
        int area = stats.at<int>(i, cv.CC_STAT_AREA);
        int width = stats.at<int>(i, cv.CC_STAT_WIDTH);
        int height = stats.at<int>(i, cv.CC_STAT_HEIGHT);

        // Alan ve boyut filtresi
        if (area > 50 &&
            area < 5000 &&
            width > 5 &&
            width < 200 &&
            height > 5 &&
            height < 200) {
          cellCount++;
        }
      }

      // Sonuçları güncelle
      _updateState('Hücre sayısı hesaplandı', cellCount);
    } catch (e) {
      _updateState('Hata oluştu: $e', 0);
    }
  }

  void _updateState(String debugInfo, int cellCount) {
    setState(() {
      _cellCount = cellCount;
      _debugInfo = debugInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hücre Sayma Uygulaması'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                : const Text('Henüz görüntü seçilmedi'),
            const SizedBox(height: 20),
            Text(
              'Toplam Hücre Sayısı: $_cellCount',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _debugInfo,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Görüntü Seç'),
            ),
          ],
        ),
      ),
    );
  }
}
