// mirra-profile.jsx — Motivation/Profile hub + customize tiles (Reminders, Widgets, Watch, etc)
// Globals: Icon, MIRRA, HeaderBar, BackArrow, CloseBtn, DarkButton, ListGroup, ListRow, ...

// ─── Profile hub (the big "Motivation" hub)
function ProfileScreen({ onClose, state, dispatch,
  openHistory, openFavorites, openCollections, openOwn, openRecent,
  openTopicsFollow, openReminders, openAppIcon, openWidgets, openWatch, openBundle,
  openPreferences,
}) {
  const days = ['Fr','Sa','Su','Mo','Tu','We','Th'];
  const streak = state.streak;
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<CloseBtn onClick={onClose}/>}
        right={<button onClick={openPreferences} style={{ fontSize: 15, color: 'var(--ink)' }}>Settings</button>}
      />
      <div style={{ padding: '4px 22px 22px', overflow: 'auto', flex: 1 }}>
        <h1 style={{ fontSize: 24, fontWeight: 800, margin: '4px 0 16px' }}>Mirra</h1>
        {/* Streak hero */}
        <div style={{ background: '#E9E6F2', borderRadius: 16, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon.flame size={52}/>
            <span style={{ position: 'absolute', color: '#fff', fontSize: 16, fontWeight: 700,
              fontFamily: 'Instrument Serif', marginTop: 8 }}>{streak}</span>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 6 }}>Your streak</div>
            <div style={{ display: 'flex', gap: 4 }}>
              {days.map((d, i) => (
                <div key={d} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, flex: 1 }}>
                  <span style={{ fontSize: 9, color: 'var(--muted)' }}>{d}</span>
                  <div style={{ width: 16, height: 16, borderRadius: 999,
                    background: i < streak ? 'linear-gradient(120deg,#B79DE8,#F0B2A3)' : 'rgba(0,0,0,0.06)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    {i < streak && <Icon.check size={9} sw={3} stroke="#fff"/>}
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <Icon.shareIOS size={18} stroke="var(--ink)"/>
            <Icon.ellipsisV size={18} stroke="var(--ink)"/>
          </div>
        </div>

        {/* Quick library grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8, marginTop: 10 }}>
          <QuickTile2 label="My favorites" icon={<Icon.heart size={18}/>} onClick={openFavorites}/>
          <QuickTile2 label="My collections" icon={<Icon.bookmark size={18}/>} onClick={openCollections}/>
          <QuickTile2 label="My own quotes" icon={<Icon.pencil size={18}/>} onClick={openOwn}/>
          <QuickTile2 label="Recent quotes" icon={<Icon.refresh size={18}/>} onClick={openRecent}/>
        </div>

        {/* Customize the app */}
        <h3 style={{ fontSize: 18, fontWeight: 800, margin: '22px 0 12px' }}>Customize the app</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8 }}>
          <CustomizeTile label="Topics you follow" art={<TopicsArt/>} onClick={openTopicsFollow}/>
          <CustomizeTile label="Reminders" art={<RemindersArt/>} onClick={openReminders}/>
          <CustomizeTile label="App icon" art={<IconStackArt/>} onClick={openAppIcon}/>
          <CustomizeTile label="Widgets" art={<WidgetArt/>} onClick={openWidgets}/>
          <CustomizeTile label="Watch" art={<WatchArt/>} onClick={openWatch}/>
          <CustomizeTile label="Self-Growth bundle" art={<BundleArt/>} onClick={openBundle}/>
        </div>
        <div style={{ height: 30 }}/>
      </div>
    </div>
  );
}

function QuickTile2({ label, icon, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      background: '#E9E6F2', borderRadius: 14, padding: '14px',
      display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 18, height: 78,
      position: 'relative', textAlign: 'left',
    }}>
      <span style={{ fontSize: 13, fontWeight: 600 }}>{label}</span>
      <span style={{ position: 'absolute', right: 12, bottom: 10, color: 'var(--ink)' }}>{icon}</span>
    </button>
  );
}

