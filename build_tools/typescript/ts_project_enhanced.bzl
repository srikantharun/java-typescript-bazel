"""
Enhanced TypeScript project rules leveraging Aspect Build's latest features.

Demonstrates:
- SWC-based fast compilation
- Automatic type checking with worker pools
- ESBuild integration for bundling
- Jest test configuration
"""

load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@aspect_rules_jest//jest:defs.bzl", "jest_test")
load("@aspect_rules_esbuild//esbuild:defs.bzl", "esbuild")
load("@aspect_rules_js//js:defs.bzl", "js_library")

def ts_library_with_tests(
        name,
        srcs = [],
        deps = [],
        test_srcs = [],
        test_deps = [],
        tsconfig = "//:tsconfig.json",
        **kwargs):
    """
    Enhanced TypeScript library with automatic test generation.

    Args:
        name: Name of the library
        srcs: TypeScript source files
        deps: Dependencies
        test_srcs: Test source files (automatically discovered if empty)
        test_deps: Additional test dependencies
        tsconfig: TypeScript configuration file
        **kwargs: Additional arguments
    """

    # Compile TypeScript sources
    ts_project(
        name = name,
        srcs = srcs,
        deps = deps,
        tsconfig = tsconfig,
        declaration = True,
        source_map = True,
        **kwargs
    )

    # Generate tests if test sources provided
    if test_srcs or test_deps:
        test_name = "{}_test".format(name)

        # Determine test sources
        actual_test_srcs = test_srcs if test_srcs else native.glob([
            "**/*.test.ts",
            "**/*.spec.ts",
        ])

        if actual_test_srcs:
            # Compile test sources
            ts_project(
                name = "{}_test_lib".format(name),
                srcs = actual_test_srcs,
                deps = deps + test_deps + [
                    "//:node_modules/@types/jest",
                    "//:node_modules/@types/node",
                    ":" + name,
                ],
                tsconfig = "//:tsconfig.test.json",
                testonly = True,
            )

            # Create Jest test
            jest_test(
                name = test_name,
                data = [
                    ":{}_test_lib".format(name),
                    "//:node_modules/jest",
                ],
                node_modules = "//:node_modules",
                config = "//:jest.config.js",
            )

def ts_microservice(
        name,
        entry_point,
        srcs = [],
        deps = [],
        minify = True,
        **kwargs):
    """
    Create a bundled TypeScript microservice using esbuild.

    Args:
        name: Name of the microservice
        entry_point: Entry point TypeScript file
        srcs: Source files
        deps: Dependencies
        minify: Whether to minify the output
        **kwargs: Additional arguments
    """

    lib_name = "{}_lib".format(name)

    # Compile TypeScript
    ts_project(
        name = lib_name,
        srcs = srcs + [entry_point],
        deps = deps,
        declaration = True,
        **kwargs
    )

    # Bundle with esbuild
    esbuild(
        name = name,
        entry_point = entry_point.replace(".ts", ".js"),
        deps = [":" + lib_name],
        minify = minify,
        platform = "node",
        target = "node20",
        output = "{}.bundle.js".format(name),
    )

def ts_web_app(
        name,
        entry_point,
        srcs = [],
        deps = [],
        assets = [],
        **kwargs):
    """
    Create a bundled web application with all assets.

    Args:
        name: Name of the application
        entry_point: Entry point TypeScript file
        srcs: Source files
        deps: Dependencies
        assets: Static assets (HTML, CSS, images)
        **kwargs: Additional arguments
    """

    lib_name = "{}_lib".format(name)

    # Compile TypeScript
    ts_project(
        name = lib_name,
        srcs = srcs + [entry_point],
        deps = deps,
        **kwargs
    )

    # Bundle application
    esbuild(
        name = "{}_bundle".format(name),
        entry_point = entry_point.replace(".ts", ".js"),
        deps = [":" + lib_name],
        minify = True,
        platform = "browser",
        output = "app.js",
    )

    # Package with assets
    native.filegroup(
        name = name,
        srcs = [
            ":{}_bundle".format(name),
        ] + assets,
    )
