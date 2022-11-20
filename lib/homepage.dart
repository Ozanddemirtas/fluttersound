import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voice_rec/player_widget.dart';
import 'package:voice_rec/record_button.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_file != null)
                PlayerWidget(
                  url: _file!.path,
                ),
              RecordButton(
                getFile: (file) async {
                  _file = file;
                  setState(() {});
                },
              ),
            ],
          )),
    );
  }
}
