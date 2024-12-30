import 'dart:io';
import 'package:colony_counter/service/image_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widget_zoom/widget_zoom.dart';

part 'home_screen_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeScreenMixin {
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
            ValueListenableBuilder(
              valueListenable: selectedFile,
              builder: (context, value, child) {
                if (value == null) return const SizedBox.shrink();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (kIsWeb) {
                                return WidgetZoom(
                                  heroAnimationTag: 'networkImage',
                                  zoomWidget: Image.network(
                                    selectedFile.value!.path,
                                  ),
                                );
                              } else {
                                return WidgetZoom(
                                  heroAnimationTag: 'networkImage',
                                  zoomWidget: Image.file(File(
                                    selectedFile.value!.path,
                                  )),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SizedBox(
                            child: FutureBuilder(
                              key: UniqueKey(),
                              future: ImageService.instance.uploadImage(
                                  selectedFile.value!.path, isInverted.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data == null) {
                                    return const Text("Data is null");
                                  }

                                  return WidgetZoom(
                                    heroAnimationTag: 'tag',
                                    zoomWidget: Image.memory(snapshot.data!),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text(snapshot.error.toString()));
                                } else {
                                  return const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Görüntü İşleniyor...."),
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: isInverted,
              builder: (context, value, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox.adaptive(
                        value: value,
                        onChanged: (value) {
                          if (value != null) {
                            isInverted.value = value;
                          }
                        }),
                    const Text("Invert Image"),
                    const SizedBox(width: 24),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Görüntü Seç'),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16)
          ],
        ),
      ),
    );
  }
}
