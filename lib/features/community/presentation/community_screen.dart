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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 10),
            margin: const EdgeInsets.only(top: 10, bottom: 14),
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
          TextField(
            textDirection: TextDirection.rtl,
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'البحث',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.text_4),
              prefixIcon: const Icon(Icons.search, color: AppColors.text_1),
              filled: true,
              fillColor: AppColors.secondary4,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CommunityProvider provider) {
    if (provider.query.trim().isNotEmpty && provider.filteredRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppColors.primary2,
            ),
            const SizedBox(height: 12),
            Text(
              'لم يتم العثور على أي نتيجة',
              style: AppTextStyles.body.copyWith(color: AppColors.text_3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
              'لا يوجد اي مجتمع',
              style: AppTextStyles.body.copyWith(color: AppColors.text_3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: provider.filteredRooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = provider.filteredRooms[index];

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
