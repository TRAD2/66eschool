import 'package:eschool_teacher/data/models/attendanceReport.dart';
import 'package:eschool_teacher/data/models/classSectionDetails.dart';
import 'package:eschool_teacher/data/models/customNotification.dart';
import 'package:eschool_teacher/data/models/event.dart';
import 'package:eschool_teacher/data/models/exam.dart';
import 'package:eschool_teacher/data/models/holiday.dart';
import 'package:eschool_teacher/data/models/staffLeave.dart';
import 'package:eschool_teacher/data/models/studentLeave.dart';
import 'package:eschool_teacher/data/models/subject.dart';
import 'package:eschool_teacher/data/models/timeTableSlot.dart';
import 'package:eschool_teacher/utils/api.dart';

class TeacherRepository {
  Future<Map<String, dynamic>> dashboard() async {
    try {
      final result = await Api.get(url: Api.dashboard, useAuthToken: true);

      return {
        "primaryClass": result['data']['class_teacher'].isEmpty
            ? null
            : (result['data']['class_teacher'] as List?)
                    ?.map((e) => ClassSectionDetails.fromJson(Map.from(e)))
                    .toList() ??
                [],
        "classes": (result['data']['other_classes'] as List?)
                ?.map((e) => ClassSectionDetails.fromJson(Map.from(e)))
                .toList() ??
            [],
        "pendingLeaveRequests":
            (result['data']['student_leave_request'] as List?)
                    ?.map((e) => StudentLeave.fromJson(Map.from(e)))
                    .toList() ??
                [],
        "todaysTimetable": (result['data']['timetable'] as List?)
                ?.map((e) => TimeTableSlot.fromJson(Map.from(e)))
                .toList() ??
            [],
        "upcomingExams": (result['data']['upcoming_exams'] as List?)
                ?.map((e) => Exam.fromExamJson(Map.from(e)))
                .toList() ??
            [],
        "todayStaffLeave": (result['data']?['staff_leaves']?['today'] as List?)
                ?.map((e) => StaffLeave.fromJson(Map.from(e)))
                .toList() ??
            [],
        "tomorrowStaffLeave":
            (result['data']?['staff_leaves']?['tomorrow'] as List?)
                    ?.map((e) => StaffLeave.fromJson(Map.from(e)))
                    .toList() ??
                [],
        "upcomingStaffLeave":
            (result['data']?['staff_leaves']?['upcoming'] as List?)
                    ?.map((e) => StaffLeave.fromJson(Map.from(e)))
                    .toList() ??
                [],
        "upcomingEvents": (result['data']['events'] as List?)
                ?.map((e) => Event.fromJson(Map.from(e)))
                .toList() ??
            [],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Subject>> subjectsByClassSection(int classSectionId) async {
    try {
      final result = await Api.get(
        url: Api.getSubjectByClassSection,
        useAuthToken: true,
        queryParameters: {"class_section_id": classSectionId},
      );
      return (result['data'] as List)
          .map(
            (subjectJson) => Subject.fromJson(Map.from(subjectJson['subject'])),
          )
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getClassAttendanceReports({
    required int classSectionId,
    required String date,
  }) async {
    try {
      final result = await Api.get(
        url: Api.getAttendance,
        useAuthToken: true,
        queryParameters: {"class_section_id": classSectionId, "date": date},
      );

      return {
        "attendanceReports": (result['data'] as List)
            .map(
              (attendanceReport) => AttendanceReport.fromJson(attendanceReport),
            )
            .toList(),
        "isHoliday": result['is_holiday'],
        "holidayDetails": Holiday.fromJson(
          //
          Map.from(
            result['holiday'] == null ? {} : (result['holiday'] as List).first,
          ),
        ),
        "onLeaveStudentIds": result['on_leave_student_ids'] is List
            ? List<int>.from(result['on_leave_student_ids'])
            : <int>[],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> submitClassAttendance({
    required int classSectionId,
    required String date,
    required List<Map<String, dynamic>> attendance,
  }) async {
    try {
      await Api.post(
        url: Api.submitAttendance,
        useAuthToken: true,
        body: {
          "class_section_id": classSectionId,
          "date": date,
          "attendance": attendance,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TimeTableSlot>> fetchTimeTable() async {
    try {
      final result = await Api.get(url: Api.timeTable, useAuthToken: true);

      return (result['data'] as List)
          .map(
            (timetableSlot) => TimeTableSlot.fromJson(Map.from(timetableSlot)),
          )
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateTimeTableLink({
    required String timetableSlotId,
    required String? linkCustomUrl,
    required String? linkName,
  }) async {
    try {
      await Api.post(
        body: {
          'timetable_id': timetableSlotId,
          'live_class_link': linkCustomUrl ?? '',
          'link_name': linkName ?? '',
        },
        url: Api.updateTimetableLink,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //get custom notifications for parent
  Future<Map<String, dynamic>> fetchNotifications({required int page}) async {
    try {
      final response = await Api.get(
        url: Api.getNotifications,
        useAuthToken: true,
        queryParameters: {"page": page},
      );

      final List<CustomNotification> notifications = [];

      for (int i = 0; i < response['data']['data'].length; i++) {
        notifications.add(
          CustomNotification.fromJson(
            response['data']['data'][i],
          ),
        );
      }

      return {
        "notifications": notifications,
        "currentPage": response['data']['current_page'],
        "totalPage": response['data']['last_page'],
      };
    } catch (error) {
      throw ApiException(error.toString());
    }
  }
}
