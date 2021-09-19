#!/usr/bin/python3
"""
`crep foo` will find all occurences of foo in the current directory, and rank them by relevancy. If it's a
git repository, it will narrow search to only files that are tracked in that repo. By default it return most
relevant file on the top, and matched lines are ordered as in the input file. Regexp syntax is as in grep
(it calls grep underneath). Note that if you provide several patterns, they will be joined to single patter
sepatated by single space.
"""

import argparse
from collections import defaultdict
import itertools
import re
import subprocess
import sys
import textwrap
from typing import Iterable, Dict, List, Tuple, Pattern, NewType

REPLACEMENT = "xxx⚓xxx"


def prepare_scorings(what: str) -> List[Tuple[Pattern, float]]:
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
        (re.compile(template), score)
        for template, score in itertools.chain(
            itertools.chain.from_iterable(
                [
                    [(rf"{prefix}\s+{what}\b", 300000), (rf"{prefix}\s+{what}", 3000), (prefix, 10)]
                    for prefix in prefix_words
                ]
            ),
            [
                # plain occurences
                (rf"{what}", 1.0),
                (rf"^{what}$", 30000),
                (rf"\b{what}\b", 300),
                # declarations
                (rf"\b{what}\s+:", 3000),
                (rf"{what}\s+:", 300),
                (rf"\b{what}\s+=", 3000),
                (rf"{what}\s+=", 300),
                # Haskell function declarations
                (rf"\b{what}\s+::", 300000),
                (rf"{what}\s+::", 3000),
                (rf"@given[(]['\"].*{what}", 300000),
                (rf"@then[(]['\"].*{what}", 300000),
                (rf"@when[(]['\"].*{what}", 300000),
            ],
        )
    ]
    return scorings


FileName = NewType("FileName", str)
Line = NewType("Line", str)
Row = NewType("Row", str)
FileScore = NewType("FileScore", float)
LineScore = NewType("LineScore", float)


def safe_stdin() -> Iterable[Line]:
    for line in sys.stdin.buffer.read().split(b"\n"):
        if not line:
            continue
        try:
            r = line.decode("utf8") + "\n"
            yield Line(r)
        except:
            try:
                r = (b":".join(line.split(b":")[:2]) + b": Matched but invalid utf8 bytes\n").decode("utf8")
                yield Line(r)
            except:
                pass


COLORS_RE = re.compile(r"\x1b\[[0-9;]*[mK]")
COLORS_K_RE = re.compile(r"\x1b\[[0-9;]*K")
HIGHLIGHT_RE = re.compile(r"\x1b\[01;31m[^\x1b]*\x1b\[m")


def process_input(
    input_stream: Iterable[Line], scorings, scorings_exact
) -> Tuple[Dict[FileName, List[Tuple[Row, Line, LineScore]]], Dict[FileName, FileScore]]:
    d: Dict[FileName, List[Tuple[Row, Line, LineScore]]] = defaultdict(list)
    score: Dict[FileName, FileScore] = dict()

    for i, inp in enumerate(input_stream):
        try:
            file_, row, line = inp.split(":", 2)
            file = FileName(file_)
            haystack = COLORS_RE.sub("", HIGHLIGHT_RE.sub(REPLACEMENT, COLORS_K_RE.sub("", line.strip())))
            haystack_lower = haystack.lower()
            line_score = 0.0
            if file not in score:
                score[file] = FileScore(-i / 100000.0)
            for regex, regex_score in scorings:
                if regex.search(haystack_lower) is not None:
                    line_score += regex_score
            for regex, regex_score in scorings_exact:
                if regex.search(haystack) is not None:
                    line_score += regex_score * 10
            d[file].append((Row(row), Line(line), LineScore(line_score)))
            score[file] = FileScore(score[file] + line_score)
        except Exception as e:
            print("X", inp, "X", file=sys.stderr)
            print("Y", e, file=sys.stderr)
    return d, score


def filename_to_multiplier(filename: FileName) -> int:
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


