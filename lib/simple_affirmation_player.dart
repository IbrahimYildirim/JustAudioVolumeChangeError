import 'package:just_audio/just_audio.dart';

class SimplePlayer {
  AudioPlayer player = AudioPlayer();

  SimplePlayer(String pathToRecording) {
    //Setup Playlist
    List<AudioSource> playlist = [];
    String breakSoundFile = 'asset:///assets/audio/3_second_silence.mp3';

    //Add recording
    //Followed by 3 second break
    //20 Times
    for (int i = 0; i < 20; i++) {
      playlist.add(AudioSource.uri(Uri.file(pathToRecording)));
      playlist.add(AudioSource.uri(Uri.parse(breakSoundFile)));
    }

    final sessionAudioSource = ConcatenatingAudioSource(children: playlist);
    player.setLoopMode(LoopMode.all);
    player.setAudioSource(sessionAudioSource);
  }

  play() {
    // debugPrint('Playing');
    player.play();
  }

  pause() {
    // debugPrint('Pause');
    player.pause();
  }

  setVolume(double volume) {
    player.setVolume(volume);
  }
}
