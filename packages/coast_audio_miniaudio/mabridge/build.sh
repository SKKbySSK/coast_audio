fvm dart run tools/miniaudio_split/main.dart
./build-android.sh
./build-apple.sh
fvm dart run tools/symbol_list/main.dart
cd ../
./ffigen.sh
