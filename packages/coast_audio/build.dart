import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

Future<void> main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((record) => print(record.message));

  final log = File('${buildConfig.packageRoot.path}/build.log').openWrite();
  logger.onRecord.listen((record) {
    log.writeln(record.message);
  });

  final buildOutput = BuildOutput();

  await _runCaDeviceBuilder(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );
  await _runMiniaudioBuilder(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );

  await buildOutput.writeToFile(outDir: buildConfig.outDir);

  await log.flush();
}

Future<void> _runCaDeviceBuilder({
  required BuildConfig buildConfig,
  required BuildOutput buildOutput,
  required Logger logger,
}) async {
  final cbuilder = CBuilder.library(
    name: 'ca_device',
    assetId: 'package:coast_audio/ca_device.dart',
    sources: ['ca_device/ca_device.c'],
    includes: ['ca_device/miniaudio'],
    flags: [
      if (buildConfig.targetOs == OS.iOS) ...[
        '-framework',
        'Foundation',
        '-framework',
        'AVFoundation',
        '-framework',
        'AudioToolbox',
        '-x',
        'objective-c',
      ],
      if (buildConfig.targetOs == OS.android) ...[
        '-lm',
      ],
    ],
  );

  await cbuilder.run(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );
}

Future<void> _runMiniaudioBuilder({
  required BuildConfig buildConfig,
  required BuildOutput buildOutput,
  required Logger logger,
}) async {
  final cbuilder = CBuilder.library(
    name: 'miniaudio',
    assetId: 'package:coast_audio/miniaudio.dart',
    sources: ['ca_device/miniaudio/extras/miniaudio_split/miniaudio.c'],
    includes: ['ca_device/miniaudio/extras/miniaudio_split'],
    flags: [
      if (buildConfig.targetOs == OS.iOS) ...[
        '-framework',
        'Foundation',
        '-framework',
        'AVFoundation',
        '-framework',
        'AudioToolbox',
        '-x',
        'objective-c',
      ],
      if (buildConfig.targetOs == OS.android) ...[
        '-lm',
      ],
    ],
  );

  await cbuilder.run(
    buildConfig: buildConfig,
    buildOutput: buildOutput,
    logger: logger,
  );
}
