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

/// Calendar months from [birth] to [asOf] (defaults to today). Non-negative.
int petAgeInMonths(DateTime birth, {DateTime? asOf}) {
  final end = _dateOnly(asOf ?? DateTime.now());
  final start = _dateOnly(birth);
  if (end.isBefore(start)) return 0;
  var months = (end.year - start.year) * 12 + end.month - start.month;
  if (end.day < start.day) months--;
  return months < 0 ? 0 : months;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// User-facing age string, e.g. `"1 month"` / `"14 months"`.
String formatAgeInMonthsLabel(DateTime birth, {DateTime? asOf}) {
  final m = petAgeInMonths(birth, asOf: asOf);
  return m == 1 ? '1 month' : '$m months';
}

/// Short breed labels for dropdowns (per [PetKind]).
List<String> dogBreeds = const [
  'Maltipoo',
  'Labrador Retriever',
  'Golden Retriever',
  'German Shepherd',
  'Bulldog',
  'Poodle',
  'Mixed / Other',
];

List<String> catBreeds = const [
  'Indian Spotted Cat',
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
