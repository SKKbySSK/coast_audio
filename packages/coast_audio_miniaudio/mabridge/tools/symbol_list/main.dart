import 'dart:io';

const functionDef = '  private func preventSymbolStrip()';

const template = '''  private func preventSymbolStrip() {
    let mabSymbols = [
TEMPLATE
    ] as [Any]
    _ = mabSymbols.count
  }''';

void main(List<String> args) {
  final ignoredFiles = [
    'mab_types.h',
    'mabridge.h',
    'mab_enum.h',
  ];

  final basepath = args.isNotEmpty ? args[0] : './src/';
  final srcDirectory = Directory(basepath);
  final headerFiles = srcDirectory
      .listSync()
      .where((e) => e.path.endsWith('.h'))
      .where((e) => !ignoredFiles.any((i) => e.path.endsWith(i)))
      .toList(growable: false);

  const iosSwiftPath = '../../flutter_coast_audio_miniaudio/ios/Classes/FlutterCoastAudioMiniaudioPlugin.swift';
  final iosSwiftFile = File(iosSwiftPath);
  const macosSwiftPath = '../../flutter_coast_audio_miniaudio/macos/Classes/FlutterCoastAudioMiniaudioPlugin.swift';
  final macosSwiftFile = File(macosSwiftPath);
    
  findAndWriteFuncDef(iosSwiftFile, basepath, headerFiles);
  findAndWriteFuncDef(macosSwiftFile, basepath, headerFiles);
  stdout.write(getFuncDef(basepath, headerFiles));
}

void findAndWriteFuncDef(File file, String basepath, List<FileSystemEntity> headerFiles) {
  var text = file.readAsStringSync();
  final startPos = text.indexOf(functionDef);
  final endPos = text.indexOf('}', startPos) + 1;

  text = text.replaceRange(startPos, endPos, getFuncDef(basepath, headerFiles));
  file.writeAsStringSync(text, flush: true);
}

String getFuncDef(String basepath, List<FileSystemEntity> headerFiles) {
  final symbolLines = <String>[];

  for (final file in headerFiles) {
    final name = file.path.replaceAll(basepath, '');
    symbolLines.add('// $name');
    symbolLines.addAll(getSymbols(file as File).map((e) => '$e,'));
    symbolLines.add('\n');
  }

  symbolLines.removeLast();
  final lastSymbol = symbolLines[symbolLines.length - 1];
  symbolLines[symbolLines.length - 1] = lastSymbol.replaceAll(',', '');

  return template.replaceAll('TEMPLATE', symbolLines.map((e) => '      $e').join('\n'));
}

List<String> getSymbols(File file) {
  final regexp = RegExp(r'.*\s(.*)\(.*\);');
  return file
      .readAsLinesSync()
      .where((line) => !line.startsWith('typedef'))
      .map((line) => regexp.firstMatch(line))
      .map((match) => match?.group(1))
      .where((match) => match != null)
      .cast<String>()
      .toList();
}