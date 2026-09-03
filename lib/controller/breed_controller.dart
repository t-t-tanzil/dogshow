import 'package:dog_show/model/breed_model.dart';
import 'package:dog_show/utils/environment.dart';
import 'package:get/get.dart';
import '../model/dog_class.dart';
import '../repositories/breed_repository.dart';
import '../utils/constants.dart';

abstract class BreedRepositoryInterface {
  void getBreedModel();
}

class BreedController extends GetxController {
  late final BreedRepository _breedRepository;

  List<String> breedList = [];
  Map<String, List<String>> breedMap = {};
  List<String> breedImageList = [];
  List<String> subBreedNameList = [];

  var image = Rxn<String?>();

  // Track the loading, loaded and error states
  bool isLoading = false;
  bool isLoaded = false;
  bool hasError = false;

  @override
  void onInit() {
    _breedRepository = BreedRepository();
    super.onInit();
  }

  void callGetBreedList() {
    isLoading = true;
    isLoaded = false;
    hasError = false;
    update();

    _breedRepository.getBreedModel((response, error) async {
      isLoading = false;

      if (response != null) {
        isLoaded = true;

        breedList = [];
        breedMap = response.message;

        response.message.keys.forEach((element) {
          breedList.add(element);
        });
      } else {
        hasError = true;
        showMessage(response?.status);
      }

      update();
    });
  }

  void callGetRandomImageByBreed(breedName) {
    var url = "/breed/$breedName/images/random";

    isLoading = true;
    isLoaded = false;
    hasError = false;
    image.value = null;
    update();

    _breedRepository.getRandomByBreed(url, (response, error) async {
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

  void callGetImageListByBreed(breed) {
    var url = "/breed/$breed/images";

    isLoading = true;
    isLoaded = false;
    hasError = false;
    update();

    _breedRepository.getImageListByBreed(url, (response, error) async {
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

  void callGetSubBreedList(String breed) {
    var url = "/breed/$breed/list";

    isLoading = true;
    isLoaded = false;
    hasError = false;
    update();

    _breedRepository.getSubBreedList(url, (response, error) async {
      isLoading = false;

      if (response != null) {
        isLoaded = true;
        subBreedNameList = response.message ?? [];
      } else {
        hasError = true;
        showMessage(response?.status);
      }

      update();
    });
  }
}
