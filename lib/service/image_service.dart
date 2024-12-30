import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  ImageService._();
  static final instance = ImageService._();

  final _dio = Dio();

  // String get _baseUrl => kIsWeb || Platform.isIOS
  //     ? "http://127.0.0.1:8000"
  //     : "http://10.0.2.2:8000";

  String get _baseUrl => "http://192.168.1.2:8000";

  Future<Uint8List?> uploadImage(String filePath, bool isInverted) async {
    try {
      // Get the actual filename from the path
      final filename = filePath.split('/').last;

      // Determine MIME type based on file extension
      String contentType = 'image/jpeg'; // default
      if (filename.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (filename.toLowerCase().endsWith('.jpg') ||
          filename.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      }

      final image = await MultipartFile.fromFile(
        filePath,
        filename: filename,
        contentType: DioMediaType.parse(contentType),
      );

      final formData = FormData.fromMap({'file': image});

      final res = await _dio.post(
        "$_baseUrl/process-image/",
        data: formData,
        queryParameters: {'isInverted': isInverted},
        options: Options(
            responseType: ResponseType.bytes,
            validateStatus: (status) {
              return status != null && status < 500;
            }),
      );

      if (res.statusCode == 200) {
        return Uint8List.fromList(res.data);
      } else {
        String errorMessage;
        if (res.data is List<int>) {
          errorMessage = String.fromCharCodes(res.data);
        } else {
          errorMessage = res.data.toString();
        }

        return Future.error("Server error: $errorMessage");
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}
