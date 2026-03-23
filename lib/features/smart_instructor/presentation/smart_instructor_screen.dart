import 'package:flutter/material.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_conversation_screen.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_intro_screen.dart';

class SmartInstructorScreen extends StatelessWidget {
  const SmartInstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartInstructorIntroScreen(
      onStartPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SmartInstructorConversationScreen(),
          ),
        );
      },
    );
  }
}
