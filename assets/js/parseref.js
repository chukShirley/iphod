// parseref.js
// for converting of biblical references to database keys
"use strict";
var bookName = 
  { "1 chronicles": "CH1",  "1 chron": "CH1", "1 ch": "CH1", "i ch": "CH1", "1ch": "CH1", "1 chr": "CH1", "i chr": "CH1", "1chr": "CH1", "i chron": "CH1", "1chron": "CH1", "i chronicles": "CH1", "1chronicles": "CH1", "1st chronicles": "CH1", "first chronicles": "CH1",
    "1 corinthians": "CO1", "1 cor": "CO1", "1 co": "CO1", "i co": "CO1", "1co": "CO1", "i cor": "CO1", "1cor": "CO1", "i corinthians": "CO1", "1corinthians": "CO1", "1st corinthians": "CO1", "first corinthians": "CO1",
    "1 esdras": "ES1",  "1 esdr": "ES1", "1 esd": "ES1", "i es": "ES1", "1es": "ES1", "i esd": "ES1", "1esd": "ES1", "i esdr": "ES1", "1esdr": "ES1", "i esdras": "ES1", "1esdras": "ES1", "1st esdras": "ES1", "first esdras": "ES1",
    "1 john": "JN1",  "1 jn": "JN1", "i jn": "JN1", "1jn": "JN1", "i jo": "JN1", "1jo": "JN1", "i joh": "JN1", "1joh": "JN1", "i jhn": "JN1", "1 jhn": "JN1", "1jhn": "JN1", "i john": "JN1", "1john": "JN1", "1st john": "JN1", "first john": "JN1",
    "1 kings": "KI1", "1 kgs": "KI1", "1 ki": "KI1", "1k": "KI1", "i kgs": "KI1", "1kgs": "KI1", "i ki": "KI1", "1ki": "KI1", "i kings": "KI1", "1kings": "KI1", "1st kgs": "KI1", "1st kings": "KI1", "first kings": "KI1", "first kgs": "KI1", "1kin": "KI1",
    "1 maccabees": "MA1", "1 macc": "MA1", "1 mac": "MA1", "1m": "MA1", "i ma": "MA1", "1ma": "MA1", "i mac": "MA1", "1mac": "MA1", "i macc": "MA1", "1macc": "MA1", "i maccabees": "MA1", "1maccabees": "MA1", "1st maccabees": "MA1", "first maccabees": "MA1",
    "1 peter": "PE1", "1 pet": "PE1", "1 pe": "PE1", "i pe": "PE1", "1pe": "PE1", "i pet": "PE1", "1pet": "PE1", "i pt": "PE1", "1 pt": "PE1", "1pt": "PE1", "i peter": "PE1", "1peter": "PE1", "1st peter": "PE1", "first peter": "PE1",
    "1 samuel": "SA1",  "1 sam": "SA1", "1 sa": "SA1", "1samuel": "SA1", "1s": "SA1", "i sa": "SA1", "1 sm": "SA1", "1sa": "SA1", "i sam": "SA1", "1sam": "SA1", "i samuel": "SA1", "1st samuel": "SA1", "first samuel": "SA1",
    "1 thessalonians": "TH1", "1 thess": "TH1", "1 th": "TH1", "i th": "TH1", "1th": "TH1", "i thes": "TH1", "1thes": "TH1", "i thess": "TH1", "1thess": "TH1", "i thessalonians": "TH1", "1thessalonians": "TH1", "1st thessalonians": "TH1", "first thessalonians": "TH1",
    "1 timothy": "TI1", "1 tim": "TI1", "1 ti": "TI1", "i ti": "TI1", "1ti": "TI1", "i tim": "TI1", "1tim": "TI1", "i timothy": "TI1", "1timothy": "TI1", "1st timothy": "TI1", "first timothy": "TI1",
    "2 chronicles": "CH2",  "2 chron": "CH2", "2 ch": "CH2", "ii ch": "CH2", "2ch": "CH2", "ii chr": "CH2", "2 chr": "CH2", "ii chron": "CH2", "2chron": "CH2", "ii chronicles": "CH2", "2chronicles": "CH2", "2nd chronicles": "CH2", "second chronicles": "CH2",
    "2 corinthians": "CO2", "2 cor": "CO2", "2 co": "CO2", "ii co": "CO2", "2co": "CO2", "ii cor": "CO2", "2cor": "CO2", "ii corinthians": "CO2", "2corinthians": "CO2", "2nd corinthians": "CO2", "second corinthians": "CO2",
    "2 esdras": "ES2",  "2 esdr": "ES2", "2 esd": "ES2", "ii es": "ES2", "2es": "ES2", "ii esd": "ES2", "2esd": "ES2", "ii esdr": "ES2", "2esdr": "ES2", "ii esdras": "ES2", "2esdras": "ES2", "2nd esdras": "ES2", "second esdras": "ES2",
    "2 john": "JN2", "2 jn": "JN2", "ii jn": "JN2", "2jn": "JN2", "ii jo": "JN2", "2jo": "JN2", "ii joh": "JN2", "2joh": "JN2", "ii jhn": "JN2", "2 jhn": "JN2", "2jhn": "JN2", "ii john": "JN2", "2john": "JN2", "2nd john": "JN2", "second john": "JN2",
    "2 kings": "KI2", "2 kgs": "KI2", "2 ki": "KI2", "2k": "KI2", "ii kgs": "KI2", "2kgs": "KI2", "ii ki": "KI2", "2ki": "KI2", "ii kings": "KI2", "2kings": "KI2", "2nd kgs": "KI2", "2nd kings": "KI2", "second kings": "KI2", "second kgs": "KI2", "2kin": "KI2",
    "2 maccabees": "MA2", "2 macc": "MA2", "2 mac": "MA2", "2m": "MA2", "ii ma": "MA2", "2ma": "MA2", "ii mac": "MA2", "2mac": "MA2", "ii macc": "MA2", "2macc": "MA2", "ii maccabees": "MA2", "2maccabees": "MA2", "2nd maccabees": "MA2", "second maccabees": "MA2",
    "PE2": "PE2", "2 pet": "PE2", "2 pe": "PE2", "ii pe": "PE2", "2pe": "PE2", "ii pet": "PE2", "2pet": "PE2", "ii pt": "PE2", "2 pt": "PE2", "2pt": "2 peter", "ii peter": "2 peter", "2peter": "2 peter", "2nd peter": "2 peter", "second peter": "2 peter",
    "2 samuel": "SA2",  "2 sam": "SA2", "2 sa": "SA2", "2s": "SA2", "ii sa": "SA2", "2 sm": "SA2", "2sa": "SA2", "ii sam": "SA2", "2sam": "SA2", "ii samuel": "SA2", "2samuel": "SA2", "2nd samuel": "SA2", "second samuel": "SA2",
    "2 thessalonians": "TH2", "2 thess": "TH2", "2 th": "TH2", "ii th": "TH2", "2th": "TH2", "ii thes": "TH2", "2thes": "TH2", "ii thess": "TH2", "2thess": "TH2", "ii thessalonians": "TH2", "2thessalonians": "TH2", "2nd thessalonians": "TH2", "second thessalonians": "TH2",
    "2 timothy": "TI2", "2 tim": "TI2", "2 ti": "TI2", "ii ti": "TI2", "2ti": "TI2", "ii tim": "TI2", "2tim": "TI2", "ii timothy": "TI2", "2timothy": "TI2", "2nd timothy": "TI2", "second timothy": "TI2",
    "3 john": "JN3", "3 jn": "JN3", "iii jn": "JN3", "3jn": "JN3", "iii jo": "JN3", "3jo": "JN3", "iii joh": "JN3", "3joh": "JN3", "iii jhn": "JN3", "3 jhn": "JN3", "3jhn": "JN3", "iii john": "JN3", "3john": "JN3", "3rd john": "JN3", "third john": "JN3",
    "3 maccabees": "MA3", "3 macc": "MA3", "3 mac": "MA3", "iii ma": "MA3", "3ma": "MA3", "iii mac": "MA3", "3mac": "MA3", "iii macc": "MA3", "3macc": "MA3", "iii maccabees": "MA3", "3rd maccabees": "MA3", "third maccabees": "MA3",
    "4 maccabees": "MA4", "4 macc": "MA4", "4 mac": "MA4", "iv ma": "MA4", "4ma": "MA4", "iv mac": "MA4", "4mac": "MA4", "iv macc": "MA4", "4macc": "MA4", "iv maccabees": "MA4", "iiii maccabees": "MA4", "4maccabees": "MA4", "4th maccabees": "MA4", "fourth maccabees": "MA4",
    "acts": "ACT",  "ac": "ACT",
    "additional psalm": "additional psalm",  "add psalm": "additional psalm", "add ps": "additional psalm",
    "additions to esther": "additions to esther", "add esth": "additions to esther", "add es": "additions to esther", "rest of esther": "additions to esther", "the rest of esther": "additions to esther", "aes": "additions to esther", "addesth": "additions to esther",
    "amos": "AMO",  "am": "AMO",
    "baruch": "BAR",  "bar": "BAR",
    "bel and the dragon": "bel and the dragon",  "bel": "bel and the dragon",
    "colossians": "COL",  "col": "COL",
    "daniel": "DAN",  "dan": "DAN", "da": "DAN", "dn": "DAN",
    "deuteronomy": "DEU", "deut": "DEU", "dt": "DEU",
    "ecclesiastes": "ECC",  "eccles": "ECC", "ec": "ECC", "ecc": "ECC", "eccl": "ECC", "qoh": "ECC", "qoheleth": "ECC",
    "ephesians": "EPH", "ephes": "EPH", "eph": "EPH",
    "epistle to the laodiceans": "epistle to the laodiceans", "laodiceans": "epistle to the laodiceans", "laod": "epistle to the laodiceans", "ep laod": "epistle to the laodiceans", "epist laodiceans": "epistle to the laodiceans", "epistle laodiceans": "epistle to the laodiceans", "epistle to laodiceans": "epistle to the laodiceans",
    "esther": "EST",  "esth": "EST", "es": "EST",
    "exodus": "EXO",  "exo": "EXO", "ex": "EXO", "exod": "EXO",
    "ezekiel": "EZK", "ezek": "EZK", "eze": "EZK", "ezk": "EZK",
    "ezra": "EZR", "ezr": "EZR",
    "galatians": "GAL", "gal": "GAL", "ga": "GAL",
    "genesis": "GEN", "gen": "GEN", "ge": "GEN", "gn": "GEN",
    "habakkuk": "HAB",  "hab": "HAB",
    "haggai": "HAG",  "hag": "HAG", "hg": "HAG",
    "hebrews": "HEB",  "heb": "HEB",
    "hosea": "HOS", "hos": "HOS", "ho": "HOS",
    "isaiah": "ISA",  "isa": "ISA", "is": "ISA",
    "james": "JAS", "jas": "JAS", "jm": "JAS",
    "jeremiah": "JER",  "jer": "JER", "je": "JER", "jr": "JER",
    "job": "JOB", "jb": "JOB",
    "joel": "JOL", "joe": "JOL", "jl": "JOL",
    "john": "JHN",  "jn": "JHN", "jhn": "JHN",
    "jonah": "JON", "jnh": "JON", "jon": "JON",
    "joshua": "JOS",  "josh": "JOS", "jos": "JOS", "jsh": "JOS",
    "jude": "JUD",  "jud": "JUD",
    "judges": "JDG",  "judg": "JDG", "jdg": "JDG", "jg": "JDG", "jdgs": "JDG",
    "judith": "JDT",  "jdth": "JDT", "jdt": "JDT", "jth": "JDT",
    "lamentations": "LAM",  "lam": "LAM", "la": "LAM",
    "letter of jeremiah": "letter of jeremiah", "let jer": "letter of jeremiah", "lje": "letter of jeremiah", "ltr jer": "letter of jeremiah",
    "leviticus": "LEV", "lev": "LEV", "le": "LEV", "lv": "LEV",
    "luke": "LUK",  "luk": "LUK", "lk": "LUK",
    "malachi": "MAL", "mal": "MAL", "ml": "MAL",
    "mark": "MRK",  "mrk": "MRK", "mk": "MRK", "mr": "MRK",
    "matthew": "MAT", "matt": "MAT", "mt": "MAT",
    "micah": "MIC",  "mic": "MIC",
    "nahum": "NAM", "nah": "NAM", "na": "NAM",
    "nehemiah": "NEH",  "neh": "NEH", "ne": "NEH",
    "numbers": "NUM", "num": "NUM", "nu": "NUM", "nm": "NUM", "nb": "NUM",
    "obadiah": "OBA", "obad": "OBA", "ob": "OBA",
    "ode": "ode",
    "philemon": "PHM", "phm": "PHM",
    "philippians": "PHP", "phil": "PHP", "php": "PHP",
    "prayer of manasseh": "MAN",  "pr of man": "MAN", "pr man": "MAN", "pma": "MAN", "prayer of manasses": "MAN",
    "proverbs": "PRO",  "prov": "PRO", "pr": "PRO", "prv": "PRO",
    "psalm": "PSA", "pslm": "PSA", "ps": "PSA", "psalms": "PSA", "psa": "PSA", "psm": "PSA", "pss": "PSA",
    "psalms of solomon": "psalms of solomon", "ps solomon": "psalms of solomon", "ps sol": "psalms of solomon", "psalms solomon": "psalms of solomon", "pssol": "psalms of solomon",
    "revelation": "REV",  "rev": "REV", "re": "REV", "the revelation": "REV",
    "romans": "ROM",  "rom": "ROM", "ro": "ROM", "rm": "ROM",
    "ruth": "RUT",  "rth": "RUT", "ru": "RUT",
    "sirach": "SIR",  "sir": "SIR", "ecclesiasticus": "SIR", "ecclus": "SIR",
    "song of solomon": "SNG", "song": "SNG", "so": "SNG", "canticle of canticles": "SNG", "canticles": "SNG", "song of songs": "SNG", "sos": "SNG",
    "song of three youths": "song of three youths",  "song of three": "song of three youths", "song thr": "song of three youths", "the song of three youths": "song of three youths", "pr az": "song of three youths", "prayer of azariah": "song of three youths", "azariah": "song of three youths", "the song of the three holy children": "song of three youths", "the song of three jews": "song of three youths", "song of the three holy children": "song of three youths", "song of thr": "song of three youths", "song of three children": "song of three youths", "song of three jews": "song of three youths",
    "susanna": "susanna",  "sus": "susanna",
    "titus": "TIT",  "tit": "TIT",
    "tobit": "TOB",  "tob": "TOB", "tb": "TOB",
    "wisdom of solomon": "WIS", "wisd of sol": "WIS", "wis": "WIS", "wisd": "WIS", "ws": "WIS", "wisdom": "WIS",
    "zechariah": "ZEC", "zech": "ZEC", "zec": "ZEC", "zc": "ZEC",
    "zephaniah": "ZEP", "zeph": "ZEP", "zep": "ZEP", "zp": "ZEP",
  }

