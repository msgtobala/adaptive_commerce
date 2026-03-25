import 'package:flutter/foundation.dart';

/// Dog or cat — set during onboarding.
enum PetKind { dog, cat }

/// Pet gender for profile.
enum PetGender { male, female }

/// Client-side pet profile collected during onboarding (shared app-wide later).
@immutable
class PetProfile {
  const PetProfile({
    this.petType,
    this.name = '',
    this.dateOfBirth,
    this.breed = '',
    this.gender,
  });

  final PetKind? petType;
  final String name;
  final DateTime? dateOfBirth;
  final String breed;
  final PetGender? gender;

  static const PetProfile empty = PetProfile();

  bool get isComplete =>
      petType != null &&
      name.trim().isNotEmpty &&
      dateOfBirth != null &&
      breed.trim().isNotEmpty &&
      gender != null;

  PetProfile copyWith({
    PetKind? petType,
    String? name,
    DateTime? dateOfBirth,
    String? breed,
    PetGender? gender,
  }) {
    return PetProfile(
      petType: petType ?? this.petType,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
    );
  }
}

/// Short breed labels for dropdowns (per [PetKind]).
List<String> dogBreeds = const [
  'Labrador Retriever',
  'Golden Retriever',
  'German Shepherd',
  'Bulldog',
  'Poodle',
  'Mixed / Other',
];

List<String> catBreeds = const [
  'Persian',
  'Siamese',
  'Maine Coon',
  'Ragdoll',
  'British Shorthair',
  'Mixed / Other',
];

List<String> breedsForKind(PetKind? kind) {
  switch (kind) {
    case PetKind.dog:
      return dogBreeds;
    case PetKind.cat:
      return catBreeds;
    case null:
      return const [];
  }
}
