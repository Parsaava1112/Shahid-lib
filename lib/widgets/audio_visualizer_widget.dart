import 'package:flutter/material.dart';
import 'package:flutter_audio_visualizer/flutter_audio_visualizer.dart';

class AudioVisualizerWidget extends StatelessWidget {
  final bool isPlaying;

  const AudioVisualizerWidget({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return AudioVisualizer(
      audioSource: AudioSource.audioPlayer,
      isActive: isPlaying,
      visualizationType: VisualizationType.waveform,
      style: AudioVisualizerStyle(
        backgroundColor: Colors.transparent,
        barWidth: 4,
        barSpacing: 2,
        waveformColor: Colors.blue,
      ),
      height: 150,
      onDataReceived: (data) {
        // داده‌های صوتی برای پردازش بیشتر
      },
      onError: (error) {
        debugPrint('Visualizer error: $error');
      },
    );
  }
}