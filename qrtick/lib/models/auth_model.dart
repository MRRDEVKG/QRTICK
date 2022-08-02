
class Auth {
  int id;
  String user_id;
  bool is_staff;


  Auth(
      {required this.id,
        required this.user_id,
        required this.is_staff
      });


  Auth.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user_id = json['user_id'],
        is_staff = json['is_staff'];


  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': user_id,
    'is_staff': is_staff
  };
}
