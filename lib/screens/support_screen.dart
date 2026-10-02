import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.indigo,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "CONTACT SUPPORT",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "If you need assistance, please contact our support team.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(Icons.email,color: Colors.indigo),
                        SizedBox(width:10),
                        Text(
                          "support@premmotors.co.in",
                          style: TextStyle(fontSize:18),
                        ),
                      ],
                    ),

                    SizedBox(height:20),

                    Row(
                      children: [
                        Icon(Icons.phone,color: Colors.green),
                        SizedBox(width:10),
                        Text(
                          "+91-70242 31111",
                          style: TextStyle(fontSize:18),
                        ),
                      ],
                    ),

                    SizedBox(height:20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time,color: Colors.orange),
                        SizedBox(width:10),
                        Expanded(
                          child: Text(
                            "Monday - Saturday\n10:00 AM - 7:00 PM",
                            style: TextStyle(fontSize:18),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height:30),

            const Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),

            const SizedBox(height:15),

            faqTile(
              "How do I reset my password?",
              "Click Forgot Password on the login page. Enter your registered email and follow the instructions sent to your inbox.",
            ),

            faqTile(
              "How do I update my profile?",
              "Login to your account, open My Profile, edit your details and click Save Changes.",
            ),

            faqTile(
              "How do I report a technical issue?",
              "Use the support form below and include screenshots, browser details, error messages and steps to reproduce the issue.",
            ),

            faqTile(
              "How can I track my support ticket?",
              "After submission you'll receive a ticket ID by email. Use it for future communication.",
            ),

            faqTile(
              "What are your support hours?",
              "Our support team is available Monday to Saturday from 10:00 AM to 7:00 PM.",
            ),

          ],
        ),
      ),
    );
  }

  static Widget faqTile(String title,String answer){
    return Card(
      margin: const EdgeInsets.only(bottom:12),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(fontSize:16),
            ),
          ),

        ],
      ),
    );
  }
}