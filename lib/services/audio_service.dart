import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/track.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _player;
  bool _isInitialized = false;

  AudioPlayer get player => _player;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _player = AudioPlayer();
    
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse('asset://audio/silence.mp3'),
        tag: MediaItem(
          id: 'init',
          title: 'Ready',
          artist: 'God Tier Player',
        ),
      ),
    );

    _isInitialized = true;
  }

  Future<void> playTrack(Track track) async {
    if (!_isInitialized) await initialize();

    if (track.youtubeId != null) {
      // For YouTube streams
      await _player.setUrl(track.youtubeId!);
    } else if (track.uri != null) {
      // For local files
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

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  void dispose() {
    _player.dispose();
    _isInitialized = false;
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
  return audioService.positionStream.map((duration) => duration ?? Duration.zero);
});

final durationProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream.map((duration) => duration ?? Duration.zero);
});
