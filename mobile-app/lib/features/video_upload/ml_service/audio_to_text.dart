// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// Future<String> getFoodPreferncePrediction(Map<String, dynamic>) async {
//   String? result;
//   String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
//    ? dotenv.env['DEFAULT_MLIP']
//    : dotenv.env['MLIP'];

//    final url = Uri.parse('http://$mlIP:8000/speech_to_text');

//     final response = await http.post(
//       url,
//       body: json.encode(data),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       result = json.decode(response.body)['result'];
//     } else {
//       throw Exception('Failed to get prediction');
//     }
// }