function CustomizeTile({ label, art, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      background: '#E9E6F2', borderRadius: 16, padding: 14,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
      minHeight: 130, textAlign: 'left',
    }}>
      <span style={{ fontSize: 14, fontWeight: 600 }}>{label}</span>
      <div style={{ alignSelf: 'flex-end' }}>{art}</div>
    </button>
  );
}

// Customize tile illustrations (small, line-style)
function TopicsArt() {
  return (
    <svg viewBox="0 0 90 70" style={{ width: 90, height: 70 }}>
      <defs><linearGradient id="ta" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <rect x="14" y="14" width="40" height="48" rx="3" fill="#fff" stroke="#1A1A1A" strokeWidth="1.4" transform="rotate(-12 34 38)"/>
      <rect x="34" y="10" width="40" height="48" rx="3" fill="url(#ta)" stroke="#1A1A1A" strokeWidth="1.4" transform="rotate(8 54 34)"/>
      <line x1="42" y1="22" x2="62" y2="22" stroke="#1A1A1A" strokeWidth="1" transform="rotate(8 54 34)"/>
      <line x1="42" y1="30" x2="58" y2="30" stroke="#1A1A1A" strokeWidth="1" transform="rotate(8 54 34)"/>
    </svg>
  );
}
function RemindersArt() {
  return (
    <svg viewBox="0 0 80 70" style={{ width: 80, height: 70 }}>
      <defs><linearGradient id="ra" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <ellipse cx="40" cy="60" rx="22" ry="2" fill="rgba(0,0,0,0.1)"/>
      <path d="M40 18c-10 0-18 8-18 18v12l-6 6h48l-6-6V36c0-10-8-18-18-18z" fill="url(#ra)" stroke="#1A1A1A" strokeWidth="1.5"/>
      <circle cx="40" cy="16" r="3" fill="#1A1A1A"/>
      <path d="M34 58a6 6 0 0012 0" fill="none" stroke="#1A1A1A" strokeWidth="1.4"/>
    </svg>
  );
}
function IconStackArt() {
  return (
    <svg viewBox="0 0 90 70" style={{ width: 90, height: 70 }}>
      <rect x="14" y="14" width="34" height="34" rx="6" fill="#171B2A" transform="rotate(-15 31 31)"/>
      <text x="20" y="44" fontFamily="Instrument Serif" fontSize="18" fill="#fff" transform="rotate(-15 31 31)">"</text>
      <rect x="32" y="20" width="34" height="34" rx="6" fill="#F8C8DC" transform="rotate(10 49 37)"/>
      <text x="40" y="48" fontFamily="Instrument Serif" fontSize="16" fill="#1A1A1A" transform="rotate(10 49 37)">"</text>
      <rect x="50" y="12" width="34" height="34" rx="6" fill="url(#ia)" transform="rotate(-5 67 29)"/>
      <defs><linearGradient id="ia"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <text x="58" y="40" fontFamily="Instrument Serif" fontSize="16" fill="#fff" transform="rotate(-5 67 29)">"</text>
    </svg>
  );
}
function WidgetArt() {
  return (
    <svg viewBox="0 0 90 70" style={{ width: 90, height: 70 }}>
      <defs><linearGradient id="wa" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <rect x="22" y="8" width="48" height="58" rx="7" fill="#fff" stroke="#1A1A1A" strokeWidth="1.5"/>
      <rect x="22" y="8" width="48" height="58" rx="7" fill="url(#wa)" opacity="0.2"/>
      <rect x="26" y="14" width="24" height="14" rx="2.5" fill="#E9E6F2" stroke="#1A1A1A" strokeWidth="1"/>
      <text x="29" y="24" fontSize="6" fontWeight="700" fill="#1A1A1A">QUOTE</text>
      <rect x="52" y="14" width="14" height="14" rx="2.5" fill="#171B2A"/>
      <text x="56" y="24" fontFamily="Instrument Serif" fontSize="10" fill="#fff">"</text>
      <rect x="26" y="32" width="40" height="28" rx="3" fill="#E9E6F2" stroke="#1A1A1A" strokeWidth="1"/>
    </svg>
  );
}
function WatchArt() {
  return (
    <svg viewBox="0 0 80 70" style={{ width: 80, height: 70 }}>
      <rect x="32" y="6" width="22" height="6" rx="2" fill="#1A1A1A"/>
      <rect x="32" y="56" width="22" height="6" rx="2" fill="#1A1A1A"/>
      <rect x="22" y="12" width="42" height="44" rx="9" fill="#1A1A1A" stroke="#1A1A1A" strokeWidth="1"/>
      <text x="28" y="28" fontFamily="Instrument Serif" fontSize="8" fill="#fff">FRI</text>
      <text x="28" y="38" fontSize="12" fontWeight="700" fill="#fff">10:09</text>
      <text x="28" y="48" fontSize="5" fill="#fff">Be kind to yourself</text>
    </svg>
  );
}
function BundleArt() {
  return (
    <svg viewBox="0 0 90 70" style={{ width: 90, height: 70 }}>
      <defs><linearGradient id="ba" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <ellipse cx="45" cy="60" rx="20" ry="2.5" fill="rgba(0,0,0,0.1)"/>
      <rect x="30" y="38" width="32" height="22" rx="3" fill="#3A3F52" stroke="#1A1A1A" strokeWidth="1.4"/>
      <ellipse cx="46" cy="38" rx="16" ry="4" fill="#2A2F40"/>
      <path d="M34 30C32 20 38 14 46 14c8 0 14 6 12 16" fill="url(#ba)" stroke="#1A1A1A" strokeWidth="1.4"/>
      <path d="M38 26c0-3 2-6 5-8M50 18c4 2 7 6 8 10" stroke="#1A1A1A" strokeWidth="0.8" fill="none"/>
    </svg>
  );
}

