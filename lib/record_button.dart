import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slide_to_act/slide_to_act.dart';

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
        // Builder(
        //   builder: (context) {
        //     final GlobalKey<SlideActionState> _key = GlobalKey();
        //     return Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: SlideAction(
        //         reversed: true,
        //         sliderButtonIcon: Icon(
        //           Icons.mic,
        //         ),
        //         child: Text(
        //           "Slide to cancel",
        //           style: TextStyle(color: Colors.black, fontSize: 17),
        //         ),
        //         key: _key,
        //         onSubmit: () async {
        //           Future.delayed(
        //             Duration(seconds: 1),
        //             () => _key.currentState?.reset(),
        //           );
        //           await stop();
        //         },
        //       ),
        //     );
        //   },
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Slide to cancel",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            SizedBox(width: 20),
            Column(
              children: [
                StreamBuilder<RecordingDisposition>(
                  stream: recorder.onProgress,
                  builder: (context, snapshot) {
                    final duration = snapshot.hasData
                        ? snapshot.data!.duration
                        : Duration.zero;
                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final twDigitMinutes =
                        twoDigits(duration.inMinutes.remainder(60));
                    final twoDigitSeconds =
                        twoDigits(duration.inSeconds.remainder(60));

                    return Text("$twDigitMinutes:$twoDigitSeconds");
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
                  // onLongPressMoveUpdate: (details) async {
                  //   await recorder.closeRecorder();
                  //   setState(() {
                  //     isRecorderReady = false;
                  //   });
                  // },
                  child: Icon(
                    recorder.isRecording ? Icons.stop : Icons.mic,
                    size: 50,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
