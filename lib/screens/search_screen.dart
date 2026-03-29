import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../widgets/liquid_aura.dart';
import '../services/audio_service.dart';
import '../models/track.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidAura(
      child: SafeArea(
        child: Column(
          children: [
            // Search header
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSearchField(context),
            ),
            
            // Content
            Expanded(
              child: _buildSearchResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search for music...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withOpacity(0.7),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchController.text.isEmpty) {
      return _buildTrendingSearches(context);
    }
    
    return _buildMockSearchResults(context);
  }

  Widget _buildTrendingSearches(BuildContext context) {
    final trending = [
      'Recent searches',
      'Popular music',
      'Chill vibes',
      'Workout playlist',
      'Study music',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Trending Searches',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        ...trending.map((search) => _buildTrendingItem(context, search)),
      ],
    );
  }

  Widget _buildTrendingItem(BuildContext context, String search) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          _searchController.text = search;
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  search,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockSearchResults(BuildContext context) {
    final mockResults = [
      {'title': 'Midnight Dreams', 'artist': 'Luna Echo', 'duration': '3:45'},
      {'title': 'Electric Pulse', 'artist': 'Neon Waves', 'duration': '4:12'},
      {'title': 'Crystal Waters', 'artist': 'Azure Sky', 'duration': '3:28'},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: mockResults.length,
      itemBuilder: (context, index) {
        final track = mockResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSearchResultItem(context, track),
        );
      },
    );
  }

  Widget _buildSearchResultItem(
    BuildContext context,
    Map<String, String> track,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Album art
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade400,
                  Colors.blue.shade400,
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track['title']!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track['artist']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track['duration']!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          // Play button
          IconButton(
            onPressed: () {
              // Handle track play with mock data
              final mockTrack = Track(
                id: 'mock_${track['title']}',
                title: track['title']!,
                artist: track['artist']!,
                album: 'Mock Album',
                uri: null, // No actual file
                artworkUrl: null,
                youtubeId: null,
                duration: null,
              );
              
              final audioService = ref.read(audioServiceProvider);
              audioService.playTrack(mockTrack);
            },
            icon: Icon(
              Icons.play_circle_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
