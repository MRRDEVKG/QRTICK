class ArrivalDeparture {
  final String employeeID;
  final String date;

  final bool present;

  final String? arrivalTime;
  final int? arrivalTimeDifference;

  final String? departureTime;
  final int? departureTimeDifference;

  final double total_time;

  ArrivalDeparture({
    required this.employeeID,
    required this.date,
    required this.present,
    required this.arrivalTime,
    required this.arrivalTimeDifference,
    required this.departureTime,
    required this.departureTimeDifference,
    required this.total_time,
  });

  ArrivalDeparture.fromJson(Map<String, dynamic> json)
      : employeeID = json['user_id'],
        date = json['date'],
        present = json['present'],
        arrivalTime = json['arrival_time'],
        arrivalTimeDifference = json['arrival_time_difference'],
        departureTime = json['departure_time'],
        departureTimeDifference = json['departure_time_difference'],
        total_time = json['total_time'];

  Map<String, dynamic> toJson() => {
        'user_id': employeeID,
        'date': date,
        'present': present,
        'arrival_time': arrivalTime,
        'arrival_time_difference': arrivalTimeDifference,
        'departure_time': departureTime,
        'departure_time_difference': departureTimeDifference,
        'total_time': total_time,
      };
}
