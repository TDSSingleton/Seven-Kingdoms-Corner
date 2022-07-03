import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quill_format/quill_format.dart';
import 'package:sk_flutter/compendiumclasses.dart';
import 'package:sk_flutter/helpers.dart';
import 'package:zefyrka/zefyrka.dart';
import 'dart:convert';
import 'package:path/path.dart' as filepath;

import 'campaignclasses.dart';

class CampaignManager extends StatefulWidget {
  const CampaignManager(
      {Key? key, required this.gamePath, required this.gameID})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "Campaign Manager";
  final String gamePath;
  final String gameID;

  @override
  State<CampaignManager> createState() => _CampaignManager(gamePath);
}

class _CampaignManager extends State<CampaignManager> {
  //Controllers
  ZefyrController _zController = ZefyrController();
  final TextEditingController _temporaryTextCont = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  //Selection Booleans
  int _selectedIndexColumns = -1;
  int _selectedIndexArticle = -1;
  //Misc data & Saved stuff
  String _currentCategoryString = "";
  String _campaignTitle = "OWS";
  String gPath = "";
  Campaign campaignHolder = Campaign();

  _CampaignManager(String gamePath) {
    gPath = gamePath;
    _setZcontrollerEvent();
    _setCampaignData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
          toolbarHeight: 48,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: SizedBox(
                width: 60,
                height: 15,
                child: DropdownButtonFormField(
                  value: _campaignTitle,
                  items: _getCampaigns(),
                  onChanged: (String? val) {
                    _temporaryTextCont.text = val!;
                    Helpers.displayAlertDialogue(
                        context, _SaveThenLoadOtherJSON,
                        textTitle:
                            "Would you like to save the contents before switching?");
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(Icons.save),
                iconSize: 26.0,
                onPressed: () {
                  _saveJSON();
                },
              ),
            )
          ],
        ),
        body: _generateBody());
  }

  Widget _generateBody() {
    return Row(
      children: [
        const Spacer(flex: 5),
        Expanded(
            flex: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(
                        width: 450,
                        child: Text(
                          "Nations",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.5,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 200,
                      width: 450,
                      child: Container(
                        color: Colors.black26,
                        child: ListView.builder(
                            itemCount: campaignHolder.nationNames.length,
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            itemBuilder: (context, index) => ListTile(
                                  title:
                                      Text(campaignHolder.nationNames[index]),
                                  selected: _selectedIndexColumns == index,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndexColumns = index;
                                      _selectedIndexArticle = -1;
                                      var textIndex =
                                          campaignHolder.nationNames[index];
                                      _currentCategoryString = "in $textIndex";
                                    });
                                  },
                                  onLongPress: () {
                                    Helpers.displayAlertDialogueNumPass(
                                        context, removeCategory, index,
                                        textTitle:
                                            "Are you sure you want to remove this Nation?");
                                  },
                                )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                      width: 450,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _temporaryTextCont.text = "";
                                Helpers.displayTextInputDialog(
                                    context, _temporaryTextCont, createCategory,
                                    textTitle: "New Nation");
                              });
                            },
                            child: const Text("Add new Nation"),
                          )),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                        width: 450,
                        child: Text(
                          "Maps $_currentCategoryString",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.5,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 200,
                      width: 450,
                      child: Container(
                        color: Colors.black26,
                        child: _generateArticlesFlexview(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                      width: 450,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              _temporaryTextCont.text = "";
                              Helpers.displayTextInputDialog(
                                  context, _temporaryTextCont, _createArticle,
                                  textTitle: "New map");
                            },
                            child: const Text("Add new Map"),
                          )),
                    )
                  ],
                ),
              ],
            )),
        const Spacer(flex: 10),
        Expanded(
            flex: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 450,
                  child: Column(
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Title",
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                          )),
                      Expanded(
                          child: TextField(
                        controller: _titleController,
                        onChanged: (val) {
                          if (_selectedIndexArticle < 0) return;
                          setState(() => campaignHolder
                              .maps[_selectedIndexColumns]
                              .nationMaps[_selectedIndexArticle]
                              .title = val);
                        },
                      )),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                  width: 450,
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Map ID",
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                          )),
                      Expanded(
                          child: TextField(
                        controller: _subtitleController,
                        onChanged: (val) {
                          if (_selectedIndexArticle < 0) return;
                          setState(() => campaignHolder
                              .maps[_selectedIndexColumns]
                              .nationMaps[_selectedIndexArticle]
                              .mapID = val);
                        },
                      )),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 350,
                  width: 450,
                  child: Column(children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Description",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.5,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.black26,
                        child: ZefyrEditor(
                          controller: _zController,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            )),
        const Spacer(flex: 5),
      ],
    );
  }

  ListView _generateArticlesFlexview() {
    if (_selectedIndexColumns < 0)
      return ListView(controller: ScrollController());
    return ListView.builder(
        itemCount: campaignHolder.maps[_selectedIndexColumns].nationMaps.length,
        scrollDirection: Axis.vertical,
        controller: ScrollController(),
        itemBuilder: (context, index) => ListTile(
              title: Text(campaignHolder
                  .maps[_selectedIndexColumns].nationMaps[index].title),
              selected: _selectedIndexArticle == index,
              onTap: () {
                setState(() {
                  _selectedIndexArticle = index;
                  _titleController.text = campaignHolder
                      .maps[_selectedIndexColumns].nationMaps[index].title;
                  _subtitleController.text = campaignHolder
                      .maps[_selectedIndexColumns].nationMaps[index].mapID;
                  var desc = campaignHolder.maps[_selectedIndexColumns]
                      .nationMaps[index].description;
                  //Swap text.
                  var newNotus = NotusDocument.fromDelta(Delta()
                    ..insert(
                        "${campaignHolder.maps[_selectedIndexColumns].nationMaps[index].description}\n"));
                  _zController = ZefyrController(newNotus);
                  _setZcontrollerEvent();
                });
              },
            ));
  }

  void createCategory() {
    setState(() {
      campaignHolder.nationNames.add(_temporaryTextCont.text);
      campaignHolder.maps.add(Nation());
      resetIndices();
      _currentCategoryString = "";
    });
  }

  void resetIndices() {
    _selectedIndexColumns = -1;
    _selectedIndexArticle = -1;
  }

  void removeCategory(int indexRemoval) {
    setState(() {
      campaignHolder.nationNames.removeAt(indexRemoval);
      campaignHolder.maps.removeAt(indexRemoval);
      resetIndices();
      _currentCategoryString = "";
    });
  }

  void _setZcontrollerEvent() {
    _zController.document.changes.listen((event) {
      if (_selectedIndexArticle >= 0) {
        campaignHolder
            .maps[_selectedIndexColumns]
            .nationMaps[_selectedIndexArticle]
            .description = _zController.document.toPlainText();
      }
    });
  }

  void _createArticle() {
    if (_selectedIndexColumns < 0) return;
    setState(() {
      campaignHolder.maps[_selectedIndexColumns].nationMaps
          .add(GameMap.titleDefined(_temporaryTextCont.text));
    });
  }

  Campaign _setCampaignData() {
    var dataFile = File(filepath.join(
        gPath, "Assets", "Resources", "Campaign", "$_campaignTitle.json"));
    if (dataFile.existsSync()) {
      return jsonDecode(dataFile.readAsStringSync()) as Campaign;
    }
    return Campaign();
  }

  void _saveJSON() {
    var testProvider = widget.gamePath;
    var dataFile = File(filepath.join(testProvider, "Assets", "Resources",
        "Campaign", "$_campaignTitle.json"));
    var results = jsonEncode(campaignHolder);
    dataFile.writeAsStringSync(results);
  }

  void _SaveThenLoadOtherJSON() {
    _saveJSON();
    setState(() {
      _campaignTitle = _temporaryTextCont.text;
      _setCampaignData();
    });
  }

  List<DropdownMenuItem<String>>? _getCampaigns() {
    List<String> compendiumItemList =
        campaignID.values.map<String>((e) => e.name).toList();
    return compendiumItemList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }
}
