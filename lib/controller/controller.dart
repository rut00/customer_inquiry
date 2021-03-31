import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'package:form_app/models/form.dart';

// FormController is a class which does work of saving FeedbackForm in Google Sheets using
// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class FormController {
  // Google App Script Web URL.
  static const String URL =
      "https://script.google.com/macros/s/AKfycbxRoUfSOUhcyPe5AyRPbtaL241bpJmsL3SRwNmbz8YMyAW0zhDBSPwQ/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  // Async function which saves feedback, parses [feedbackForm] parameters
  // and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(AppForm appForm, void Function(String) callback) async {
    try {
      await http.post(URL, body: appForm.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Async function which loads feedback from endpoint URL and returns List.
  Future<List<AppForm>> getFeedbackList() async {
    return await http.get(URL).then((response) {
      var jsonFeedback = convert.jsonDecode(response.body) as List;
      return jsonFeedback.map((json) => AppForm.fromJson(json)).toList();
    });
  }
}