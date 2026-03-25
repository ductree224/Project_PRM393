import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import '../bloc/track_admin_bloc.dart';
import '../bloc/track_admin_event.dart';
import '../bloc/track_admin_state.dart';
import '../bloc/album_admin_bloc.dart' as album_bloc;
import '../bloc/album_admin_event.dart' as album_event;
import '../bloc/album_admin_state.dart' as album_state;
import '../../../../data/models/track_admin_model.dart';
import 'package:intl/intl.dart';

class AdminTracksPage extends StatefulWidget {
  const AdminTracksPage({super.key});

  @override
  State<AdminTracksPage> createState() => _AdminTracksPageState();
}

class _AdminTracksPageState extends State<AdminTracksPage> {
  final Set<String> _selectedTrackIds = {};
  String _currentStatusFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrackAdminBloc>()..add(const LoadTracks()),
      child: BlocConsumer<TrackAdminBloc, TrackAdminState>(
        listener: (context, state) {
          if (state is TrackAdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is TrackAdminOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            setState(() {
              _selectedTrackIds.clear();
            });
          }
        },
        builder: (context, state) {
          bool isDesktop = MediaQuery.of(context).size.width >= 1100;

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Actions
                isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildHeaderTitle(),
                          _buildHeaderActions(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderTitle(),
                          const SizedBox(height: 24),
                          _buildHeaderActions(),
                        ],
                      ),
                const SizedBox(height: 32),
                // Filters & Stats
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildFiltersContainer(context),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildStatsContainer(state),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          _buildFiltersContainer(context),
                          const SizedBox(height: 24),
                          _buildStatsContainer(state),
                        ],
                      ),
                const SizedBox(height: 32),
                // Data Table Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF201F1F),
                        borderRadius: BorderRadius.circular(16)),
                    width: double.infinity,
                    child: state is TrackAdminLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (state is TrackAdminLoaded)
                            ? _buildTable(context, state.tracks)
                            : (state is TrackAdminOperationInProgress)
                                ? _buildTable(context, state.tracks)
                                : const Center(
                                    child: Text('No tracks loaded',
                                        style: TextStyle(color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 24),
                // Sticky Footer (Bulk Action)
                if (_selectedTrackIds.isNotEmpty)
                  _buildBulkActionsFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<TrackAdminModel> tracks) {
    if (tracks.isEmpty) {
      return const Center(
          child:
              Text('No tracks found.', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: true,
          headingRowColor: WidgetStateProperty.all(
              const Color(0xFF2A2A2A).withValues(alpha: 0.5)),
          columns: const [
            DataColumn(
                label: Text('TRACK INFO',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
            DataColumn(
                label: Text('ARTIST & ALBUM',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
            DataColumn(
                label: Text('STATUS',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
            DataColumn(
                label: Text('CACHED AT',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
            DataColumn(
                label: Text('ACTIONS',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
          ],
          rows: tracks.map((track) {
            final isSelected = _selectedTrackIds.contains(track.externalId);
            return _buildTrackRow(context, track, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBulkActionsFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFD79B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.info,
                      color: Color(0xFFFFD79B), size: 16)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selection Mode (${_selectedTrackIds.length} selected)',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const Text('SELECT TRACKS TO PERFORM MASS ACTIONS',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                ],
              )
            ],
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTrackIds.clear();
                    });
                  },
                  child: const Text('Clear Selection',
                      style: TextStyle(color: Colors.grey))),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                color: const Color(0xFF2A2A2A),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('Bulk Update', style: TextStyle(color: Colors.white)),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
                onSelected: (status) {
                  context.read<TrackAdminBloc>().add(UpdateTrackStatus(
                    externalIds: _selectedTrackIds.toList(),
                    status: status,
                  ));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Active', child: Text('Set Active', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'Inactive', child: Text('Set Inactive', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'Hidden', child: Text('Set Hidden', style: TextStyle(color: Colors.white))),
                ],
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD79B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showAlbumSelectionDialog(context),
                icon: const Icon(Icons.library_add, size: 18),
                label: const Text('Add to Album'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATALOG > TRACK MANAGEMENT',
            style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Manage Tracks',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 4),
        Text('Configure your global library and active cache',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD79B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          onPressed: () {
            // Placeholder: Search external to add new tracks to cache
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search in common UI to fetch more tracks.')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Fetch New Tracks'),
        ),
      ],
    );
  }

  Widget _buildFiltersContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() { _searchQuery = val; });
                    context.read<TrackAdminBloc>().add(LoadTracks(
                      query: val,
                      status: _currentStatusFilter,
                    ));
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search title or artist...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  context.read<TrackAdminBloc>().add(LoadTracks(
                    query: _searchQuery,
                    status: _currentStatusFilter,
                  ));
                },
                icon: const Icon(Icons.refresh, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('STATUS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['All', 'Active', 'Inactive', 'Hidden'].map((status) {
                    final isSelected = _currentStatusFilter == status;
                    return GestureDetector(
                      onTap: () {
                        setState(() { _currentStatusFilter = status; });
                        context.read<TrackAdminBloc>().add(LoadTracks(
                          status: status,
                          query: _searchQuery,
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF353534) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFFFD79B) : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContainer(TrackAdminState state) {
    int total = 0;
    if (state is TrackAdminLoaded) {
      total = state.tracks.length;
    } else if (state is TrackAdminOperationInProgress) {
      total = state.tracks.length;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16)),
      width: double.infinity,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOADED TRACKS',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              Text(total.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFA4E7FF), size: 12),
                  SizedBox(width: 4),
                  Text('In results',
                      style: TextStyle(color: Color(0xFFA4E7FF), fontSize: 10)),
                ],
              )
            ],
          ),
          const Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.library_music, size: 60, color: Colors.white10)),
        ],
      ),
    );
  }

  DataRow _buildTrackRow(BuildContext context, TrackAdminModel track, bool isSelected) {
    Color statusColor = Colors.grey;
    if (track.status == 'Active') {
      statusColor = const Color(0xFFA4E7FF);
    } else if (track.status == 'Inactive') {
      statusColor = Colors.redAccent;
    }

    return DataRow(
      selected: isSelected,
      onSelectChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedTrackIds.add(track.externalId);
          } else {
            _selectedTrackIds.remove(track.externalId);
          }
        });
      },
      cells: [
        DataCell(Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildImage(track.artworkUrl),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(track.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(track.source.toUpperCase(),
                    style: const TextStyle(color: Colors.grey, fontSize: 9)),
              ],
            )
          ],
        )),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(track.artistName,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
            if (track.albumName != null)
              Text(track.albumName!,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Text(track.status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        )),
        DataCell(Text(
          DateFormat('yyyy-MM-dd HH:mm').format(track.cachedAt),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.visibility_off, color: Colors.grey, size: 18),
                tooltip: 'Hide',
                onPressed: () {
                  context.read<TrackAdminBloc>().add(UpdateTrackStatus(
                    externalIds: [track.externalId],
                    status: 'Hidden',
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 18),
                tooltip: 'Activate',
                onPressed: () {
                  context.read<TrackAdminBloc>().add(UpdateTrackStatus(
                    externalIds: [track.externalId],
                    status: 'Active',
                  ));
                }),
            IconButton(
                icon: const Icon(Icons.library_add, color: Colors.grey, size: 18),
                tooltip: 'Add to Album',
                onPressed: () {
                  setState(() {
                    _selectedTrackIds.clear();
                    _selectedTrackIds.add(track.externalId);
                  });
                  _showAlbumSelectionDialog(context);
                }),
          ],
        )),
      ],
    );
  }

  void _showAlbumSelectionDialog(BuildContext context) {
    final trackAdminBloc = context.read<TrackAdminBloc>();
    String? selectedAlbumId;

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: trackAdminBloc),
          BlocProvider(create: (context) => sl<album_bloc.AlbumAdminBloc>()..add(const album_event.LoadAlbums())),
        ],
        child: BlocListener<TrackAdminBloc, TrackAdminState>(
          listener: (context, state) {
            if (state is TrackAdminOperationSuccess) {
              Navigator.pop(dialogContext);
            }
          },
          child: StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Select Album', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 400,
                height: 400,
                child: BlocBuilder<album_bloc.AlbumAdminBloc, album_state.AlbumAdminState>(
                  builder: (context, state) {
                    if (state is album_state.AlbumAdminLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is album_state.AlbumAdminError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  }
                  if (state is album_state.AlbumAdminLoaded) {
                    final albums = state.albums;
                    if (albums.isEmpty) {
                      return const Center(child: Text('No albums found', style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.separated(
                      itemCount: albums.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final isSelected = selectedAlbumId == album.id;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: const Color(0xFFFFD79B).withValues(alpha: 0.1),
                          leading: _buildImage(album.coverImageUrl),
                          title: Text(album.title, style: TextStyle(color: isSelected ? const Color(0xFFFFD79B) : Colors.white)),
                          subtitle: Text(album.artist?.name ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? const Color(0xFFFFD79B) : Colors.grey,
                            size: 20,
                          ),
                          onTap: () {
                            setDialogState(() {
                              selectedAlbumId = isSelected ? null : album.id;
                            });
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Unexpected state'));
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              BlocBuilder<TrackAdminBloc, TrackAdminState>(
                builder: (context, state) {
                  final isLoading = state is TrackAdminLoading || state is TrackAdminOperationInProgress;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD79B),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                    onPressed: (selectedAlbumId == null || isLoading)
                        ? null
                        : () {
                            // Dispatch bulk add event
                            trackAdminBloc.add(AddTracksToAlbum(
                                  albumId: selectedAlbumId!,
                                  trackIds: _selectedTrackIds.toList(),
                                ));
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Add to Album'),
                  );
                },
              ),
            ],
          );
        }),
      ),
    ),
  );
}

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.album, color: Colors.grey);
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || uri.scheme == 'file') {
        return const Icon(Icons.album, color: Colors.grey);
      }
      return Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 20),
      );
    } catch (_) {
      return const Icon(Icons.album, color: Colors.grey);
    }
  }
}
