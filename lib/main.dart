import 'package:flutter/material.dart';
import 'package:secure_storage_example/util/cached_settings.dart';
import 'package:secure_storage_example/util/file_utils.dart';
import 'package:secure_storage_example/util/secure_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Secure Settings Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FileUtils fileService = FileUtils();
  final Map<String, String> settings = {
    'email': 'test@test.de',
    'loginToken': 'jwtSomething',
    'refreshToken': 'asdf',
    'userId': '1',
  };
  late SecureSettings secureSettings;

  MyHomePage({Key? key, required this.title}) : super(key: key) {
    CachedSettings cachedSettings = CachedSettings(settings);
    secureSettings = SecureSettings(cachedSettings, fileService);
  }

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerToken = TextEditingController();
  final TextEditingController _controllerRefreshToken = TextEditingController();
  final TextEditingController _controllerUserId = TextEditingController();

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerToken.dispose();
    _controllerRefreshToken.dispose();
    _controllerUserId.dispose();

    super.dispose();
  }

  void _saveSettings() {
    widget.secureSettings.saveSettings();
    widget.secureSettings.saveString('email', _controllerEmail.text);
    widget.secureSettings.saveString('loginToken', _controllerToken.text);
    widget.secureSettings.saveString('refreshToken', _controllerRefreshToken.text);
    widget.secureSettings.saveString('userId', _controllerUserId.text);
    setState(() {});
  }

  Future<void> _loadSettings() async {
    await widget.secureSettings.loadSettings();

    _controllerEmail.text = await widget.secureSettings.loadString('email');
    _controllerToken.text = await widget.secureSettings.loadString('loginToken');
    _controllerRefreshToken.text = await widget.secureSettings.loadString('refreshToken');
    _controllerUserId.text = await widget.secureSettings.loadString('userId');

    setState(() {});
  }

  Future<void> _clearTextFields() async {
    await widget.secureSettings.loadSettings();

    _controllerEmail.text = '';
    _controllerToken.text = '';
    _controllerRefreshToken.text = '';
    _controllerUserId.text = '';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'email',
                ),
                controller: _controllerEmail,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'loginToken',
                ),
                controller: _controllerToken,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'refreshToken',
                ),
                controller: _controllerRefreshToken,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'userId',
                ),
                controller: _controllerUserId,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _saveSettings,
              tooltip: 'Save',
              child: const Icon(Icons.save),
            ),
            FloatingActionButton(
              onPressed: _loadSettings,
              tooltip: 'Load',
              child: const Icon(Icons.folder_open),
            ),
            FloatingActionButton(
              onPressed: _clearTextFields,
              tooltip: 'Clear',
              child: const Icon(Icons.clear),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