def pp_line(
    file: FileName, line: Row, score_f: FileScore, score_l: LineScore, text: Line, explain: bool, color: bool
) -> None:
    score = str(score_f)
    l_score = str(score_l)
    if color:
        semicolon = "\033[96m:"
        score = "\033[33m" + score
        l_score = "\033[33m" + l_score
        postprocess = lambda x: x
    else:
        semicolon = ":"
        postprocess = lambda x: COLORS_RE.sub("", x)
    if explain:
        sys.stdout.write(postprocess(semicolon.join([file, line, score, l_score, text])))
    else:
        sys.stdout.write(postprocess(semicolon.join([file, line, text])))


def print_sorted(
    d: Dict[FileName, List[Tuple[Row, Line, LineScore]]],
    score: Dict[FileName, FileScore],
    sort_type: str,
    explain: bool,
    color: bool,
) -> None:
    out = []
    for k, v in d.items():
        file_multiplier = filename_to_multiplier(k)
        for row, line, line_score in v:
            out.append(
                (FileScore(score[k] * file_multiplier), k, row, line, LineScore(line_score * file_multiplier))
            )
    if sort_type == "file":
        out.sort(reverse=True)
    elif sort_type == "line":
        out.sort(reverse=True, key=lambda x: (x[-1], x[0]))
    elif sort_type == "none":
        pass
    else:
        raise NotImplementedError(f"Sort type {sort_type}.")

    for file_score, k, row, line, line_score in out:
        pp_line(k, row, file_score, line_score, line, explain, color)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser("cgrep", description=__doc__)
    parser.add_argument(
        "--sort",
        default="file",
        choices=["none", "file", "line"],
        help="How to sort lines."
        " `file` is to sort by file relevancy so all matches from same file are grouped and order by line numer."
        " `line` orders by line relevancy.",
    )
    parser.add_argument("--explain", action="store_true", help="Print also score.")
    parser.add_argument("--dir", "-d", default=".", help="Default directory to search in.")
    parser.add_argument("--extensions", "-e", help="Comma separated list of extensions.")
    parser.add_argument("--input", default="auto", choices=["stdin", "recursive", "git", "auto"])
    parser.add_argument("--color", default="auto", choices=["always", "never", "auto"])
    parser.add_argument("pattern", nargs="+")
    args = parser.parse_args()
    if args.color == "auto":
        args.color = sys.stdout.isatty()
    else:
        if args.color not in ["always", "never"]:
            raise NotImplementedError(f"Color {args.color} not implemented")
        args.color = args.color == "always"
    return args


def grep(*args: str) -> Iterable[Line]:
    """Wrapper for `grep`"""
    out = subprocess.run(
        ["grep", "--binary-files=text", "--color=always"] + list(args), stdout=subprocess.PIPE, check=False
    )
    for line in out.stdout.decode("utf8").strip("\n").split("\n"):
        if line:
            yield Line(f"{line}\n")


def git_ls_files(directory: str) -> Iterable[str]:
    """Wrapper for `git ls-files`"""
    out = subprocess.run(
        ["git", "ls-files"], cwd=directory, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    for file in out.stdout.decode("utf8").strip("\n").split("\n"):
        if file:
            yield f"{directory}/{file}"


def get_source(args: argparse.Namespace) -> Iterable[Line]:
    """Returns search results for ranking and sorting"""
    pattern = " ".join(args.pattern)
    extensions = [f"--include=*.{ext}" for ext in args.extensions.split(",")] if args.extensions else []
    if args.input == "stdin":
        yield from safe_stdin()
    elif args.input == "auto":
        try:
            files = list(git_ls_files(args.dir))
            yield from grep("-nH", *extensions, pattern, *files)
        except subprocess.CalledProcessError:
            yield from grep("-rnH", *extensions, pattern, args.dir)
    elif args.input == "git":
        yield from grep("-nH", *extensions, pattern, *git_ls_files(args.dir))
    elif args.input == "recursive":
        yield from grep("-rnH", *extensions, pattern, args.dir)
    else:
        raise NotImplementedError(f"Command {args.command} is not implemented")


def main() -> None:
    args = parse_args()
    scorings_exact = prepare_scorings(REPLACEMENT)
    scorings = prepare_scorings(REPLACEMENT)
    d, score = process_input(get_source(args), scorings, scorings_exact)
    print_sorted(d, score, sort_type=args.sort, explain=args.explain, color=args.color)


if __name__ == "__main__":
    main()
