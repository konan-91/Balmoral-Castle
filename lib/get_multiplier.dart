import 'package:flutter/services.dart';

Future<double> getMultiplier(String language, int videoNumber) async {
  double multiplier = 1.0;

  try {
    String content = await rootBundle.loadString('assets/texts/multipliers.txt');
    List<String> lines = content.split('\n');

    switch (language) {
      case 'English':
        multiplier = double.parse(lines[videoNumber]);
        break;
      case 'German':
        multiplier = double.parse(lines[12 + videoNumber]);
        break;
      case 'French':
        multiplier = double.parse(lines[24 + videoNumber]);
        break;
      case 'Dutch':
        multiplier = double.parse(lines[36 + videoNumber]);
        break;
      case 'Italian':
        multiplier = double.parse(lines[48 + videoNumber]);
        break;
      default:
        print('Defaulted!');
        multiplier = 1.0;
    }

  } catch (e) {
    print('Error reading file: $e');
  }

  print('Multiplier for video $videoNumber: $multiplier');
  return multiplier;
}