import 'package:eschool_teacher/data/models/studentLeave.dart';
import 'package:eschool_teacher/data/repositories/studentLeaveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetStudentLeaveState {}

class GetStudentLeaveInitial extends GetStudentLeaveState {}

class GetStudentLeaveInProgress extends GetStudentLeaveState {}

class GetStudentLeaveSuccess extends GetStudentLeaveState {
  List<StudentLeave> studentLeaves;
  int totalStudentLeaves;
  GetStudentLeaveSuccess(
      {required this.studentLeaves, required this.totalStudentLeaves,});
}

class GetStudentLeaveFailure extends GetStudentLeaveState {
  final String errorMessage;

  GetStudentLeaveFailure(this.errorMessage);
}

class GetStudentLeaveCubit extends Cubit<GetStudentLeaveState> {
  final StudentLeaveRepository studentLeaveRepository;

  GetStudentLeaveCubit(this.studentLeaveRepository)
      : super(GetStudentLeaveInitial());

  Future<void> getStudentLeave(
      {required String classSectionId,
      required String? month,
      required String sessionYearId,}) async {
    emit(GetStudentLeaveInProgress());

    await studentLeaveRepository
        .getStudentLeaveRequest(
            classSectionId: classSectionId,
            month: month,
            sessionYearId: sessionYearId,)
        .then((leaveData) {
      emit(
        GetStudentLeaveSuccess(
            studentLeaves: leaveData.leaves,
            totalStudentLeaves: leaveData.totalRequestedLeaves,),
      );
    }).catchError((error) {
      emit(GetStudentLeaveFailure(error.toString()));
    });
  }

  void updateStatus(int leaveId, String status) {
    if (state is GetStudentLeaveSuccess) {
      final stateAs = state as GetStudentLeaveSuccess;
      if (stateAs.studentLeaves.any((element) => element.id == leaveId)) {
        final List<StudentLeave> studentLeaves = [];
        for (int i = 0; i < stateAs.studentLeaves.length; i++) {
          if (stateAs.studentLeaves[i].id != leaveId) {
            studentLeaves.add(stateAs.studentLeaves[i]);
          } else {
            studentLeaves
                .add(stateAs.studentLeaves[i].copyWith(status: status));
          }
        }
        emit(
          GetStudentLeaveSuccess(
            studentLeaves: studentLeaves,
            totalStudentLeaves: stateAs.totalStudentLeaves,
          ),
        );
      }
    }
  }
}
