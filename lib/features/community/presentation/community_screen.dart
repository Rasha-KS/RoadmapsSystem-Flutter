import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/community/presentation/chat_room_screen.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';

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
    final hasInitialLoading = provider.loadingRooms && provider.rooms.isEmpty;
    final hasInitialError =
        provider.roomsError != null && provider.rooms.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 9),
            margin: const EdgeInsets.only(top: 10, bottom: 16, right: 15, left: 15),
            decoration: BoxDecoration(
              color: AppColors.accent_1,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'المجتمعات',
              style: AppTextStyles.heading4.copyWith(color: AppColors.text_1),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: hasInitialLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary2),
                  )
                : hasInitialError
                ? _ErrorState(
                    onRetry: () {
                      provider.loadRooms();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await context.read<CommunityProvider>().loadRooms();
                      if (provider.roomsError != null) {
                        _showRefreshFailedSnackBar(messenger);
                      }
                    },
                    color: AppColors.primary2,
                    child: _buildRefreshableContent(provider),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshableContent(CommunityProvider provider) {
    if (provider.rooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
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
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.text_3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: provider.rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
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

  void _showRefreshFailedSnackBar(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        content: Text(
          'تعذر التحديث بسبب انقطاع الاتصال بالشبكة',
          textAlign: TextAlign.right,
          style: AppTextStyles.body.copyWith(color: AppColors.text_2),
        ),
        backgroundColor: AppColors.backGroundError,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'تعذر تحميل المجتمعات',
                style: AppTextStyles.heading5.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                foregroundColor: AppColors.text_1,
                elevation: 0,
              ),
              child: Text(
                'المجتمعات',
                style: AppTextStyles.boldSmallText.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityRoomTile extends StatelessWidget {
  const CommunityRoomTile({
    super.key,
    required this.roomName,
    required this.onTap,
  });

  final String roomName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.communityListTile,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                  color: AppColors.primary.withValues(alpha:0.3), // لون الظل بشفافية
                  offset: const Offset(-3, 3), // يحرك الظل يسار وأسفل
                  blurRadius: 7, // درجة نعومة الظل
                  spreadRadius: 0, // مدى انتشار الظل
                  
                  )
                ]
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary2,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: Offset(1, 2),
                          spreadRadius: 0,
                          blurRadius: 2
                        )
                      ]
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      roomName,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primary1,
                      ),
                    ),
                  ),
                ],
              ),
            ),


          
    
      ),
    );
  }
}