// ─── Reminders (in-app)
function RemindersScreen({ onClose }) {
  const [items, setItems] = useState([
    { id: 1, title: 'General', sub: 'Every day', time: '7:00AM-10:00PM', count: 11, on: true },
    { id: 2, title: 'General', sub: 'Every weekday', time: '9:00AM-5:00PM', count: 3, on: false },
    { id: 3, title: 'Streak reminder', sub: 'Every day', time: '3:45PM', count: 1, on: true },
    { id: 4, title: 'Gratitude and Positive thinking', sub: 'Every day', time: '9:00PM', count: 1, on: false },
  ]);
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>} right={<button style={{ fontSize: 15 }}>Add</button>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 4px' }}>Reminders</h2>
      <p style={{ fontSize: 13, color: 'var(--muted)', margin: '4px 22px 14px' }}>Set up your daily routine to make Mirra fit your habits</p>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {items.map(r => (
          <div key={r.id} style={{ background: '#E9E6F2', borderRadius: 14, padding: '12px 14px',
            opacity: r.on ? 1 : 0.6, transition: 'opacity 0.2s' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontSize: 15, fontWeight: 700 }}>{r.title}</div>
                <div style={{ fontSize: 12, color: 'var(--muted-2)', marginTop: 2 }}>
                  <span style={{ fontWeight: 600 }}>{r.count}x</span> {r.sub}
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <span style={{ fontSize: 12, color: 'var(--ink-2)' }}>{r.time}</span>
                <Switch on={r.on} onChange={(v) => setItems(items.map(x => x.id === r.id ? {...x, on: v} : x))}/>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton>Add reminder</DarkButton>
      </div>
    </div>
  );
}

// ─── App Icon picker (in-app, includes native alert)
function AppIconScreen({ onClose }) {
  const [picked, setPicked] = useState('i2');
  const [showAlert, setShowAlert] = useState(false);
  const choose = (id) => { setPicked(id); setShowAlert(true); };
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 18px' }}>App icon</h2>
      <div style={{ padding: '0 22px 24px', overflow: 'auto', flex: 1 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 12 }}>
          {window.MIRRA.ICON_CHOICES.map(c => (
            <IconTile key={c.id} c={c} selected={picked === c.id} onClick={() => choose(c.id)}/>
          ))}
        </div>
      </div>
      {showAlert && (
        <NativeAlert icon={<MirraMark size={42}/>}
          title='You have changed the icon for "Mirra".'
          actions={[{ label: 'OK', primary: true, onClick: () => setShowAlert(false) }]}/>
      )}
    </div>
  );
}

// ─── Widgets info (separate from onboarding walkthrough — same component reused)
function WidgetsScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 16px' }}>Widgets</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1 }}>
        <div style={{ background: '#E9E6F2', borderRadius: 22, padding: 16, marginBottom: 18 }}>
          <div style={{ background: '#fff', borderRadius: 18, padding: '22px 12px 12px', minHeight: 220, border: '1px solid var(--line)', position: 'relative' }}>
            <div style={{ position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)', width: 56, height: 18, borderRadius: 999, background: '#171B2A' }}/>
            <div style={{ background: '#fff', borderRadius: 14, padding: 18, border: '1.5px dashed var(--ink-2)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: 84 }}>
              <p style={{ margin: 0, fontSize: 15, fontWeight: 600, textAlign: 'center' }}>Your are stronger<br/>than you think.</p>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 6, marginTop: 14 }}>
              {Array.from({length:8}).map((_,i)=><div key={i} style={{ aspectRatio:'1', borderRadius: 9, background: 'rgba(0,0,0,0.08)' }}/>)}
            </div>
          </div>
        </div>
        <p style={{ fontSize: 16, fontWeight: 700, textAlign: 'center', margin: '0 0 12px' }}>Add a widget to your<br/>Home Screen</p>
        <ol style={{ fontSize: 13, color: 'var(--ink-2)', margin: 0, paddingInlineStart: 18, lineHeight: 1.6 }}>
          <li>On your phone's Home Screen, touch and hold an empty area until the apps jiggle</li>
          <li>Tap the Edit button in the upper corner to add the widget</li>
        </ol>
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton>Install widget</DarkButton>
      </div>
    </div>
  );
}

