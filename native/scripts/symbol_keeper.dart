import 'dart:io';

const template = '''/// THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.
/// You can regenerate this file by running `fvm dart scripts/symbol_keeper.dart`.
import Foundation
import coast_audio

@objc public final class CoastAudioSymbolKeeper: NSObject {
  @objc public static func keep() {
    let symbols = [
TEMPLATE,
    ] as [Any]
    
    let _ = symbols.count
  }
}
''';

void main(List<String> args) {
  final ignoredFiles = [
    'dart_types.h',
  ];

  final basepath = args.isNotEmpty ? args[0] : 'src/';
  final srcDirectory = Directory(basepath);
  final headerFiles = srcDirectory.listSync().where((e) => e.path.endsWith('.h')).where((e) => !ignoredFiles.any((i) => e.path.endsWith(i))).toList();
  headerFiles.add(File('miniaudio/extras/miniaudio_split/miniaudio.h'));

  const swiftPath = 'src/SymbolKeeper.swift';
  final swiftFile = File(swiftPath);

  findAndWriteFuncDef(swiftFile, basepath, headerFiles);
  stdout.write(getFuncDef(basepath, headerFiles));
}

void findAndWriteFuncDef(File file, String basepath, List<FileSystemEntity> headerFiles) {
  file.writeAsStringSync(getFuncDef(basepath, headerFiles), flush: true);
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
      .where((e) => e.startsWith('ma_') || e.startsWith('ca_') || e.startsWith('coast_audio'))
      .where((e) => !e.contains('resource_manager') && !e.contains('node') && !e.contains('engine') && !e.contains('sound'))
      .toList();
}
