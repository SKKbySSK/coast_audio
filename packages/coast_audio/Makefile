build_runner:
	@fvm dart run build_runner build

test_with_coverage:
	@fvm dart run coverage:test_with_coverage
	@fvm dart run coverage:format_coverage --packages=.dart_tool/package_config.json --lcov -i coverage/coverage.json -o coverage/lcov.info
	@genhtml coverage/lcov.info -o coverage/html

ffigen:
	@fvm dart run ffigen
