#!/usr/bin/env python3

import os
import re
import sys
import subprocess


def open_in_emacs(filepath, line_number=None):
    """Open the specified file and line number in emacsclient."""
    if line_number:
        command = [
            "emacsclient",
            "-e",
            f'(progn (find-file "{filepath}") (goto-line {line_number}))',
        ]
    else:
        command = ["emacsclient", "-e", f'(find-file "{filepath}")']

    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}")


def parse_input_text(text):
    """Parse the input text and find file paths and line numbers."""

    # Regular expression patterns to match file paths and line numbers
    patterns = [
        r'File ["\']?(.*?\.cc|.*?\.py)["\']?, line (\d+)',  # Matches with or without quotes
        r'["\']?(.*?\.cc|.*?\.py)["\']?:(\d+):',  # Matches with or without quotes
        r'["\'](.*?\.cc|.*?\.py):(\d+)["\']',  # Matches file path and line number together inside quotes
        r'["\']?(.*?\.cc|.*?\.py)["\']?:\s',  # Matches just the filepath with a potential trailing colon followed by space
    ]

    matches = []
    for pattern in patterns:
        matches.extend(re.findall(pattern, text))
    if len(matches) == 1:
        if isinstance(matches[0], str):
            matches = [(matches[0], 1)]
    return matches


if __name__ == "__main__":
    input_text = sys.stdin.read()
    paths_and_lines = parse_input_text(input_text)

    for path, line_number in paths_and_lines:
        open_in_emacs(path, line_number)
        # print(f"File: {path}\nLine: {line_number}")
