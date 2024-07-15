import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDetailPage extends StatelessWidget {
  final String documentId;

  BloodDetailPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Post Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('blood_donation').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Blood post not found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Hospital', data['hospital'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Description', data['description'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Blood Quantity', data['blood_quantity'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Phone', data['phone'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Location Details', data['location_details'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Blood Group', data['blood_group'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Sub District', data['sub_district'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('District', data['district'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow('Posted by User ID', data['user_id'] ?? 'Unknown'),
                SizedBox(height: 10),
                _buildInfoRow(
                  'Operation Date',
                  data['operation_date'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(data['operation_date'].millisecondsSinceEpoch).toString()
                      : 'Unknown',
                ),
                SizedBox(height: 10),
                _buildInfoRow(
                  'Last Application Date',
                  data['last_application_date'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(data['last_application_date'].millisecondsSinceEpoch).toString()
                      : 'Unknown',
                ),
                SizedBox(height: 10),
                _buildInfoRow('Image URL', data['image_url'] ?? 'Unknown'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}