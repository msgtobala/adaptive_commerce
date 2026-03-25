import 'package:adaptive_commerce/features/onboarding/pet_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the in-progress and completed pet profile from onboarding.
final petProfileProvider =
    NotifierProvider<PetProfileNotifier, PetProfile>(PetProfileNotifier.new);

class PetProfileNotifier extends Notifier<PetProfile> {
  @override
  PetProfile build() => PetProfile.empty;

  void setPetType(PetKind type) {
    state = state.copyWith(petType: type, breed: '');
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDateOfBirth(DateTime dob) {
    state = state.copyWith(dateOfBirth: dob);
  }

  void setBreed(String breed) {
    state = state.copyWith(breed: breed);
  }

  void setGender(PetGender gender) {
    state = state.copyWith(gender: gender);
  }

  void reset() {
    state = PetProfile.empty;
  }
}
