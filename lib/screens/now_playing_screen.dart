import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../widgets/liquid_aura.dart';
import '../widgets/breathing_artwork.dart';
import '../widgets/morphing_play_button.dart';
import '../widgets/elastic_scrubber.dart';
import '../widgets/particle_shift_transition.dart';
import '../services/audio_service.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    
    final isPlaying = playerState.value?.playing ?? false;
    final currentPosition = position.value ?? Duration.zero;
    final totalDuration = duration.value ?? Duration.zero;
    
    return LiquidAura(
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.expand_more_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Menu options
                        },
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Main artwork
                Expanded(
                  flex: 3,
                  child: Center(
                    child: BreathingArtwork(
                      imageUrl: 'https://picsum.photos/seed/music/400/400.jpg',
                      size: MediaQuery.of(context).size.width * 0.8,
                      isPlaying: isPlaying,
                      duration: totalDuration,
                      position: currentPosition,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Track info and controls
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // Track info
                        Column(
                          children: [
                            Text(
                              'Midnight Dreams',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Luna Echo',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Progress scrubber
                        ElasticScrubber(
                          duration: totalDuration,
                          position: currentPosition,
                          onSeek: (newPosition) {
                            final audioService = ref.read(audioServiceProvider);
                            audioService.seek(newPosition);
                          },
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Main controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Previous
                            IconButton(
                              onPressed: () {
                                // Handle previous
                              },
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            
                            // Play/Pause
                            MorphingPlayButton(
                              isPlaying: isPlaying,
                              onPressed: () {
                                final audioService = ref.read(audioServiceProvider);
                                if (isPlaying) {
                                  audioService.pause();
                                } else {
                                  audioService.play();
                                }
                              },
                              size: 80,
                            ),
                            
                            // Next
                            IconButton(
                              onPressed: () {
                                // Handle next
                              },
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Additional controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              context,
                              Icons.shuffle_rounded,
                              false,
                              () {},
                            ),
                            _buildControlButton(
                              context,
                              Icons.favorite_rounded,
                              false,
                              () {},
                            ),
                            _buildControlButton(
                              context,
                              Icons.repeat_rounded,
                              false,
                              () {},
                            ),
                            _buildControlButton(
                              context,
                              Icons.queue_music_rounded,
                              false,
                              () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
        size: 24,
      ),
    );
  }
}