var book_title =
  { "CH1" :  "1 Chronicles",
    "CO1" :  "1 Corinthians",
    "ES1" :  "1 Esdras",
    "JN1" :  "1 John",
    "KI1" :  "1 Kings",
    "MA1" :  "1 Maccabees",
    "PE1" :  "1 Peter",
    "SA1" :  "1 Samuel",
    "TH1" :  "1 Thessalonians",
    "TI1" :  "1 Timothy",
    "CH2" :  "2 Chronicles",
    "CO2" :  "2 Corinthians",
    "ES2" :  "2 Esdras",
    "JN2" :  "2 John",
    "KI2" :  "2 Kings",
    "MA2" :  "2 Maccabees",
    "PE2" :  "2 Peter",
    "SA2" :  "2 Samuel",
    "TH2" :  "2 Thessalonians",
    "TI2" :  "2 Timothy",
    "JN3" :  "3 John",
    "MA3" :  "3 Maccabees",
    "MA4" :  "4 Maccabees",
    "ACT" :  "Acts",
    "AMO" :  "Amos",
    "BAR" :  "Baruch",
    "COL" :  "Colossians",
    "DAG" :  "Daniel (Greek)",
    "DAN" :  "Daniel",
    "DEU" :  "Deuteronomy",
    "ECC" :  "Ecclesiastes",
    "EPH" :  "Ephesians",
    "ESG" :  "Esther (Greek)",
    "EST" :  "Esther",
    "EXO" :  "Exodus",
    "EZK" :  "Ezekiel",
    "EZR" :  "Ezra",
    "GAL" :  "Galatians",
    "GEN" :  "Genesis",
    "GLO" :  "Glossary",
    "HAB" :  "Habakkuk",
    "HAG" :  "Haggai",
    "HEB" :  "Hebrews",
    "HOS" :  "Hosea",
    "ISA" :  "Isaiah",
    "JAS" :  "James",
    "JER" :  "Jeremiah",
    "JOB" :  "Job",
    "JOL" :  "Joel",
    "JHN" :  "John",
    "JON" :  "Jonah",
    "JOS" :  "Joshua",
    "JUD" :  "Jude",
    "JDG" :  "Judges",
    "JDT" :  "Judith",
    "LAM" :  "Lamentations",
    "LEV" :  "Leviticus",
    "LUK" :  "Luke",
    "MAL" :  "Malachi",
    "MRK" :  "Mark",
    "MAT" :  "Matthew",
    "MIC" :  "Micah",
    "NAM" :  "Nahum",
    "NEH" :  "Nehemiah",
    "NUM" :  "Numbers",
    "OBA" :  "Obadiah",
    "PHM" :  "Philemon",
    "PHP" :  "Philippians",
    "MAN" :  "Prayer of Manasses",
    "FRT" :  "Preface",
    "PRO" :  "Proverbs",
    "PS2" :  "Psalm 151",
    "PSA" :  "Psalms",
    "REV" :  "Revelation",
    "ROM" :  "Romans",
    "RUT" :  "Ruth",
    "SIR" :  "Sirach",
    "SNG" :  "Song of Solomon",
    "TIT" :  "Titus",
    "TOB" :  "Tobit",
    "WIS" :  "Wisdom of Solomon",
    "ZEC" :  "Zechariah",
    "ZEP" :  "Zephaniah",
  }
