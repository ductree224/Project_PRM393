import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/usecases/user_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _avatarUrl;
  final _displayNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _selectedGender;
  final _pronounsCtrl = TextEditingController();
  String? _selectedStatus;
  DateTime? _birthday;
  bool _isProfilePublic = true;
  bool _allowComments = true;
  bool _allowMessages = true;
  bool _showStatus = true;
  String _followerPrivacyMode = 'public';
  bool _loading = false;
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _pronounsCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill form with current profile from AuthBloc if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthBloc>().state;
      if (state is AuthAuthenticated) {
        final user = state.user;
        _avatarUrl = user.avatarUrl;
        _displayNameCtrl.text = user.displayName ?? '';
        _bioCtrl.text = user.bio ?? '';

        if (['nam', 'nữ', 'khác'].contains(user.gender)) {
          _selectedGender = user.gender;
        }

        _pronounsCtrl.text = user.pronouns ?? '';

        if (['online', 'offline', 'busy'].contains(user.statusMessage)) {
          _selectedStatus = user.statusMessage;
        }

        _birthday = user.birthday;

        final serverMode = user.followerPrivacyMode ?? 'everyone';
        _followerPrivacyMode = serverMode == 'everyone' ? 'public' : serverMode;

        _isProfilePublic = user.isProfilePublic ?? _isProfilePublic;
        _allowComments = user.allowComments ?? _allowComments;
        _allowMessages = user.allowMessages ?? _allowMessages;
        // Assuming _showStatus can be mapped from profile public or another field if available
        // For now, default to true or add to user entity if needed
        setState(() {});
      }
    });
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final useCase = sl<UpdateProfileUseCase>();

    String? followerModeToSend;
    if (_followerPrivacyMode == 'public')
      followerModeToSend = 'everyone';
    else
      followerModeToSend = _followerPrivacyMode;

    final result = await useCase.call(
      avatarUrl: _avatarUrl,
      displayName: _displayNameCtrl.text.isEmpty
          ? null
          : _displayNameCtrl.text.trim(),
      bio: _bioCtrl.text.isEmpty ? null : _bioCtrl.text.trim(),
      birthday: _birthday,
      gender: _selectedGender,
      pronouns: _pronounsCtrl.text.isEmpty ? null : _pronounsCtrl.text.trim(),
      isProfilePublic: _isProfilePublic,
      statusMessage: _showStatus ? _selectedStatus : 'offline', // Example logic
      allowComments: _allowComments,
      allowMessages: _allowMessages,
      followerPrivacyMode: followerModeToSend,
    );
    setState(() => _loading = false);
    result.fold(
      (err) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      },
      (user) {
        context.read<AuthBloc>().add(AuthProfileRefreshRequested());
        Navigator.pop(context);
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() => _uploading = true);
      final useCase = sl<UploadAvatarUseCase>();

      Object fileArg;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        fileArg = bytes;
      } else {
        fileArg = picked.path;
      }

      final res = await useCase.call(fileArg);
      if (!mounted) return;
      setState(() => _uploading = false);
      res.fold(
        (err) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err))),
        (url) {
          setState(() => _avatarUrl = url);
        },
      );
    } catch (e) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_uploading)
                      const Positioned.fill(child: CircularProgressIndicator()),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploading ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.camera_alt, size: 20),
                              Text('Edit', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _displayNameCtrl,
                decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                maxLength: 60,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(labelText: 'Tiểu sử'),
                maxLines: 3,
                maxLength: 250,
              ),
              const SizedBox(height: 8),

              // Custom Birthday Field
              InkWell(
                onTap: _pickBirthday,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    _birthday != null
                        ? DateFormat('dd/MM/yyyy').format(_birthday!)
                        : 'Chọn ngày sinh',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gender and Status on a single row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'nữ', child: Text('Nữ')),
                        DropdownMenuItem(value: 'khác', child: Text('Khác')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v),
                      decoration: const InputDecoration(labelText: 'Giới tính'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'online',
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: 'offline',
                          child: Text('Offline'),
                        ),
                        DropdownMenuItem(value: 'busy', child: Text('Bận')),
                      ],
                      onChanged: (v) => setState(() => _selectedStatus = v),
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Hiển thị trạng thái'),
                value: _showStatus,
                onChanged: (v) => setState(() => _showStatus = v),
              ),

              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Hiển thị hồ sơ công khai'),
                value: _isProfilePublic,
                onChanged: (v) => setState(() => _isProfilePublic = v),
              ),
              SwitchListTile(
                title: const Text('Cho phép bình luận'),
                value: _allowComments,
                onChanged: (v) => setState(() => _allowComments = v),
              ),
              SwitchListTile(
                title: const Text('Cho phép tin nhắn'),
                value: _allowMessages,
                onChanged: (v) => setState(() => _allowMessages = v),
              ),
              DropdownButtonFormField<String>(
                value: _followerPrivacyMode,
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Công khai')),
                  DropdownMenuItem(
                    value: 'followers_only',
                    child: Text('Chỉ người theo dõi'),
                  ),
                  DropdownMenuItem(value: 'private', child: Text('Riêng tư')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _followerPrivacyMode = v);
                },
                decoration: const InputDecoration(
                  labelText: 'Quyền xem người theo dõi',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
