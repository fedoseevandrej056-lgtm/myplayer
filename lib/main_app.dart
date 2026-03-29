import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'screens/home_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/search_screen.dart';
import 'services/audio_service.dart';
import 'services/youtube_search_service.dart';
import 'widgets/liquid_aura.dart';
import 'widgets/morphing_play_button.dart';
import 'widgets/elastic_scrubber.dart';
import 'widgets/breathing_artwork.dart';
import 'widgets/particle_shift_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI for true black OLED
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize services
  await AudioService().initialize();
  await YouTubeSearchService().initialize();
  
  runApp(
    const ProviderScope(
      child: GodTierMusicPlayer(),
    ),
  );
}

class GodTierMusicPlayer extends ConsumerWidget {
  const GodTierMusicPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'God Tier Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
          background: Colors.black,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 32,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 24,
          ),
          bodyLarge: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.white60,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.value?.playing ?? false;
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    
    return LiquidAura(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            HomeScreen(),
            SearchScreen(),
            NowPlayingScreen(),
          ],
        ),
        bottomNavigationBar: _currentIndex != 2
            ? _buildGlassBottomNavigationBar()
            : null,
        // Mini player for home and search screens
        bottomSheet: _currentIndex != 2
            ? _buildMiniPlayer(isPlaying, position.value, duration.value)
            : null,
      ),
    );
  }

  Widget _buildGlassBottomNavigationBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_rounded, 0, 'Home'),
              _buildNavItem(Icons.search_rounded, 1, 'Search'),
              _buildNavItem(Icons.play_circle_rounded, 2, 'Player'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(bool isPlaying, Duration position, Duration duration) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
      height: 80,
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
          child: Row(
            children: [
              // Mini artwork
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple,
                        Colors.blue,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Track info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Artist Name',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Mini controls
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MorphingPlayButton(
                  isPlaying: isPlaying,
                  onPressed: () {
                    final audioService = ref.read(audioServiceProvider);
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.play();
                    }
                  },
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
