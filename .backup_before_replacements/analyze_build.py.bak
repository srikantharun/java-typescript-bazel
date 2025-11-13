#!/usr/bin/env python3
"""
Build analysis tool for extracting insights from Bazel builds.

Usage:
    bazel run //build_tools:analyze_build -- --bep-file=build_events.json
"""

import argparse
import sys
from pathlib import Path
from bazel_utils import BEPAnalyzer


def main():
    parser = argparse.ArgumentParser(description='Analyze Bazel build events')
    parser.add_argument('--bep-file', required=True, help='Path to BEP JSON file')
    parser.add_argument('--show-slow-actions', action='store_true',
                        help='Show slow actions')
    parser.add_argument('--threshold-ms', type=int, default=1000,
                        help='Threshold for slow actions in milliseconds')

    args = parser.parse_args()

    bep_file = Path(args.bep_file)
    if not bep_file.exists():
        print(f"Error: BEP file not found: {bep_file}", file=sys.stderr)
        sys.exit(1)

    analyzer = BEPAnalyzer(bep_file)

    # Extract and display metrics
    metrics = analyzer.extract_metrics()
    print("=" * 60)
    print("BUILD METRICS")
    print("=" * 60)
    print(f"Total Targets:       {metrics.total_targets}")
    print(f"Successful:          {metrics.successful_targets}")
    print(f"Failed:              {metrics.failed_targets}")
    print(f"Total Time:          {metrics.total_time_ms / 1000:.2f}s")
    print(f"Action Count:        {metrics.action_count}")
    print(f"Cache Hits:          {metrics.cache_hits}")
    print(f"Remote Cache Hits:   {metrics.remote_cache_hits}")

    if metrics.action_count > 0:
        cache_rate = (metrics.cache_hits / metrics.action_count) * 100
        print(f"Cache Hit Rate:      {cache_rate:.1f}%")

    # Show failed targets
    failed_targets = analyzer.get_failed_targets()
    if failed_targets:
        print("\n" + "=" * 60)
        print("FAILED TARGETS")
        print("=" * 60)
        for target in failed_targets:
            print(f"  {target}")

    # Show slow actions if requested
    if args.show_slow_actions:
        slow_actions = analyzer.get_slow_actions(args.threshold_ms)
        if slow_actions:
            print("\n" + "=" * 60)
            print(f"SLOW ACTIONS (>{args.threshold_ms}ms)")
            print("=" * 60)
            for action in slow_actions[:10]:  # Top 10
                print(f"  {action['duration_ms']:>6}ms  {action['mnemonic']:>20}  {action['target']}")

    print("\n" + "=" * 60)


if __name__ == '__main__':
    main()
