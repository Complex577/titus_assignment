class ScanRecord {
  final int? id;
  final String plateNumber;
  final String? imagePath;
  final DateTime scanDate;
  final String rawText;
  final bool isValidPlate;

  const ScanRecord({
    this.id,
    required this.plateNumber,
    this.imagePath,
    required this.scanDate,
    required this.rawText,
    required this.isValidPlate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'plate_number': plateNumber,
        'image_path': imagePath,
        'scan_date': scanDate.millisecondsSinceEpoch,
        'raw_text': rawText,
        'is_valid_plate': isValidPlate ? 1 : 0,
      };

  factory ScanRecord.fromMap(Map<String, dynamic> map) => ScanRecord(
        id: map['id'] as int?,
        plateNumber: map['plate_number'] as String, 
        imagePath: map['image_path'] as String?,
        scanDate: DateTime.fromMillisecondsSinceEpoch(map['scan_date'] as int),
        rawText: map['raw_text'] as String? ?? '',
        isValidPlate: (map['is_valid_plate'] as int) == 1,
      );

  ScanRecord copyWith({
    int? id,
    String? plateNumber,
    String? imagePath,
    DateTime? scanDate,
    String? rawText,
    bool? isValidPlate,
  }) =>
      ScanRecord(
        id: id ?? this.id,
        plateNumber: plateNumber ?? this.plateNumber,
        imagePath: imagePath ?? this.imagePath,
        scanDate: scanDate ?? this.scanDate,
        rawText: rawText ?? this.rawText,
        isValidPlate: isValidPlate ?? this.isValidPlate,
      );
}