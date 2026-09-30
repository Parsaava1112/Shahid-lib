import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Book book;

  const AudioPlayerScreen({super.key, required this.book});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(widget.book.audioUrl!),
        tag: MediaItem(
          id: widget.book.id,
          title: widget.book.title,
          artist: widget.book.author,
          artUri: Uri.parse(widget.book.coverUrl),
        ),
      ),
    );
    
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'در حال پخش',
            style: GoogleFonts.vazirmatn(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              
              // تصویر جلد با انیمیشن
              ZoomIn(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.book.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.book, size: 80, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // اطلاعات کتاب
              FadeInUp(
                child: Text(
                  widget.book.title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  widget.book.author,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // نوار پیشرفت
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _player.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                          onChanged: (value) {
                            _player.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.blue,
                          inactiveColor: Colors.white24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white54),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // دکمه‌های کنترل
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.replay_10, color: Colors.white70),
                      onPressed: () {
                        _player.seek(_player.position - const Duration(seconds: 10));
                      },
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                      ),
                      child: IconButton(
                        iconSize: 50,
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
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.forward_10, color: Colors.white70),
                      onPressed: () {
                        _player.seek(_player.position + const Duration(seconds: 10));
                      },
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}