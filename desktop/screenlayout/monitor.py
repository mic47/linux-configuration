from __future__ import annotations

import dataclasses as dc
import re
import sys
import typing as t
import subprocess

@dc.dataclass
class Monitor:
    output: str
    connected: bool
    edid: t.Optional[str]

class Nested:
    def __init__(self, payload: t.Union[str, t.List[Nested]]) -> None:
        self.p = payload

T = t.TypeVar('T')
def maybe_next(inp: t.Iterator[T]) -> t.Optional[T]:
    try:
        return next(inp)
    except StopIteration:
        return None

def parse(lines: t.Iterator[str]) -> t.Iterable[Monitor]:
    line = None
    monitor = None
    edid = None
    connected = False
    def reset():
        nonlocal monitor
        nonlocal edid
        nonlocal connected
        monitor = None
        edid = None
        connected = False
    reset()
    try:
        while True:
            #print("INPUT", line)
            #print("STATE", monitor, edid[:10] if edid is not None else None, len(edid) if edid is not None else None)
            if line is None:
                line = maybe_next(lines)
            if line is None:
                return
            m = MONITOR.match(line)
            if m is None:
                line = None
                continue
            g = m.groupdict()
            if monitor is not None:
                yield Monitor(monitor, connected, edid)
                reset()
            monitor = g["monitor"]
            connection = g["connection"]
            if connection != "connected":
                connected = False
                yield Monitor(monitor, connected, None)
                line = None
                reset()
                continue
            connected = True
            line = None
            while True:
                if line is None:
                    line = maybe_next(lines)
                if line is None:
                    return;
                if SPACE.match(line) is None:
                    break
                m = EDID.match(line)
                if m is None:
                    line = None
                    continue
                g = m.groupdict()
                space = g["space"]
                edids = []
                try:
                    while True:
                        line = maybe_next(lines)
                        if line is None:
                            return
                        if line.startswith(space) and SPACE.match(line[len(space)]) is not None:
                            edids.append(line.strip())
                        else:
                            line = None
                            break
                    break
                finally:
                    edid = "".join(edids)
    finally:
        if monitor is not None:
            yield Monitor(monitor, edid is not None, edid)
            reset()


MONITOR = re.compile(r"(?P<monitor>\S*)\s(?P<connection>(connected|disconnected))\s")
EDID = re.compile(r"(?P<space>\s\s*)EDID:\s*$")
SPACE = re.compile(r"\s")

def main():
    for out in parse(sys.stdin):
        print(out)



if __name__ == "__main__":
    main()

