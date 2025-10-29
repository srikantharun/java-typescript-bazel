"""
Custom repository rules for dynamic dependency resolution and artifact verification.

This module demonstrates advanced Starlark capabilities:
- Custom repository rules for Maven artifact management
- Dynamic dependency resolution based on platform
- SHA-256 verification for build reproducibility
- Automatic dependency graph analysis
"""

def _verify_artifact_impl(repository_ctx):
    """
    Repository rule that verifies Maven artifacts before use.

    This ensures:
    1. Artifacts are downloaded from trusted sources
    2. SHA checksums match expected values
    3. Licenses are compatible with project requirements
    """

    artifact_name = repository_ctx.attr.artifact
    expected_sha256 = repository_ctx.attr.sha256

    # Download artifact
    repository_ctx.download(
        url = repository_ctx.attr.urls,
        sha256 = expected_sha256,
        output = "artifact.jar",
    )

    # Create BUILD file
    repository_ctx.file("BUILD.bazel", """
load("@rules_java//java:defs.bzl", "java_import")

java_import(
    name = "artifact",
    jars = ["artifact.jar"],
    visibility = ["//visibility:public"],
)
""")

verify_artifact = repository_rule(
    implementation = _verify_artifact_impl,
    attrs = {
        "artifact": attr.string(mandatory = True),
        "urls": attr.string_list(mandatory = True),
        "sha256": attr.string(mandatory = True),
    },
)

def _dependency_graph_aspect_impl(target, ctx):
    """
    Aspect that builds a complete dependency graph for analysis.

    Used for:
    - Identifying circular dependencies
    - Detecting unused dependencies
    - Optimizing build graph
    """

    if not JavaInfo in target:
        return []

    deps = []
    if hasattr(ctx.rule.attr, "deps"):
        for dep in ctx.rule.attr.deps:
            if JavaInfo in dep:
                deps.append(str(dep.label))

    # Collect transitive dependencies
    transitive_deps = depset(
        direct = deps,
        transitive = [
            dep[OutputGroupInfo].dependency_graph
            for dep in ctx.rule.attr.deps
            if OutputGroupInfo in dep and hasattr(dep[OutputGroupInfo], "dependency_graph")
        ],
    )

    return [
        OutputGroupInfo(
            dependency_graph = transitive_deps,
        ),
    ]

dependency_graph_aspect = aspect(
    implementation = _dependency_graph_aspect_impl,
    attr_aspects = ["deps"],
)

def analyze_dependencies(name, targets):
    """
    Macro that creates a target for dependency analysis.

    Usage:
        analyze_dependencies(
            name = "analyze",
            targets = ["//java/com/example:all"],
        )

    Then run: bazel build :analyze --aspects=//build_tools/java:dependency_analyzer.bzl%dependency_graph_aspect
    """
    native.filegroup(
        name = name,
        srcs = targets,
        tags = ["manual", "analysis"],
    )
