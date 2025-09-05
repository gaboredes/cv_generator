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

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    setState(() {
      _isLoading = true;
    });
    final File? image = await _fileService.getProfileImage();
    setState(() {
      _profileImage = image;
      _isLoading = false;
    });
  }

  void _onTapProfileImage() async {
    final message = await _fileService.setProfilePicture();
    _loadProfileImage();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message!)));
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
      child: _profileImage != null && _profileImage!.existsSync()
          ? Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: FileImage(_profileImage!, scale: 1),
                ),
              ),
            )
          : const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }
}