var singleChapterBooks = ["PHM", "JN2", "JN3", "JUD", "PS2"]
var singleChapterBookCodes = [57000000, 63000000, 64000000, 65000000, 75000000]
var bookCode = 
  { GEN: 1000000,  EXO: 2000000,  LEV: 3000000,  NUM: 4000000,  DEU:  5000000, JOS:  6000000,
    JDG: 7000000,  RUT: 8000000,  SA1: 9000000,  SA2: 10000000, KI1: 11000000, KI2: 12000000,
    CH1: 13000000, CH2: 14000000, EZR: 15000000, NEH: 16000000, EST: 17000000, JOB: 18000000,
    PSA: 19000000, PRO: 20000000, ECC: 21000000, SNG: 22000000, ISA: 23000000, JER: 24000000,
    LAM: 25000000, EZK: 26000000, DAN: 27000000, HOS: 28000000, JOL: 29000000, AMO: 30000000,
    OBA: 31000000, JON: 32000000, MIC: 33000000, NAM: 34000000, HAB: 35000000, ZEP: 36000000,
    HAG: 37000000, ZEC: 38000000, MAL: 39000000, 
    MAT: 40000000, MRK: 41000000, LUK: 42000000, JHN: 43000000, ACT: 44000000, ROM: 45000000, 
    CO1: 46000000, CO2: 47000000, GAL: 48000000, EPH: 49000000, PHP: 50000000, COL: 51000000, 
    TH1: 52000000, TH2: 53000000, TI1: 54000000, TI2: 55000000, TIT: 56000000, PHM: 57000000, 
    HEB: 58000000, JAS: 59000000, PE1: 60000000, PE2: 61000000, JN1: 62000000, JN2: 63000000, 
    JN3: 64000000, JUD: 65000000, REV: 66000000, 
    TOB: 67000000, JDT: 68000000, ESG: 69000000, WIS: 70000000, SIR: 71000000, BAR: 72000000, 
    ES1: 73000000, MAN: 74000000, PS2: 75000000, MA1: 76000000, MA2: 77000000, MA3: 78000000, 
    ES2: 79000000, MA4: 80000000, DAG: 81000000, 
    FRT: 82000000, GLO: 83000000
    }

