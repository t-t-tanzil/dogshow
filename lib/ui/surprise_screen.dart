import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../components/skeleton_box.dart';
import '../components/state_message_component.dart';
import '../repositories/breed_repository.dart';
import '../utils/breed_name_utils.dart';
import '../utils/endpoints.dart';
import '../utils/style.dart';

class SurpriseScreen extends StatefulWidget {
  const SurpriseScreen({super.key});

  @override
  State<SurpriseScreen> createState() => _SurpriseScreenState();
}

class _SurpriseScreenState extends State<SurpriseScreen> {
  final _repository = BreedRepository();
  String? _imageUrl;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    setState(() {
      _loading = true;
      _failed = false;
    });

    _repository.getRandomByBreed(randomImageEndpoint, (response, error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (response?.message != null) {
          _imageUrl = response!.message;
        } else {
          _failed = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: kTextColor),
                  ),
                  const Text(
                    'Surprise Me',
                    style: TextStyle(fontSize: 18, fontWeight: titleFontWeight, color: kTextColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return StateMessageComponent(
        title: 'Something went wrong',
        subtitle: "We couldn't load the dogs.",
        actionLabel: 'Try Again',
        onAction: _fetch,
      );
    }

    final breedName = breedNameFromImageUrl(_imageUrl);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: kPrimaryColor.withOpacity(0.10), blurRadius: 26, offset: const Offset(0, 12)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 1,
            child: _loading || _imageUrl == null
                ? const SkeletonBox(borderRadius: 0)
                : CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (c, u) => const SkeletonBox(borderRadius: 0),
                    errorWidget: (c, u, e) => Container(
                      color: kSurfaceAltColor,
                      alignment: Alignment.center,
                      child: const Icon(Icons.pets, color: kSubTitleTextColor, size: 40),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          breedName ?? (_loading ? 'Loading...' : ''),
          style: const TextStyle(fontSize: 19, fontWeight: titleFontWeight, color: kTextColor),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.casino_outlined, size: 20),
            label: const Text('Another One'),
            style: ElevatedButton.styleFrom(
              backgroundColor: gradientColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: boldFontWeight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: _imageUrl == null ? null : () => Share.share(_imageUrl!),
          icon: const Icon(Icons.ios_share, size: 18, color: kSubTitleTextColor),
          label: const Text('Share', style: TextStyle(color: kSubTitleTextColor, fontWeight: titleFontWeight)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
