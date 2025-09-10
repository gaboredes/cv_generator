import 'package:cv_generator/services/file_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final FileService _fileService = FileService();
  File? _profileImage;
  bool _isLoading = true;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoading = true;
    });
    final File? image = await _fileService.getProfileImage();
    if (!mounted) return;
    setState(() {
      _profileImage = image;
      _imageProvider = image != null ? FileImage(image) : null;
      _isLoading = false;
    });
  }

  void _onTapProfileImage() async {
    final message = await _fileService.setProfilePicture();
    if (message != null &&
        message.contains('A fájl sikeresen elmentve a következő helyre:') ==
            true) {
      _imageProvider?.evict();
      await _loadProfileImage();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: Text(message!),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 100,
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: _onTapProfileImage,
      child:
          _profileImage != null &&
              _profileImage!.existsSync() &&
              _imageProvider != null
          ? Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: _imageProvider!,
                ),
              ),
            )
          : const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }
}
