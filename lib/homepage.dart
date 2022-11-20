import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final recorder = FlutterSoundRecorder();
  //final audioPlayer = AudioPlayer();
  //late AudioCache audioCache = AudioCache();
  late File audioFile;

  bool isRecorderReady = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    initRecorder();
    //audioCache = AudioCache(prefix: audioFile.path);
//
    //audioPlayer.onPlayerStateChanged.listen((s) {
    //  setState(() {
    //    isPlaying = s == PlayerState.playing;
    //  });
    //});
//
    //audioPlayer.onDurationChanged.listen((newDuration) {
    //  setState(() {
    //    duration = newDuration;
    //  });
    //});
//
    //audioPlayer.onPositionChanged.listen((newPosition) {
    //  setState(() {
    //    position = newPosition;
    //  });
    //});
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    // audioPlayer.dispose();

    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Mic permission not granted';
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
    audioFile = File(path!);
    print('Record audio: $audioFile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //   Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Row(
              //       children: [
              //         Container(
              //           height: 50,
              //           width: 50,
              //           decoration: BoxDecoration(
              //               color: Colors.amber,
              //               borderRadius: BorderRadius.circular(100)),
              //           child: IconButton(
              //             onPressed: () async {
              //               if (isPlaying) {
              //                 await audioPlayer.stop();
              //               } else {
              //                 await audioPlayer.setSourceAsset(audioFile.path);
              //                 audioPlayer.play(aaaaa);
              //               }
              //               setState(() {});
              //             },
              //             icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              //           ),
              //         ),
              //         Expanded(
              //           child: Slider(
              //               min: 0,
              //               value: position.inSeconds.toDouble(),
              //               onChanged: (v) async {}),
              //         ),
              //       ],
              //     ),
              //   ),
              // Padding(
              //   padding: const EdgeInsets.all(15.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(position.toString()),
              //       Text((duration - position).toString()),
              //     ],
              //   ),
              // ),
              StreamBuilder<RecordingDisposition>(
                stream: recorder.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;

                  return Text("${duration.inSeconds} s");
                },
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  onPressed: () async {
                    if (recorder.isRecording) {
                      await stop();
                    } else {
                      await record();
                    }
                    setState(() {});
                  },
                  icon: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
                ),
              )
            ],
          )),
    );
  }
}
