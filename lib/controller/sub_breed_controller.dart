import 'package:dog_show/model/breed_model.dart';
import 'package:dog_show/utils/environment.dart';
import 'package:get/get.dart';
import '../model/dog_class.dart';
import '../repositories/breed_repository.dart';
import '../repositories/sub_breed_repository.dart';
import '../utils/constants.dart';


class SubBreedController extends GetxController {
  late final SubBreedRepository _subBreedRepository;

  List<String> breedList = [];
  List<String> breedImageList = [];

  var image = Rxn<String?>();

  // Track the loading, loaded and error states
  bool isLoading = false;
  bool isLoaded = false;
  bool hasError = false;

  @override
  void onInit() {
    _subBreedRepository = SubBreedRepository();
    super.onInit();
  }

  void callGetRandomImageBySubBreed(String breed, String subBreed) {
    var url = "/breed/$breed/$subBreed/images/random";

    image.value = null;
    isLoading = true;
    isLoaded = false;
    hasError = false;
    update();

    _subBreedRepository.getRandomBySubBreed(url, (response, error) async {
      isLoading = false;

      if (response != null) {
        isLoaded = true;
        image.value = response.message;
      } else {
        hasError = true;
        showMessage(response?.status);
      }

      update();
    });
  }

  void callGetImageListBySubBreed(String breed, String subBreed) {
    var url = "/breed/$breed/$subBreed/images";

    isLoading = true;
    isLoaded = false;
    hasError = false;
    update();

    _subBreedRepository.getImageListBySubBreed(url, (response, error) async {
      isLoading = false;

      if (response != null) {
        isLoaded = true;
        breedImageList = response.message ?? [];
      } else {
        hasError = true;
        showMessage(response?.status);
      }

      update();
    });
  }
}
