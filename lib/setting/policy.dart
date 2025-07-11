import 'package:flutter/material.dart';
class Policy extends StatelessWidget {
  const Policy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right:20,top: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Navigate back to the previous page
                      },
                      child: const Icon(Icons.arrow_back,size: 25,),
                    ),
                    const Text("Privacy Policy",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
                    const Text("  "),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to The Birdo!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'At The Birdo, we are dedicated to helping homeowners maintain a peaceful living environment by keeping birds away from their properties. Established by Lakshay Taneja, our mission is to provide innovative solutions that effectively prevent birds from perching on homes while ensuring a harmonious balance with nature.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our mission is to create a bird-free zone around your home through the use of sound technology. We believe that every homeowner deserves to enjoy their space without the disturbances that come from birds nesting or sitting on their property.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Our Story',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Founded by Lakshay Taneja, The Birdo began with a vision to develop effective solutions for homeowners facing challenges with birds. Through extensive research and development, we have created a sound-based system that deters birds from settling on your house, allowing you to enjoy your living space in peace.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'What We Offer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We specialize in:\n'
                              '- Sound Deterrent Solutions: Our innovative devices emit sounds that effectively discourage birds from perching on your home, ensuring a serene environment.\n'
                              '- Expert Guidance: Our team provides personalized recommendations on the best solutions tailored to your specific needs and property layout.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Our Team',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Birdo is made up of a passionate group of professionals who are focused on developing effective and humane bird deterrent solutions. Our expertise and commitment drive us to provide the best products for our customers.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Community Involvement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'At The Birdo, we believe in giving back. We actively engage with our local community, offering educational resources on bird behavior and the importance of humane deterrent methods. Together, we can create a better living environment for everyone.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Get in Touch',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We would love to hear from you! For any inquiries or feedback, feel free to reach out to us at [contact email or phone number]. Follow us on [mention any social media platforms] to stay updated with our latest news, solutions, and tips for maintaining a bird-free home.',
                          style: TextStyle(fontSize: 16),
                        ),
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
