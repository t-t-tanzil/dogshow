import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/breed_thumbnail.dart';
import '../components/skeleton_box.dart';
import '../controller/breed_controller.dart';
import '../repositories/breed_repository.dart';
import '../utils/breed_name_utils.dart';
import '../utils/dog_of_the_day_store.dart';
import '../utils/endpoints.dart';
import '../utils/style.dart';
import 'breeds_screen.dart';
import 'surprise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _breedController = Get.put(BreedController(), tag: 'home');
  final _repository = BreedRepository();

  String? _dogOfTheDayUrl;
  bool _dogOfTheDayFailed = false;

  @override
  void initState() {
    super.initState();
    _breedController.callGetBreedList();
    _loadDogOfTheDay();
  }

  Future<void> _loadDogOfTheDay() async {
    final cached = await DogOfTheDayStore.getTodaysImage();
    if (cached != null) {
      setState(() => _dogOfTheDayUrl = cached);
      return;
    }

    setState(() {
      _dogOfTheDayUrl = null;
      _dogOfTheDayFailed = false;
    });

    _repository.getRandomByBreed(randomImageEndpoint, (response, error) async {
      if (!mounted) return;

      if (response?.message != null) {
        await DogOfTheDayStore.saveTodaysImage(response!.message!);
        setState(() => _dogOfTheDayUrl = response.message);
      } else {
        setState(() => _dogOfTheDayFailed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              const Text(
                'Discover your\nfavorite breeds',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: titleFontWeight,
                  color: kTextColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 26),
              _buildSectionLabel('DOG OF THE DAY'),
              const SizedBox(height: 10),
              _buildDogOfTheDay(),
              const SizedBox(height: 28),
              _buildExploreBreedsHeader(),
              const SizedBox(height: 12),
              _buildExploreBreedsRow(),
              const SizedBox(height: 30),
              _buildSurpriseMeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.pets, size: 22, color: kPrimaryColor),
            SizedBox(width: 8),
            Text(
              'Dog Show',
              style: TextStyle(
                fontSize: 20,
                fontWeight: boldFontWeight,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.to(() => const BreedsScreen()),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kWhiteColor,
              shape: BoxShape.circle,
              border: Border.all(color: kCardBorderColor),
            ),
            child: const Icon(Icons.search, size: 18, color: kTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: titleFontWeight,
        color: kSubTitleTextColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDogOfTheDay() {
    final breedName = breedNameFromImageUrl(_dogOfTheDayUrl);

    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: _dogOfTheDayFailed
                ? _retryTile(_loadDogOfTheDay)
                : _dogOfTheDayUrl == null
                    ? const SkeletonBox(borderRadius: 0)
                    : CachedNetworkImage(
                        imageUrl: _dogOfTheDayUrl!,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 250),
                        placeholder: (context, url) =>
                            const SkeletonBox(borderRadius: 0),
                        errorWidget: (context, url, error) =>
                            _retryTile(_loadDogOfTheDay),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Text(
              breedName ?? (_dogOfTheDayFailed ? 'Unavailable' : 'Loading...'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: titleFontWeight,
                color: kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _retryTile(VoidCallback onRetry) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        color: kSurfaceAltColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets, color: kSubTitleTextColor, size: 28),
            SizedBox(height: 8),
            Text('Tap to retry', style: TextStyle(color: kSubTitleTextColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreBreedsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Explore Breeds',
          style: TextStyle(fontSize: 17, fontWeight: titleFontWeight, color: kTextColor),
        ),
        GestureDetector(
          onTap: () => Get.to(() => const BreedsScreen()),
          child: const Row(
            children: [
              Text('See all', style: TextStyle(fontSize: 13, fontWeight: titleFontWeight, color: gradientColor1)),
              Icon(Icons.chevron_right, size: 18, color: gradientColor1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExploreBreedsRow() {
    return SizedBox(
      height: 172,
      child: GetBuilder<BreedController>(
        tag: 'home',
        init: _breedController,
        builder: (controller) {
          if (controller.isLoading || !controller.isLoaded) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const SizedBox(
                width: 132,
                child: SkeletonBox(),
              ),
            );
          }

          final preview = controller.breedList.take(6).toList();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final breed = preview[index];
              return SizedBox(
                width: 132,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 132,
                      height: 132,
                      child: BreedThumbnail(breed: breed),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatBreedName(breed),
                      style: const TextStyle(fontSize: 13, fontWeight: titleFontWeight, color: kTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSurpriseMeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.to(() => const SurpriseScreen()),
        icon: const Icon(Icons.casino_outlined, size: 20),
        label: const Text('Surprise Me'),
        style: ElevatedButton.styleFrom(
          backgroundColor: gradientColor1,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: boldFontWeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
        ),
      ),
    );
  }
}
