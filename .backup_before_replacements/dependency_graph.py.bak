#!/usr/bin/env python3
"""
Dependency graph analyzer for visualizing and understanding target relationships.

Usage:
    bazel run //build_tools:dependency_graph -- --target=//java/com/example/userservice:all
"""

import argparse
import sys
from bazel_utils import BazelQuery, DependencyAnalyzer


def analyze_target_dependencies(target: str):
    """Analyze and display dependency information for a target."""
    print("=" * 60)
    print(f"DEPENDENCY ANALYSIS: {target}")
    print("=" * 60)

    try:
        # Get dependency statistics
        stats = DependencyAnalyzer.analyze_dependencies(target)

        print(f"\nTotal Dependencies:   {stats['total_dependencies']}")
        print(f"Direct Dependencies:  {stats['direct_dependencies']}")

        # Show direct dependencies
        print("\nDirect Dependencies:")
        direct_deps = BazelQuery.deps(target, depth=1)
        for dep in sorted(direct_deps):
            if dep != target:
                print(f"  {dep}")

        # Find reverse dependencies
        print("\n" + "=" * 60)
        print("REVERSE DEPENDENCIES (who depends on this)")
        print("=" * 60)
        rdeps = BazelQuery.rdeps("//...", target, depth=1)
        for rdep in sorted(rdeps):
            if rdep != target:
                print(f"  {rdep}")

    except Exception as e:
        print(f"Error analyzing target: {e}", file=sys.stderr)
        sys.exit(1)


def find_circular_dependencies(package: str):
    """Attempt to detect circular dependencies in a package."""
    print("=" * 60)
    print(f"CIRCULAR DEPENDENCY CHECK: {package}")
    print("=" * 60)

    try:
        targets = BazelQuery.query(f"{package}:*")
        print(f"\nAnalyzing {len(targets)} targets...\n")

        # This is a simplified check - full cycle detection requires graph algorithms
        for target in targets:
            deps = set(BazelQuery.deps(target, depth=2))
            rdeps = set(BazelQuery.rdeps(package, target, depth=2))

            # If target appears in both deps and rdeps, potential cycle
            intersection = deps & rdeps
            if len(intersection) > 1:  # More than just the target itself
                print(f"Potential cycle involving: {target}")
                print(f"  Mutual dependencies: {intersection}")

    except Exception as e:
        print(f"Error checking for cycles: {e}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description='Analyze Bazel target dependencies'
    )
    parser.add_argument(
        '--target',
        required=True,
        help='Target to analyze (e.g., //java/com/example:library)',
    )
    parser.add_argument(
        '--check-cycles',
        action='store_true',
        help='Check for circular dependencies',
    )

    args = parser.parse_args()

    # Analyze target dependencies
    analyze_target_dependencies(args.target)

    # Check for cycles if requested
    if args.check_cycles:
        # Extract package from target
        package = args.target.split(':')[0] if ':' in args.target else args.target
        print("\n")
        find_circular_dependencies(package)


if __name__ == '__main__':
    main()
