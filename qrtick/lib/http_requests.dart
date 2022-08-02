
import 'package:flutter/material.dart';
import 'package:http/http.dart' as client;
import 'dart:async';
import 'dart:io';

String ip_address = '192.168.0.106';

Future<client.Response> getToken(String username, String password) async {
  final client.Response response = await client.post(
      Uri.parse('http://$ip_address:8000/api/login/'),
      body: <String, String>{
        'username': username,
        'password': password,
      });

  return response;
}

Future<client.Response> getUserType(String user_id, String token) async {
  print(token);
  final client.Response response = await client.get(
    Uri.parse('http://$ip_address:8000/api/is_staff/'),
    headers: {
      HttpHeaders.authorizationHeader: 'Token ' + token,
    },
  );

  return response;
}

Future<client.Response> checkQRCode(String qr_code, String token) async {
  client.Response response = await client
      .post(Uri.parse('http://$ip_address:8000/api/check_qr_code/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  }, body: {
    'scanned_qr_code': qr_code
  });
  return response;
}

Future<client.Response> arrivedAt(
    String user_id, String token, bool first_time) async {
  DateTime today = DateTime.now();
  String str_today = today.day.toString().padLeft(2, '0') +
      '_' +
      today.month.toString().padLeft(2, '0') +
      '_' +
      today.year.toString() +
      '_';
  client.Response response = await client.patch(
      Uri.parse('http://$ip_address:8000/api/arrival_departure/' +
          str_today +
          user_id +
          '/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Token ' + token,
      },
      body: first_time
          ? {
              'arrival_time': '00:00',
              'departure_time': '00:00',
            }
          : {
              'arrival_time': '12:12',
              'departure_time': '12:12',
            });
  return response;
}

Future<client.Response> currentSchedule(String token) async {
  print(token);
  final client.Response response = await client.get(
    Uri.parse('http://$ip_address:8000/api/current_schedule/'),
    headers: {
      HttpHeaders.authorizationHeader: 'Token ' + token,
    },
  );

  return response;
}

Future<client.Response> workSchedule(String token) async {
  print(token);
  final client.Response response = await client.get(
    Uri.parse('http://$ip_address:8000/api/work_schedule/'),
    headers: {
      HttpHeaders.authorizationHeader: 'Token ' + token,
    },
  );

  return response;
}

Future<client.Response> getUserMonthlyAttendance(
    String user_id, String token, String month, String year) async {
  print(token);
  final client.Response response = await client.get(
    Uri.parse('http://$ip_address:8000/api/arrival_departure/?search=' +
        '_' +
        month +
        '_' +
        year +
        '_' +
        user_id),
    headers: {
      HttpHeaders.authorizationHeader: 'Token ' + token,
    },
  );

  return response;
}

/////////////////////////////////////////////////////////////////////////////
Future<client.Response> updateQRCode(String new_qr_code, String token) async {
  client.Response response = await client.patch(
      Uri.parse('http://$ip_address:8000/api/update_qr_code/qr_code_id/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Token ' + token,
      },
      body: {
        'qr_code': new_qr_code,
      });
  return response;
}

Future<client.Response> updateWorkSchedule(
    int index, String token, TimeOfDay time, bool is_from_time) async {
  client.Response response = await client.patch(
      Uri.parse('http://$ip_address:8000/api/work_schedule/$index/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Token ' + token,
      },
      body: is_from_time
          ? {'from_time': '${time.hour}:${time.minute}'}
          : {'to_time': '${time.hour}:${time.minute}'});
  return response;
}

Future<client.Response> updateIsDayOff(
    int index, String token, bool is_day_off) async {
  client.Response response = await client.patch(
      Uri.parse('http://$ip_address:8000/api/work_schedule/$index/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Token ' + token,
      },
      body: {
        'from_time': '',
        'to_time': '',
        'is_day_off': '${is_day_off}'
      });
  return response;
}

Future<client.Response> getUsersDailyAttendance(
    String token, String day, String month, String year) async {
  print(token);
  final client.Response response = await client.get(
    Uri.parse('http://$ip_address:8000/api/arrival_departure/?search=' +
        day +
        '_' +
        month +
        '_' +
        year),
    headers: {
      HttpHeaders.authorizationHeader: 'Token ' + token,
    },
  );

  return response;
}

Future<client.Response> getUserAuth(String token) async {
  client.Response response = await client
      .get(Uri.parse('http://$ip_address:8000/api/auth/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  });
  return response;
}

Future<client.Response> AddUser(
    {required String token,
    required String name,
    required String surname,
    required String department,
    required String designation}) async {
  client.Response response = await client
      .post(Uri.parse('http://$ip_address:8000/api/profile/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  }, body: {
    'name': name,
    'surname': surname,
    'department': department,
    'designation': designation,
    'employed_date': '',
    'skills': '',
    'address': '',
    'phone_number': '',
    'email': '',
    'date_of_birth': '',
    'about_me': '',
    'profile_image': '',
  });
  return response;
}

Future<client.Response> DeleteUser(
    {required String token,
      required int id,
    }) async {
  client.Response response = await client
      .delete(Uri.parse('http://$ip_address:8000/api/auth/$id/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  });
  return response;
}

Future<client.Response> AddStaff(
    {required String token,
      required String user_id,
      required String password,
      }) async {

  client.Response response = await client
      .post(Uri.parse('http://$ip_address:8000/api/auth/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  }, body: {
    "user_id": user_id,
    "password": password,
    "is_staff": "true"
  });
  return response;
}

Future<client.Response> GetUser(
    {required String token,
      required String user_id
    }) async {

  client.Response response = await client
      .get(Uri.parse('http://$ip_address:8000/api/profile/${user_id}/'), headers: {
    HttpHeaders.authorizationHeader: 'Token ' + token,
  });
  return response;
}




