#!/usr/bin/env python3
"""Campaign page gets the search (Ask) and info (i) buttons like the other tabs (Curtis 2026-11-04).
Adds HELP.camp (which adds both buttons), Ask answers for campaigns, and lets Ask jump to Campaign and My journal.
Usage: patch_camphelp.py <in> <out> <version>"""
import sys, re
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)
rep('''    journal: { t: "My journal", why:''', '''    camp: { t: "Campaign", why: "Team battles. A band of brothers marches together for " + CAMP_WEEKS + " weeks and holds each other to the mission.", tip: "Standings and campaign points live on the Board. Tap Campaign there to see them.", how: [
      "A brother raises a banner and invites " + (CAMP_MIN - 1) + " to " + (CAMP_MAX - 1) + " men. Teams are " + CAMP_MIN + " to " + CAMP_MAX + " men.",
      "Raise a banner to be a captain, or answer a captain\\u2019s invite here.",
      CAMP_WEEKS + " weeks, Monday to Sunday. Rosters lock on the first day.",
      "Team score is the average Kingdom Warrior points per man each week. A brother who sits out a week doesn\\u2019t count against his team.",
      "One box counts double each week for every man in the battle.",
      "Wall Held: every man checks every box all 7 days and the team earns +" + WALL_BONUS + ".",
      "My team opens your roster and team chat.",
      "When no campaign is running, this page shows when the next one starts."] },
    journal: { t: "My journal", why:''')
rep('''var PG = { today: "today", fuel: "fuel", train: "train", workout: "train", board: "board", checkin: "checkin", settings: "settings", profile: "profile" }''',
    '''var PG = { today: "today", fuel: "fuel", train: "train", workout: "train", board: "board", checkin: "checkin", settings: "settings", profile: "profile", camp: "camp", journal: "journal" }''')
rep('''{"t": "Write in my journal",''', '''{"t": "Campaign", "a": "Team battles of 6 to 8 men for 6 weeks. Raise a banner to be a captain, or answer a captain\\u2019s invite. Your team, Wall Held and team chat live on the Campaign tab. Standings are on the Board.", "w": "Campaign tab \\u00B7 Board \\u203A Campaign", "k": "campaign team battle banner captain invite wall held double points squad", "go": {"p": "camp"}}, {"t": "Write in my journal",''')
s = re.sub(r'var APP_VERSION = "[^"]*"', 'var APP_VERSION = "' + ver + '"', s, count=1)
open(dst, 'w').write(s); print("ok", dst)
