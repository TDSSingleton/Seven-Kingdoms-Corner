import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quill_format/quill_format.dart';
import 'package:sk_flutter/compendiumclasses.dart';
import 'package:sk_flutter/helpers.dart';
import 'package:zefyrka/zefyrka.dart';
import 'dart:convert';
import 'package:path/path.dart' as filepath;

class CompendiumManager extends StatefulWidget {
  const CompendiumManager(
      {Key? key, required this.gamePath, required this.gameID})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "Compendium Manager";
  final String gamePath;
  final String gameID;

  @override
  State<CompendiumManager> createState() => _CompendiumManager(gamePath);
}

class _CompendiumManager extends State<CompendiumManager> {
  //Controllers
  ZefyrController _zController = ZefyrController();
  final TextEditingController _temporaryTextCont = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  //Selection Booleans
  int _selectedIndexColumns = -1;
  int _selectedIndexArticle = -1;
  //Misc data & Saved stuff
  String dropdownValue = 'None';
  String _currentCategoryString = "";
  CompendiumHolder compendiumHolder = CompendiumHolder();

  _CompendiumManager(String gamePath) {
    _setZcontrollerEvent();
    compendiumHolder = _setCompendiumData(gamePath);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
          toolbarHeight: 48,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(Icons.save),
                iconSize: 26.0,
                onPressed: () {
                  _saveJSON();
                },
              ),
            ),
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
                    SizedBox(
                        width: 450,
                        child: Text(
                          "Main Categories",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.5,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 200,
                      width: 450,
                      child: Container(
                        color: Colors.black26,
                        child: ListView.builder(
                            itemCount: compendiumHolder.mainCategories.length,
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            itemBuilder: (context, index) => ListTile(
                                  title: Text(
                                      compendiumHolder.mainCategories[index]),
                                  selected: _selectedIndexColumns == index,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndexColumns = index;
                                      _selectedIndexArticle = -1;
                                      var textIndex = compendiumHolder
                                          .mainCategories[index];
                                      _currentCategoryString = "in $textIndex";
                                    });
                                  },
                                  onLongPress: () {
                                    Helpers.displayAlertDialogueNumPass(
                                        context, removeCategory, index,
                                        textTitle:
                                            "Are you sure you want to remove this category?");
                                  },
                                )),
                      ),
                    ),
                    SizedBox(
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
                                    textTitle: "New main category");
                              });
                            },
                            child: const Text("Add new Category"),
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
                          "Articles $_currentCategoryString",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1.5,
                        )),
                    SizedBox(
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
                    SizedBox(
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
                                  textTitle: "New article");
                            },
                            child: Text("Add new Article"),
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
                      Align(
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
                          setState(() => compendiumHolder
                              .subCategories[_selectedIndexColumns]
                              .categoryArticles[_selectedIndexArticle]
                              .title = val);
                        },
                      )),
                      SizedBox(
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
                            "Subtitle",
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                          )),
                      Expanded(
                          child: TextField(
                        controller: _subtitleController,
                        onChanged: (val) {
                          if (_selectedIndexArticle < 0) return;
                          setState(() => compendiumHolder
                              .subCategories[_selectedIndexColumns]
                              .categoryArticles[_selectedIndexArticle]
                              .subtitle = val);
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
                SizedBox(
                  height: 75,
                  width: 450,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            "Image",
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                          )),
                      Expanded(
                          flex: 6,
                          child: DropdownButtonFormField(
                            value: dropdownValue,
                            items: _returnDropdownItems(),
                            onChanged: (String? newValue) {
                              var probe = 0;
                              if (_selectedIndexArticle >= 0) {
                                setState(() {
                                  dropdownValue = newValue!;
                                  compendiumHolder
                                          .subCategories[_selectedIndexColumns]
                                          .categoryArticles[_selectedIndexArticle]
                                          .image =
                                      compendiumImage.values.firstWhere(
                                          (element) =>
                                              element.name == newValue);
                                });
                              }
                            },
                          ))
                    ],
                  ),
                )
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
        itemCount: compendiumHolder
            .subCategories[_selectedIndexColumns].categoryArticles.length,
        scrollDirection: Axis.vertical,
        controller: ScrollController(),
        itemBuilder: (context, index) => ListTile(
              title: Text(compendiumHolder.subCategories[_selectedIndexColumns]
                  .categoryArticles[index].title),
              selected: _selectedIndexArticle == index,
              onTap: () {
                setState(() {
                  _selectedIndexArticle = index;
                  _titleController.text = compendiumHolder
                      .subCategories[_selectedIndexColumns]
                      .categoryArticles[index]
                      .title;
                  _subtitleController.text = compendiumHolder
                      .subCategories[_selectedIndexColumns]
                      .categoryArticles[index]
                      .subtitle;
                  var desc = compendiumHolder
                      .subCategories[_selectedIndexColumns]
                      .categoryArticles[index]
                      .description;
                  //Swap text.
                  var newNotus = NotusDocument.fromDelta(Delta()
                    ..insert(
                        "${compendiumHolder.subCategories[_selectedIndexColumns].categoryArticles[index].description}\n"));
                  _zController = ZefyrController(newNotus);
                  _setZcontrollerEvent();
                  dropdownValue = compendiumHolder
                      .subCategories[_selectedIndexColumns]
                      .categoryArticles[index]
                      .image
                      .name;
                });
              },
            ));
  }

  void createCategory() {
    setState(() {
      compendiumHolder.mainCategories.add(_temporaryTextCont.text);
      compendiumHolder.subCategories.add(CompendiumCategory());
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
      compendiumHolder.mainCategories.removeAt(indexRemoval);
      compendiumHolder.subCategories.removeAt(indexRemoval);
      resetIndices();
      _currentCategoryString = "";
    });
  }

  void _setZcontrollerEvent() {
    _zController.document.changes.listen((event) {
      if (_selectedIndexArticle >= 0) {
        compendiumHolder
            .subCategories[_selectedIndexColumns]
            .categoryArticles[_selectedIndexArticle]
            .description = _zController.document.toPlainText();
      }
    });
  }

  void _createArticle() {
    if (_selectedIndexColumns < 0) return;
    setState(() {
      compendiumHolder.subCategories[_selectedIndexColumns].categoryArticles
          .add(CompendiumArticle.titleDefined(_temporaryTextCont.text));
    });
  }

  CompendiumHolder _setCompendiumData(String gamePath) {
    var testProvider = gamePath;
    var dataFile = File(filepath.join(
        testProvider, "Assets", "Resources", "Compendium", "Compendium.json"));
    if (dataFile.existsSync()) {
      return jsonDecode(dataFile.readAsStringSync()) as CompendiumHolder;
    }
    return CompendiumHolder();
  }

  List<DropdownMenuItem<String>> _returnDropdownItems() {
    List<String> compendiumItemList =
        compendiumImage.values.map<String>((e) => e.name).toList();
    return compendiumItemList.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  void _saveJSON() {
    var testProvider = widget.gamePath;
    var dataFile = File(filepath.join(
        testProvider, "Assets", "Resources", "Compendium", "Compendium.json"));
    var results = jsonEncode(compendiumHolder);
    dataFile.writeAsStringSync(results);
  }
}
