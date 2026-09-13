import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/components/default_profile_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class CachedProfileImage extends StatefulWidget {
  final String? photoUrl;
  final String displayName;
  final double size;
  final bool isCircular;
  final BoxFit fit;
  final Duration fadeInDuration;
  final bool showLoadingIndicator;
  final Color? defaultAvatarBackgroundColor;
  final Color? defaultAvatarTextColor;

  const CachedProfileImage({
    Key? key,
    this.photoUrl,
    required this.displayName,
    required this.size,
    this.isCircular = true,
    this.fit = BoxFit.cover,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.showLoadingIndicator = true,
    this.defaultAvatarBackgroundColor,
    this.defaultAvatarTextColor,
  }) : super(key: key);

  @override
  State<CachedProfileImage> createState() => _CachedProfileImageState();
}

class _CachedProfileImageState extends State<CachedProfileImage> {
  String? _cachedUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.photoUrl == null || widget.photoUrl!.isEmpty) {
      setState(() {
        _isLoading = false;
        _cachedUrl = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? url = widget.photoUrl;
      if (url!.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        url = await ref.getDownloadURL();
      }

      if (mounted) {
        setState(() {
          _cachedUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _cachedUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.showLoadingIndicator) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(),
      );
    }

    if (_cachedUrl == null) {
      return DefaultProfileAvatar(
        displayName: widget.displayName,
        size: widget.size,
        backgroundColor: widget.defaultAvatarBackgroundColor,
        textColor: widget.defaultAvatarTextColor,
      );
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: _cachedUrl!,
      fit: widget.fit,
      width: widget.size,
      height: widget.size,
      fadeInDuration: widget.fadeInDuration,
      placeholder: (context, url) => widget.showLoadingIndicator
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
      errorWidget: (context, url, error) => DefaultProfileAvatar(
        displayName: widget.displayName,
        size: widget.size,
        backgroundColor: widget.defaultAvatarBackgroundColor,
        textColor: widget.defaultAvatarTextColor,
      ),
    );

    return widget.isCircular
        ? ClipOval(child: imageWidget)
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          );
  }
}
