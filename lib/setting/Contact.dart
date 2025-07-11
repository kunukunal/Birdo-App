import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right:20,top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Text("Contact Us",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
                    const Text(""),
                  ],
                ),

                const SizedBox(height: 20,),

                const Text("If you have any issue or any other matters, Please contact us.",style:TextStyle(fontSize: 16),),
                const SizedBox(height: 20,),

                const Row(
                  children: [
                    Icon(Icons.email_outlined,color: Color(0xFFDA4C4F),),
                    SizedBox(width: 10,),
                    Text("Support@thebirdo.com"),

                  ],
                )



              ],
            ),
          ),
        ),
      ),
    );
  }
}
