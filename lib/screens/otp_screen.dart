import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:sahayagi/widget/common_widget.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Code",style: appFontStyle(30,texColorDark,FontWeight.bold),),
              Text("Verification",style: appFontStyle(20),),
              SizedBox(height: 10,),
              Text("Enter the verification code sent at"),
              Text("support@gmail.com"),
              SizedBox(height: 30,),
              OtpTextField(
                mainAxisAlignment: MainAxisAlignment.center,
                numberOfFields: 6,
                fillColor: texColorLight.withOpacity(.5),
                filled: true,
                onSubmit: (code){print("Your OTP is => $code");},

              ),
              TextButton(onPressed: (){}, child: Text("Next"))

            ],
          ),
        ),
      ),
    );
  }
}
