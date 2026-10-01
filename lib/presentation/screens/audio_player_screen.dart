import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/book_model.dart';

class AudioPlayerScreen extends StatefulWidget {
  final BookModel book;

  const AudioPlayerScreen({super.key, required this.book});

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
      final source = widget.book.filePath.isNotEmpty
          ? AudioSource.file(
              widget.book.filePath,
              tag: MediaItem(
                id: widget.book.id.toString(),
                title: widget.book.title,
                artist: widget.book.author,
              ),
            )
          : AudioSource.uri(
              Uri.parse(widget.book.fileUrl),
              tag: MediaItem(
                id: widget.book.id.toString(),
                title: widget.book.title,
                artist: widget.book.author,
              ),
            );

      await _player.setAudioSource(source);

      _player.durationStream.listen((d) {
        if (mounted && d != null) setState(() => _duration = d);
      });

      _player.playerStateStream.listen((s) {
        if (mounted) setState(() => _isPlaying = s.playing);
      });

      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
    } catch (e) {
      debugPrint('Error: $e');
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
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: GoogleFonts.vazirmatn(),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
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
              ),
            ),
            child: const Icon(
              Icons.headphones,
              size: 80,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms).fadeIn(),
          const SizedBox(height: 32),
          Text(
            widget.book.title,
            style: GoogleFonts.vazirmatn(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.author,
            style: GoogleFonts.vazirmatn(fontSize: 14),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Slider(
                  value: _position.inSeconds
                      .toDouble()
                      .clamp(0, _duration.inSeconds.toDouble()),
                  max: _duration.inSeconds.toDouble().clamp(1, 999999),
                  onChanged: (v) =>
                      _player.seek(Duration(seconds: v.toInt())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(_position)),
                    Text(_fmt(_duration)),
                  ],
                ),
              ],
            ),
          ),
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
                  onPressed: () =>
                      _isPlaying ? _player.pause() : _player.play(),
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

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}