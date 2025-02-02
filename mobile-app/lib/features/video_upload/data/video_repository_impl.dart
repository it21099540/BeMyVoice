import 'package:bemyvoice/features/video_upload/domain/entities/video.dart';
import 'package:bemyvoice/features/video_upload/domain/repositories/video_repository.dart';
import 'package:image_picker/image_picker.dart';

class VideoRepositoryImpl implements VideoRepository {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<Video?> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video != null ? Video(video.path) : null;
  }
}
