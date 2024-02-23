import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput();

  final cbuilder = CBuilder.library(
    name: 'ca_device',
    assetId: 'package:coast_audio/ca_device.dart',
    sources: ['ca_device/ca_device.m'],
    includes: ['ca_device/miniaudio'],
    flags: [
      if (buildConfig.targetOs == OS.iOS) ...[
        '-framework',
        'Foundation',
        '-framework',
        'AVFoundation',
        '-framework',
        'AudioToolbox',
      ],
      if (buildConfig.targetOs == OS.android) ...[
        '-lm',
      ],
    ],
  );

  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((record) => print(record.message));

  final log = File('${buildConfig.packageRoot.path}/build.log').openWrite();
  logger.onRecord.listen((record) {
    log.writeln(record.message);
  });

  await cbuilder.run(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );

  await buildOutput.writeToFile(outDir: buildConfig.outDir);
  await log.flush();
}
