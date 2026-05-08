class AppStrings {
  AppStrings._();

  static const String appName = 'Plate Scanner';
  static const String appSubtitle = 'Vehicle Number Plate Recognition';

  // Dashboard
  static const String scanWithCamera = 'Scan with Camera';
  static const String scanCameraDesc = 'Use the camera to capture a plate in real time';
  static const String recentScans = 'Recent Scans';
  static const String viewAll = 'View all';
  static const String totalScans = 'Total Scans';
  static const String todayScans = "Today's Scans";

  // Camera
  static const String positionPlate = 'Position the number plate in the frame';
  static const String tapToCapture = 'Tap the button to capture';
  static const String processing = 'Analysing image...';
  static const String cameraError = 'Camera unavailable';
  static const String cameraPermDenied = 'Camera permission denied. Open Settings to enable it.';
  static const String openSettings = 'Open Settings';

  // Result
  static const String scanResult = 'Scan Result';
  static const String plateNumber = 'Plate Number';
  static const String rawOcrText = 'Raw OCR Text';
  static const String validFormat = 'Recognised format';
  static const String partialFormat = 'Partial / unrecognised';
  static const String copy = 'Copy';
  static const String saveToHistory = 'Save to History';
  static const String savedSuccess = 'Saved to history';
  static const String copiedToClipboard = 'Copied to clipboard';
  static const String editPlate = 'Edit plate number';
  static const String noTextFound = 'No text detected. Try better lighting or a clearer angle.';
  static const String ocrFailed = 'Recognition failed. Please try again.';
  static const String scanAgain = 'Scan Again';
  static const String shareText = 'Share';

  // History
  static const String history = 'Scan History';
  static const String searchHint = 'Search plate numbers...';
  static const String noHistory = 'No scans yet';
  static const String noHistoryDesc = 'Captured plates will appear here';
  static const String noResults = 'No results found';
  static const String swipeToDelete = 'Swipe left to delete';
  static const String deleteConfirm = 'Delete this scan?';
  static const String deleteDesc = 'This action cannot be undone.';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';

  // Settings
  static const String settings = 'Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String darkModeEnabledDesc = 'Dark mode is currently enabled';
  static const String lightModeEnabledDesc = 'Light mode is currently enabled';
  static const String data = 'Data';
  static const String clearHistory = 'Clear All History';
  static const String clearHistoryDesc = 'Permanently delete all scan records';
  static const String clearConfirmTitle = 'Clear all scans?';
  static const String clearConfirmDesc =
      'All scan records and images will be permanently deleted. This cannot be undone.';
  static const String clearAll = 'Clear All';
  static const String historyCleared = 'History cleared';
  static const String about = 'About';
  static const String aboutTitle = 'Vehicle Number Plate Recognition System';
  static const String version = 'Version 1.0.0';
  static const String aboutDesc =
      'Uses Google ML Kit OCR to detect and recognise vehicle number plates from camera captures. '
      'Results are stored locally with full search and share support.';
}
