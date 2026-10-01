import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String artist;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.artist,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.audioUrl),
          tag: MediaItem(
            id: '1',
            title: widget.title,
            artist: widget.artist,
          ),
        ),
      );
      _duration = _player.duration ?? Duration.zero;
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          const Spacer(),
          // کاور
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.headphones,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
          ).animate().scale(duration: 600.ms).fadeIn(),
          const SizedBox(height: 32),
          Text(
            widget.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            widget.artist,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const Spacer(),
          // نوار پیشرفت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Slider(
                  value: _position.inSeconds.toDouble().clamp(
                        0,
                        _duration.inSeconds.toDouble(),
                      ),
                  max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) {
                    _player.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // دکمه‌های کنترل
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.replay_10),
                onPressed: () => _player.seek(
                  _position - const Duration(seconds: 10),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: IconButton(
                  iconSize: 48,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.forward_10),
                onPressed: () => _player.seek(
                  _position + const Duration(seconds: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}