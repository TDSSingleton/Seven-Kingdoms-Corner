import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Helpers {
  static Future<void> displayTextInputDialog(BuildContext context,
      TextEditingController textFieldController, Function callback,
      {String textTitle = "Input a value"}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(textTitle),
            content: TextField(
                onChanged: (value) {}, controller: textFieldController),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    callback();
                    Navigator.pop(context);
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }

  static Future<void> displayAlertDialogue(
      BuildContext context, Function callback,
      {String textTitle = "Input a value"}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(textTitle),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    callback();
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"))
            ],
          );
        });
  }

  static Future<void> displayAlertDialogueNumPass(
      BuildContext context, Function callback, int numberPass,
      {String textTitle = "Input a value"}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(textTitle),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    callback(numberPass);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"))
            ],
          );
        });
  }
}
