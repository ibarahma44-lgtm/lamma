import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> playWinSound() async {
    if (_isMuted) return;
    try {
      await _audioPlayer.play(AssetSource('audios/win.mp3'));
    } catch (e) {
      print('Error playing win sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
} 