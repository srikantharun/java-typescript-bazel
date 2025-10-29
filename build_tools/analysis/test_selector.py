#!/usr/bin/env python3
"""
Intelligent test selector that identifies affected tests based on code changes.

This demonstrates build optimization by running only affected tests.

Usage:
    # Find tests affected by current changes
    bazel run //build_tools:test_selector

    # Find tests for specific files
    bazel run //build_tools:test_selector -- --files=java/com/example/UserService.java
"""

import argparse
import sys
from typing import List, Set
from bazel_utils import DependencyAnalyzer, get_changed_files_from_git, BazelQuery


def select_tests(changed_files: List[str]) -> Set[str]:
    """
    Select test targets that should be run based on changed files.

    This implements intelligent test selection:
    1. Find all targets that own the changed files
    2. Find reverse dependencies (targets that depend on changed targets)
    3. Filter to only test targets
    """
    print(f"Analyzing {len(changed_files)} changed files...")

    # Find affected targets
    affected_targets = DependencyAnalyzer.find_affected_targets(changed_files)
    print(f"Found {len(affected_targets)} affected targets")

    # Filter to test targets
    test_targets = DependencyAnalyzer.find_test_targets(affected_targets)
    print(f"Identified {len(test_targets)} test targets to run")

    return test_targets


def print_bazel_command(test_targets: Set[str]):
    """Print the Bazel command to run selected tests."""
    if not test_targets:
        print("\nNo tests need to be run!")
        return

    print("\n" + "=" * 60)
    print("AFFECTED TESTS")
    print("=" * 60)
    for target in sorted(test_targets):
        print(f"  {target}")

    print("\n" + "=" * 60)
    print("RUN COMMAND")
    print("=" * 60)
    targets_str = " ".join(sorted(test_targets))
    print(f"bazel test {targets_str}")


def main():
    parser = argparse.ArgumentParser(
        description='Select tests based on code changes'
    )
    parser.add_argument(
        '--files',
        help='Comma-separated list of changed files (defaults to git diff)',
    )
    parser.add_argument(
        '--base-branch',
        default='main',
        help='Base branch for git diff (default: main)',
    )

    args = parser.parse_args()

    try:
        # Get changed files
        if args.files:
            changed_files = [f.strip() for f in args.files.split(',')]
        else:
            print(f"Getting changed files from git (base: {args.base_branch})...")
            changed_files = get_changed_files_from_git(args.base_branch)

        if not changed_files:
            print("No changed files detected")
            return

        print(f"\nChanged files ({len(changed_files)}):")
        for f in changed_files[:10]:  # Show first 10
            print(f"  {f}")
        if len(changed_files) > 10:
            print(f"  ... and {len(changed_files) - 10} more")

        # Select tests
        test_targets = select_tests(changed_files)

        # Print results
        print_bazel_command(test_targets)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
