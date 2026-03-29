import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/common/selection/multi_select_controller.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/history_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MultiSelectController<String> _selectionController =
      MultiSelectController<String>();

  List<_HistoryEntry> _entries = <_HistoryEntry>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectionController.addListener(_onSelectionChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    _selectionController
      ..removeListener(_onSelectionChanged)
      ..dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = sl<GetHistoryUseCase>();
    final result = await repo();

    if (!mounted) {
      return;
    }

    await result.fold(
      (error) async {
        setState(() {
          _errorMessage = error;
          _entries = <_HistoryEntry>[];
          _isLoading = false;
        });
      },
      (history) async {
        final entries = await _hydrateHistory(history);
        if (!mounted) {
          return;
        }
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      },
    );
  }

  Future<List<_HistoryEntry>> _hydrateHistory(
    List<Map<String, dynamic>> history,
  ) async {
    final getTrackUseCase = sl<GetTrackUseCase>();

    final futures = history.map((item) async {
      final rawTrackId = item['trackExternalId']?.toString() ?? '';
      final trackResult = rawTrackId.isNotEmpty
          ? await getTrackUseCase(rawTrackId)
          : null;

      final fallbackTrack = TrackEntity(
        externalId: rawTrackId,
        source: 'audius',
        title: rawTrackId.isNotEmpty ? rawTrackId : 'Bài hát không xác định',
        artistName: 'Không xác định',
        durationSeconds: (item['durationListened'] as num?)?.toInt() ?? 0,
      );

      final track =
          trackResult?.fold((_) => fallbackTrack, (value) => value) ??
          fallbackTrack;

      return _HistoryEntry(
        id: item['id']?.toString() ?? '',
        trackExternalId: rawTrackId,
        listenedAt: _parseDateTime(item['listenedAt']),
        durationListened: (item['durationListened'] as num?)?.toInt() ?? 0,
        track: track,
      );
    });

    return Future.wait(futures);
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }
    return DateTime.now();
  }

  Future<void> _deleteSelected() async {
    final selectedIds = _selectionController.selectedItems
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có mục hợp lệ để xoá.')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xoá lịch sử đã chọn?'),
          content: Text('Bạn sẽ xoá ${selectedIds.length} mục lịch sử nghe.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xoá'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final repo = sl<DeleteHistoryUseCase>();
    final result = await repo(selectedIds);

    if (!mounted) {
      return;
    }

    result.fold(
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
      (deletedCount) {
        setState(() {
          _entries = _entries
              .where((entry) => !selectedIds.contains(entry.id))
              .toList(growable: false);
        });
        _selectionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xoá $deletedCount mục lịch sử.')),
        );
      },
    );
  }

  void _openPlayer(_HistoryEntry entry) {
    final queue = _entries.map((item) => item.track).toList(growable: false);

    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: entry.track,
        queue: queue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inSelectionMode = _selectionController.isSelectionMode;
    final selectedCount = _selectionController.selectedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          inSelectionMode ? '$selectedCount đã chọn' : 'Lịch sử nghe',
        ),
        leading: inSelectionMode
            ? IconButton(
                onPressed: _selectionController.clear,
                icon: const Icon(Icons.close),
              )
            : null,
        actions: inSelectionMode
            ? [
                IconButton(
                  onPressed: () {
                    if (_entries.isEmpty) {
                      return;
                    }
                    _selectionController.selectAll(
                      _entries
                          .where((entry) => entry.id.isNotEmpty)
                          .map((entry) => entry.id),
                    );
                  },
                  icon: const Icon(Icons.select_all),
                  tooltip: 'Chọn tất cả',
                ),
                IconButton(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Xoá mục đã chọn',
                ),
              ]
            : [
                IconButton(
                  onPressed: _loadHistory,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Làm mới',
                ),
              ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadHistory,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử nghe nhạc',
              style: TextStyle(color: AppColors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final isSelectionMode = _selectionController.isSelectionMode;
          final isSelected = _selectionController.isSelected(entry.id);

          return ListTile(
            leading: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      if (entry.id.isNotEmpty) {
                        _selectionController.toggle(entry.id);
                      }
                    },
                  )
                : _HistoryArtwork(track: entry.track),
            title: Text(
              entry.track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${entry.track.artistName} • ${_formatRoundedMinutes(entry.durationListened)} • ${_formatListenedAt(entry.listenedAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            selected: isSelected,
            onLongPress: () {
              if (entry.id.isNotEmpty) {
                _selectionController.enterSelectionMode(entry.id);
              }
            },
            onTap: () {
              if (_selectionController.isSelectionMode) {
                if (entry.id.isNotEmpty) {
                  _selectionController.toggle(entry.id);
                }
                return;
              }
              _openPlayer(entry);
            },
          );
        },
      ),
    );
  }

  String _formatRoundedMinutes(int seconds) {
    if (seconds <= 0) {
      return '0 phút';
    }

    var minutes = (seconds / 60).round();
    if (minutes == 0) {
      minutes = 1;
    }
    return '$minutes phút';
  }

  String _formatListenedAt(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _HistoryArtwork extends StatelessWidget {
  final TrackEntity track;

  const _HistoryArtwork({required this.track});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 52,
        height: 52,
        child: track.artworkUrl != null
            ? CachedNetworkImage(
                imageUrl: track.artworkUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 104,
                memCacheHeight: 104,
                placeholder: (context, url) => _fallbackArtwork(),
                errorWidget: (context, url, error) => _fallbackArtwork(),
              )
            : _fallbackArtwork(),
      ),
    );
  }

  Widget _fallbackArtwork() {
    return Container(
      color: AppColors.grey.withOpacity(0.25),
      child: const Icon(Icons.music_note, color: AppColors.grey),
    );
  }
}

class _HistoryEntry {
  final String id;
  final String trackExternalId;
  final DateTime listenedAt;
  final int durationListened;
  final TrackEntity track;

  const _HistoryEntry({
    required this.id,
    required this.trackExternalId,
    required this.listenedAt,
    required this.durationListened,
    required this.track,
  });
}
