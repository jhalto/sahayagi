import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationHelper {
  final String _serviceAccountJson = json.encode({
    "type": "service_account",
    "project_id": "sahayagi-6f549",
    "private_key_id": "2c48a5e1e93dc76d07b8dc8469996720c66adb96",
    "private_key": "replace you private key",
    "client_email": "sahayagi-jhalto@sahayagi-6f549.iam.gserviceaccount.com",
    "client_id": "106097478209623934789",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sahayagi-jhalto%40sahayagi-6f549.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });


  Future<void> sendPushNotification(String token, String title, String message) async {
    final List<String> scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    try {
      // Load service account credentials
      final credentials = auth.ServiceAccountCredentials.fromJson(json.decode(_serviceAccountJson));

      // Obtain an OAuth2 client
      final authClient = await auth.clientViaServiceAccount(credentials, scopes);

      // Send notification
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/sahayagi-6f549/messages:send');
      final response = await authClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': message,
            },
          },
        }),
      );

      // Log response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('Failed to send notification: ${response.body}');
      }

      authClient.close();
    } catch (e) {
      // Log any errors
      print('Error sending notification: $e');
    }
  }
}