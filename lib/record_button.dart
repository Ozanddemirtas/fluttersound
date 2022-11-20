import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordButton extends StatefulWidget {
  final Future Function(File file) getFile;

  const RecordButton({
    Key? key,
    required this.getFile,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final recorder = FlutterSoundRecorder();

  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    super.dispose();
    recorder.closeRecorder();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Mic permission not granted';
      //TODO Buraya izinlerle alakalı popup gelecekkk
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    widget.getFile(File(path!));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<RecordingDisposition>(
          stream: recorder.onProgress,
          builder: (context, snapshot) {
            final duration =
                snapshot.hasData ? snapshot.data!.duration : Duration.zero;

            return Text("${duration.inSeconds} s");
          },
        ),
        GestureDetector(
          onLongPressStart: (_) async {
            await record();

            setState(() {});
          },
          onLongPressEnd: (details) async {
            await stop();
            setState(() {});
          },
          child: Icon(
            recorder.isRecording ? Icons.stop : Icons.mic,
            size: 50,
          ),
        )
      ],
    );
  }
}
