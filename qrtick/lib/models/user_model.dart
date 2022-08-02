
class User {
  String user_id;
  String name;
  String surname;
  String department;
  String designation;
  String? employedDate;
  String? skills;
  String? address;
  String? phone;
  String? email;
  String? dob;
  String? aboutMe;
  String? imagePath;

  User(
      {required this.imagePath,
      required this.user_id,
      required this.name,
      required this.surname,
      required this.department,
      required this.designation,
      required this.employedDate,
      required this.skills,
      required this.address,
      required this.phone,
      required this.email,
      required this.dob,
      required this.aboutMe});
  

  User.fromJson(Map<String, dynamic> json)
      :
        user_id = json['user_id'],
        name = json['name'],
        surname = json['surname'],
        department = json['department'],
        designation = json['designation'],
        employedDate = json['employed_date'],
        skills = json['skills'],
        address = json['address'],
        phone = json['phone_number'],
        email = json['email'],
        dob = json['date_of_birth'],
        aboutMe = json['about_me'],
        imagePath = json['profile_image'];

  Map<String, dynamic> toJson() => {

        'user_id': user_id,
        'name': name,
        'surname': surname,
        'department': department,
        'designation': designation,
        'employed_date': employedDate,
        'skills': skills,
        'address': address,
        'phone_number': phone,
        'email': email,
        'date_of_birth': dob,
        'about_me': aboutMe,
        'profile_image': imagePath,
      };
}
