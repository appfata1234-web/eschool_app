import 'package:flutter/material.dart';

/// Metadata for a school subject including visual accent and icon.
class SubjectMeta {
  const SubjectMeta({
    required this.id,
    required this.name,
    required this.shortName,
    required this.teacher,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String shortName;
  final String teacher;
  final Color color;
  final IconData icon;
}

/// Student profile information.
class StudentProfile {
  const StudentProfile({
    required this.fullName,
    required this.shortName,
    required this.initials,
    required this.gradeClass,
    required this.schoolName,
    required this.cafeteriaBalanceRub,
    required this.attendancePercent,
    required this.averageGpa,
    required this.rankInClass,
  });

  final String fullName;
  final String shortName;
  final String initials;
  final String gradeClass;
  final String schoolName;
  final int cafeteriaBalanceRub;
  final int attendancePercent;
  final double averageGpa;
  final int rankInClass;
}

/// Lesson entry inside the daily schedule.
class LessonItem {
  const LessonItem({
    required this.id,
    required this.order,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.topic,
    this.isCurrent = false,
    this.isDone = false,
    this.grade,
    this.homeworkId,
    this.lessonNote,
  });

  final String id;
  final int order;
  final String subjectId;
  final String startTime;
  final String endTime;
  final String room;
  final String topic;
  final bool isCurrent;
  final bool isDone;
  final GradeEntry? grade;
  final String? homeworkId;
  final String? lessonNote;
}

/// Schedule for a single weekday.
class DaySchedule {
  const DaySchedule({
    required this.weekdayShort,
    required this.weekdayFull,
    required this.dateLabel,
    required this.dayNumber,
    required this.isToday,
    required this.lessons,
  });

  final String weekdayShort;
  final String weekdayFull;
  final String dateLabel;
  final int dayNumber;
  final bool isToday;
  final List<LessonItem> lessons;
}

/// Individual grade record.
class GradeEntry {
  const GradeEntry({
    required this.id,
    required this.subjectId,
    required this.value,
    required this.weight,
    required this.workType,
    required this.dateLabel,
    required this.quarter,
    this.comment,
  });

  final String id;
  final String subjectId;
  final int value;
  final double weight;
  final String workType;
  final String dateLabel;
  final int quarter;
  final String? comment;
}

/// Homework task item.
class HomeworkItem {
  const HomeworkItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueDateLabel,
    required this.isUrgent,
    required this.estimatedMinutes,
    required this.attachments,
    required this.steps,
    this.isCompleted = false,
  });

  final String id;
  final String subjectId;
  final String title;
  final String description;
  final String dueDateLabel;
  final bool isUrgent;
  final int estimatedMinutes;
  final List<String> attachments;
  final List<String> steps;
  final bool isCompleted;

  HomeworkItem copyWith({bool? isCompleted}) {
    return HomeworkItem(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description,
      dueDateLabel: dueDateLabel,
      isUrgent: isUrgent,
      estimatedMinutes: estimatedMinutes,
      attachments: attachments,
      steps: steps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

