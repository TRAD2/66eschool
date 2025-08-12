import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateTimetableLinkState {}

class UpdateTimetableLinkInitial extends UpdateTimetableLinkState {}

class UpdateTimetableLinkInProgress extends UpdateTimetableLinkState {}

class UpdateTimetableLinkSuccess extends UpdateTimetableLinkState {
  final String? url;
  final String? name;

  UpdateTimetableLinkSuccess({required this.url, required this.name});
}

class UpdateTimetableLinkFailure extends UpdateTimetableLinkState {
  final String errorMessage;

  UpdateTimetableLinkFailure(this.errorMessage);
}

class UpdateTimetableLinkCubit extends Cubit<UpdateTimetableLinkState> {
  final TeacherRepository _teacherRepository;

  UpdateTimetableLinkCubit(this._teacherRepository)
      : super(UpdateTimetableLinkInitial());

  Future<void> updateTimetableLink({
    required String timetableSlotId,
    required String? url,
    required String? name,
  }) async {
    emit(UpdateTimetableLinkInProgress());
    try {
      await _teacherRepository.updateTimeTableLink(
        timetableSlotId: timetableSlotId,
        linkCustomUrl: url,
        linkName: name,
      );

      emit(UpdateTimetableLinkSuccess(url: url, name: name));
    } catch (e) {
      emit(UpdateTimetableLinkFailure(e.toString()));
    }
  }
}
