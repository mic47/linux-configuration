#!/usr/bin/python3

import argparse
import subprocess
import sys
from collections import defaultdict
import re
import itertools

from typing import Iterable, Dict, List, Tuple, Pattern, NewType


def prepare_scorings(what_escaped: str) -> List[Tuple[Pattern, float]]:
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
                ("\\b{what}\\s+:", 3000),
                ("{what}\\s+:", 300),
                ("\\b{what}\\s+=", 3000),
                ("{what}\\s+=", 300),
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


FileName = NewType("FileName", str)
Line = NewType("Line", str)
Row = NewType("Row", str)
FileScore = NewType("FileScore", float)
LineScore = NewType("LineScore", float)


def safe_stdin() -> Iterable[Line]:
    for line in sys.stdin.buffer.read().split(b"\n"):
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


def process_input(
    input_stream: Iterable[Line], scorings, scorings_exact
) -> Tuple[Dict[FileName, List[Tuple[Row, Line, LineScore]]], Dict[FileName, FileScore]]:
    d: Dict[FileName, List[Tuple[Row, Line, LineScore]]] = defaultdict(list)
    score: Dict[FileName, FileScore] = dict()

    for i, inp in enumerate(input_stream):
        try:
            file_, row, line = inp.split(":", 2)
            file = FileName(file_)
            haystack = COLORS_RE.sub("", line.strip())
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
            # TODO: make scoring to match ranges from grep matches
            d[file].append((Row(row), Line(line), LineScore(line_score)))
            score[file] = FileScore(score[file] + line_score)
        except Exception as e:
            print(inp, file=sys.stderr)
            print(e, file=sys.stderr)
            pass
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
    else:
        semicolon = ":"
    if explain:
        sys.stdout.write(semicolon.join([file, line, score, l_score, text]))
    else:
        sys.stdout.write(semicolon.join([file, line, text]))


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
    parser = argparse.ArgumentParser()
    parser.add_argument("--sort", default="file", choices=["none", "file", "line"], help="How to sort lines.")
    parser.add_argument("--explain", action="store_true", help="Print also score.")
    parser.add_argument("--dir", "-d", default=".", help="Default directory to search in.")
    parser.add_argument("--extensions", "-e", help="Comma separated list of extensions.")
    parser.add_argument("--input", default="auto", choices=["stdin", "recursive", "git", "auto"])
    parser.add_argument("--color", default="auto", choices=["always", "never", "auto"])
    parser.add_argument("what", nargs="*")
    args = parser.parse_args()
    if args.color == "auto":
        args.color = sys.stdout.isatty()
    else:
        if args.color not in ["always", "never"]:
            raise NotImplementedError(f"Color {args.color} not implemented")
        args.color = args.color == "always"
    return args


def get_what(args: argparse.Namespace) -> str:
    return " ".join(args.what)


def grep(color: bool, *args: str) -> Iterable[Line]:
    out = subprocess.run(
        ["grep", "--color={}".format("always" if color else "never")] + list(args),
        stdout=subprocess.PIPE,
        check=False,
    )
    for x in out.stdout.decode("utf8").strip("\n").split("\n"):
        if x:
            yield Line(f"{x}\n")


def git_ls_files(directory: str) -> Iterable[str]:
    out = subprocess.run(
        ["git", "ls-files"], cwd=directory, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    for x in out.stdout.decode("utf8").strip("\n").split("\n"):
        if x:
            yield f"{directory}/{x}"


def get_source(args: argparse.Namespace) -> Iterable[Line]:
    what = get_what(args)
    extensions = [f"--include=*.{ext}" for ext in args.extensions.split(",")]
    if args.input == "stdin":
        yield from safe_stdin()
    elif args.input == "auto":
        try:
            files = list(git_ls_files(args.dir))
            yield from grep(args.color, "-n", *extensions, what, *files)
        except subprocess.CalledProcessError:
            yield from grep(args.color, "-rn", *extensions, what, args.dir)
    elif args.input == "git":
        yield from grep(args.color, "-n", *extensions, what, *git_ls_files(args.dir))
    elif args.input == "recursive":
        yield from grep(args.color, "-rn", *extensions, what, args.dir)
    elif args.input == "extension":
        yield from grep(args.color, "-rn", *extensions, what, args.dir)
    else:
        raise NotImplementedError(f"Command {args.command} is not implemented")


def main() -> None:
    args = parse_args()
    what = get_what(args)
    scorings_exact = prepare_scorings(re.escape(what))
    scorings = prepare_scorings(re.escape(what.lower()))
    d, score = process_input(get_source(args), scorings, scorings_exact)
    print_sorted(d, score, sort_type=args.sort, explain=args.explain, color=args.color)


if __name__ == "__main__":
    main()
