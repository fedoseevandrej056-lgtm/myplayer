import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late final AudioPlayer _player;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _player = AudioPlayer();
    _isInitialized = true;
  }

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> playTrack(Track track) async {
    if (!_isInitialized) await initialize();

    if (track.uri != null) {
      await _player.setFilePath(track.uri!);
    }

    await _player.play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void dispose() {
    if (_isInitialized) {
      _player.dispose();
      _isInitialized = false;
    }
  }
}

// Riverpod providers
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playerStateStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});
