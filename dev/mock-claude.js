/* Local-only stand-in for the claude.ai runtime (window.claude). In-memory: data resets on reload. Set window.MOCK_LATENCY_MS before load to delay writes and snapshot echoes (to test stale updates).
   Provides just what index.html calls: db, user, assets. Uploaded media will not display (no /_blob/ server). */
(function () {
  var docs = {}, subs = [], n = 0, ME = "u_dev_local";
  function seed(coll, obj) { Object.keys(obj).forEach(function (k) { docs[coll + "/" + k] = obj[k]; }); }
  seed("tasks", {
    t_devo: { title: "Daily Devotional", sub: "", points: 2, kind: "devo", mandatory: true, createdAt: 1 },
    t_motto: { title: "Morning Motto", sub: "Say it today", points: 1, kind: "check", createdAt: 2 },
    t_weigh: { title: "Weigh-In", sub: "Weigh in today", points: 1, kind: "weigh", createdAt: 3 },
    t_photos: { title: "Progress Photos", sub: "Front, side and rear", points: 1, kind: "photos", createdAt: 3.5 },
    t_comms: { title: "Daily Check-In", sub: "Post in the thread today", points: 1, kind: "checkin", createdAt: 4 },
    t_workout: { title: "Workout", sub: "", points: 3, kind: "workout", createdAt: 5 },
    t_water: { title: "Drink 3 Liters of Water", sub: "3 L today", points: 1, kind: "water", createdAt: 6 },
    t_cal: { title: "Calories", sub: "", points: 1, kind: "calories", createdAt: 7 },
    t_steps: { title: "Steps", sub: "10,000 steps", points: 1, kind: "steps", createdAt: 8 }
  });
  seed("lifts", { l_squat: { name: "Back Squat", order: 1 }, l_bench: { name: "Bench Press", order: 2 }, l_dead: { name: "Deadlift", order: 3 }, l_ohp: { name: "Overhead Press", order: 4 } });
  function notify() { subs.slice().forEach(function (s) { s(); }); }
  function snap(id, data) { return { id: id, exists: data !== undefined, data: function () { if (data === undefined) return undefined; var c = JSON.parse(JSON.stringify(data)); if (window.MOCK_FREEZE) { (function f(o) { if (o && typeof o === "object") { Object.keys(o).forEach(function (k) { f(o[k]); }); Object.freeze(o); } })(c); } return c; } }; }
  function cmp(a, op, b) { return op === "==" ? a === b : op === "!=" ? a !== b : op === ">=" ? a >= b : op === "<=" ? a <= b : op === ">" ? a > b : op === "<" ? a < b : false; }
  function Query(path, wh, ord, lim) {
    var q = {
      where: function (f, op, v) { return Query(path, wh.concat([[f, op, v]]), ord, lim); },
      orderBy: function (f, d) { return Query(path, wh, [f, d || "asc"], lim); },
      limit: function (k) { return Query(path, wh, ord, k); },
      doc: function (id) { return Doc(path + "/" + id); },
      get: function () { return Promise.resolve(run()); },
      onSnapshot: function (cb) { var f = function () { cb(run()); }; subs.push(f); setTimeout(f, 0); return function () { subs = subs.filter(function (x) { return x !== f; }); }; },
      add: function (data) { var id = "d" + Date.now() + "_" + (n++); docs[path + "/" + id] = JSON.parse(JSON.stringify(data)); notify(); return Promise.resolve(Doc(path + "/" + id)); }
    };
    function run() {
      var out = Object.keys(docs).filter(function (k) { return k.indexOf(path + "/") === 0 && k.slice(path.length + 1).indexOf("/") < 0; })
        .map(function (k) { return { id: k.slice(path.length + 1), d: docs[k] }; })
        .filter(function (r) { return wh.every(function (w) { return cmp(r.d[w[0]], w[1], w[2]); }); });
      if (ord) out.sort(function (a, b) { var x = a.d[ord[0]], y = b.d[ord[0]]; return (x < y ? -1 : x > y ? 1 : 0) * (ord[1] === "desc" ? -1 : 1); });
      if (lim) out = out.slice(0, lim);
      return { docs: out.map(function (r) { return snap(r.id, r.d); }) };
    }
    return q;
  }
  function Doc(path) {
    var id = path.split("/").pop();
    return {
      id: id,
      get: function () { return Promise.resolve(snap(id, docs[path])); },
      set: function (data) { var c = JSON.parse(JSON.stringify(data)), L = window.MOCK_LATENCY_MS || 0; if (!L) { docs[path] = c; notify(); return Promise.resolve(); } return new Promise(function (res) { setTimeout(function () { docs[path] = c; notify(); res(); }, L); }); },
      delete: function () { delete docs[path]; notify(); return Promise.resolve(); },
      onSnapshot: function (cb) { var f = function () { cb(snap(id, docs[path])); }; subs.push(f); setTimeout(f, 0); return function () { subs = subs.filter(function (x) { return x !== f; }); }; },
      collection: function (name) { return Query(path + "/" + name, [], null, 0); }
    };
  }
  var db = { collection: function (p) { return Query(p, [], null, 0); }, doc: Doc };
  var user = {
    id: function () { return Promise.resolve(ME); }, me: function () { return Promise.resolve({ id: ME }); },
    isOwner: function () { return true; }, canEdit: function () { return true; }, can: function () { return Promise.resolve(true); },
    profiles: function (ids) { var o = {}; ids.forEach(function (i) { o[i] = { name: i === ME ? "Dev User" : "Brother " + i.slice(-3), avatarUrl: "", guest: false }; }); return Promise.resolve(o); },
    search: function () { return Promise.resolve([]); }
  };
  var assets = { upload: function (f) { var id = "blob" + (n++); (window.__uploads = window.__uploads || []).push({ size: f.size, type: f.type, name: f.name }); return Promise.resolve({ id: id, url: URL.createObjectURL(f), sizeBytes: f.size, contentType: f.type }); }, delete: function () { return Promise.resolve(); } };
  var sample = { limits: function () { return Promise.resolve({ maxBytes: 262144, images: { maxCount: 4, maxBytes: 20000000, mediaTypes: ["image/jpeg", "image/png", "image/webp", "image/gif"] } }); }, json: function (q) { return new Promise(function (res, rej) { setTimeout(function () { if (/FAIL/.test(q)) rej({ code: "rate_limited" }); else if (/meal prep:/.test(q)) res({ name: "Chicken, rice and broccoli", l: "1 container", kcal: 545, p: 46, f: 13.5, c: 58, note: "About 6 oz grilled chicken, 1 cup white rice and 1 cup broccoli." }); else if (/food search/.test(q)) res({ results: [{ name: "Egg, whole, large", d: "Generic", s: [{ l: "1 large egg (50 g)", kcal: 72, p: 6.3, f: 4.8, c: 0.4 }, { l: "100 g", kcal: 143, p: 12.6, f: 9.5, c: 0.7 }] }, { name: "Scrambled eggs", d: "Cooked with butter", s: [{ l: "1 egg", kcal: 91, p: 6.1, f: 6.7, c: 1 }] }, { name: "Egg whites", d: "Liquid", s: [{ l: "3 tbsp (46 g)", kcal: 25, p: 5, f: 0, c: 0 }] }] }); else res({ name: "2 eggs and toast", kcal: "310", p: 19, f: 14, c: 26 }); }, 150); }); } };
  window.claude = { use: function (name) { return Promise.resolve(name === "db" ? db : name === "user" ? user : name === "assets" ? assets : name === "sample" ? sample : null); } };
})();
