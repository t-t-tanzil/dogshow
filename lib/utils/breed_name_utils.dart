String formatBreedName(String raw) {
  return raw
      .split(RegExp(r'[\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

/// Dog CEO image URLs look like
/// `https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg`.
/// The breeds path segment is `{breed}` or `{breed}-{subBreed}`, so we
/// reverse it to read naturally, e.g. "Afghan Hound".
String? breedNameFromImageUrl(String? url) {
  if (url == null) return null;

  final match = RegExp(r'/breeds/([a-z0-9-]+)/').firstMatch(url);
  final segment = match?.group(1);
  if (segment == null) return null;

  final parts = segment.split('-');
  final reversed = parts.reversed.join(' ');
  return formatBreedName(reversed);
}
