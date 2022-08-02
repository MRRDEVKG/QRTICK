class WorkSchedule {
  final int id;
  final String day_of_week;
  final String? from_time;
  final String? to_time;
  final bool is_day_off;

  const WorkSchedule({
    required this.id,
    required this.day_of_week,
    required this.from_time,
    required this.to_time,
    required this.is_day_off,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id'],
      day_of_week: json['day_of_week'],
      from_time: json['from_time'],
      to_time: json['to_time'],
      is_day_off: json['is_day_off']
    );
  }
}