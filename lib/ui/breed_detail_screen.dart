import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/skeleton_box.dart';
import '../controller/breed_controller.dart';
import '../utils/breed_name_utils.dart';
import '../utils/style.dart';
import 'gallery_screen.dart';

class BreedDetailScreen extends StatefulWidget {
  const BreedDetailScreen({super.key});

  @override
  State<BreedDetailScreen> createState() => _BreedDetailScreenState();
}

class _BreedDetailScreenState extends State<BreedDetailScreen> {
  late final String breed = Get.arguments as String;
  late final String _tag = 'detail-$breed-${DateTime.now().microsecondsSinceEpoch}';
  late final BreedController _controller = Get.put(BreedController(), tag: _tag);

  @override
  void initState() {
    super.initState();
    _controller.callGetRandomImageByBreed(breed);
    _controller.callGetImageListByBreed(breed);
    _controller.callGetSubBreedList(breed);
  }

  @override
  void dispose() {
    Get.delete<BreedController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breedName = formatBreedName(breed);

    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breedName,
                    style: const TextStyle(fontSize: 24, fontWeight: boldFontWeight, color: kTextColor),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Breed Gallery',
                    style: TextStyle(fontSize: 17, fontWeight: titleFontWeight, color: kTextColor),
                  ),
                  const SizedBox(height: 12),
                  _buildGalleryPreview(breedName),
                  const SizedBox(height: 28),
                  Container(height: 1, color: kDividerColor),
                  const SizedBox(height: 24),
                  const Text(
                    'Sub-breeds',
                    style: TextStyle(fontSize: 17, fontWeight: titleFontWeight, color: kTextColor),
                  ),
                  const SizedBox(height: 12),
                  _buildSubBreeds(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 5 / 4,
          child: GetBuilder<BreedController>(
            tag: _tag,
            init: _controller,
            builder: (controller) {
              final url = controller.image.value;
              if (controller.hasError || (controller.isLoaded && url == null)) {
                return Container(
                  color: kSurfaceAltColor,
                  alignment: Alignment.center,
                  child: const Icon(Icons.pets, color: kSubTitleTextColor, size: 40),
                );
              }
              if (url == null) return const SkeletonBox(borderRadius: 0);
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 250),
                placeholder: (context, u) => const SkeletonBox(borderRadius: 0),
                errorWidget: (context, u, e) => Container(
                  color: kSurfaceAltColor,
                  alignment: Alignment.center,
                  child: const Icon(Icons.pets, color: kSubTitleTextColor, size: 40),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Get.back(),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kWhiteColor.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: kTextColor),
      ),
    );
  }

  Widget _buildGalleryPreview(String breedName) {
    return GetBuilder<BreedController>(
      tag: _tag,
      init: _controller,
      builder: (controller) {
        if (controller.isLoading && controller.breedImageList.isEmpty) {
          return Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
                  child: const AspectRatio(aspectRatio: 1, child: SkeletonBox(borderRadius: 14)),
                ),
              ),
            ),
          );
        }

        final images = controller.breedImageList;
        if (images.isEmpty) {
          return const Text(
            'No photos yet.',
            style: TextStyle(color: kSubTitleTextColor, fontSize: 14),
          );
        }

        final preview = images.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(preview.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == preview.length - 1 ? 0 : 10),
                    child: GestureDetector(
                      onTap: () => Get.to(
                        () => const GalleryScreen(),
                        arguments: GalleryArgs(images: images, title: breedName, initialIndex: i),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: preview[i],
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const SkeletonBox(borderRadius: 14),
                            errorWidget: (c, u, e) => Container(color: kSurfaceAltColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Get.to(
                () => const GalleryScreen(),
                arguments: GalleryArgs(images: images, title: breedName, initialIndex: 0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('View all photos', style: TextStyle(fontSize: 13, fontWeight: titleFontWeight, color: gradientColor1)),
                  Icon(Icons.chevron_right, size: 18, color: gradientColor1),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubBreeds() {
    return GetBuilder<BreedController>(
      tag: _tag,
      init: _controller,
      builder: (controller) {
        if (controller.isLoading && controller.subBreedNameList.isEmpty) {
          return const SkeletonBox(height: 90, borderRadius: 16);
        }

        if (controller.subBreedNameList.isEmpty) {
          return const Text(
            'None',
            style: TextStyle(color: kSubTitleTextColor, fontSize: 14),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorderColor),
          ),
          child: Column(
            children: List.generate(controller.subBreedNameList.length, (i) {
              final subBreed = controller.subBreedNameList[i];
              final isLast = i == controller.subBreedNameList.length - 1;

              return GestureDetector(
                onTap: () => Get.to(
                  () => const GalleryScreen(),
                  arguments: GalleryArgs(
                    breed: breed,
                    subBreed: subBreed,
                    title: '${formatBreedName(subBreed)} ${formatBreedName(breed)}',
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(bottom: BorderSide(color: kDividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatBreedName(subBreed), style: const TextStyle(fontSize: 15, color: kTextColor)),
                      const Icon(Icons.chevron_right, size: 18, color: kSubTitleTextColor),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
