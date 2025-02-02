import 'dart:io';
import 'package:bemyvoice/features/video_upload/presentation/bloc/video_upload_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:bemyvoice/features/video_upload/domain/entities/video.dart';
import 'package:bemyvoice/core/common/widgets/custom_button.dart';
import 'package:bemyvoice/features/video_upload/presentation/widgets/predicted_result.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';

class VideoPlayerView extends StatelessWidget {
  final Video video;

  const VideoPlayerView({required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = VideoPlayerController.file(File(video.path));

    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(controller),
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppPalette.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  buttonText: 'Pick Another Video',
                  icon: Icons.video_library_outlined,
                  onPressed: () {
                    context.read<VideoUploadCubit>().pickVideo();
                  },
                ),
                const SizedBox(height: 20),
                PredictedResultWidget(),
              ],
            ),
          );
        } else {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppPalette.primaryColor),
          ));
        }
      },
    );
  }
}
