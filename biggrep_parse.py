#!/usr/bin/python3

import sys
from collections import defaultdict
import os
import re
import itertools
import math


def prepare_scorings(what_escaped):
    prefix_words = [
        "class",
        "function",
        "message",
        "def",
        "interface",
        "data",
        "newtype",
        "trait",
        "type",
        "const",
        "object",
    ]
    scorings = [
        (re.compile(template.format(what=what_escaped)), score)
        for template, score in itertools.chain(
            itertools.chain.from_iterable(
                [
                    [(prefix + " {what}\\b", 300000), (prefix + " {what}", 3000), (prefix, 10)]
                    for prefix in prefix_words
                ]
            ),
            [
                # plain occurences
                ("{what}", 1.0),
                ("^{what}$", 30000),
                ("\\b{what}\\b", 300),
                # declarations
                ("\\b{what}\s+:", 3000),
                ("{what}\s+:", 300),
                ("\\b{what}\s+=", 3000),
                ("{what}\s+=", 300),
                # Haskell function declarations
                ("\\b{what} ::", 300000),
                ("{what} ::", 3000),
                ("@given[(]['\"].*{what}", 300000),
                ("@then[(]['\"].*{what}", 300000),
                ("@when[(]['\"].*{what}", 300000),
            ],
        )
    ]
    return scorings

def safe_stdin():
    for line in sys.stdin.buffer.read().split(b"\n"):
        try:
            r = line.decode("utf8") + "\n"
            yield r
        except:
            try:
                r = (b":".join(line.split(b":")[:2]) + b": Matched but invalid utf8 bytes\n").decode('utf8')
                yield r
            except:
                pass


def process_input(input_stream, scorings, scorings_exact):
    d = defaultdict(list)
    score = dict()

    for i, inp in enumerate(input_stream):
        try:
            file, row, line = inp.split(":", 2)
            haystack = line.strip()
            haystack_lower = haystack.lower()
            line_score = 0.0
            if file not in score:
                score[file] = -i / 100000.0
            for regex, regex_score in scorings:
                if regex.search(haystack_lower) is not None:
                    line_score += regex_score
            for regex, regex_score in scorings_exact:
                if regex.search(haystack) is not None:
                    line_score += regex_score * 10
            d[file].append((row, line))
            score[file] += line_score
        except:
            pass
    return d, score


def filename_to_multiplier(filename):
    # Put most relevant tests to the end
    if filename.count("__tests__") + filename.count(".test.") + filename.count("test_data") > 0:
        return -10000
    if filename.split("/")[-1].startswith("test_"):
        return -10000
    if filename.count("_pb2.pyi") > 0:
        return -30000
    if filename.count("_pb2.py") > 0:
        return -20000
    if filename.endswith(".class"):
        return -20000
    if filename.count("/target/"):
        return -20000
    # Put irrelevant generated files to the middle
    if re.search("doc/.*svg$", filename) is not None:
        return -1
    if re.search("doc/.*svg.dot$", filename) is not None:
        return -1
    return 1


def print_sorted(d, score):
    out = []
    for k, v in d.items():
        out.append((score[k] * filename_to_multiplier(k), k, v))
    out.sort(reverse=True)

    for score, k, v in out:
        for vv in v:
            sys.stdout.write(f"{k}:{vv[0]}:{vv[1]}")


def main():
    what = sys.argv[1]
    scorings_exact = prepare_scorings(re.escape(what))
    scorings = prepare_scorings(re.escape(what.lower()))
    d, score = process_input(safe_stdin(), scorings, scorings_exact)
    print_sorted(d, score)


if __name__ == "__main__":
    main()
