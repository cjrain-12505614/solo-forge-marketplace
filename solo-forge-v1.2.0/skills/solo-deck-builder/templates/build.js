// solo-deck-builder — 편집 가능 PPTX 빌드 골격 (함정 C1~C7 회피 적용)
// 사용법: 이 파일을 복사 → 아래 DECK 설정과 SLIDE 블록만 교체 → `node build.js`
//   (사전: `npm i -g pptxgenjs`, `python3 gen_bg.py`로 배경 3종 생성)
const pptxgen = require("pptxgenjs");
const path = require("path");

const DIR = "/tmp/pptx_build";
const BG_BODY  = path.join(DIR, "bg_body.png");
const BG_COVER = path.join(DIR, "bg_cover.png");
const GRAD     = path.join(DIR, "grad_h.png");

// ─── 좌표/단위 변환 (1280×720 px → inch, pt = px*0.75) ───
const X = px => +(px/96).toFixed(3);
const PT = px => Math.round(px*0.75*10)/10;

// ─── 색상 (중립 다크 팔레트 — 브랜드 색이 있으면 여기만 교체) ───
const C = {
  white:"FFFFFF", gray:"C2C8D6", gray2:"9AA2B6", dim:"767E94",
  blue:"5B7CFF", blueB:"6E8BFF", blueD:"4A6CF7",
  purple:"A78BFA", purpleB:"B79CFF",
  good:"4EC38A", warn:"F0A65C",
  card:"171B30", cardLine:"2C335A", cardHi:"23284A",
  embar:"11142A", tblBase:"141829", tblHead:"1E2440", tblHi:"232A4A", tblLine:"2A3050",
};
// ─── 폰트 (기본 Arial = 대부분 PC에 존재. 브랜드 폰트가 있으면 정확한 family로 교체) ───
const TITLE = "Arial", TEXT = "Arial";

// ─── 덱 설정 (여기만 바꾸면 헤더/푸터/표지에 반영) ───
const DECK = {
  eyebrow: "PRESENTATION",           // 좌상단 브랜드/구분 라벨
  title:   "발표 제목",               // 표지·헤더 보조 제목
  subtitle:"부제 한 줄",
  footer:  "발표 제목 · 부제",
  date:    "2026.01.01",
};

const pres = new pptxgen();
pres.defineLayout({ name:"DECK", width:13.333, height:7.5 });
pres.layout = "DECK";
pres.title  = DECK.title;

// ─── 공통: 헤더띠 ───
function header(s, title){
  s.addText(DECK.eyebrow, { x:X(64), y:X(20), w:X(220), h:X(40), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(19), color:C.white, valign:"middle", align:"left" });
  s.addShape(pres.shapes.LINE, { x:X(196), y:X(28), w:0, h:X(24), line:{color:"FFFFFF", width:1, transparency:78} });
  s.addText(title, { x:X(212), y:X(20), w:X(700), h:X(40), margin:0,
    fontFace:TEXT, fontSize:PT(16), color:C.gray2, valign:"middle", align:"left" });
}
// ─── 공통: 푸터 ───
function footer(s, pg){
  s.addText(DECK.footer, { x:X(64), y:X(692), w:X(500), h:X(20), margin:0,
    fontFace:TEXT, fontSize:PT(11), color:C.dim, valign:"middle" });
  s.addText([
    { text:String(pg), options:{ fontFace:TITLE, bold:true, color:C.blue } },
    { text:"  ·  "+DECK.date, options:{ color:C.dim } }
  ], { x:X(916), y:X(692), w:X(300), h:X(20), margin:0, fontFace:TEXT, fontSize:PT(11), align:"right", valign:"middle" });
}
// ─── 공통: 중앙 타이틀 ───
function centerTitle(s, eyebrow, runs){
  s.addText(eyebrow.toUpperCase(), { x:X(64), y:X(108), w:X(1152), h:X(20), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(11), color:C.blue, align:"center", charSpacing:3 });
  s.addText(runs, { x:X(64), y:X(132), w:X(1152), h:X(46), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(30), color:C.white, align:"center", valign:"middle" });
}
// ─── 공통: 카드 ───
function card(s, x,y,w,h, fill){
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(x), y:X(y), w:X(w), h:X(h),
    rectRadius:0.08, fill:{color:fill||C.card}, line:{color:C.cardLine, width:1} });
}
// ─── 공통: 칩 헤더 카드 (그라데이션 헤더 + 본문) ───
function chipCard(s, x,y,w,h, chipText){
  card(s, x,y,w,h, C.card);
  s.addImage({ path:GRAD, x:X(x), y:X(y), w:X(w), h:X(40), rounding:false });
  s.addText(chipText, { x:X(x), y:X(y), w:X(w), h:X(40), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(15), color:C.white, align:"center", valign:"middle" });
}
// ─── 공통: 라벨 ───
function lab(s, x,y,w, t, color){
  s.addText(t.toUpperCase(), { x:X(x), y:X(y), w:X(w), h:X(18), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(11), color:color||C.dim, charSpacing:1.5, valign:"middle" });
}
// ─── 공통: 하단 강조 캡슐 ───
function embar(s, y, runs){
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(64), y:X(y), w:X(1152), h:X(50),
    rectRadius:0.25, fill:{color:C.embar}, line:{color:C.blue, width:1.5} });
  s.addText(runs, { x:X(80), y:X(y), w:X(1120), h:X(50), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(16), color:C.white, align:"center", valign:"middle" });
}
// rich run helper — C2 함정 회피: 색이 섞인 줄은 반드시 run 배열로 편다
const r  = (text, opt={}) => ({ text, options:opt });
const bl = (text, opt={}) => ({ text, options:{ bullet:{indent:14}, breakLine:true, ...opt } });

