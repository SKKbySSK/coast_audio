./build-android.sh
./build-apple.sh
fvm dart run tools/symbol_list/main.dart
cd ../
./ffigen.sh
