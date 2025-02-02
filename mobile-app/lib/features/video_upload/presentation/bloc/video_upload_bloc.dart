import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bemyvoice/features/video_upload/domain/entities/video.dart';

abstract class VideoUploadState {}

class VideoUploadInitial extends VideoUploadState {}

class VideoUploadLoading extends VideoUploadState {}

class VideoUploadSuccess extends VideoUploadState {
  final Video video;
  VideoUploadSuccess(this.video);
}

class VideoUploadFailure extends VideoUploadState {
  final String errorMessage;
  VideoUploadFailure(this.errorMessage);
}

class VideoUploadCubit extends Cubit<VideoUploadState> {
  VideoUploadCubit() : super(VideoUploadInitial());

  void pickVideo() {
    // Implementation for picking video
  }
}
