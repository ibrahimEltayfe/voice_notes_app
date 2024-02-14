import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:voice_notes/core/utils/app_bottom_sheet.dart';
import 'package:voice_notes/core/utils/constants/app_colors.dart';
import 'package:voice_notes/core/utils/constants/app_styles.dart';
import 'package:voice_notes/home/manager/audio_recorder_manager/audio_recorder_file_helper.dart';
import 'package:voice_notes/home/manager/voice_notes_cubit/voice_notes_cubit.dart';
import 'package:voice_notes/home/model/voice_note_model.dart';
import 'package:voice_notes/home/widgets/audio_recorder_view/audio_recorder_view.dart';
import 'package:voice_notes/home/widgets/voice_note_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceNotesCubit(AudioRecorderFileHelper()),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({super.key});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final PagingController<int,VoiceNoteModel> pagingController =
    PagingController<int,VoiceNoteModel>(firstPageKey: 1,invisibleItemsThreshold: 6);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      context.read<VoiceNotesCubit>().getAllVoiceNotes(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  void onDataFetched(VoiceNotesFetched state) {
    final data = state.voiceNotes;

    final isLastPage = data.isEmpty || data.length < context.read<VoiceNotesCubit>().fetchLimit;
    if (isLastPage) {
      pagingController.appendLastPage(data);
    } else {
      final nextPageKey = (pagingController.nextPageKey??0) + 1;
      pagingController.appendPage(data, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text("Voice Notes",style: AppTextStyles.bold(
                      fontSize: 24,
                      color: AppColors.black900,
                    ),),
                  ),

                  const SizedBox(height: 16,),

                  Expanded(
                    child: BlocListener<VoiceNotesCubit,VoiceNotesState>(
                      listener: (context, state) {
                        if(state is VoiceNotesError){
                          pagingController.error = state.message;
                        }else if(state is VoiceNotesFetched){
                          onDataFetched(state);
                        }else if(state is VoiceNoteDeleted){
                          final List<VoiceNoteModel> voiceNotes = List.from(pagingController.value.itemList ?? []);
                          voiceNotes.remove(state.voiceNoteModel);
                          pagingController.itemList = voiceNotes;
                        }else if(state is VoiceNoteAdded){
                          final List<VoiceNoteModel> newItems = List.from(pagingController.itemList ?? []);
                          newItems.insert(0,state.voiceNoteModel);
                          pagingController.itemList = newItems;
                        }
                      },
                      child: PagedListView<int,VoiceNoteModel>(
                        pagingController: pagingController,
                        padding: const EdgeInsets.only(
                            right: 24,
                            left: 24,
                            bottom: 80
                        ),
                        builderDelegate: PagedChildBuilderDelegate(
                          noItemsFoundIndicatorBuilder: (context) {
                            return Column(
                                children: [
                                  const SizedBox(height: 55,),

                                  SvgPicture.asset(
                                    "assets/images/no_voice_notes.svg",
                                    width: 350,
                                    height: 340,
                                    placeholderBuilder: (context) {
                                      return const SizedBox(
                                        width: 350,
                                        height: 340,
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16,),

                                  Text(
                                    "No voice notes yet!",
                                    style: AppTextStyles.medium(
                                        color: AppColors.grey,
                                        fontSize: 24
                                    ),
                                  ),
                                ]
                            );
                          },
                          firstPageErrorIndicatorBuilder: (context) {
                            return Center(
                              child: Column(
                                children: [
                                  Text(pagingController.error.toString()),

                                  const SizedBox(height: 8,),

                                  GestureDetector(
                                      onTap: () {
                                        pagingController.retryLastFailedRequest();
                                      },
                                      child: Text("Retry",style: AppTextStyles.medium(),)
                                  )
                                ],
                              ),
                            );
                          },
                          firstPageProgressIndicatorBuilder: (context) {
                            return const Center(child: CircularProgressIndicator(),);
                          },
                          newPageProgressIndicatorBuilder: (context) {
                            return const Center(child: CircularProgressIndicator(),);
                          },
                          noMoreItemsIndicatorBuilder: (context) {
                            return const SizedBox.shrink();
                          },
                          itemBuilder: (context, item, index) {
                            return VoiceNoteCard(voiceNoteInfo: item);
                          },

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            child: Container(
              width: 150,
              height: 50,
              decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(70),
                    topLeft: Radius.circular(70),
                  )
              ),
            ),
          ),

          const Positioned(
            bottom:10,
            child: _AddRecordButton()
          )
        ],
      )
    );
  }
}

class _AddRecordButton extends StatelessWidget {
  const _AddRecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(27),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.white12,
        onTap: () async{
          final VoiceNoteModel? newVoiceNote = await showAppBottomSheet(
            context,
            builder: (context){
              return const AudioRecorderView();
            }
          );

          if(newVoiceNote != null && context.mounted){
            context.read<VoiceNotesCubit>().addToVoiceNotes(newVoiceNote);
          }
        },
        child: const SizedBox(
          width: 75,
          height: 75,
          child: Icon(
            FeatherIcons.plus,
            color: AppColors.background,
            size: 28,
          ),
        ),
      ),
    );
  }
}
