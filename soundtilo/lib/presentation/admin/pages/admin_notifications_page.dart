import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/core/network/api_client.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Dio _dio = sl<ApiClient>().dio;

  bool _isLoadingTemplates = false;
  bool _isLoadingSchedules = false;
  List<Map<String, dynamic>> _templates = const [];
  List<Map<String, dynamic>> _schedules = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTemplates();
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoadingTemplates = true);
    try {
      final response = await _dio.get(
        ApiUrls.adminNotificationTemplates,
        queryParameters: {'page': 1, 'pageSize': 100},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['templates'] as List?) ?? const [];
      _templates = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the tai template thong bao.'));
    } catch (e) {
      _showMessage('Da xay ra loi: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingTemplates = false);
      }
    }
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoadingSchedules = true);
    try {
      final response = await _dio.get(
        ApiUrls.adminNotificationSchedules,
        queryParameters: {'page': 1, 'pageSize': 100},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['schedules'] as List?) ?? const [];
      _schedules = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the tai lich thong bao.'));
    } catch (e) {
      _showMessage('Da xay ra loi: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSchedules = false);
      }
    }
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await _dio.delete(ApiUrls.adminNotificationTemplateById(id));
      _showMessage('Da xoa template.');
      await _loadTemplates();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the xoa template.'));
    }
  }

  Future<void> _saveTemplate(Map<String, dynamic> payload, {String? id}) async {
    try {
      if (id == null) {
        await _dio.post(ApiUrls.adminNotificationTemplates, data: payload);
      } else {
        await _dio.put(
          ApiUrls.adminNotificationTemplateById(id),
          data: payload,
        );
      }
      _showMessage('Da luu template.');
      await _loadTemplates();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the luu template.'));
    }
  }

  Future<void> _saveSchedule(Map<String, dynamic> payload, {String? id}) async {
    try {
      if (id == null) {
        await _dio.post(ApiUrls.adminNotificationSchedules, data: payload);
      } else {
        await _dio.put(
          ApiUrls.adminNotificationScheduleById(id),
          data: payload,
        );
      }
      _showMessage('Da luu lich thong bao.');
      await _loadSchedules();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the luu lich thong bao.'));
    }
  }

  Future<void> _cancelSchedule(String id) async {
    try {
      await _dio.delete(ApiUrls.adminNotificationScheduleById(id));
      _showMessage('Da huy lich thong bao.');
      await _loadSchedules();
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the huy lich thong bao.'));
    }
  }

  Future<void> _sendTestBroadcast() async {
    try {
      await _dio.post(
        ApiUrls.adminNotificationSendBroadcast,
        data: {
          'type': 4,
          'title': 'Test realtime notification',
          'message': 'Thong bao test tu trang admin notifications.',
          'metadataJson': '{"origin":"admin-ui-test"}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 12))
              .toUtc()
              .toIso8601String(),
        },
      );
      _showMessage('Da gui thong bao test den tat ca user.');
    } on DioException catch (e) {
      _showMessage(_extractError(e, 'Khong the gui thong bao test.'));
    }
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quan ly template thong bao va lich gui thong bao tu dong.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _sendTestBroadcast,
                icon: const Icon(Icons.send),
                label: const Text('Send test notification'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Templates'),
              Tab(text: 'Schedules'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildTemplatesTab(), _buildSchedulesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    if (_isLoadingTemplates) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<_TemplateResult>(
                  context: context,
                  builder: (context) => const _TemplateDialog(),
                );
                if (result != null) {
                  await _saveTemplate(result.payload);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New template'),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: _templates.length,
              separatorBuilder: (_, index) =>
                  const Divider(height: 1, color: Colors.white12),
              itemBuilder: (context, index) {
                final item = _templates[index];
                final id = item['id']?.toString() ?? '';
                return ListTile(
                  title: Text(
                    item['name']?.toString() ?? '(No name)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${item['type']} • ${item['isActive'] == true ? 'Active' : 'Inactive'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () async {
                          final result = await showDialog<_TemplateResult>(
                            context: context,
                            builder: (context) =>
                                _TemplateDialog(initial: item),
                          );
                          if (result != null) {
                            await _saveTemplate(result.payload, id: id);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deleteTemplate(id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesTab() {
    if (_isLoadingSchedules) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<_ScheduleResult>(
                  context: context,
                  builder: (context) => _ScheduleDialog(
                    templateOptions: _templates
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t['id']?.toString(),
                            child: Text(t['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(growable: false),
                  ),
                );
                if (result != null) {
                  await _saveSchedule(result.payload);
                }
              },
              icon: const Icon(Icons.schedule),
              label: const Text('New schedule'),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: _loadSchedules,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: _schedules.length,
              separatorBuilder: (_, index) =>
                  const Divider(height: 1, color: Colors.white12),
              itemBuilder: (context, index) {
                final item = _schedules[index];
                final id = item['id']?.toString() ?? '';
                return ListTile(
                  title: Text(
                    item['title']?.toString() ?? '(No title)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Status: ${item['status']} • ${item['recurrence'] ?? 'OneTime'} • At: ${item['scheduledFor']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () async {
                          final result = await showDialog<_ScheduleResult>(
                            context: context,
                            builder: (context) => _ScheduleDialog(
                              initial: item,
                              templateOptions: _templates
                                  .map(
                                    (t) => DropdownMenuItem<String>(
                                      value: t['id']?.toString(),
                                      child: Text(t['name']?.toString() ?? ''),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          );
                          if (result != null) {
                            await _saveSchedule(result.payload, id: id);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _cancelSchedule(id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TemplateResult {
  final Map<String, dynamic> payload;
  const _TemplateResult(this.payload);
}

class _ScheduleResult {
  final Map<String, dynamic> payload;
  const _ScheduleResult(this.payload);
}

class _TemplateDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const _TemplateDialog({this.initial});

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _messageCtrl;
  late final TextEditingController _metadataCtrl;
  int _type = 1;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameCtrl = TextEditingController(text: initial?['name']?.toString() ?? '');
    _titleCtrl = TextEditingController(
      text: initial?['titleTemplate']?.toString() ?? '',
    );
    _messageCtrl = TextEditingController(
      text: initial?['messageTemplate']?.toString() ?? '',
    );
    _metadataCtrl = TextEditingController(
      text: initial?['metadataTemplateJson']?.toString() ?? '',
    );

    _type = _parseInt(initial?['type']) ?? 1;
    _isActive = initial?['isActive'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _metadataCtrl.dispose();
    super.dispose();
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'usermessage':
          return 1;
        case 'violationwarning':
          return 2;
        case 'trackupdate':
          return 3;
        case 'systemannouncement':
          return 4;
      }
      return int.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Create Template' : 'Edit Template'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Template name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('User message')),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Violation warning'),
                    ),
                    DropdownMenuItem(value: 3, child: Text('Track update')),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('System announcement'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title template',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Message template',
                  ),
                  minLines: 2,
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _metadataCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Metadata JSON (optional)',
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.pop(
              context,
              _TemplateResult({
                'name': _nameCtrl.text.trim(),
                'type': _type,
                'titleTemplate': _titleCtrl.text.trim(),
                'messageTemplate': _messageCtrl.text.trim(),
                'metadataTemplateJson': _metadataCtrl.text.trim().isEmpty
                    ? null
                    : _metadataCtrl.text.trim(),
                'isActive': _isActive,
              }),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final List<DropdownMenuItem<String>> templateOptions;

  const _ScheduleDialog({this.initial, required this.templateOptions});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _messageCtrl;
  late final TextEditingController _metadataCtrl;
  late final TextEditingController _userSearchCtrl;
  late final TextEditingController _targetUserCtrl;
  final Dio _dio = sl<ApiClient>().dio;
  Timer? _searchDebounce;
  bool _isSearchingUsers = false;
  List<Map<String, dynamic>> _userSearchResults = const [];
  Map<String, dynamic>? _selectedUser;

  DateTime _scheduledFor = DateTime.now().add(const Duration(hours: 1));
  int _type = 1;
  int _targetScope = 2;
  int _recurrence = 1;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;

    _titleCtrl = TextEditingController(
      text: initial?['title']?.toString() ?? '',
    );
    _messageCtrl = TextEditingController(
      text: initial?['message']?.toString() ?? '',
    );
    _metadataCtrl = TextEditingController(
      text: initial?['metadataJson']?.toString() ?? '',
    );
    _targetUserCtrl = TextEditingController(
      text: initial?['targetUserId']?.toString() ?? '',
    );
    _userSearchCtrl = TextEditingController();

    _type = _parseInt(initial?['type']) ?? 1;
    _targetScope = _parseTargetScope(initial?['targetScope']) ?? 2;
    _recurrence = _parseRecurrence(initial?['recurrence']) ?? 1;
    _templateId = initial?['templateId']?.toString();

    final rawScheduled = initial?['scheduledFor']?.toString();
    if (rawScheduled != null) {
      final parsed = DateTime.tryParse(rawScheduled);
      if (parsed != null) {
        _scheduledFor = parsed.toLocal();
      }
    }

    if (_targetScope == 1 && _targetUserCtrl.text.trim().isNotEmpty) {
      _loadSelectedUserById(_targetUserCtrl.text.trim());
    }
  }

  Future<void> _searchUsers(String keyword) async {
    final q = keyword.trim();
    if (q.length < 2) {
      if (!mounted) {
        return;
      }
      setState(() {
        _userSearchResults = const [];
        _isSearchingUsers = false;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() => _isSearchingUsers = true);

    try {
      final response = await _dio.get(
        ApiUrls.adminUsers,
        queryParameters: {'page': 1, 'pageSize': 10, 'search': q},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final raw = (data['users'] as List?) ?? const [];
      final mapped = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);

      if (!mounted) {
        return;
      }
      setState(() {
        _userSearchResults = mapped;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _userSearchResults = const [];
      });
    } finally {
      if (mounted) {
        setState(() => _isSearchingUsers = false);
      }
    }
  }

  Future<void> _loadSelectedUserById(String userId) async {
    try {
      final response = await _dio.get(ApiUrls.adminUserById(userId));
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedUser = data;
        final username = (data['username'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        _userSearchCtrl.text = username.isNotEmpty
            ? '$username ($email)'
            : email;
      });
    } catch (_) {
      // Keep existing target id even if details cannot be loaded.
    }
  }

  void _onUserKeywordChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      _searchUsers(value);
    });
  }

  void _selectUser(Map<String, dynamic> user) {
    final id = (user['id'] ?? '').toString();
    if (id.isEmpty) {
      return;
    }

    final username = (user['username'] ?? '').toString();
    final email = (user['email'] ?? '').toString();

    setState(() {
      _selectedUser = user;
      _targetUserCtrl.text = id;
      _userSearchCtrl.text = username.isNotEmpty ? '$username ($email)' : email;
      _userSearchResults = const [];
    });
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'usermessage':
          return 1;
        case 'violationwarning':
          return 2;
        case 'trackupdate':
          return 3;
        case 'systemannouncement':
          return 4;
      }
      return int.tryParse(value);
    }
    return null;
  }

  int? _parseTargetScope(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'user':
          return 1;
        case 'allusers':
          return 2;
      }
      return int.tryParse(value);
    }
    return null;
  }

  int? _parseRecurrence(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'onetime':
          return 1;
        case 'daily':
          return 2;
        case 'monthly':
          return 3;
      }
      return int.tryParse(value);
    }
    return null;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _metadataCtrl.dispose();
    _userSearchCtrl.dispose();
    _targetUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Create Schedule' : 'Edit Schedule'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: _templateId,
                  decoration: const InputDecoration(
                    labelText: 'Template (optional)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No template'),
                    ),
                    ...widget.templateOptions,
                  ],
                  onChanged: (value) => setState(() => _templateId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('User message')),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Violation warning'),
                    ),
                    DropdownMenuItem(value: 3, child: Text('Track update')),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('System announcement'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _targetScope,
                  decoration: const InputDecoration(labelText: 'Target scope'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Single user')),
                    DropdownMenuItem(value: 2, child: Text('All users')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetScope = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _recurrence,
                  decoration: const InputDecoration(
                    labelText: 'Schedule recurrence',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('One-time')),
                    DropdownMenuItem(value: 2, child: Text('Daily')),
                    DropdownMenuItem(value: 3, child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _recurrence = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_targetScope == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _userSearchCtrl,
                        decoration: InputDecoration(
                          labelText: 'Find user (name/email)',
                          hintText: 'Type at least 2 characters',
                          suffixIcon: _isSearchingUsers
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.search),
                        ),
                        onChanged: _onUserKeywordChanged,
                      ),
                      const SizedBox(height: 8),
                      if (_userSearchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _userSearchResults.length,
                            separatorBuilder: (_, index) =>
                                const Divider(height: 1, color: Colors.white12),
                            itemBuilder: (context, index) {
                              final user = _userSearchResults[index];
                              final username = (user['username'] ?? '')
                                  .toString();
                              final email = (user['email'] ?? '').toString();
                              final displayName = (user['displayName'] ?? '')
                                  .toString();
                              return ListTile(
                                dense: true,
                                title: Text(
                                  displayName.isNotEmpty
                                      ? '$displayName (@$username)'
                                      : '@$username',
                                ),
                                subtitle: Text(email),
                                onTap: () => _selectUser(user),
                              );
                            },
                          ),
                        ),
                      if (_selectedUser != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.greenAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selected: ${(_selectedUser!['username'] ?? '').toString()} • ${(_selectedUser!['email'] ?? '').toString()}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetUserCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Target user id',
                        ),
                        validator: (value) {
                          if (_targetScope == 1 &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please select a user';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                if (_targetScope == 1) const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(labelText: 'Message'),
                  minLines: 2,
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _metadataCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Metadata JSON (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled for'),
                  subtitle: Text(_scheduledFor.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledFor,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date == null || !context.mounted) {
                      return;
                    }

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_scheduledFor),
                    );
                    if (time == null || !context.mounted) {
                      return;
                    }

                    setState(() {
                      _scheduledFor = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              _ScheduleResult({
                'templateId': _templateId,
                'targetUserId': _targetScope == 1
                    ? _targetUserCtrl.text.trim()
                    : null,
                'type': _type,
                'targetScope': _targetScope,
                'recurrence': _recurrence,
                'title': _titleCtrl.text.trim(),
                'message': _messageCtrl.text.trim(),
                'metadataJson': _metadataCtrl.text.trim().isEmpty
                    ? null
                    : _metadataCtrl.text.trim(),
                'scheduledFor': _scheduledFor.toUtc().toIso8601String(),
              }),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
