import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_recording_volume/audio_recorder.dart';
import 'package:just_audio_recording_volume/simple_affirmation_player.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  // final AudioPlayer _backgroundPlayer = AudioPlayer();

  SimplePlayer? simplePlayer;

  double _volume = 0.5;

  bool _isRecording = false;
  bool _hasRecording = false;
  bool _hasPermission = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    Permission.microphone.isGranted.then((value) {
      _hasPermission = value;
      if (mounted) setState(() {});
    });
    _initAudio();
  }

  _initAudio() async {
    // _backgroundPlayer.setAudioSource(AudioSource.uri(Uri.parse('asset:///assets/audio/background.mp3')));
  }

  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  _loadAudioPlayer() {
    List<AudioSource> playlist = [];
    for (int i = 0; i < 200; i++) {
      playlist.add(AudioSource.uri(Uri.file(_recorder.pathToRecordingFile)));
    }
  }

  _updateVolume() {
    simplePlayer?.setVolume(_volume);
    // _backgroundPlayer.setVolume(min(-_volume + 0.8, 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changing Recording Volume'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: !_hasPermission
              ? Center(
                  child: ElevatedButton(
                      onPressed: () {
                        requestMicrophonePermission();
                      },
                      child: const Text('Request Microphone Permission')))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Make a 3-4 second recording recording',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_isRecording) {
                          _recorder.startRecorder();
                        } else {
                          _recorder.stopRecording();
                          _loadAudioPlayer();
                          _hasRecording = true;
                        }
                        setState(() {
                          _isRecording = !_isRecording;
                        });
                      },
                      child: Text(_isRecording ? 'Stop' : 'Record'),
                    ),
                    const SizedBox(height: 60),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 333),
                      child: !_hasRecording
                          ? Container()
                          : Column(
                              children: [
                                const Text(
                                  'Play Recording while adjusting volume',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  '(Looping with 3 sec silent break between)',
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                    onPressed: () {
                                      if (_isPlaying) {
                                        simplePlayer?.pause();
                                        // _backgroundPlayer.stop();
                                        _isPlaying = false;
                                      } else {
                                        simplePlayer ??= SimplePlayer(_recorder.pathToRecordingFile);
                                        simplePlayer?.play();
                                        // _backgroundPlayer.play();
                                        _isPlaying = true;
                                      }
                                      setState(() {});
                                    },
                                    child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow_rounded)),
                                const SizedBox(height: 12),
                                Slider(
                                    value: _volume,
                                    onChanged: (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                      _updateVolume();
                                    }),
                              ],
                            ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Seems like audio takes a "break" when changing volume while the audio is playing.',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
        ),
      ),
    );
  }
}
