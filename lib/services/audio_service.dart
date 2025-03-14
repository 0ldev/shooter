import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Play beep sound
  Future<void> playBeep() async {
    await _audioPlayer.play(AssetSource('audio/beep.mp3'));
  }
  
  // Stop any playing sound
  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }
  
  // Dispose audio player resources
  void dispose() {
    _audioPlayer.dispose();
  }
}