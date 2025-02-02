import 'package:bemyvoice/features/video_upload/domain/entities/video.dart';

abstract class VideoRepository {
  Future<Video?> pickVideo();
}
