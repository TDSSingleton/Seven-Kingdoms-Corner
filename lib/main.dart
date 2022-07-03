import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as filepath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sk_flutter/compendiummanager.dart';
import 'package:window_manager/window_manager.dart';

import 'chaptermanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 850),
    maximumSize: Size(1280, 850),
    minimumSize: Size(1280, 850),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seven Kingdoms Corner',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark),
      home: const MyHomePage(title: 'Seven Kingdoms Corner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? projectLocation;
  Map<String, dynamic> projectData = {};
  String dataString = "";
  bool _compendiumManagerTileEnabled = false;

  _MyHomePageState() {
    _checkExistingProject();
  }

  void _setDeviceSetupText() {
    if (projectLocation != null) {
      setState(() {
        String projectID = projectData['cornerID'];
        dataString = 'Loaded Unity Project. ID $projectID';
      });
    }
  }

  Future<void> _checkExistingProject() async {
    final prefs = await SharedPreferences.getInstance();
    projectLocation = prefs.getString("ProjectPath");
    if (projectLocation != null && projectLocation!.isNotEmpty) {
      setState(() {
        _compendiumManagerTileEnabled = true;
        var dataFile = File(filepath.join(
            projectLocation!, "ProjectSettings", "SeldronCorner.sdr"));
        projectData = jsonDecode(dataFile.readAsStringSync());
      });
    }
  }

  Future<void> _chooseProjectPath() async {
    final prefs = await SharedPreferences.getInstance();
    var testProvider = await FilePicker.platform.getDirectoryPath();
    if (testProvider == null) return;
    var dataFile = File(
        filepath.join(testProvider, "ProjectSettings", "SeldronCorner.sdr"));
    if (dataFile.existsSync()) {
      projectData = jsonDecode(dataFile.readAsStringSync());
      if (projectData['cornerID'] == "SK") {
        projectLocation = testProvider;
        prefs.setString("ProjectPath", testProvider);
        _setDeviceSetupText();
        _compendiumManagerTileEnabled = true;
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                returnBasicAlert("Chosen folder lacks ID inside file."));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              returnBasicAlert("Chosen folder lacks identifying file."));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          centerTitle: true,
          title: Text(widget.title),
          toolbarHeight: 48,
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: returnMainBody()),
        floatingActionButton: FloatingActionButton(
          onPressed: _chooseProjectPath,
          tooltip: '[INTERNAL] Add Unity project.',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        drawer: Drawer(
            width: 320,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  //We added testing children.
                  Column(
                    children: [
                      const DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 160),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          image: DecorationImage(
                              image: AssetImage('assets/images/SK_Bar1.png'),
                              fit: BoxFit.fitWidth),
                        ),
                        child: Text(''),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: const Text('Compendium Data Manager'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompendiumManager(
                                    gamePath: projectLocation!,
                                    gameID: projectData['cornerID']))),
                        enabled: _compendiumManagerTileEnabled,
                      ),
                      ListTile(
                          leading: const Icon(Icons.map),
                          title: const Text('Campaign Manager'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CampaignManager(
                                      gamePath: projectLocation!,
                                      gameID: projectData['cornerID'])))),
                      ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Map Manager'),
                          onTap: () {})
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ListTile(
                          onTap: () {},
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ListTile(
                          onTap: () {
                            showAboutDialog(
                                context: context,
                                applicationIcon: const Icon(Icons.star),
                                applicationName:
                                    "Seldron - Seven Kingdoms Corner",
                                applicationLegalese: "Developed by Singleton");
                          },
                          leading: const Icon(Icons.question_mark),
                          title: const Text('About'),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ListTile(
                          minLeadingWidth: 30,
                          subtitle: Text(dataString),
                        ),
                      ),
                    ],
                  )
                ])));
  }

  AlertDialog returnBasicAlert(String contents) {
    return AlertDialog(
      title: const Text("Alert"),
      content: Text(contents),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget returnMainBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Seven Kingdoms Corner!'),
            const Text(
                'We are planning to add multiple news and other elements here in the future.')
          ],
        )
      ],
    );
  }
}
