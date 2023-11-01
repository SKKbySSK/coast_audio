import 'dart:io';

void main(List<String> args) {
  final String filePath;
  if (args.isEmpty) {
    filePath = 'modules/miniaudio/miniaudio.h';
  } else {
    filePath = args[0];
  }

  final file = File(filePath);
  if (!file.existsSync()) {
    stderr.writeln('failed to locate miniaudio.h at $filePath');
    return;
  }

  final separator = '/* miniaudio_h */';
  final data = file.readAsStringSync();
  final headerEnd = data.indexOf(separator);
  final implStart = data.indexOf('#ifndef miniaudio_c', headerEnd);
  final implEnd = data.indexOf('#endif  /* MINIAUDIO_IMPLEMENTATION */', implStart);

  final header = data.substring(0, headerEnd);
  final source = data.substring(implStart, implEnd);

  File('tools/miniaudio_split/miniaudio.h').writeAsStringSync(
    '#pragma once\n$header',
    flush: true,
  );
  File('tools/miniaudio_split/miniaudio.c').writeAsStringSync(
    '''
#ifdef __APPLE__
#define MA_NO_RUNTIME_LINKING
#endif

#include "miniaudio.h"
$source
''',
    flush: true,
  );
}
