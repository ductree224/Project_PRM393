import 'package:flutter/material.dart';
import '../../../../data/models/artist_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/artist_admin_bloc.dart';
import '../bloc/artist_admin_event.dart';

class ArtistFormDialog extends StatefulWidget {
  final ArtistModel? artist;

  const ArtistFormDialog({super.key, this.artist});

  @override
  State<ArtistFormDialog> createState() => _ArtistFormDialogState();
}

class _ArtistFormDialogState extends State<ArtistFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _imageUrlController;
  late TextEditingController _tagsController;
  bool _isOverride = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.artist?.name ?? '');
    _bioController = TextEditingController(text: widget.artist?.bio ?? '');
    _imageUrlController = TextEditingController(text: widget.artist?.imageUrl ?? '');
    _tagsController = TextEditingController(text: widget.artist?.tags.join(', ') ?? '');
    _isOverride = widget.artist?.isOverride ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'tags': tags,
        'isOverride': _isOverride,
      };

      if (widget.artist == null) {
        context.read<ArtistAdminBloc>().add(CreateArtist(data));
      } else {
        context.read<ArtistAdminBloc>().add(UpdateArtist(widget.artist!.id, data));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artist == null ? 'New Artist' : 'Edit Artist',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),
                _buildTextField(_nameController, "Name", "Enter artist name", true),
                const SizedBox(height: 16),
                _buildTextField(_bioController, "Bio", "Enter artist bio", false, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField(_imageUrlController, "Image URL", "Enter image URL", false),
                const SizedBox(height: 16),
                _buildTextField(_tagsController, "Tags", "Comma separated tags (e.g. Trending, Vietnamese Hot)", false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Is Override', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isOverride,
                      onChanged: (val) {
                        setState(() {
                          _isOverride = val;
                        });
                      },
                      activeColor: const Color(0xFF61440C),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61440C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _submit,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, bool isRequired, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
