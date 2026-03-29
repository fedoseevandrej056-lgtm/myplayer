import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';

class YouTubeSearchService {
  static final YouTubeSearchService _instance = YouTubeSearchService._internal();
  factory YouTubeSearchService() => _instance;
  YouTubeSearchService._internal();

  late YoutubeExplode _youtube;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _youtube = YoutubeExplode();
    _isInitialized = true;
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (!_isInitialized) await initialize();

    try {
      final searchResults = await _youtube.search.search(query);
      final videoResults = searchResults.take(limit).whereType<Video>().toList();
      
      final tracks = <Track>[];
      
      for (final video in videoResults) {
        try {
          // Get video details including duration
          final videoId = video.id.value;
          final videoInfo = await _youtube.videos.get(video.id);
          
          // Get audio stream URL
          final streamManifest = await _youtube.videos.streamsClient.getManifest(video.id);
          final audioStream = streamManifest.audioOnly.withHighestBitrate();
          
          final track = Track.fromYouTube(
            id: videoId,
            title: video.title,
            artist: video.author,
            album: null,
            artworkUrl: video.thumbnails.highResUrl,
            youtubeId: audioStream.url.toString(),
            duration: videoInfo.duration,
          );
          
          tracks.add(track);
        } catch (e) {
          // Skip video if stream extraction fails
          continue;
        }
      }
      
      return tracks;
    } catch (e) {
      throw Exception('Failed to search YouTube: $e');
    }
  }

  Future<Track?> getTrackFromUrl(String url) async {
    if (!_isInitialized) await initialize();

    try {
      final videoId = VideoId.parseVideoId(url);
      if (videoId == null) return null;
      
      final video = await _youtube.videos.get(videoId);
      final streamManifest = await _youtube.videos.streamsClient.getManifest(videoId);
      final audioStream = streamManifest.audioOnly.withHighestBitrate();
      
      return Track.fromYouTube(
        id: videoId.toString(),
        title: video.title,
        artist: video.author,
        album: null,
        artworkUrl: video.thumbnails.highResUrl,
        youtubeId: audioStream.url.toString(),
        duration: video.duration,
      );
    } catch (e) {
      throw Exception('Failed to get track from URL: $e');
    }
  }

  Future<List<String>> getTrendingSearches() async {
    // Return some popular music search terms
    return [
      'trending music',
      'best songs 2024',
      'chill vibes',
      'workout music',
      'study playlist',
      'pop hits',
      'indie music',
      'electronic music',
      'hip hop',
      'rock classics',
    ];
  }

  void dispose() {
    if (_isInitialized) {
      _youtube.close();
      _isInitialized = false;
    }
  }
}

// Search provider for Riverpod
final youtubeSearchServiceProvider = Provider<YouTubeSearchService>((ref) {
  return YouTubeSearchService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = FutureProvider<List<Track>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final searchService = ref.watch(youtubeSearchServiceProvider);
  
  if (query.isEmpty) return [];
  
  return await searchService.searchTracks(query);
});

final trendingSearchesProvider = FutureProvider<List<String>>((ref) async {
  final searchService = ref.watch(youtubeSearchServiceProvider);
  return await searchService.getTrendingSearches();
});
