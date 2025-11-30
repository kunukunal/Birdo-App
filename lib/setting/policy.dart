import 'package:flutter/material.dart';

class Policy extends StatelessWidget {
  const Policy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context); // Navigate back to the previous page
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 25,
                      ),
                    ),
                    const Text(
                      "Privacy Policy",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const Text("  "),
                  ],
                ),
                const SizedBox(height: 20),
                const _PolicyBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyBody extends StatelessWidget {
  const _PolicyBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _bodyText('Last updated: September 30, 2025'),
        // const SizedBox(height: 16),
        _bodyText(
          'This Privacy Policy describes our policies and procedures on the '
          'collection, use, and disclosure of your information when you use the '
          'Service and explains your privacy rights.',
        ),
        const SizedBox(height: 24),
        _sectionTitle('1. Interpretation and Definitions'),
        const SizedBox(height: 12),
        _subTitle('Company Information'),
        _bodyText('The Birdo'),
        _bodyText(
          'F.No 602, Aditya Coral Apartment, New Shiv Bari Road, '
          'Chanakya Nagar, Bikaner, Rajasthan 334001',
        ),
        const SizedBox(height: 12),
        _subTitle('Key Definitions'),
        _bullet(
            'Account: A unique account created for you to access our Service.'),
        _bullet(
            'Personal Data: Any information relating to an identified or identifiable individual.'),
        _bullet(
            'Usage Data: Data collected automatically during the use of the Service.'),
        _bullet(
            'Cookies: Small files placed on your device containing browsing details.'),
        const SizedBox(height: 24),
        _sectionTitle('2. Information Collection'),
        const SizedBox(height: 12),
        _subTitle('Personal Data We Collect'),
        _bullet('First and last name'),
        _bullet('Phone number'),
        _bullet('Address details'),
        _bullet('Usage data'),
        const SizedBox(height: 12),
        _subTitle('Usage Data Collection'),
        _bodyText('We automatically collect:'),
        _bullet('IP address'),
        _bullet('Browser type and version'),
        _bullet('Pages visited and time spent'),
        _bullet('Device information'),
        const SizedBox(height: 24),
        _sectionTitle('3. Use of Your Personal Data'),
        const SizedBox(height: 12),
        _bodyText('We use your data to:'),
        _bullet('Provide and maintain our Service'),
        _bullet('Manage your account and process payments'),
        _bullet('Contact you with updates and notifications'),
        _bullet('Improve our services and user experience'),
        const SizedBox(height: 24),
        _sectionTitle('4. Data Security & Retention'),
        const SizedBox(height: 12),
        _bodyText('We implement the following measures to protect your data:'),
        _bullet('Secure SSL encryption'),
        _bullet('Regular security audits'),
        _bullet('Limited access controls'),
        _bullet('Defined data retention policies'),
        const SizedBox(height: 24),
        _sectionTitle('5. Your Rights'),
        const SizedBox(height: 12),
        _bodyText('You have the right to:'),
        _bullet('Access, correct, or delete your data'),
        _bullet('Object to processing'),
        _bullet('Request data portability'),
        const SizedBox(height: 24),
        _sectionTitle('6. Children\'s Privacy'),
        const SizedBox(height: 12),
        _bodyText(
          'Our Service does not address anyone under the age of 13, and we do '
          'not knowingly collect personal information from children under 13.',
        ),
        const SizedBox(height: 24),
        _sectionTitle('7. Changes to This Policy'),
        const SizedBox(height: 12),
        _bodyText(
            'We may update this Privacy Policy periodically. We will notify you by:'),
        _bullet('Posting the updated policy on this page'),
        _bullet('Sending an email notification'),
        _bullet('Updating the "Last updated" date'),
        const SizedBox(height: 32),
        _sectionTitle('Terms & Conditions'),
        const SizedBox(height: 12),
        _bodyText(
          'By accessing or using our services, you agree to the following terms:',
        ),
        _bullet(
            'Do not misuse our platform or engage in fraudulent activities.'),
        _bullet(
            'All content is owned by The Birdo and may not be copied without permission.'),
        _bullet('We may update these terms at any time without prior notice.'),
        _bullet(
            'Using our payment gateway means accepting the Razorpay terms.'),
        const SizedBox(height: 24),
        _sectionTitle('Additional Privacy Notes'),
        const SizedBox(height: 12),
        _bullet(
            'We collect personal information only to process orders and provide better service.'),
        _bullet(
            'We do not share your information with third parties without consent.'),
        _bullet(
            'Payment details are securely handled via Razorpay and are not stored on our servers.'),
        const SizedBox(height: 24),
        _sectionTitle('Contact Us'),
        const SizedBox(height: 12),
        _bodyText('Email: Thebirdosystem@gmail.com'),
        _bodyText(
          'Address:\nF.No 602, Aditya Coral Apartment, New Shiv Bari Road,\n'
          'Chanakya Nagar, Bikaner, Rajasthan 334001',
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  static Text _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Text _subTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Text _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.4),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
