#!/usr/bin/env python3
"""c91: simpler devotional Act lines. Usage: patch-devoacts.py acts.json in.html out.html
acts.json = {"MM-DD": "new act"}. Rule: one simple step a man can do today in a minute or two; actions with a brother
are a word, a text or a prayer; no appointments, purchases, scripts or deadlines. Only DEVOS.days[*].act changes."""
import json, sys
acts = json.load(open(sys.argv[1], encoding="utf-8"))
s = open(sys.argv[2], encoding="utf-8").read()
tag = "var DEVOS = "
assert s.count(tag) == 1
i = s.index(tag) + len(tag)
d, n = json.JSONDecoder().raw_decode(s[i:])
for k, v in acts.items():
    assert k in d["days"], k
    d["days"][k]["act"] = v
out = json.dumps(d, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
open(sys.argv[3], "w", encoding="utf-8").write(s[:i] + out + s[i + n:])
print("acts changed:", len(acts))
