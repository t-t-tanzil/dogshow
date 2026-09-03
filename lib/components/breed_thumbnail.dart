import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../repositories/breed_repository.dart';
import '../utils/style.dart';
import 'skeleton_box.dart';

/// A breed card image that fetches its own random photo lazily, the
/// moment it is actually built. Since it's only ever used inside a
/// builder-based list/grid, Flutter itself only builds cards near the
/// viewport — so scrolling naturally staggers the requests instead of
/// firing them all at once for the whole breed list.
///
/// By default it fills whatever fixed-size box it's given (cropping to
/// fit). With [natural] set, it instead sizes itself to the photo's own
/// aspect ratio once known — for use in a masonry/staggered grid, so
/// portrait and landscape photos aren't all force-cropped into identical
/// squares.
class BreedThumbnail extends StatefulWidget {
  final String breed;
  final double borderRadius;
  final bool natural;

  const BreedThumbnail({
    super.key,
    required this.breed,
    this.borderRadius = 16,
    this.natural = false,
  });

  @override
  State<BreedThumbnail> createState() => _BreedThumbnailState();
}

class _BreedThumbnailState extends State<BreedThumbnail> {
  final _repository = BreedRepository();
  String? _imageUrl;
  bool _failed = false;
  double? _aspectRatio;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _repository.getRandomByBreed('/breed/${widget.breed}/images/random',
        (response, error) {
      if (!mounted) return;
      setState(() {
        if (response?.message != null) {
          _imageUrl = response!.message;
          if (widget.natural) _resolveAspectRatio(_imageUrl!);
        } else {
          _failed = true;
        }
      });
    });
  }

  void _resolveAspectRatio(String url) {
    final stream = CachedNetworkImageProvider(url).resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        final width = info.image.width;
        final height = info.image.height;
        if (height > 0) {
          setState(() => _aspectRatio = width / height);
        }
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() => _failed = true);
      },
    );
    _imageStream = stream;
    _imageStreamListener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    if (_failed) {
      final placeholder = _placeholder(radius);
      return widget.natural ? AspectRatio(aspectRatio: 1, child: placeholder) : placeholder;
    }

    final stillResolving = _imageUrl == null || (widget.natural && _aspectRatio == null);
    if (stillResolving) {
      final skeleton = SkeletonBox(borderRadius: widget.borderRadius);
      return widget.natural ? AspectRatio(aspectRatio: 1, child: skeleton) : skeleton;
    }

    final image = ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (context, url) =>
            SkeletonBox(borderRadius: widget.borderRadius),
        errorWidget: (context, url, error) => _placeholder(radius),
      ),
    );

    return widget.natural ? AspectRatio(aspectRatio: _aspectRatio!, child: image) : image;
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceAltColor,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.pets, color: kSubTitleTextColor.withOpacity(0.4), size: 28),
    );
  }
}
