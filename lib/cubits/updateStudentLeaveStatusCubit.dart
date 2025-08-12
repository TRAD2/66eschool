import 'package:eschool_teacher/data/repositories/studentLeaveRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateStudentLeaveStatusState {}

class UpdateStudentLeaveStatusInitial extends UpdateStudentLeaveStatusState {}

class UpdateStudentLeaveStatusInProgress
    extends UpdateStudentLeaveStatusState {}

class UpdateStudentLeaveStatusSuccess extends UpdateStudentLeaveStatusState {
  final String status;
  final int id;
  UpdateStudentLeaveStatusSuccess({required this.status, required this.id});

  bool get isStatusPending => status == '0';
}

class UpdateStudentLeaveStatusFailure extends UpdateStudentLeaveStatusState {
  final String errorMessage;

  UpdateStudentLeaveStatusFailure(this.errorMessage);
}

class UpdateStudentLeaveStatusCubit
    extends Cubit<UpdateStudentLeaveStatusState> {
  final StudentLeaveRepository studentLeaveRepository;

  UpdateStudentLeaveStatusCubit(this.studentLeaveRepository)
      : super(UpdateStudentLeaveStatusInitial());

  Future<void> updateStudentLeaveStatus({
    required int leaveId,
    required String status,
    String? reason,
  }) async {
    emit(UpdateStudentLeaveStatusInProgress());
    try {
      await studentLeaveRepository.updateStudentLeaveStatus(
        leaveId: leaveId.toString(),
        status: status,
        reason: reason,
      );
      emit(
        UpdateStudentLeaveStatusSuccess(
          status: status,
          id: leaveId,
        ),
      );
    } catch (e) {
      emit(UpdateStudentLeaveStatusFailure(e.toString()));
    }
  }
}
