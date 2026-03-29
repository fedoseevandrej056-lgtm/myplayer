import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../widgets/liquid_aura.dart';
import '../widgets/morphing_play_button.dart';
import '../services/audio_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;
    
    return LiquidAura(
      child: CustomScrollView(
        slivers: [
          // Glass morphic SliverAppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Your Library',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            background: ClipRRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassCard(
                          context,
                          'Recently Played',
                          Icons.history_rounded,
                          () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassCard(
                          context,
                          'Favorites',
                          Icons.favorite_rounded,
                          () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Section header
                  Text(
                    'Local Tracks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // Sample tracks list
                  _buildTrackList(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context, WidgetRef ref) {
    final sampleTracks = [
      {'title': 'Midnight Dreams', 'artist': 'Luna Echo', 'duration': '3:45'},
      {'title': 'Electric Pulse', 'artist': 'Neon Waves', 'duration': '4:12'},
      {'title': 'Crystal Waters', 'artist': 'Azure Sky', 'duration': '3:28'},
      {'title': 'Urban Lights', 'artist': 'City Beats', 'duration': '3:56'},
      {'title': 'Starlight Symphony', 'artist': 'Cosmic Flow', 'duration': '5:02'},
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sampleTracks.length,
      itemBuilder: (context, index) {
        final track = sampleTracks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTrackItem(context, track, ref),
        );
      },
    );
  }

  Widget _buildTrackItem(
    BuildContext context,
    Map<String, String> track,
    WidgetRef ref,
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
          // Album art placeholder
          Container(
            width: 48,
            height: 48,
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
                ),
                const SizedBox(height: 4),
                Text(
                  track['artist']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Duration and play button
          Column(
            children: [
              Text(
                track['duration']!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              MorphingPlayButton(
                isPlaying: false,
                onPressed: () {
                  // Handle track play
                },
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
