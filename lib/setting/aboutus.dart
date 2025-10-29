import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

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
                      "About Us",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const Text(""),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to The Birdo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'At The Birdo, we are redefining how people live and work in harmony with nature.\n'
                          'Founded by Ar. Lakshya Taneja, The Birdo offers innovative sound-based solutions that gently guide birds away from sensitive areas — keeping surroundings clean, calm, and healthy without causing harm.\n\n'
                          'Our vision is simple: to create peaceful, hygienic, and balanced environments across homes, industries, and institutions through the power of intelligent design and technology.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our mission is to help people protect their spaces while preserving nature\'s rhythm.\n'
                          'Using advanced acoustic technology, we reduce bird disturbances around buildings — ensuring safety, hygiene, and serenity in homes, factories, schools, hotels, and hospitals alike.\n'
                          'We believe true innovation is one that serves both humans and the environment with compassion.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Our Story',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Birdo began when Ar. Lakshya Taneja, an architect deeply involved in healthy living design, observed how birds nesting on rooftops and ledges were affecting air quality and structural hygiene in urban areas.\n\n'
                          'Driven by this insight, our team developed a humane, research-based acoustic system that prevents birds from settling on buildings — a solution that respects life while restoring cleanliness and calm to human spaces.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'What We Offer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Acoustic Deterrent Devices\n'
                          'Smart sound systems engineered to gently discourage birds from resting or nesting on structures — ensuring lasting cleanliness and comfort.\n\n'
                          '2. Customized Solutions for Every Sector\n'
                          'From residential buildings and factories to hospitals, hotels, schools, and warehouses, The Birdo provides tailored configurations suited to your architecture and surroundings.\n\n'
                          '3. Expert Consultation\n'
                          'Our specialists study your property layout and environmental context to design effective, aesthetic, and sustainable solutions.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Our Team',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Birdo is powered by a dedicated group of architects, engineers, and environmental designers committed to creating technologies that serve both people and nature.\n'
                          'Our strength lies in combining scientific precision with ethical design thinking.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Community & Responsibility',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We believe awareness builds lasting change.\n'
                          'That\'s why The Birdo works with communities and organizations to share knowledge on bird behavior, health safety, and humane deterrence methods — fostering cleaner cities and healthier living for all.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Get in Touch',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'re here to help you protect your space with intelligence and care.\n',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text('📩 Email: ', style: TextStyle(fontSize: 16)),
                            GestureDetector(
                              onTap: () async {
                                const url = 'mailto:thebirdosystem@gmail.com';
                                try {
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                } catch (e) {
                                  try {
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.externalApplication);
                                  } catch (e2) {
                                    print('Could not launch email: $e2');
                                  }
                                }
                              },
                              child: Text(
                                'thebirdosystem@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 8),
                        // Text(
                        //   '📱 Follow us on Instagram for updates, insights, and real-world applications of The Birdo.',
                        //   style: TextStyle(fontSize: 16),
                        // ),
                        // SizedBox(height: 16),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Follow us on ',
                        //       style: TextStyle(fontSize: 16),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () async {
                        //         const url =
                        //             'https://www.instagram.com/the__birdo?igsh=MWlkbnJmZmhjNWJwMw==';
                        //         try {
                        //           final uri = Uri.parse(url);
                        //           if (await canLaunchUrl(uri)) {
                        //             await launchUrl(uri,
                        //                 mode: LaunchMode.externalApplication);
                        //           } else {
                        //             // Fallback: try to launch without checking
                        //             await launchUrl(uri,
                        //                 mode: LaunchMode.externalApplication);
                        //           }
                        //         } catch (e) {
                        //           // If URL launcher fails, try alternative approach
                        //           try {
                        //             await launchUrl(Uri.parse(url),
                        //                 mode: LaunchMode.externalApplication);
                        //           } catch (e2) {
                        //             print('Could not launch URL: $e2');
                        //           }
                        //         }
                        //       },
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Icon(
                        //             Icons.camera_alt,
                        //             color: Colors.pink[600],
                        //             size: 20,
                        //           ),
                        //           SizedBox(width: 4),
                        //           Text(
                        //             'Instagram',
                        //             style: TextStyle(
                        //               fontSize: 16,
                        //               color: Colors.pink[600],
                        //               fontWeight: FontWeight.w500,
                        //               decoration: TextDecoration.underline,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
