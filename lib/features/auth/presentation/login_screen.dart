import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(  
          backgroundColor: Color.fromRGBO(238, 241, 243, 1),
          actions:[
           IconButton(
            iconSize: 35,
            splashRadius: 35,
            padding: EdgeInsets.all(30),
            onPressed: (){
           Navigator.of(context).pop();
          }, 
          icon: Icon(Icons.arrow_right_alt_rounded,size: 35,color: Color.fromRGBO(12, 32, 49, 1),)
          ,)
          ,]
           ),
          backgroundColor: Color.fromRGBO(238, 241, 243, 1),
          body: Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      child: Text(
                        "تسجيل دخول",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromRGBO(45, 49, 96, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: "البريد الالكتروني",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(184, 198, 209, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(184, 198, 209, 1),
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(248, 154, 100, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(248, 154, 100, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 1),
                          child: TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: "كلمة المرور",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(184, 198, 209, 1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(184, 198, 209, 1),
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(248, 154, 100, 1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(248, 154, 100, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentGeometry.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "هل نسيت كلمة المرور؟",
                              style: TextStyle(
                                color: Color.fromRGBO(201, 110, 58, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                
                    Padding(
                         padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: MaterialButton(
                        onPressed: () {},
                        height: 45,
                        minWidth: 187,
                        color: Color.fromRGBO(254, 202, 172, 1),
                        disabledColor: Color.fromRGBO(134, 204, 255, 0.2),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Color.fromRGBO(248, 154, 100, 1),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "تسجيل",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(34, 51, 66, 1),
                          ),
                        ),
                      ),
                    ),
                
                    /// إنشاء حساب جديد
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          color: Color.fromRGBO(248, 154, 100, 1),
                          fontSize: 14,
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 15),
                
                    /// أو تسجيل دخول بـ
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("او تسجيل دخول بـ"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                 const SizedBox(height: 25),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.g_mobiledata, size: 50),
                        ),
                        Text("Google",style: TextStyle(
                           color: Color.fromRGBO(45, 49, 96, 1),
                        ),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
