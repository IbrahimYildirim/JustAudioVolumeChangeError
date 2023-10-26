import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorder {
  Record? _recorder;
  bool get isRecording => _recorder != null;

  Directory? _storageDirectory;
  String get pathToRecordingFile => '${_storageDirectory?.path}/recording.aac';
  bool get hasRecording => File(pathToRecordingFile).existsSync();

  AudioRecorder() {
    _setupDirectory();
  }

  _setupDirectory() async {
    if (Platform.isAndroid) {
      await getExternalStorageDirectory().then((directory) {
        _storageDirectory = directory;
      });
    } else if (Platform.isIOS) {
      await getLibraryDirectory().then((directory) {
        _storageDirectory = directory;
      });
    }
  }

  Future<bool> startRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      debugPrint('No Permission!');
      await openAppSettings();
      return false;
    } else {
      //Delete existing recording
      if (await hasRecording) {
        await File(pathToRecordingFile).delete();
      }

      _recorder = Record();
      await _recorder?.start(
        path: pathToRecordingFile,
        encoder: AudioEncoder.aacLc,
        bitRate: 256000,
        samplingRate: 44100,
      );
      return true;
    }
  }

  Future<void> stopRecording() async {
    await _recorder?.stop();
    await _recorder?.dispose();
    _recorder = null;
  }
}
