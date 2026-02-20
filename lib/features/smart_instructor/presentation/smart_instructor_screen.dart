import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_conversation_screen.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_intro_screen.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';

class SmartInstructorScreen extends StatefulWidget {
  const SmartInstructorScreen({super.key});

  @override
  State<SmartInstructorScreen> createState() => _SmartInstructorScreenState();
}

class _SmartInstructorScreenState extends State<SmartInstructorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SmartInstructorProvider>();
      if (provider.intro == null && !provider.introLoading) {
        provider.loadIntro();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartInstructorIntroScreen(
      onStartPressed: () async {
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SmartInstructorConversationScreen(),
          ),
        );
      },
    );
  }
}
