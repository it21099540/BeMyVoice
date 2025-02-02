import 'package:bemyvoice/features/video_upload/domain/repositories/video_repository.dart';
import 'package:bemyvoice/features/video_upload/presentation/bloc/video_upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoUploadCubit extends Cubit<VideoUploadState> {
  final VideoRepository _videoRepository;

  VideoUploadCubit(this._videoRepository) : super(VideoUploadInitial());

  Future<void> pickVideo() async {
    emit(VideoUploadLoading()); // Emit loading state

    try {
      final video = await _videoRepository.pickVideo();
      if (video != null) {
        emit(VideoUploadSuccess(video)); // Emit success state with the video
      } else {
        emit(VideoUploadFailure(
            'No video selected.')); // Handle video selection failure
      }
    } catch (e) {
      emit(VideoUploadFailure(
          e.toString())); // Emit failure state with error message
    }
  }
}
