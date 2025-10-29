"""
Bazel utility functions for build analysis and automation.

This module provides utilities for:
- Parsing Build Event Protocol (BEP) files
- Analyzing dependency graphs
- Extracting build metrics
- Identifying affected targets
"""

import json
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List, Set, Dict, Optional


@dataclass
class BuildMetrics:
    """Metrics extracted from a Bazel build."""
    total_targets: int
    successful_targets: int
    failed_targets: int
    total_time_ms: int
    action_count: int
    cache_hits: int
    remote_cache_hits: int


@dataclass
class Target:
    """Represents a Bazel target."""
    label: str
    kind: str
    size: Optional[str] = None


class BazelQuery:
    """Execute Bazel queries and parse results."""

    @staticmethod
    def query(expression: str) -> List[str]:
        """Execute a Bazel query and return target labels."""
        result = subprocess.run(
            ["bazel", "query", expression, "--output=label"],
            capture_output=True,
            text=True,
            check=True,
        )
        return [line.strip() for line in result.stdout.splitlines() if line.strip()]

    @staticmethod
    def cquery(expression: str) -> List[str]:
        """Execute a Bazel cquery (configured query)."""
        result = subprocess.run(
            ["bazel", "cquery", expression, "--output=label"],
            capture_output=True,
            text=True,
            check=True,
        )
        return [line.strip() for line in result.stdout.splitlines() if line.strip()]

    @staticmethod
    def rdeps(universe: str, target: str, depth: int = 1) -> List[str]:
        """Find reverse dependencies of a target."""
        query = f'rdeps({universe}, {target}, {depth})'
        return BazelQuery.query(query)

    @staticmethod
    def deps(target: str, depth: int = 1) -> List[str]:
        """Find dependencies of a target."""
        query = f'deps({target}, {depth})'
        return BazelQuery.query(query)

    @staticmethod
    def kind(kind: str, pattern: str = "//...") -> List[str]:
        """Find all targets of a specific kind."""
        query = f'kind("{kind}", {pattern})'
        return BazelQuery.query(query)


class BEPAnalyzer:
    """Analyze Build Event Protocol JSON files."""

    def __init__(self, bep_file: Path):
        self.bep_file = bep_file
        self.events = []
        self._load_events()

    def _load_events(self):
        """Load and parse BEP JSON file."""
        with open(self.bep_file, 'r') as f:
            for line in f:
                if line.strip():
                    self.events.append(json.loads(line))

    def extract_metrics(self) -> BuildMetrics:
        """Extract build metrics from BEP events."""
        total_targets = 0
        successful = 0
        failed = 0
        total_time = 0
        action_count = 0
        cache_hits = 0
        remote_cache_hits = 0

        for event in self.events:
            if 'configured' in event:
                total_targets += 1

            if 'completed' in event:
                completed = event['completed']
                if completed.get('success'):
                    successful += 1
                else:
                    failed += 1

            if 'action' in event:
                action = event['action']
                action_count += 1
                if action.get('type') == 'CACHE_HIT':
                    cache_hits += 1
                if action.get('primaryOutput', {}).get('uri', '').startswith('remote://'):
                    remote_cache_hits += 1

            if 'finished' in event:
                finished = event['finished']
                if 'finishTimeMillis' in finished and 'startTimeMillis' in finished:
                    total_time = finished['finishTimeMillis'] - finished.get('startTimeMillis', 0)

        return BuildMetrics(
            total_targets=total_targets,
            successful_targets=successful,
            failed_targets=failed,
            total_time_ms=total_time,
            action_count=action_count,
            cache_hits=cache_hits,
            remote_cache_hits=remote_cache_hits,
        )

    def get_failed_targets(self) -> List[str]:
        """Extract list of failed target labels."""
        failed = []
        for event in self.events:
            if 'aborted' in event or ('completed' in event and not event['completed'].get('success')):
                if 'id' in event and 'targetCompleted' in event['id']:
                    label = event['id']['targetCompleted'].get('label')
                    if label:
                        failed.append(label)
        return failed

    def get_slow_actions(self, threshold_ms: int = 1000) -> List[Dict]:
        """Find actions that took longer than threshold."""
        slow_actions = []
        for event in self.events:
            if 'action' in event:
                action = event['action']
                if 'actionMetrics' in action:
                    metrics = action['actionMetrics']
                    duration = metrics.get('executionTimeInMs', 0)
                    if duration > threshold_ms:
                        slow_actions.append({
                            'mnemonic': action.get('type', 'Unknown'),
                            'duration_ms': duration,
                            'target': action.get('label', 'Unknown'),
                        })
        return sorted(slow_actions, key=lambda x: x['duration_ms'], reverse=True)


class DependencyAnalyzer:
    """Analyze dependency relationships between targets."""

    @staticmethod
    def find_affected_targets(changed_files: List[str]) -> Set[str]:
        """Find all targets affected by changed files."""
        affected = set()

        for file_path in changed_files:
            # Find targets that include this file
            try:
                owners = BazelQuery.query(f'owner("{file_path}")')
                affected.update(owners)

                # Find reverse dependencies
                for owner in owners:
                    rdeps = BazelQuery.rdeps("//...", owner, depth=1)
                    affected.update(rdeps)
            except subprocess.CalledProcessError:
                # File might not be tracked by Bazel
                continue

        return affected

    @staticmethod
    def find_test_targets(targets: Set[str]) -> Set[str]:
        """Filter test targets from a set of targets."""
        tests = set()
        for target in targets:
            if '_test' in target or target.endswith('_tests'):
                tests.add(target)
        return tests

    @staticmethod
    def analyze_dependencies(target: str) -> Dict[str, int]:
        """Analyze dependency tree depth and breadth."""
        all_deps = BazelQuery.deps(target, depth=100)

        return {
            'total_dependencies': len(all_deps),
            'direct_dependencies': len(BazelQuery.deps(target, depth=1)) - 1,  # Exclude target itself
            'max_depth': len(all_deps),  # Approximation
        }


def get_changed_files_from_git(base_branch: str = "main") -> List[str]:
    """Get list of changed files from git diff."""
    result = subprocess.run(
        ["git", "diff", "--name-only", f"{base_branch}...HEAD"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]
