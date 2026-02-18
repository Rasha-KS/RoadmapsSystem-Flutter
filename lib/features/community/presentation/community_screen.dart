import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/community/presentation/chat_room_screen.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/community/presentation/widgets/community_room_tile.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 10),
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.accent_1,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              'المجتمعات',
              style: AppTextStyles.heading5.copyWith(color: AppColors.text_1),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildContent(CommunityProvider provider) {
    if (provider.loadingRooms && provider.rooms.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary2),
      );
    }

    if (provider.rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.speaker_notes_off_outlined,
              size: 74,
              color: AppColors.primary2,
            ),
            const SizedBox(height: 14),
            Text(
              'لا يوجد أي مجتمع',
              style: AppTextStyles.body.copyWith(color: AppColors.text_3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: provider.rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = provider.rooms[index];
        return CommunityRoomTile(
          roomName: room.name,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  chatRoomId: room.id,
                  roomName: room.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
