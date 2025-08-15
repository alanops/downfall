extends Resource

# GUT Configuration for Sky Drop Tests

# Test directories
var test_dirs = ["res://tests/"]

# Test name pattern
var test_prefix = "test_"

# Output settings
var log_level = 1  # 0=quiet, 1=normal, 2=verbose
var should_print_to_console = true
var should_exit_on_success = false
var should_exit_on_failure = false

# Test execution settings
var disable_strict_datatype_checks = false
var double_strategy = "partial"  # partial or full
var unit_test_name = ""  # Run specific test if set

# UI settings
var opacity = 100
var should_maximize = false
var compact_mode = false

# Hooks
var pre_run_script = ""
var post_run_script = ""

# Export settings
var junit_xml_file = ""
var junit_xml_timestamp = false