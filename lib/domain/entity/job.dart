import 'business_size.dart';
import 'income_type.dart';

class Job {
  const Job({
    required this.id,
    required this.name,
    required this.hourlyWage,
    required this.incomeType,
    required this.businessSize,
    required this.colorArgb,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final int hourlyWage;
  final IncomeType incomeType;
  final BusinessSize businessSize;
  final int colorArgb;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job copyWith({
    String? name,
    int? hourlyWage,
    IncomeType? incomeType,
    BusinessSize? businessSize,
    int? colorArgb,
    bool? archived,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id,
      name: name ?? this.name,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      incomeType: incomeType ?? this.incomeType,
      businessSize: businessSize ?? this.businessSize,
      colorArgb: colorArgb ?? this.colorArgb,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Job &&
      other.id == id &&
      other.name == name &&
      other.hourlyWage == hourlyWage &&
      other.incomeType == incomeType &&
      other.businessSize == businessSize &&
      other.colorArgb == colorArgb &&
      other.archived == archived &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        hourlyWage,
        incomeType,
        businessSize,
        colorArgb,
        archived,
        createdAt,
        updatedAt,
      );
}