export var Web = {

webName: function (s) {
  return bookname[s] // returns undefined if not found
},

bookTitle: function (s) {
  return bookTitle[bn]; // returns undefined if not found
},

tokenize: function(s) {
  return s.replace(/end/g, "999")
  .replace(/\s/g, "") // get rid of all the spaces
  .toLowerCase()
  .split(/(\d+|[a-z]+)/) // split on numbers and words, keep the punctuation
  .filter(function(s) {return s.length > 0}) // get rid of empty tokens
},

refToWEBcodes: function(s) {
  var tokens = this.tokenize(s)
    , book = tokens.shift() // shift is pop() from the other end
    , refs = []
    //, ref = [0,1,999]
    ;
  while (tokens.length > 0 && !parseInt(tokens[0]) ) {
    book = book + " " + tokens.shift();
  }
  tokens = tokens.filter( function(el) { return !el.match(/[a-z]/)} ) // no partial vss
  var state = 0
    , bc = bookCode[bookName[book]]
    , chap = 0
    , vsFrom = 0
    , vsTo = 0
    , refRange = [] // should end up being [webKeyFrom, webKeyTo]
    , ok = false
    ;

  while (tokens.length > 0) {
    // I would have used switch, but the required break
    // breaks out of the while loop. Arg!
    // the following will alter refs
    // check for longest matching first
    [ok, tokens] = this.multipleChaptersOrVss(bc, refs, tokens); 
    if (!ok) { [ok, tokens] = this.chapVss(bc, refs, tokens) };
    if (!ok) { [ok, tokens] = [true, tokens.slice(1)] }
    if (!ok) { [ok, tokens] = [true, tokens.slice(1)] }
    if (!ok) { [ok, tokens] = this.singleChapterOrVs(bc, refs, tokens) }
  }
  return refs;
}, // end of refToWEBcodes

singleChapterOrVs: function(bookCode, refs, tokens) {
  var [a,b] = tokens;
  a = parseInt(a);
  if (Number.isInteger(a) && ( b == "," || !b) ) { // !b means end of tokens
    if (singleChapterBookCodes.indexOf(bc) < 0 ) { // it's not a single chapter book
      refs.push( [bc + a * 1000, bc + a * 1000, 999])
    } else {
      refs.push( [bc + 1000 + a, bc + 1000 + a] )
    }
    return ( [true, tokens.slice(2)] )
  } else {
    return ( [false, tokens])
  }
},

multipleChaptersOrVss: function(bookCode, refs, tokens) {
  var [chap1, colon1, vs1, dash, chap2, colon2, vs2] = tokens;
  if (colon1 != ":" || dash != "-", colon2 != ":") { return [false, tokens]}
  var ref1 = bookCode + parseInt(chap1) * 1000 + parseInt(vs1)
    , ref2 = bookCode + parseInt(chap2) * 1000 + parseInt(vs2)
    , ok = Number.isInteger(ref1) && Number.isInteger(ref2)
    ;
  if (!ok) {return ([false, tokens]) }
  refs.push( [ref1, ref2] );
  return ( [true, tokens.slice(7)] );
},


addRefRange: function(tokens, refs, rr) { // if a comma, save range
  if (tokens[0] == ",") {
    refs.push(rr);
    rr = [];
    return ( [true, tokens.slice(1)]);
  } else {
    return ( [false, tokens]);
  }
},

chapVss: function(bookCode, refs, tokens) {
  // looking for pattern n:n-n
  var [chap,colon,vs1,dash,vs2] = tokens;
  if (colon != ":" || dash != "-") { return [false, tokens]}
  chap = parseInt(chap) * 1000;
  var ref1 = bookCode + chap + parseInt(vs1)
    , ref2 = bookCode + chap + parseInt(vs2)
    , ok = Number.isInteger(ref1) && Number.isInteger(ref2)
    ;
  // fail if any are not ints
  if ( !ok ) { return [false, tokens] }
  refs.push( [ref1, ref2] );
  return( [true, tokens.slice(5)] );
},

// webKey: function(bookKey, chap, vs) {
//   return bookCode[bookKey] + (chap * 1000) + vs
// }
// 
// refToKeys: function(s) {
//   var [book, refs] = bookAndVss(s)
//     , bookKey = bookCode[book]
//     ;
//   return refs.map( function(ref) {
//     var [chap, vsFrom, vsTo] = ref
//       bc = chap * 1000;
//     return [bookKey + bc + vsFrom, bookKey + bc + vsTo]
//   })
// }

} // end of export var Web = 
