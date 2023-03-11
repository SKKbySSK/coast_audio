import 'dart:io';

void main() {
  final ignoredFiles = [
    'mab_types.h',
    'mabridge.h',
    'mab_enum.h',
  ];

  final basepath = '../../src/';
  final srcDirectory = Directory(basepath);
  final headerFiles = srcDirectory
      .listSync()
      .where((e) => e.path.endsWith('.h'))
      .toList(growable: false);

  stdout.writeln('[');
  for (final file in headerFiles) {
    final name = file.path.replaceAll(basepath, '');
    if (ignoredFiles.contains(name)) {
      continue;
    }

    stdout.writeln('  // $name');
    final symbols = getSymbols(file as File);
    for (final symbol in symbols) {
      stdout.writeln('  $symbol,');
    }
  }
  stdout.writeln(']');
}

List<String> getSymbols(File file) {
  final regexp = RegExp(r'.*\s(.*)\(.*\);');
  return file
      .readAsLinesSync()
      .map((line) => regexp.firstMatch(line))
      .map((match) => match?.group(1))
      .where((match) => match != null)
      .cast<String>()
      .toList();
}
