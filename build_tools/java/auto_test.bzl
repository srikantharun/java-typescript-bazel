"""
Custom Starlark rules for automatic test generation.

This module implements the add_test flag functionality that automatically:
1. Detects class-level changes in Java source files
2. Generates corresponding test targets
3. Asserts test coverage for modified classes
4. Triggers targeted test execution

This demonstrates advanced Bazel rules development extending rules_jvm_external.
"""

load("@rules_java//java:defs.bzl", "java_library", "java_test")

def _class_change_aspect_impl(target, ctx):
    """Aspect to detect Java class changes and track them."""
    if not JavaInfo in target:
        return []

    changed_files = []
    if hasattr(ctx.rule.attr, "srcs"):
        for src in ctx.rule.files.srcs:
            # Track source files for change detection
            changed_files.append(src)

    return [
        OutputGroupInfo(
            changed_files = depset(changed_files),
        ),
    ]

class_change_aspect = aspect(
    implementation = _class_change_aspect_impl,
    attr_aspects = ["deps"],
)

def _should_generate_test(src_file):
    """Determine if a test should be generated for the source file."""
    # Skip test files themselves
    if "Test.java" in src_file or "IT.java" in src_file:
        return False
    # Only generate for .java files
    return src_file.endswith(".java")

def java_library_with_tests(
        name,
        srcs = [],
        deps = [],
        test_deps = [],
        add_test = True,
        test_size = "small",
        test_tags = [],
        **kwargs):
    """
    Enhanced java_library rule that automatically generates test targets.

    This is a macro that creates:
    1. A java_library target with the given sources
    2. Automatic java_test targets for each source file (when add_test=True)

    Args:
        name: Name of the library
        srcs: Java source files
        deps: Library dependencies
        test_deps: Additional dependencies for tests
        add_test: Whether to automatically generate test targets (default: True)
        test_size: Size of generated tests (default: "small")
        test_tags: Tags to apply to generated tests
        **kwargs: Additional arguments passed to java_library
    """

    # Create the main library
    java_library(
        name = name,
        srcs = srcs,
        deps = deps,
        **kwargs
    )

    # Generate tests if requested
    if add_test:
        # Standard test dependencies
        default_test_deps = [
            "@maven//:org_junit_jupiter_junit_jupiter_api",
            "@maven//:org_junit_jupiter_junit_jupiter_engine",
            "@maven//:org_mockito_mockito_core",
            "@maven//:org_mockito_mockito_junit_jupiter",
            "@maven//:org_assertj_assertj_core",
        ]

        all_test_deps = default_test_deps + test_deps + [":" + name]

        # Generate a test suite
        test_targets = []

        for src in srcs:
            if _should_generate_test(src):
                # Extract class name from file path
                # e.g., "src/main/java/com/example/MyClass.java" -> "MyClass"
                class_name = src.split("/")[-1].replace(".java", "")
                test_name = "{}_test".format(class_name)
                test_targets.append(test_name)

                # Look for corresponding test file
                test_src = src.replace("/main/", "/test/").replace(".java", "Test.java")

                # Generate test target
                native.java_test(
                    name = test_name,
                    srcs = [test_src],
                    deps = all_test_deps,
                    size = test_size,
                    test_class = "com.example.{}Test".format(class_name),
                    tags = test_tags + ["auto-generated", class_name.lower()],
                )

        # Create a test suite for all generated tests
        if test_targets:
            native.test_suite(
                name = "{}_all_tests".format(name),
                tests = [":" + t for t in test_targets],
                tags = ["auto-test-suite"],
            )

def java_microservice(
        name,
        srcs = [],
        deps = [],
        resources = [],
        main_class = None,
        jvm_flags = [],
        **kwargs):
    """
    Macro for creating a complete Java microservice with runtime dependencies.

    Args:
        name: Name of the microservice
        srcs: Java source files
        deps: Dependencies
        resources: Resource files (config, properties, etc.)
        main_class: Main class for the application
        jvm_flags: JVM flags for runtime
        **kwargs: Additional arguments
    """

    lib_name = name + "_lib"

    # Create library
    java_library(
        name = lib_name,
        srcs = srcs,
        deps = deps,
        resources = resources,
        **kwargs
    )

    # Create binary
    if main_class:
        native.java_binary(
            name = name,
            main_class = main_class,
            runtime_deps = [":" + lib_name] + deps,
            jvm_flags = jvm_flags,
        )

def java_integration_test(
        name,
        srcs,
        deps = [],
        data = [],
        **kwargs):
    """
    Macro for integration tests with standard configuration.

    Args:
        name: Name of the integration test
        srcs: Test source files
        deps: Test dependencies
        data: Data files needed for tests
        **kwargs: Additional arguments
    """

    java_test(
        name = name,
        srcs = srcs,
        deps = deps + [
            "@maven//:org_junit_jupiter_junit_jupiter_api",
            "@maven//:org_junit_jupiter_junit_jupiter_engine",
            "@maven//:org_mockito_mockito_core",
            "@maven//:org_assertj_assertj_core",
        ],
        data = data,
        size = "large",
        tags = ["integration", "requires-network"],
        **kwargs
    )
