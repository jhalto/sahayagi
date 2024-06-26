import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationHelper {
  final String _serviceAccountJson = json.encode({
    "type": "service_account",
    "project_id": "sahayagi-6f549",
    "private_key_id": "2c48a5e1e93dc76d07b8dc8469996720c66adb96",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDjMf+4RxjOzh6l\nu80JK/CT4og3/toOwf2Y1Fi5CyHHBkOpBVpJg+szpPyFmX2GMEGkdUGil5PErIjM\ng4KTs9FMrSenEIVl0Ve5ccISfDcutVWMz0YmffVujCWmLi8lhnN8T4OfzktLTR1l\nKQ0h1CZLvCJQ2YS38WlfHhxVPuqWCej4GhGIlQYe/0aYwztnPhNslNRx6+NrjkrF\noNR+6hMRoW99Czo/O/qY6JNl9TnTwURFD3NHwW3Q1LMxY0yEe+H1JHKfLG85crq1\n+t9eBs24hb6t3Jb5GRNCgkJa4exb1ZikgJ/ji7BL2r8Usc8wWpBArxeSLAIkTBCA\nWTfkX1txAgMBAAECggEAbpHLyUxYp3Uq9y/B5p/K0r4h21admycQG4vkrhHb23eS\nADVJrpOUKSs3dnGv5Fmh6L7kNZQdZ08suJOcPfP6fZ2bubPRqC7MycSyVbq8RHAd\n9Yx+sIcGpklwnULG0TVxCOPNxD1q6XfbQXtMF9We2aby8HQcIkVMKe2GjnozQtce\n0zhTOBsvb57m2Yt7xfJ6x4o2rlx2gzeSqiCdDhBpAOeAf3zwFTHLSP9Eq7Xvf3CV\nyqizRaRLlJZWhy9tmCR5vxWWKrAYUv1K/q2H/2QSbgIL9/SG/2GG9PhTTqRo4MZP\noFfFSfIYoFELNwJatms42pAgeRoZ0gGrb4G8tyOEvQKBgQD9Rfeuu6QU+GdgzcXG\nIsJxRVs0cd4SNtK/fMNckzxGVSHJJ7exdppFB4Pr+zdZzbE2TmvmD4rHEWGUSoIq\nIIRudTsGrDbgSOFG1dwc/UrmXG45ws0WSOpfLmgrBOzNaUKMQc1fHMAkq4x9w7tB\nneq2mrTqHfnznyBggOsKToHkJwKBgQDlpCjFeQ4AQgRB5ksBiEV3QqSjbD9x75nf\n4nZ/QmArIaywuC7lxIwZN3IToNF7VI01FPNNR29U4VJM0wnm4O+kdr44z6IZtNTL\nMbg90tPrhEiwUQwXhRW2+NebVlAcfXHO394kBTyl4ITevpDxG8KRQrMcsWyBT98x\nZZ7MwbYKpwKBgBXzanQKbz4iCVOqgemaOZ/3kuAIvmZ1ue4+se/kEuVFm5gDiTgo\nP1acQCLDsxhla2Z5hYB6+FwodXyUuJNOHiw0nNkHM/pcVqn8/wbELSmp+SOobn3v\n8+Ar9XtFAgELjmj5iwMjSsPi2lpMDH6zYRRSdDuWPYOP1w6GHdjW1QshAoGAPGxB\nPhRoFrFIJX7O5YxRmtuyLj3hQ71jo4EW5M02OKMXqTgNPu/EXS41meyKsgTBUuI8\nUm0lYhQXb5dn15P/+io0SwZ3BISMKRrf+4RptmKMLbhlkhq2Z/p54KmJUrW/KEvH\nS3sFRjAZRfKmeIpxW39NWZNllXDKrViru/yMRakCgYBcIYf2ZadPsbVfV0KxC4U1\nHufu6veGi35QuhmNEPDXYnk40rYNcsI6Jqy1VfKvFJ/cmLTC3WniOksue3bf4lzg\nJapTqTUS254DRVx31iBOuMDP9jWdRmImLYdR3i2VSW0CLrl8VlI1D7hILvNeEzZS\nJZ0JW3Z2eRIdZ3K+w4SaEQ==\n-----END PRIVATE KEY-----\n",
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