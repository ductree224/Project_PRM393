import 'package:flutter/material.dart';
import '../../../../data/models/album_model.dart';
import '../../../../data/models/artist_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/album_admin_bloc.dart';
import '../bloc/album_admin_event.dart';

class AlbumFormDialog extends StatefulWidget {
  final AlbumModel? album;
  final List<ArtistModel> availableArtists;

  const AlbumFormDialog({
    super.key,
    this.album,
    required this.availableArtists,
  });

  @override
  State<AlbumFormDialog> createState() => _AlbumFormDialogState();
}

class _AlbumFormDialogState extends State<AlbumFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverImageUrlController;
  late TextEditingController _tagsController;
  String? _selectedArtistId;
  DateTime? _releaseDate;
  bool _isOverride = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.album?.title ?? '');
    _descriptionController = TextEditingController(text: widget.album?.description ?? '');
    _coverImageUrlController = TextEditingController(text: widget.album?.coverImageUrl ?? '');
    _tagsController = TextEditingController(text: widget.album?.tags.join(', ') ?? '');
    _selectedArtistId = widget.album?.artistId;
    _releaseDate = widget.album?.releaseDate;
    _isOverride = widget.album?.isOverride ?? false;

    // Validate selectedArtistId against available list
    if (_selectedArtistId != null && !widget.availableArtists.any((a) => a.id == _selectedArtistId)) {
        _selectedArtistId = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverImageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _releaseDate) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'coverImageUrl': _coverImageUrlController.text.trim(),
        'artistId': _selectedArtistId,
        'releaseDate': _releaseDate?.toIso8601String(),
        'tags': tags,
        'isOverride': _isOverride,
      };

      if (widget.album == null) {
        context.read<AlbumAdminBloc>().add(CreateAlbum(data));
      } else {
        context.read<AlbumAdminBloc>().add(UpdateAlbum(widget.album!.id, data));
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
                  widget.album == null ? 'New Album' : 'Edit Album',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),
                _buildTextField(_titleController, "Title", "Enter album title", true),
                const SizedBox(height: 16),
                
                // Artist Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedArtistId,
                  decoration: InputDecoration(
                    labelText: "Artist",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("No Artist")),
                    ...widget.availableArtists.map((artist) => DropdownMenuItem(
                          value: artist.id,
                          child: Text(artist.name),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedArtistId = val;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, "Description", "Enter description", false, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField(_coverImageUrlController, "Cover Image URL", "Enter image URL", false),
                const SizedBox(height: 16),
                _buildTextField(_tagsController, "Tags", "Comma separated (e.g. New Release, V-Pop)", false),
                const SizedBox(height: 16),
                
                // Release Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Release Date",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _releaseDate == null ? "Select Date" : "${_releaseDate!.year}-${_releaseDate!.month.toString().padLeft(2, '0')}-${_releaseDate!.day.toString().padLeft(2, '0')}",
                          style: TextStyle(color: _releaseDate == null ? Colors.white24 : Colors.white),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
                
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
                      activeColor: const Color(0xFFFFD79B),
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
                        backgroundColor: const Color(0xFFFFD79B),
                        foregroundColor: Colors.black,
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