// ─── Watch
function WatchScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 18px' }}>Watch</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1 }}>
        <h3 style={{ fontSize: 15, fontWeight: 700, margin: '0 0 12px' }}>Mirra face</h3>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{
            width: 88, height: 110, borderRadius: 14, background: '#171B2A',
            padding: '10px 8px', position: 'relative', flexShrink: 0,
          }}>
            <div style={{ fontFamily: 'Instrument Serif', fontSize: 10, color: '#fff', display: 'flex', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontSize: 7 }}>FRI</div>
                <div style={{ fontSize: 18, fontWeight: 700, lineHeight: 1 }}>23</div>
              </div>
              <div style={{ fontSize: 16, fontWeight: 700 }}>10:09</div>
            </div>
            <p style={{ fontSize: 7, color: '#fff', marginTop: 10, lineHeight: 1.3 }}>Choose people who choose you.</p>
          </div>
          <button style={{
            padding: '8px 14px', borderRadius: 8, border: '1.5px solid #1A1A1A',
            fontSize: 14, fontWeight: 600, background: '#fff',
          }}>Set as Watch face</button>
          <button style={{ marginLeft: 'auto' }}><Icon.shareIOS size={20}/></button>
        </div>
        <p style={{ fontSize: 13, color: 'var(--muted)', margin: '12px 0 24px', lineHeight: 1.45 }}>
          You can also add Mirra complications to the face you're using on your Watch.
        </p>
        <h3 style={{ fontSize: 15, fontWeight: 700, margin: '0 0 12px' }}>Watch content</h3>
        <button style={{ width: '100%', background: '#E9E6F2', borderRadius: 12, padding: '12px 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span style={{ fontSize: 14, fontWeight: 600 }}>Type of quotes</span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--muted)', fontSize: 13 }}>
            General <Icon.chevronRight size={16}/>
          </span>
        </button>
      </div>
    </div>
  );
}

Object.assign(window, {
  ProfileScreen, RemindersScreen, AppIconScreen, WidgetsScreen, WatchScreen,
});
