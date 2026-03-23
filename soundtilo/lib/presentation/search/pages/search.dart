import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/common/widgets/track/track_tile.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/search/bloc/search_bloc.dart';
import 'package:soundtilo/presentation/search/bloc/search_event.dart';
import 'package:soundtilo/presentation/search/bloc/search_state.dart';

class SearchPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const SearchPage({super.key, this.onBackPressed, this.showBackButton = true});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _handleBack,
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        return TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Tìm bài hát, nghệ sĩ...',
                            filled: true,
                            fillColor: context.isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.grey,
                            ),
                            suffixIcon: value.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _controller.clear();
                                      context.read<SearchBloc>().add(
                                        SearchCleared(),
                                      );
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (query) {
                            context.read<SearchBloc>().add(
                              SearchQueryChanged(query),
                            );
                          },
                          onSubmitted: (query) {
                            context.read<SearchBloc>().add(
                              SearchSubmitted(query),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppColors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tìm kiếm bài hát yêu thích',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off,
                            size: 64,
                            color: AppColors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy kết quả cho "${state.query}"',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: AppColors.errorColor),
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final track = state.results[index];
                        return TrackTile(
                          track: track,
                          onMoreTap: () => _showTrackActions(context, track),
                          onTap: () {
                            Navigator.push(
                              context,
                              PlayerPage.createRoute(
                                track: track,
                                queue: state.results,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTrackActions(
    BuildContext context,
    TrackEntity track,
  ) async {
    final libraryState = context.read<LibraryBloc>().state;
    final isFavorite =
        libraryState is LibraryLoaded &&
        libraryState.favoriteTrackIds.contains(track.externalId);

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                title: Text(isFavorite ? 'Bo yeu thich' : 'Them vao yeu thich'),
                onTap: () {
                  context.read<LibraryBloc>().add(
                    LibraryToggleFavorite(track.externalId),
                  );
                  Navigator.of(sheetContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Them vao playlist'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _showPlaylistChooser(context, track);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPlaylistChooser(
    BuildContext context,
    TrackEntity track,
  ) async {
    final libraryBloc = context.read<LibraryBloc>();
    final libraryState = libraryBloc.state;

    if (libraryState is! LibraryLoaded) {
      libraryBloc.add(LibraryLoad());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dang tai thu vien. Vui long thu lai sau.'),
        ),
      );
      return;
    }

    if (libraryState.playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ban chua co playlist nao.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: libraryState.playlists.length,
            itemBuilder: (context, index) {
              final playlist = libraryState.playlists[index];
              return ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackCount} bai hat'),
                onTap: () {
                  libraryBloc.add(
                    LibraryAddTrackToPlaylist(
                      playlistId: playlist.id,
                      trackExternalId: track.externalId,
                    ),
                  );
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Da them vao ${playlist.name}.')),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleBack() async {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!.call();
      return;
    }

    final popped = await Navigator.of(context).maybePop();
    if (!popped && mounted) {
      _focusNode.unfocus();
    }
  }
}
