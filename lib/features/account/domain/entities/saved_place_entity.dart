class SavedPlaceEntity {
  const SavedPlaceEntity({
    required this.id,
    required this.title,
    required this.address,
    required this.type,
    required this.iconType,
    required this.colorType,
    required this.isDefault,
  });

  final String id;
  final String title;
  final String address;
  final String type;
  final String iconType;
  final String colorType;
  final bool isDefault;

  SavedPlaceEntity copyWith({
    String? id,
    String? title,
    String? address,
    String? type,
    String? iconType,
    String? colorType,
    bool? isDefault,
  }) {
    return SavedPlaceEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      type: type ?? this.type,
      iconType: iconType ?? this.iconType,
      colorType: colorType ?? this.colorType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
