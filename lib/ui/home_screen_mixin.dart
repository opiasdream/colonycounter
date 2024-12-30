part of 'home_screen.dart';

mixin HomeScreenMixin on State<HomeScreen> {
  final selectedFile = ValueNotifier<XFile?>(null);

  final isInverted = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedFile.value = pickedFile;
    }
  }
}
