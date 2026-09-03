import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../components/breed_thumbnail.dart';
import '../components/skeleton_box.dart';
import '../components/state_message_component.dart';
import '../controller/breed_controller.dart';
import '../utils/breed_name_utils.dart';
import '../utils/style.dart';
import 'breed_detail_screen.dart';

class BreedsScreen extends StatefulWidget {
  const BreedsScreen({super.key});

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  // BreedsScreen is reachable both as the persistent bottom-nav tab (kept
  // alive forever inside AppShell's IndexedStack) and as a screen pushed on
  // top of it (Home's "See all" / search icon). A fixed tag would make a
  // freshly pushed copy's initState synchronously trigger a rebuild of the
  // tab copy's already-mounted GetBuilder mid-build, which Flutter forbids.
  // A unique tag per instance keeps every copy's controller independent.
  late final String _tag = 'breeds-${DateTime.now().microsecondsSinceEpoch}';
  late final BreedController _breedController = Get.put(BreedController(), tag: _tag);
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _breedController.callGetBreedList();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<BreedController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 18),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (Navigator.of(context).canPop())
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back, color: kTextColor),
            ),
          ),
        const Text(
          'Explore Breeds',
          style: TextStyle(fontSize: 24, fontWeight: boldFontWeight, color: kTextColor),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorderColor),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 15, color: kTextColor),
        decoration: const InputDecoration(
          hintText: 'Search breeds...',
          hintStyle: TextStyle(color: kSubTitleTextColor, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: kSubTitleTextColor, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return GetBuilder<BreedController>(
      tag: _tag,
      init: _breedController,
      builder: (controller) {
        if (controller.isLoading) {
          return _buildSkeletonGrid();
        }

        if (controller.hasError) {
          return StateMessageComponent(
            title: 'Something went wrong',
            subtitle: "We couldn't load the dogs.",
            actionLabel: 'Try Again',
            onAction: controller.callGetBreedList,
          );
        }

        final breeds = _query.isEmpty
            ? controller.breedList
            : controller.breedList
                .where((b) => b.toLowerCase().contains(_query))
                .toList();

        if (breeds.isEmpty) {
          return const StateMessageComponent(
            title: 'No breeds found',
            subtitle: 'Try searching for another breed.',
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.only(bottom: 24),
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 14,
          itemCount: breeds.length,
          itemBuilder: (context, index) {
            final breed = breeds[index];
            return GestureDetector(
              onTap: () => Get.to(() => const BreedDetailScreen(), arguments: breed),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    BreedThumbnail(breed: breed, natural: true, borderRadius: 0),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 26, 12, 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xB3000000), Color(0x00000000)],
                          ),
                        ),
                        child: Text(
                          formatBreedName(breed),
                          style: const TextStyle(fontSize: 14, fontWeight: titleFontWeight, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    const ratios = [0.8, 1.15, 1.3, 0.85, 1.0, 1.2];
    return MasonryGridView.count(
      padding: const EdgeInsets.only(bottom: 24),
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 14,
      itemCount: ratios.length,
      itemBuilder: (context, index) => AspectRatio(
        aspectRatio: ratios[index],
        child: const SkeletonBox(),
      ),
    );
  }
}