// 표 공통
function tbl(s, rows, x,y,w, colW, opt={}){
  s.addTable(rows, { x:X(x), y:X(y), w:X(w), colW:colW.map(X),
    border:{type:"solid", pt:0.5, color:C.tblLine}, fontFace:TEXT, fontSize:PT(12.5),
    color:C.gray, valign:"middle", autoPage:false, ...opt });
}
function th(t){ return { text:t.toUpperCase(), options:{ fill:{color:C.tblHead}, color:C.gray2, bold:true, fontFace:TITLE, fontSize:PT(10.5) } }; }
function td(t, o={}){ return { text:t, options:{ fill:{color:C.tblBase}, ...o } }; }
function tdHi(t, o={}){ return { text:t, options:{ fill:{color:C.tblHi}, ...o } }; }

// ════════════════ SLIDE 1 — 표지 (예시) ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_COVER };
  s.addText(DECK.eyebrow, { x:X(72), y:X(80), w:X(700), h:X(34), margin:0,
    fontFace:TITLE, fontSize:PT(22), color:C.white });
  s.addText([
    r(DECK.title, { color:C.white }),
    r("\n"+DECK.subtitle, { color:C.blueB }),
  ], { x:X(72), y:X(272), w:X(900), h:X(150), margin:0, fontFace:TITLE, bold:true, fontSize:PT(46), lineSpacingMultiple:1.25 });
  s.addText(DECK.date, { x:X(72), y:X(470), w:X(600), h:X(18), margin:0, fontFace:TEXT, fontSize:PT(12), color:C.dim, charSpacing:1 });
}

// ════════════════ SLIDE 2 — 본문 (예시: 카드 + 표 + 강조 캡슐 + C2 불릿) ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "본문 슬라이드 제목");
  centerTitle(s, "section eyebrow", [ r("핵심 메시지 ", {color:C.white}), r("한 줄", {color:C.blueB}) ]);

  // 카드 + 그 안의 C2 불릿 패턴 (색 섞인 줄은 run 배열로)
  chipCard(s, 64, 200, 560, 300, "요점");
  s.addText([
    r("첫째 항목", { bullet:{indent:16}, bold:true, color:C.white }),
    r(" — 색이 섞인 줄은 run으로 편다", { breakLine:true, color:C.gray }),
    bl("둘째 항목 (단색 불릿)", { color:C.gray }),
    bl("셋째 항목", { color:C.gray }),
  ], { x:X(88), y:X(260), w:X(512), h:X(220), margin:0, fontFace:TEXT, fontSize:PT(14), lineSpacingMultiple:1.3, valign:"top" });

  // 표
  tbl(s, [
    [th("구분"), th("값")],
    [td("항목 A"), tdHi("42%", {color:C.blueB, bold:true, align:"right"})],
    [td("항목 B"), tdHi("12%", {color:C.good, bold:true, align:"right"})],
  ], 664, 210, 552, [360, 192]);

  embar(s, 560, [ r("한 줄 결론 — ", {color:C.white}), r("강조하고 싶은 결과", {color:C.blueB}) ]);
  footer(s, 2);
}

pres.writeFile({ fileName: "deck.pptx" }).then(f => console.log("생성:", f));
