import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';

/// Text block prepended to Food & Toys chat turns so the model always sees profile.
String formatPetProfileForPrompt(PetProfile p) {
  final dob = p.dateOfBirth != null
      ? '${p.dateOfBirth!.year}-${p.dateOfBirth!.month.toString().padLeft(2, '0')}-${p.dateOfBirth!.day.toString().padLeft(2, '0')}'
      : 'not specified';
  final age = p.dateOfBirth != null
      ? formatAgeInMonthsLabel(p.dateOfBirth!)
      : 'not specified';
  final gender = p.gender == null
      ? 'not specified'
      : (p.gender == PetGender.male ? 'male' : 'female');

  return '''
--- Pet profile (use for every answer; tailor food/toy advice to this pet) ---
Pet type: ${p.petType?.name ?? 'not specified'}
Name: ${p.name.trim().isNotEmpty ? p.name.trim() : 'not specified'}
Date of birth: $dob
Age: $age
Breed: ${p.breed.trim().isNotEmpty ? p.breed.trim() : 'not specified'}
Gender: $gender
--- End pet profile ---''';
}

/// Wraps the user’s question with [formatPetProfileForPrompt].
String foodToysMessageWithProfile(PetProfile profile, String userQuestion) {
  return '${formatPetProfileForPrompt(profile)}\n\nUser question:\n$userQuestion';
}
