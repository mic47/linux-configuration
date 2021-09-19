# -*- coding: utf-8 -*-

"""Call platypus lol."""

try:
    from albertv0 import *
except ImportError:
    pass
from math import *
from builtins import pow
import http.client
from urllib.parse import quote
import json
import copy
try:
    import numpy as np
except ImportError:
    pass
import os

__iid__ = "PythonInterface/v0.1"
__prettyname__ = "PlatypusLol"
__version__ = "1.0"
__trigger__ = "pls "
__author__ = "Michal Nanasi"
__dependencies__ = []

iconPath = os.path.dirname(__file__)+"/platypus.png"

def getSuggest(query):
    c = http.client.HTTPConnection("localhost:3047")
    c.request("GET", "/suggest?q=" + quote(query))
    r = c.getresponse()
    ret = json.loads((r.read()))
    return ret

def getRedirect(query):
    if query.strip() == '': return []
    c = http.client.HTTPConnection("localhost:3047")
    c.request("GET", "/redirect?q=" + quote(query))
    r = c.getresponse()
    loc = r.headers.get('Location')
    print(r.headers.items())
    if loc is None:
        return []
    return [(query, loc)]

def debug(x):
    with open("/home/mic/pldeb", "a") as f:
        f.write(str(x))
        f.write("\n")

def mkLink(x):
    x = x.replace("<", "").replace(">", "")
    return (x, "http://localhost:3047/redirect?q=" + quote(x))

def deduplicate(x):
    ret = []
    prev = None
    for y in x:
        if y != prev:
            ret.append(y)
        prev = y
    return ret


def handleQuery(query):
    ret = None
    if query.isTriggered:
        ret = []
        stripped = query.string
        suggestions = getSuggest(stripped)
        hits = getRedirect(stripped)
        if len(suggestions) >= 2:
            suggestions = suggestions[1]
        else:
            suggestions = []
        suggestions = list(map(mkLink, suggestions))
        for (suggestion, link) in deduplicate(suggestions + hits):
            it = Item(id=__prettyname__, icon=iconPath, completion=query.rawString)
            it.text = suggestion
            it.subtext = "Do query in browser"
            it.addAction(UrlAction("Open in web browser", link))
            ret.append(it)
    return ret
