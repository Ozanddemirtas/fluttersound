import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:voice_rec/format.dart';

class PlayerWidget extends StatefulWidget {
  final String url;
  const PlayerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with TickerProviderStateMixin {
  late AudioPlayer player;
  late bool initialized;
  late AnimationController _animationController;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialized = false;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    init();
  }

  //as
  Future<void> init() async {
    player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    player.onPlayerStateChanged.listen((s) {
      setState(() {
        initialized = s == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });

    player.onPositionChanged.listen((p) {
      player.onPositionChanged.listen((p) {
        setState(() {
          position = p;
        });
      });
    });
    await player.setSourceDeviceFile(widget.url);
    // await setDuration();
    // player.onPositionChanged.listen((event) {
    //   position = event;
    //   print(position);
    //   setState(() {});
    // });
    Future.microtask(() {
      initialized = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.amber),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (player.state == PlayerState.playing) {
                              player.pause();
                            } else if (player.state == PlayerState.completed ||
                                player.state == PlayerState.stopped) {
                              player.play(DeviceFileSource(widget.url));
                              // await player.play(BytesSource(File(widget.url).readAsBytesSync()));
                              // await player.seek(Duration(seconds: 1));
                            } else {
                              player.resume();
                            }
                          },
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _animationController,
                          )),
                      if (duration != null)
                        Expanded(
                          child: Slider(
                            onChanged: (value) async {
                              final _position =
                                  Duration(seconds: value.toInt());
                              await player.seek(_position);
                            },
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
                            min: 0,
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 35.0, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(formatTime(position)),
                        Text(" - "),
                        Text(formatTime(duration - position))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
