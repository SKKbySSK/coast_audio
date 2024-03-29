build_runner:
	@fvm dart run build_runner build

ffigen:
	@fvm dart run ffigen

test_with_coverage:
	@fvm dart run coverage:test_with_coverage
	@fvm dart run coverage:format_coverage --packages=.dart_tool/package_config.json --lcov -i coverage/coverage.json -o coverage/lcov.info
	@fvm dart run remove_from_coverage:remove_from_coverage -f coverage/lcov.info -r 'bindings\.dart'
	@genhtml coverage/lcov.info -o coverage/html
