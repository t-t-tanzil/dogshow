import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../components/skeleton_box.dart';
import '../components/state_message_component.dart';
import '../controller/sub_breed_controller.dart';

class GalleryArgs {
  final List<String>? images;
  final String? breed;
  final String? subBreed;
  final String title;
  final int initialIndex;

  const GalleryArgs({
    this.images,
    this.breed,
    this.subBreed,
    required this.title,
    this.initialIndex = 0,
  });
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final GalleryArgs _args = Get.arguments as GalleryArgs;
  late final String _tag = 'gallery-${DateTime.now().microsecondsSinceEpoch}';
  SubBreedController? _subBreedController;
  late final PageController _pageController =
      PageController(initialPage: _args.initialIndex);
  int _index = 0;

  bool get _needsFetch => _args.images == null && _args.breed != null && _args.subBreed != null;

  @override
  void initState() {
    super.initState();
    _index = _args.initialIndex;

    if (_needsFetch) {
      _subBreedController = Get.put(SubBreedController(), tag: _tag);
      _subBreedController!.callGetImageListBySubBreed(_args.breed!, _args.subBreed!);
    }
  }

  @override
  void dispose() {
    if (_needsFetch) {
      Get.delete<SubBreedController>(tag: _tag);
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161009),
      body: _args.images != null
          ? _buildViewer(_args.images!)
          : _buildFetchedViewer(),
    );
  }

  Widget _buildFetchedViewer() {
    return GetBuilder<SubBreedController>(
      tag: _tag,
      init: _subBreedController,
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.white54));
        }

        if (controller.hasError || controller.breedImageList.isEmpty) {
          return Stack(
            children: [
              StateMessageComponent(
                title: controller.hasError ? 'Something went wrong' : 'No photos yet',
                subtitle: controller.hasError ? "We couldn't load the dogs." : null,
                actionLabel: controller.hasError ? 'Try Again' : null,
                onAction: controller.hasError
                    ? () => controller.callGetImageListBySubBreed(_args.breed!, _args.subBreed!)
                    : null,
              ),
              _backButton(),
            ],
          );
        }

        return _buildViewer(controller.breedImageList);
      },
    );
  }

  Widget _buildViewer(List<String> images) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.contain,
                placeholder: (c, u) => const SkeletonBox(borderRadius: 0),
                errorWidget: (c, u, e) => const Icon(Icons.pets, color: Colors.white38, size: 48),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 16, 18, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x8C000000), Color(0x00000000)],
              ),
            ),
            child: Row(
              children: [
                _iconButton(Icons.arrow_back, () => Get.back()),
                const Spacer(),
                if (images.length > 1)
                  Text(
                    '${_index + 1} / ${images.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x9E000000), Color(0x00000000)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _args.title,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
                ),
                _shareButton(() => Share.share(images[_index])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 18,
      child: _iconButton(Icons.arrow_back, () => Get.back()),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _shareButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share, size: 16, color: Colors.white),
            SizedBox(width: 7),
            Text('Share', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
