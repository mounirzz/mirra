// mirra-icons.jsx — all line + filled icons
const I = ({ children, size = 22, stroke = 'currentColor', fill = 'none', sw = 1.6, vb = 24 }) => (
  <svg width={size} height={size} viewBox={`0 0 ${vb} ${vb}`} fill={fill} stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{children}</svg>
);

const Icon = {
  // Nav
  chevronLeft:  (p) => <I {...p}><path d="M15 6l-6 6 6 6"/></I>,
  chevronRight: (p) => <I {...p}><path d="M9 6l6 6-6 6"/></I>,
  chevronDown:  (p) => <I {...p}><path d="M6 9l6 6 6-6"/></I>,
  chevronUp:    (p) => <I {...p}><path d="M6 15l6-6 6 6"/></I>,
  x:    (p) => <I {...p}><path d="M6 6l12 12M18 6L6 18"/></I>,
  plus: (p) => <I {...p}><path d="M12 5v14M5 12h14"/></I>,
  minus:(p) => <I {...p}><path d="M5 12h14"/></I>,
  check:(p) => <I {...p}><path d="M5 12l4 4 10-10"/></I>,
  swipeUp: (p) => <I {...p}><path d="M6 12l6-6 6 6"/></I>,
  ellipsis: (p) => <I {...p}><circle cx="5" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="19" cy="12" r="1.4" fill="currentColor" stroke="none"/></I>,
  ellipsisV: (p) => <I {...p}><circle cx="12" cy="5" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="19" r="1.4" fill="currentColor" stroke="none"/></I>,
  // Actions
  heart: (p) => <I {...p}><path d="M12 20s-7-4.5-9-9c-1.4-3.2 1-7 4.5-7 2 0 3.5 1 4.5 2.5C13 5 14.5 4 16.5 4 20 4 22.4 7.8 21 11c-2 4.5-9 9-9 9z"/></I>,
  heartFill: (p) => <I {...p} fill="currentColor" sw={0}><path d="M12 20s-7-4.5-9-9c-1.4-3.2 1-7 4.5-7 2 0 3.5 1 4.5 2.5C13 5 14.5 4 16.5 4 20 4 22.4 7.8 21 11c-2 4.5-9 9-9 9z"/></I>,
  bookmark: (p) => <I {...p}><path d="M6 4h12v17l-6-4-6 4V4z"/></I>,
  bookmarkFill: (p) => <I {...p} fill="currentColor" sw={0}><path d="M6 4h12v17l-6-4-6 4V4z"/></I>,
  shareIOS: (p) => <I {...p}><path d="M12 3v13M7.5 7.5L12 3l4.5 4.5M6 12v8a1 1 0 001 1h10a1 1 0 001-1v-8"/></I>,
  copy: (p) => <I {...p}><rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V6a2 2 0 00-2-2H6a2 2 0 00-2 2v8a2 2 0 002 2h2"/></I>,
  download: (p) => <I {...p}><path d="M12 4v12M7 11l5 5 5-5M5 20h14"/></I>,
  refresh: (p) => <I {...p}><path d="M20 8a8 8 0 10-2 9M20 4v4h-4"/></I>,
  filter: (p) => <I {...p}><path d="M4 6h16M7 12h10M10 18h4"/></I>,
  sortVert: (p) => <I {...p}><path d="M7 4v16M4 17l3 3 3-3M17 20V4M14 7l3-3 3 3"/></I>,
  // System
  search: (p) => <I {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3-3"/></I>,
  bell: (p) => <I {...p}><path d="M6 16V11a6 6 0 1112 0v5l2 3H4l2-3z"/><path d="M10 21h4"/></I>,
  cog: (p) => <I {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1 1 0 00.2 1.1l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1 1 0 00-1.1-.2 1 1 0 00-.6.9V20a2 2 0 11-4 0v-.1a1 1 0 00-.6-.9 1 1 0 00-1.1.2l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1 1 0 00.2-1.1 1 1 0 00-.9-.6H4a2 2 0 110-4h.1a1 1 0 00.9-.6 1 1 0 00-.2-1.1l-.1-.1a2 2 0 112.8-2.8l.1.1a1 1 0 001.1.2H9a1 1 0 00.6-.9V4a2 2 0 114 0v.1a1 1 0 00.6.9 1 1 0 001.1-.2l.1-.1a2 2 0 112.8 2.8l-.1.1a1 1 0 00-.2 1.1V9a1 1 0 00.9.6H20a2 2 0 110 4h-.1a1 1 0 00-.9.6z"/></I>,
  user: (p) => <I {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></I>,
  // App nav glyphs
  brush:   (p) => <I {...p}><path d="M3 21c0-3 3-3 3-6"/><path d="M14 4l6 6-9 9-3-3 9-9"/></I>,
  grid:    (p) => <I {...p}><rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/></I>,
  paint:   (p) => <I {...p}><rect x="4" y="5" width="11" height="6" rx="1.5"/><path d="M15 8h4v4h-7"/><path d="M11 12v3a1 1 0 001 1h1v5h-2v-5"/></I>,
  globe:   (p) => <I {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/></I>,
  lock:    (p) => <I {...p}><rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/></I>,
  // Onboarding glyphs
  sun:       (p) => <I {...p}><circle cx="12" cy="12" r="4"/><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4L7 17M17 7l1.4-1.4"/></I>,
  head:      (p) => <I {...p}><path d="M5 12a7 7 0 1114 0v4l1 3h-3v3H8v-4a7 7 0 01-3-6z"/><path d="M9 13c.6 0 1 .4 1 1"/></I>,
  brain:     (p) => <I {...p}><path d="M12 4a3 3 0 00-3 3 3 3 0 00-3 3v3a3 3 0 002 3 3 3 0 003 3v-4a3 3 0 003-3V4z"/></I>,
  shield:    (p) => <I {...p}><path d="M12 3l8 3v6c0 4-3.5 8-8 9-4.5-1-8-5-8-9V6l8-3z"/></I>,
  handshake: (p) => <I {...p}><path d="M3 14l3-3 3 3 4-4 4 4 4-4M9 14l3-3 3 3-3 3-3-3z"/></I>,
  mountain:  (p) => <I {...p}><path d="M3 19h18L15 8l-3 5-2-3-7 9z"/><circle cx="17" cy="6" r="1.5"/></I>,
  cloud:     (p) => <I {...p}><path d="M7 18a4 4 0 010-8 5 5 0 0110 1 4 4 0 010 7H7z"/></I>,
  briefcase: (p) => <I {...p}><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 012-2h4a2 2 0 012 2v2"/></I>,
  pulse:     (p) => <I {...p}><path d="M3 12h4l2-5 4 10 2-5h6"/></I>,
  home:      (p) => <I {...p}><path d="M4 11l8-7 8 7v9H4v-9z"/><path d="M10 20v-5h4v5"/></I>,
  hands:     (p) => <I {...p}><path d="M3 12c0-2 2-3 3-3l3 1 3-1 3 1 3-1c1 0 3 1 3 3v2c0 3-3 5-6 5h-6c-3 0-6-2-6-5v-2z"/></I>,
  // Mood curves
  'curve-awesome':  (p) => <I {...p} sw={1.8}><path d="M6 10c1 5 4 7 6 7s5-2 6-7"/></I>,
  'curve-good':     (p) => <I {...p} sw={1.8}><path d="M7 11c1 3 3 5 5 5s4-2 5-5"/></I>,
  'curve-neutral':  (p) => <I {...p} sw={1.8}><path d="M6 13h12"/></I>,
  'curve-bad':      (p) => <I {...p} sw={1.8}><path d="M7 15c1-3 3-5 5-5s4 2 5 5"/></I>,
  'curve-terrible': (p) => <I {...p} sw={1.8}><path d="M6 17c1-5 4-7 6-7s5 2 6 7"/></I>,
  'curve-other':    (p) => <I {...p} sw={1.8}><path d="M5 13c2-3 3 0 5-3s3 3 5 0 3 0 5 0"/></I>,
  // Zodiac
  capricorn:   (p) => <I {...p}><path d="M4 8c2-3 4-3 5 0l3 8c1 3 3 3 4 1"/><circle cx="14" cy="14" r="2.5"/></I>,
  aquarius:    (p) => <I {...p}><path d="M3 10c2-2 3 0 5 0s3-2 5 0 3 0 5 0M3 15c2-2 3 0 5 0s3-2 5 0 3 0 5 0"/></I>,
  pisces:      (p) => <I {...p}><path d="M7 4c1 4 1 12 0 16M17 4c-1 4-1 12 0 16M5 12h14"/></I>,
  aries:       (p) => <I {...p}><path d="M12 6v14M7 9c0-3 2-5 5-5s5 2 5 5"/></I>,
  taurus:      (p) => <I {...p}><circle cx="12" cy="16" r="4"/><path d="M5 5c1 4 4 6 7 6s6-2 7-6"/></I>,
  gemini:      (p) => <I {...p}><path d="M5 5c5 1 9 1 14 0M5 19c5-1 9-1 14 0M7 5v14M17 5v14"/></I>,
  cancer:      (p) => <I {...p}><path d="M4 9c4-3 12-3 16 0M4 15c4 3 12 3 16 0"/><circle cx="8" cy="9" r="1.5"/><circle cx="16" cy="15" r="1.5"/></I>,
  leo:         (p) => <I {...p}><circle cx="9" cy="9" r="4"/><path d="M11 12c2 3 1 7-2 7s-4-2-3-4"/></I>,
  virgo:       (p) => <I {...p}><path d="M4 6v12M9 6v12c0-6 1-7 5-6s6 2 5 7M16 14c1 4-2 6-4 6"/></I>,
  libra:       (p) => <I {...p}><path d="M4 17h16M4 14h6c0-3 1-5 2-5s2 2 2 5h6"/></I>,
  scorpio:     (p) => <I {...p}><path d="M3 8v8M7 8v10M11 8v10M11 18l5-5 4 4-2 2"/></I>,
  sagittarius: (p) => <I {...p}><path d="M5 19L19 5M14 5h5v5M11 13l-3-3"/></I>,
  // Streak
  flame: (p) => <svg width={p?.size||44} height={p?.size||44} viewBox="0 0 48 48">
    <defs><linearGradient id="fl1" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stopColor="#F0B2A3"/><stop offset="0.5" stopColor="#E0AECB"/><stop offset="1" stopColor="#B79DE8"/></linearGradient></defs>
    <path d="M24 4c2 6 9 10 9 19a9 9 0 11-18 0c0-3 1-5 3-7-.4 4 2 6.4 4.5 6.4 0-5-3-9 1.5-18.4z" fill="url(#fl1)"/>
  </svg>,
  // Misc
  edit: (p) => <I {...p}><path d="M4 20h4l10-10-4-4L4 16v4z"/><path d="M14 6l4 4"/></I>,
  trash:(p) => <I {...p}><path d="M5 7h14M9 7V5a2 2 0 012-2h2a2 2 0 012 2v2M6 7l1 13a2 2 0 002 2h6a2 2 0 002-2l1-13"/></I>,
  star:     (p) => <I {...p}><path d="M12 3l2.7 5.6 6 .9-4.3 4.3 1 6.2L12 17l-5.4 3 1-6.2L3.3 9.5l6-.9L12 3z"/></I>,
  starFill: (p) => <I {...p} fill="currentColor" sw={0}><path d="M12 3l2.7 5.6 6 .9-4.3 4.3 1 6.2L12 17l-5.4 3 1-6.2L3.3 9.5l6-.9L12 3z"/></I>,
  arrowUp:  (p) => <I {...p}><path d="M12 19V5M6 11l6-6 6 6"/></I>,
  arrowSortVert: (p) => <I {...p}><path d="M7 4v16M4 9l3-5 3 5M17 20V4M14 15l3 5 3-5"/></I>,
  quote:     (p) => <I {...p} fill="currentColor" sw={0}><path d="M6 16c0-3 1-5 4-6l.6 1.5C9 12 8 13 8 14h2v5H4v-3zm9 0c0-3 1-5 4-6l.6 1.5c-1.6.5-2.6 1.5-2.6 2.5h2v5h-6v-3z"/></I>,
  crown:    (p) => <I {...p}><path d="M3 19h18M3 7l4 5 5-7 5 7 4-5v12H3V7z"/></I>,
  pencil:   (p) => <I {...p}><path d="M3 21h4l11-11-4-4L3 17v4z"/></I>,
  // Preferences icons
  contentPrefs: (p) => <I {...p}><rect x="4" y="4" width="16" height="16" rx="2"/><path d="M9 4v16M4 12h5"/></I>,
  mute: (p) => <I {...p}><path d="M3 9v6h4l5 4V5L7 9H3z"/><path d="M16 8l5 8M21 8l-5 8"/></I>,
  name: (p) => <I {...p}><circle cx="12" cy="8" r="3"/><path d="M6 21c0-3 3-5 6-5s6 2 6 5"/><path d="M16 4l3 3M19 4l-3 3"/></I>,
  sound:(p) => <I {...p}><path d="M4 9v6h4l5 4V5L8 9H4z"/><path d="M16 9c1 1 1 5 0 6M19 7c2 2 2 8 0 10"/></I>,
  voice:(p) => <I {...p}><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 12a7 7 0 0014 0M12 19v3"/></I>,
  siri: (p) => <I {...p}><circle cx="12" cy="12" r="8"/><path d="M8 12c0-2 2-4 4-4s4 2 4 4"/></I>,
  signin: (p) => <I {...p}><circle cx="10" cy="8" r="4"/><path d="M2 21c0-4 4-6 8-6"/><path d="M14 12h7M18 9l3 3-3 3"/></I>,
  help: (p) => <I {...p}><circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 015 0c0 2-2.5 2-2.5 4"/><circle cx="12" cy="17" r="0.5" fill="currentColor"/></I>,
  reviewHand: (p) => <I {...p}><path d="M9 11V5a2 2 0 014 0v4M9 11c-1 0-2 1-2 2v5a3 3 0 003 3h5a3 3 0 003-3v-5l-2-3H13"/></I>,
  ig:    (p) => <I {...p}><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor"/></I>,
  tiktok:(p) => <I {...p}><path d="M14 4v9.5a4.5 4.5 0 11-4-4.5V12a2 2 0 102 2V4h2c0 2 2 3 4 3"/></I>,
  fb:    (p) => <I {...p}><path d="M14 8h3V4h-3a4 4 0 00-4 4v3H7v4h3v6h4v-6h3l1-4h-4V8c0-.5.5-1 1-1z"/></I>,
  pin:   (p) => <I {...p}><circle cx="12" cy="12" r="9"/><path d="M10 17l3-9M10 17l2-2M13 8c1.5 0 3 1 3 3s-1 3-3 3"/></I>,
  x_tw:  (p) => <I {...p}><path d="M4 4l16 16M20 4L4 20"/></I>,
  doc:   (p) => <I {...p}><path d="M6 3h9l4 4v14H6z"/><path d="M14 3v5h5"/></I>,
  monkey:(p) => <I {...p}><circle cx="12" cy="13" r="6"/><circle cx="7" cy="10" r="2.5"/><circle cx="17" cy="10" r="2.5"/><circle cx="10" cy="12" r="0.5" fill="currentColor"/><circle cx="14" cy="12" r="0.5" fill="currentColor"/></I>,
  // Edit theme tools
  cameraIcon: (p) => <I {...p}><rect x="3" y="7" width="18" height="13" rx="2"/><circle cx="12" cy="13" r="4"/><path d="M9 7l2-3h2l2 3"/></I>,
  leaf:       (p) => <I {...p}><path d="M5 19c0-8 6-14 14-14 0 8-6 14-14 14z"/><path d="M5 19c4-2 8-6 10-10"/></I>,
  colorWheel: (p) => (
    <svg width={p?.size||22} height={p?.size||22} viewBox="0 0 24 24">
      <defs>
        <radialGradient id="cw">
          <stop offset="0" stopColor="#fff"/>
          <stop offset="1" stopColor="#fff" stopOpacity="0"/>
        </radialGradient>
      </defs>
      <circle cx="12" cy="12" r="10" fill="url(#cw)" />
      <g>
        <path d="M12 2 A10 10 0 0 1 20.66 7" stroke="#F0B2A3" strokeWidth="3" fill="none"/>
        <path d="M20.66 7 A10 10 0 0 1 20.66 17" stroke="#F8D2A8" strokeWidth="3" fill="none"/>
        <path d="M20.66 17 A10 10 0 0 1 12 22" stroke="#CFE0B8" strokeWidth="3" fill="none"/>
        <path d="M12 22 A10 10 0 0 1 3.34 17" stroke="#B6E1C1" strokeWidth="3" fill="none"/>
        <path d="M3.34 17 A10 10 0 0 1 3.34 7" stroke="#B79DE8" strokeWidth="3" fill="none"/>
        <path d="M3.34 7 A10 10 0 0 1 12 2" stroke="#E8B5D5" strokeWidth="3" fill="none"/>
      </g>
    </svg>
  ),
  alignEq: (p) => <I {...p}><path d="M5 8h14M5 12h10M5 16h14"/></I>,
  textA:   (p) => <I {...p}><path d="M6 19l5-14h2l5 14M8 14h8"/></I>,
  textAa:  (p) => <I {...p}><path d="M3 19l4-12h1l4 12M4 15h6M14 11a3 3 0 116 0v8M14 16h6"/></I>,
  // Widgets / Watch
  widget: (p) => <I {...p}><rect x="3" y="3" width="8" height="8" rx="1.5"/><rect x="13" y="3" width="8" height="8" rx="1.5"/><rect x="3" y="13" width="18" height="8" rx="1.5"/></I>,
  watch:  (p) => <I {...p}><rect x="7" y="7" width="10" height="14" rx="2"/><path d="M9 7V3h6v4M9 21v-2"/></I>,
};
// alias used in some places
Icon.heartLine = Icon.heart;
window.Icon = Icon;
