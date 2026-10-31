  /* Challenge patches: every challenge gets a badge. Shape tells the slot (Family = shield, Iron = hexagon,
     Endure = round), the drawn icon tells what the challenge is, and the ribbon carries its number (50, 5K, 1:30).
     Gauntlet weeks get a gold double edge and a star. Icons are drawn on a 24 grid; "o" lines are outlines, "f" fills. */
  var CHB_G = {
    pushup:  'o:M2 20.5H22|o:M7.4 12.6 20.6 19|o:M7.6 12.9 7.2 20.3|f:c4.8,11.4,2',
    plank:   'o:M2 20.5H22|o:M7 12.8 20.6 19.4|o:M7.4 13 7.4 19.4H11.5|f:c4.6,11.6,2',
    pullup:  'o:M3 3.5H21|o:M8.2 3.5 10.4 10.2|o:M15.8 3.5 13.6 10.2|o:M12 10V16|o:M12 16 10.2 21.3M12 16 13.8 21.3|f:c12,7.6,1.9',
    hang:    'o:M3 3.5H21|o:M10.4 3.5V10|o:M13.6 3.5V10|o:M12 10.2V16.2|o:M12 16.2 11 21.5M12 16.2 13 21.5|f:c12,7.9,1.9',
    dip:     'o:M6.5 11V21.5M17.5 11V21.5|o:M12 7V13.4|o:M12 8 8.4 8.6 6.5 11M12 8 15.6 8.6 17.5 11|o:M12 13.4 10.2 17 12.2 19.2|f:c12,4.6,1.9',
    squat:   'o:M3 21H21|o:M10.6 7.6 7 13.6|o:M7 13.6H13.6L12.2 20.6|o:M10.4 8.8 17.4 9.2|f:c11.8,5.2,1.9',
    goblet:  'o:M3 21H21|o:M10.6 7.6 7 13.6|o:M7 13.6H13.6L12.2 20.6|o:M10.4 8.8 13.4 10.4|f:c15.2,10.8,2.3|o:M13.9 8.4Q15.2 6.9 16.5 8.4',
    lunge:   'o:M3 21H21|o:M12 6.2V12.6|o:M12 12.6 16.6 14.2 16.6 20.6|o:M12 12.6 8.6 19 5.2 19.6|o:M12 7.8 12.9 12.4|f:c12,4.2,1.9',
    pistol:  'o:M3 21H21|o:M9.6 8 7.8 13.8|o:M7.8 13.8H12.8L11.8 20.6|o:M7.8 13.8 20.4 12.6|o:M9.8 9.6H17.6|f:c9.4,5.9,1.9',
    stepup:  'o:M13 14.4H21.5V21H13Z|o:M2 21H13|o:M8.6 6.6V12.6|o:M8.6 12.6 13.6 11.8 15.2 14.4|o:M8.6 12.6 7.8 17 6.4 21|o:M8.6 8 10.6 11.4|f:c8.6,4.6,1.9',
    wallsit: 'o:M4.6 2.5V21.5|o:M4.6 21H20.5|o:M7.2 7.6V14H14V21|o:M7.2 9 11.6 11|f:c7.4,5.4,1.9',
    hinge:   'o:M3 21H21|o:M6.6 11 14 8.8|o:M6.6 11 8 16 7.4 20.8|o:M14 8.8 14.2 16|o:M8.8 16H19.4|o:M10 13.4V18.6M18.2 13.4V18.6|f:c16.2,8,1.9',
    press:   'o:M12 9.6V15.6|o:M12 15.6 10 21.2M12 15.6 14 21.2|o:M12 10.6 8.4 9 7.8 4.4M12 10.6 15.6 9 16.2 4.4|o:M3.6 4.4H20.4|o:M5 2.2V6.6M19 2.2V6.6|f:c12,7.5,1.9',
    row:     'o:M3 21H21|o:M6.6 11 14 8.8|o:M6.6 11 8 16 7.4 20.8|o:M14 8.8 11.4 8.4 12.4 12.6|o:M10.2 12.6H14.6|o:M10.4 11V14.2M14.4 11V14.2|f:c16.2,8,1.9',
    carry:   'o:M12 6V13.2|o:M12 13.2 9.6 20.8M12 13.2 14.4 20.8|o:M12 7.6 8.4 12.6M12 7.6 15.6 12.6|f:c8,15.4,2.2|f:c16,15.4,2.2|f:c12,4,1.9',
    legraise:'o:M2.5 20.5H21.5|o:M6.8 18.9 13 19.3|o:M13 19.3 19.4 10|o:M6.6 18.3 4 14|f:c4.6,17.6,1.9',
    hollow:  'o:M2.5 20.5H21.5|o:M7.6 14.8Q12 19.6 18.6 13.2|o:M6.8 13.8 2.8 11|f:c6,13.4,1.8',
    core:    'o:M8 4H16V20H8Z|o:M12 4V20|o:M8 9.4H16M8 14.6H16',
    burpee:  'o:M4 22H20|o:M12 7.6V14|o:M12 8.6 8 3.6M12 8.6 16 3.6|o:M12 14 9.4 18.6M12 14 14.6 18.6|f:c12,5.4,1.9',
    run:     'o:M13 6.6 11 13|o:M11 13 15 15.6 14 20.8|o:M11 13 8.4 16.6 4.6 16|o:M12.6 8.2 16 10.6 18 8.6|o:M12.6 8.2 9 9.6 7.6 12.4|f:c13.8,4.4,1.9',
    sprint:  'o:M14 6.6 12 13|o:M12 13 16 15.6 15 20.8|o:M12 13 9.4 16.6 5.6 16|o:M13.6 8.2 17 10.6 19 8.6|o:M13.6 8.2 10 9.6 8.6 12.4|f:c14.8,4.4,1.9|o:M1.6 7H5.4M1 11H4.6M2 15H4.6',
    hill:    'o:M2 20.5 9.6 8.4 13.4 14 16.4 10.4 22 20.5Z|o:M15.4 3.2H19.6V7.4|o:M19.6 3.2 13.6 9.2',
    stairs:  'o:M2.5 21H7V17H11V13H15V9H19V5H21.5|o:M4 12.4 9.6 6.8|o:M6.6 6.8H9.6V9.8',
    rope:    'o:M12 7.4V13.6|o:M12 13.6 10.4 18.6M12 13.6 13.6 18.6|o:M12 8.6 8 11.6M12 8.6 16 11.6|o:M8 11.6C4.6 18 7 22.6 12 22.4 17 22.6 19.4 18 16 11.6|f:c12,5.4,1.9',
    ruck:    'o:M6.8 8.2Q6.8 5 12 5 17.2 5 17.2 8.2V20.6H6.8Z|o:M6.8 11.4H17.2|o:M9.6 14H14.4V18H9.6Z|o:M10 5V3.4H14V5',
    shuttle: 'o:M3 8.6H19|o:M16 5.6 19 8.6 16 11.6|o:M21 15.4H5|o:M8 12.4 5 15.4 8 18.4',
    watch:   'o:M12 13.6m-7.4 0a7.4 7.4 0 1 0 14.8 0a7.4 7.4 0 1 0-14.8 0|o:M12 13.6 12 9.2|o:M12 13.6 15 15.4|o:M9.6 3.4H14.4|o:M12 3.4V6.2|o:M18 7.2 19.6 5.6',
    pack:    'f:c6,8.2,2.1|f:c12,6,2.1|f:c18,8.2,2.1|o:M2.4 17.4Q6 11 9.6 17.4|o:M8.4 15.4Q12 9 15.6 15.4|o:M14.4 17.4Q18 11 21.6 17.4',
    flag:    'o:M5 21.5V2.8|o:M5 4H19.4L16.2 8L19.4 12H5',
    pulse:   'o:M12 20C4.4 14.2 3 9.2 5.8 6.6 8.2 4.6 10.8 5.4 12 7.6 13.2 5.4 15.8 4.6 18.2 6.6 21 9.2 19.6 14.2 12 20Z|o:M5.6 12.4H9L10.4 9.6 12.4 15 13.8 12.4H18.6',
    road:    'o:M7.6 21.5 11 2.5|o:M16.4 21.5 13 2.5|o:M12 17.6V20M12 11.6V14M12 6.6V8.4',
    bolt:    'o:M13.4 2.2 5.4 13H11.2L10.2 21.8 18.6 10.6H12.8Z',
    clock11: 'o:M12 12m-8.6 0a8.6 8.6 0 1 0 17.2 0a8.6 8.6 0 1 0-17.2 0|o:M12 12 12 6|o:M12 12 10.4 7.6',
    pray:    'o:M12 3.4Q9 7.6 9 12.6L7 17|o:M12 3.4Q15 7.6 15 12.6L17 17|o:M12 3.6V15.4|o:M5.6 16.4 9.4 20.8M18.4 16.4 14.6 20.8',
    table:   'o:M3 11.4H21|o:M6 11.4V20.6M18 11.4V20.6|o:M10.8 4.6H13.2V11.4H10.8Z|f:M12 1.4Q13.4 2.9 12 4.2 10.6 2.9 12 1.4Z',
    heart:   'o:M12 20C4.4 14.2 3 9.2 5.8 6.6 8.2 4.6 10.8 5.4 12 7.6 13.2 5.4 15.8 4.6 18.2 6.6 21 9.2 19.6 14.2 12 20Z',
    mend:    'o:M12 20C4.4 14.2 3 9.2 5.8 6.6 8.2 4.6 10.8 5.4 12 7.6 13.2 5.4 15.8 4.6 18.2 6.6 21 9.2 19.6 14.2 12 20Z|o:M12 7.6 10.4 11.2 13.2 13.2 11.6 16.6',
    speech:  'o:M3.6 4.6H20.4V15H11L7 19.2V15H3.6Z|o:M7.6 8.6H16.4M7.6 11.6H13.6',
    letter:  'o:M6 2.8H15L19 6.8V21.2H6Z|o:M15 2.8V6.8H19|o:M8.8 10.8H16.2M8.8 14.2H16.2M8.8 17.6H13',
    book:    'o:M12 6C9.6 4.4 6 4.4 3 5.4V19C6 18 9.6 18 12 19.6 14.4 18 18 18 21 19V5.4C18 4.4 14.4 4.4 12 6Z|o:M12 6V19.6',
    bookheart:'o:M12 6C9.6 4.4 6 4.4 3 5.4V19C6 18 9.6 18 12 19.6 14.4 18 18 18 21 19V5.4C18 4.4 14.4 4.4 12 6Z|o:M12 6V19.6|f:M7.6 13.4C5.6 11.8 5.6 9.8 7 9.4 7.6 9.2 8.2 9.6 8.4 10.2 8.6 9.6 9.2 9.2 9.8 9.4 11.2 9.8 11 11.8 8.4 13.8Z',
    house:   'o:M3 11.2 12 3.6 21 11.2|o:M5.6 9.4V20.6H18.4V9.4|o:M10 20.6V14.6H14V20.6',
    housepray:'o:M3 11.2 12 3.6 21 11.2|o:M5.6 9.4V20.6H18.4V9.4|o:M12 10.4Q10.2 12.6 10.2 15.4L9.4 17.6|o:M12 10.4Q13.8 12.6 13.8 15.4L14.6 17.6|o:M12 10.6V17',
    shield:  'o:M12 3 19.4 5.8V11.4C19.4 16 16.4 19.4 12 21 7.6 19.4 4.6 16 4.6 11.4V5.8Z|o:M8.6 12 11 14.4 15.6 9.6',
    line:    'o:M12 3 19.4 5.8V11.4C19.4 16 16.4 19.4 12 21 7.6 19.4 4.6 16 4.6 11.4V5.8Z|o:M7.4 12H16.6',
    eye:     'o:M2.6 12Q12 3.6 21.4 12 12 20.4 2.6 12Z|f:c12,12,3',
    calendar:'o:M4 5.8H20V20.6H4Z|o:M4 10H20|o:M8.4 3.4V7.4M15.6 3.4V7.4|o:M8.8 15.2 11 17.2 15.2 13.2',
    caldate: 'o:M4 5.8H20V20.6H4Z|o:M4 10H20|o:M8.4 3.4V7.4M15.6 3.4V7.4|f:M12 18.4C9.4 16.4 9.2 14.6 10.2 13.8 10.9 13.3 11.6 13.6 12 14.2 12.4 13.6 13.1 13.3 13.8 13.8 14.8 14.6 14.6 16.4 12 18.4Z',
    phone:   'o:M7 3.6H9.8L11.4 7.6 9.4 9C10.4 11.6 12.4 13.6 15 14.6L16.4 12.6 20.4 14.2V17C20.4 18.6 19 20 17.4 19.8 9.8 19 4.6 13.8 4 6.2 4 4.8 5.4 3.6 7 3.6Z',
    swords:  'o:M4.4 4.4 15.8 15.8|o:M14 18 18 14|o:M17 17 20.2 20.2|o:M19.6 4.4 8.2 15.8|o:M6 14 10 18|o:M7 17 3.8 20.2',
    gap:     'o:M3 20.5H8.6V9.6|o:M21 20.5H15.4V9.6|o:M8.6 9.6H15.4|f:c12,5.6,1.9|o:M12 7.6V9.6',
    hammer:  'o:M10.6 9.6 19.6 19.8|o:M5 7 9 3 14 8 10 12Z',
    tools:   'o:M10.6 9.6 19.6 19.8|o:M5 7 9 3 14 8 10 12Z|o:M4.4 19.6 9.6 14.4|o:M3.4 16.6 6.4 19.6',
    hands:   'o:M3 13.6 7.6 9.4 11.4 11.4|o:M21 13.6 16.4 9.4 12.6 11.4|o:M7.6 9.4 12 13.4 16.4 9.4|o:M5.4 16 9.6 19.4M8.4 14.6 12.2 18M11.6 13.6 14.6 16.4',
    sunrise: 'o:M2.6 18H21.4|o:M6.4 18A5.6 5.6 0 0 1 17.6 18|o:M12 6V8.6|o:M5.4 10.2 7.2 11.8|o:M18.6 10.2 16.8 11.8|o:M7 21H17',
    hourglass:'o:M7 3H17M7 21H17|o:M8 3V5.6C8 9 12 10 12 12 12 14 8 15 8 18.4V21|o:M16 3V5.6C16 9 12 10 12 12 12 14 16 15 16 18.4V21|f:M9.6 20.6H14.4L12 17.4Z',
    gift:    'o:M4.6 10H19.4V20.6H4.6Z|o:M3.6 7H20.4V10H3.6Z|o:M12 7V20.6|o:M12 7C9.2 2.6 6 5 8.6 7M12 7C14.8 2.6 18 5 15.4 7',
    door:    'o:M10.2 3.6H4.8V20.4H10.2|o:M8.8 12H20.4|o:M16.6 8 20.4 12 16.6 16',
    torch:   'o:M10.4 11H13.6L12.8 21.2H11.2Z|f:M12 2.4C15.2 5.4 15.6 8 14 10.2H10C8.4 8 8.8 5.4 12 2.4Z',
    question:'o:M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0-18 0|o:M9.2 9.4C9.2 7.2 10.6 6.2 12 6.2 13.8 6.2 15 7.4 15 9 15 11 12 11.4 12 13.8|f:c12,17.2,1.1',
    two:     'f:c8,7,2.3|f:c16,7,2.3|o:M3.4 19.4Q8 10.6 12.6 19.4|o:M11.4 19.4Q16 10.6 20.6 19.4',
    church:  'o:M12 2.4V7M10 4.4H14|o:M7 21V12.2L12 7.6 17 12.2V21Z|o:M10.6 21V16.6H13.4V21|o:M3 21H21',
    rings:   'o:M9.4 13.4m-5 0a5 5 0 1 0 10 0a5 5 0 1 0-10 0|o:M14.6 13.4m-5 0a5 5 0 1 0 10 0a5 5 0 1 0-10 0|o:M9.4 8.4 8 6.4 9.4 4.6 10.8 6.4Z',
    lantern: 'o:M8.8 6.4H15.2L16.2 18H7.8Z|o:M10 6.4V4.6Q12 2 14 4.6V6.4|f:M12 9.8C13.4 11.4 13.4 13.6 12 14.6 10.6 13.6 10.6 11.4 12 9.8Z|o:M6.8 18H17.2V20.4H6.8Z',
    steps:   'f:M7.4 3.6C9.2 3.6 10.2 5.6 10.2 8 10.2 10.4 9.2 12.2 7.4 12.2 5.6 12.2 4.6 10.4 4.6 8 4.6 5.6 5.6 3.6 7.4 3.6Z|f:c7.4,14.8,1.8|f:M16.6 9.6C18.4 9.6 19.4 11.6 19.4 14 19.4 16.4 18.4 18.2 16.6 18.2 14.8 18.2 13.8 16.4 13.8 14 13.8 11.6 14.8 9.6 16.6 9.6Z|f:c16.6,20.8,1.8',
    sun:     'o:M12 12m-4 0a4 4 0 1 0 8 0a4 4 0 1 0-8 0|o:M12 2.6V5M12 19V21.4M2.6 12H5M19 12H21.4M5.4 5.4 7 7M17 17 18.6 18.6M5.4 18.6 7 17M17 7 18.6 5.4',
    compass: 'o:M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0-18 0|o:M15.6 8.4 13.4 13.4 8.4 15.6 10.6 10.6Z',
    star:    'o:M12 2.8 14.7 8.6 21 9.3 16.3 13.6 17.6 19.8 12 16.6 6.4 19.8 7.7 13.6 3 9.3 9.3 8.6Z'
  };
  var CHB_FAMILY = {
    "watch and pray": "lantern", "pray by name": "pray", "honor a veteran": "flag", "words for her": "letter", "the family table": "table",
    "one-on-one": "two", "read it aloud": "book", "guard the home": "house", "call a man you respect": "phone", "pray for their future": "compass",
    "ready for worship": "church", "make it right": "mend", "family watch night": "lantern", "family mission": "compass", "where do you need me": "hands",
    "seven days of prayer": "pray", "hide it in the heart": "bookheart", "draw the line": "line", "serve together": "hands", "fast with purpose": "hourglass",
    "lead the date": "caldate", "pass it on": "tools", "gratitude round": "sun", "stand in the gap": "gap", "hard questions": "question",
    "covenant night": "rings", "lead at the table": "table", "take the initiative": "hammer", "man the calendar": "calendar", "speak a blessing": "speech",
    "open books": "book", "remember the fallen": "flag", "integrity check": "eye", "iron sharpens iron": "swords", "family workday": "hammer",
    "tell your story": "speech", "honor your parents": "heart", "face the fear": "shield", "service day": "hands", "love their way": "heart",
    "speak life": "speech", "first light": "sunrise", "go and invite": "door", "prayer walk": "steps", "heritage night": "torch",
    "written blessing": "letter", "true sabbath": "calendar", "pray the house": "housepray", "honor her publicly": "heart", "quiet giving": "gift",
    "remember answered prayer": "pray", "commissioned": "torch"
  };
  var CHB_MOVES = [
    [/murph|ruck for a vet/i, "flag"], [/eleven-eleven/i, "clock11"], [/remember reps/i, "flag"], [/forged test|iron 50s|triple 50|warrior 250/i, "star"],
    [/move 5000|hinge/i, "hinge"], [/push-up|foundation/i, "pushup"], [/chin-up|pull-up/i, "pullup"], [/dead hang/i, "hang"], [/dip/i, "dip"],
    [/goblet|loaded squat/i, "goblet"], [/single-leg/i, "pistol"], [/split squat|lunge/i, "lunge"], [/step-up/i, "stepup"], [/wall sit/i, "wallsit"],
    [/squat/i, "squat"], [/press/i, "press"], [/row/i, "row"], [/carry/i, "carry"], [/leg raise/i, "legraise"], [/hollow/i, "hollow"],
    [/core/i, "core"], [/plank/i, "plank"], [/burpee/i, "burpee"], [/sprint/i, "sprint"], [/hill/i, "hill"], [/stair/i, "stairs"],
    [/jump rope/i, "rope"], [/ruck/i, "ruck"], [/shuttle/i, "shuttle"], [/amrap|tabata|minute distance/i, "watch"], [/pack run/i, "pack"],
    [/cardio/i, "pulse"], [/long haul/i, "road"], [/mile|5k|10k|run/i, "run"]
  ];
  var CHB_WORDS = { one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9, ten: 10 };
  function chbGlyph(c) {
    var nm = String(c.name || "").replace(/^Gauntlet:\s*/i, "").toLowerCase();
    if (c.slot === "family") return CHB_FAMILY[nm] || "heart";
    for (var i = 0; i < CHB_MOVES.length; i++) if (CHB_MOVES[i][0].test(nm)) return CHB_MOVES[i][1];
    return c.slot === "endure" ? "run" : "bolt";
  }
  function chbTag(c) {
    var nm = String(c.name || "").replace(/^Gauntlet:\s*/i, ""), m;
    if (/eleven-eleven/i.test(nm)) return "11:11";
    if (/murph/i.test(nm)) return "MURPH";
    if ((m = /(\d+)\s*x\s*(\d+)/i.exec(nm))) return m[1] + "×" + m[2];
    if ((m = /(\d+:\d{2})/.exec(nm))) return m[1];
    if ((m = /\b(\d+)K\b/i.exec(nm))) return m[1] + "K";
    if ((m = /(\d+)-Min/i.exec(nm))) return m[1] + " MIN";
    if ((m = /\b(one|two|three|four|five|six|seven)-mile/i.exec(nm))) return CHB_WORDS[m[1].toLowerCase()] + " MI";
    if (/\bmile\b/i.test(nm)) return "1 MI";
    if ((m = /(\d+)/.exec(nm))) return m[1];
    var u = { sec: "SEC", min: "MIN", mi: "MI", reps: "REPS", days: "DAYS", meals: "MEALS", nights: "NIGHTS", people: "MEN", yd: "YD", lb: "LB", flights: "FLIGHTS" }[c.unit];
    if (u && Number(c.target) > 1) return c.target + " " + u;
    return "";
  }
  var CHB_FRAME = {
    family: "M32 3 56 11V30C56 45 46 55 32 61 18 55 8 45 8 30V11Z",
    iron: "M32 3 57 17.5V46.5L32 61 7 46.5V17.5Z",
    endure: "M32 4a28 28 0 1 0 0.01 0Z"
  };
  function chbInner(slot) { return slot === "family" ? "M32 8 51.5 14.6V30.4C51.5 42.6 43.4 50.8 32 55.8 20.6 50.8 12.5 42.6 12.5 30.4V14.6Z" : slot === "iron" ? "M32 8.2 52.5 20.1V43.9L32 55.8 11.5 43.9V20.1Z" : "M32 9a23 23 0 1 0 0.01 0Z"; }
  function chbGlyphSvg(key) {
    return (CHB_G[key] || CHB_G.bolt).split("|").map(function (p) {
      var kind = p.slice(0, 1), d = p.slice(2), m = /^c([\d.]+),([\d.]+),([\d.]+)$/.exec(d);
      if (m) return '<circle cx="' + m[1] + '" cy="' + m[2] + '" r="' + m[3] + '" class="chb-f"/>';
      return '<path d="' + d + '" class="' + (kind === "f" ? "chb-f" : "chb-o") + '"/>';
    }).join("");
  }
  function chalBadgeSvg(c, gaunt) {
    var slot = c.slot === "family" || c.slot === "endure" ? c.slot : "iron", tag = chbTag(c), gy = tag ? 8.6 : 15.4;
    var s = '<svg class="chb chb-' + slot + (gaunt ? " chb-gaunt" : "") + '" viewBox="0 0 64 64" aria-hidden="true">';
    if (gaunt) s += '<path d="' + CHB_FRAME[slot] + '" class="chb-gold" transform="translate(32 32) scale(1.06) translate(-32 -32)"/>';
    s += '<path d="' + CHB_FRAME[slot] + '" class="chb-fr"/><path d="' + chbInner(slot) + '" class="chb-st"/>';
    s += '<g transform="translate(17.6 ' + gy + ') scale(1.2)">' + chbGlyphSvg(chbGlyph(c)) + '</g>';
    if (tag) {
      var fs = tag.length > 6 ? 7 : tag.length > 4 ? 8 : 9.5, w = Math.min(44, 12 + tag.length * fs * 0.62);
      s += '<rect x="' + (32 - w / 2) + '" y="42.5" width="' + w + '" height="12" rx="2" class="chb-rib"/><text x="32" y="51.6" text-anchor="middle" class="chb-tx" font-size="' + fs + '">' + tag.replace(/&/g, "&amp;") + '</text>';
    }
    if (gaunt) s += '<path d="M32 -1.4 33.6 2 37.2 2.4 34.5 4.8 35.3 8.4 32 6.6 28.7 8.4 29.5 4.8 26.8 2.4 30.4 2Z" class="chb-star" transform="translate(0 1)"/>';
    return s + "</svg>";
  }
