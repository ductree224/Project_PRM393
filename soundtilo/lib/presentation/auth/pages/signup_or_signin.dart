import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/common/widgets/button/basic_app_button.dart';
import 'package:soundtilo/core/configs/assets/app_images.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/presentation/auth/pages/signin.dart';
import 'package:soundtilo/presentation/auth/pages/signup.dart';

import '../../../common/widgets/appbar/app_bar.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          const BasicAppBar(),
          Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                AppImages.authBG,
              )
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                        AppVectors.logo,
                        width: MediaQuery.of(context).size.width * 0.55,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Tận hưởng không gian nghe nhạc tuyệt vời',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: BasicAppButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => const SignUpPage()
                                  ),
                              );
                            },
                            title: 'Đăng ký',

                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => const SignInPage()
                                  ),
                                );
                              },
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: context.isDarkMode ? Colors.white : Colors.black,
                                ),
                              )
                          ),


                        )
                      ],
                    )
                  ],
                ),
              )
          ),
        ],
      )
    );
  }
}
