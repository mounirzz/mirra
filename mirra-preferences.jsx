// mirra-preferences.jsx — Preferences hub + subscreens
// Globals: Icon, MIRRA, HeaderBar, BackArrow, DarkButton, ListGroup, ListRow, ...

// ─── Preferences (settings hub)
function PreferencesScreen({ onClose,
  openManageSub, openContentPrefs, openGender, openMuted, openLanguage,
  openName, openSound, openVoice, openSiri, openSignIn, openHelp, openSocialShare,
}) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>} center="Preferences"/>
      <div style={{ padding: '4px 22px 22px', overflow: 'auto', flex: 1 }}>
        <SectionLabel>Premium</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.crown size={18}/>} label="Manage subscription" onClick={openManageSub}/>
        </ListGroup>
        <SectionLabel>Make it yours</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.contentPrefs size={18}/>} label="Content preferences" onClick={openContentPrefs}/>
          <ListRow icon={<Icon.user size={18}/>} label="Gender identity" onClick={openGender}/>
          <ListRow icon={<Icon.mute size={18}/>} label="Muted content" onClick={openMuted}/>
          <ListRow icon={<Icon.globe size={18}/>} label="Language" onClick={openLanguage}/>
          <ListRow icon={<Icon.name size={18}/>} label="Name" onClick={openName}/>
          <ListRow icon={<Icon.sound size={18}/>} label="Sound" onClick={openSound}/>
          <ListRow icon={<Icon.voice size={18}/>} label="Voice" onClick={openVoice}/>
          <ListRow icon={<Icon.siri size={18}/>} label="Add Siri Shortcuts" onClick={openSiri}/>
        </ListGroup>
        <SectionLabel>Account</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.signin size={18}/>} label="Sign in" onClick={openSignIn}/>
        </ListGroup>
        <SectionLabel>Support us</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.shareIOS size={18}/>} label="Share Mirra" onClick={openSocialShare}/>
          <ListRow icon={<Icon.monkey size={18}/>} label="More by Mirra Studio" onClick={() => {}}/>
          <ListRow icon={<Icon.reviewHand size={18}/>} label="Leave us a review" onClick={() => {}}/>
        </ListGroup>
        <SectionLabel>Help</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.help size={18}/>} label="Help" onClick={openHelp}/>
        </ListGroup>
        <SectionLabel>Follow us</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.ig size={18}/>} label="Instagram"/>
          <ListRow icon={<Icon.tiktok size={18}/>} label="TikTok"/>
          <ListRow icon={<Icon.fb size={18}/>} label="Facebook"/>
          <ListRow icon={<Icon.pin size={18}/>} label="Pinterest"/>
          <ListRow icon={<Icon.x_tw size={18}/>} label="X (formerly Twitter)"/>
        </ListGroup>
        <SectionLabel>Other</SectionLabel>
        <ListGroup>
          <ListRow icon={<Icon.doc size={18}/>} label="Privacy Policy"/>
          <ListRow icon={<Icon.doc size={18}/>} label="Terms and Conditions"/>
        </ListGroup>
        <div style={{
          marginTop: 20, background: '#E9E6F2', borderRadius: 14, padding: '10px 14px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div>
            <div style={{ fontSize: 12, color: 'var(--ink)', fontWeight: 500 }}>Mirra app - version 6.1.1</div>
            <div style={{ fontSize: 11, color: 'var(--muted)', marginTop: 1 }}>User ID: F7399D6E-1F45-41AC-8099-E…</div>
          </div>
          <button style={{ width: 30, height: 30, borderRadius: 6, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon.copy size={16} stroke="var(--ink)"/>
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Manage subscription
function ManageSubScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Back"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 20px' }}>Manage subscription</h2>
      <div style={{ padding: '0 22px', flex: 1, overflow: 'auto' }}>
        <p style={{ fontSize: 14, color: 'var(--ink-2)', margin: '0 0 12px' }}>You are subscribed to:</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 20 }}>
          <Icon.crown size={22}/>
          <span style={{ fontSize: 15, fontWeight: 700 }}>Mirra free Premium trial</span>
        </div>
        {/* timeline */}
        <div style={{ position: 'relative', paddingLeft: 26 }}>
          <div style={{ position: 'absolute', left: 9, top: 8, bottom: 16, width: 2, background: '#171B2A' }}/>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 16, position: 'relative' }}>
            <span style={{ position: 'absolute', left: -26, width: 20, height: 20, borderRadius: 999, background: '#171B2A', color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', zIndex: 1 }}><Icon.check size={11} sw={2.8}/></span>
            <span style={{ fontSize: 14, color: 'var(--ink)', minWidth: 60 }}>Started:</span>
            <span style={{ fontSize: 14, fontWeight: 600 }}>09/19/2025</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, position: 'relative' }}>
            <span style={{ position: 'absolute', left: -26, width: 20, height: 20, borderRadius: 999, background: '#171B2A',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', zIndex: 1 }}>
              <span style={{ width: 8, height: 8, borderRadius: 999, background: '#fff' }}/>
            </span>
            <span style={{ fontSize: 14, color: 'var(--ink)', minWidth: 60 }}>Renewal:</span>
            <span style={{ fontSize: 14, fontWeight: 600 }}>09/22/2025</span>
          </div>
        </div>
        <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 24, lineHeight: 1.5 }}>
          You can <u>cancel</u> or change your subscription plan. If you cancel, you can keep using the subscription until the next billing date.
        </p>
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton>Cancel or change subscription</DarkButton>
      </div>
    </div>
  );
}

// ─── Content preferences (2-col selectable cards)
function ContentPrefsScreen({ onClose }) {
  const [picks, setPicks] = useState(new Set(['Working out','Self-esteem','Positive thinking','Stress & Anxiety']));
  const toggle = (t) => { const n = new Set(picks); n.has(t) ? n.delete(t) : n.add(t); setPicks(n); };
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Back"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 6px' }}>Content preferences</h2>
      <p style={{ fontSize: 14, color: 'var(--ink-2)', margin: '0 22px 14px' }}>Select all topics that interest you</p>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 10 }}>
          {window.MIRRA.CONTENT_PREFS.map(t => {
            const sel = picks.has(t);
            return (
              <button key={t} onClick={() => toggle(t)} style={{
                background: sel ? '#E9E6F2' : '#fff',
                border: `1.4px solid ${sel ? '#171B2A' : '#E5E0D2'}`,
                borderRadius: 14, padding: '16px 12px',
                fontSize: 14, fontWeight: 500, color: 'var(--ink)',
                textAlign: 'center', minHeight: 56,
              }}>{t}</button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ─── Gender identity
function GenderScreen({ onClose }) {
  const [v, setV] = useState('Female');
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Back"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 4px' }}>Gender identity</h2>
      <p style={{ fontSize: 13, color: 'var(--muted)', margin: '4px 22px 16px' }}>Your gender identity is used to personalize your content</p>
      <div style={{ padding: '0 22px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {['Female','Male','Non-binary','Other'].map(o => (
          <OptionPill key={o} selected={v === o} onClick={() => setV(o)}>{o}</OptionPill>
        ))}
        <button style={{ textAlign: 'center', padding: '14px', fontWeight: 700, fontSize: 15, color: 'var(--ink)' }}>Prefer not to say</button>
      </div>
    </div>
  );
}

// ─── Muted content (empty)
function MutedScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>} right={<button style={{ fontSize: 15 }}>Add</button>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>Muted content</h2>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 28 }}>
        <MutedArt/>
        <p style={{ fontSize: 18, fontWeight: 700, textAlign: 'center', margin: '22px 0 8px' }}>You haven't muted anything yet</p>
        <p style={{ fontSize: 13, color: 'var(--muted)', textAlign: 'center', lineHeight: 1.45, maxWidth: 280 }}>
          When you mute content, you won't see it in your feed, notifications, or widgets
        </p>
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton>Add muted content</DarkButton>
      </div>
    </div>
  );
}
function MutedArt() {
  return (
    <svg viewBox="0 0 140 140" style={{ width: 130, height: 130 }}>
      <circle cx="70" cy="70" r="46" fill="none" stroke="#1A1A1A" strokeWidth="3"/>
      <line x1="38" y1="38" x2="102" y2="102" stroke="#1A1A1A" strokeWidth="3"/>
      <circle cx="62" cy="58" r="10" fill="#C7C2D8" stroke="#1A1A1A" strokeWidth="1.5"/>
      <path d="M50 95c0-10 6-14 16-14s16 4 16 14" fill="#C7C2D8" stroke="#1A1A1A" strokeWidth="1.5"/>
      <ellipse cx="70" cy="115" rx="22" ry="3" fill="rgba(0,0,0,0.1)"/>
    </svg>
  );
}

// ─── Language
function LanguageScreen({ onClose }) {
  const [v, setV] = useState('English');
  const langs = ['English','Español','Français','Deutsch','Italiano','Português','日本語','한국어','中文 (简体)','العربية'];
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>Language</h2>
      <div style={{ padding: '0 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
        {langs.map(l => (
          <button key={l} onClick={() => setV(l)} style={{
            background: '#E9E6F2', borderRadius: 12, padding: '13px 14px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <span style={{ fontSize: 14, color: 'var(--ink)' }}>{l}</span>
            {v === l && <span style={{ width: 22, height: 22, borderRadius: 999, background: '#171B2A', color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}><Icon.check size={12} sw={2.8}/></span>}
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Name (with keyboard)
function NameScreen({ onClose }) {
  const [v, setV] = useState(window.MIRRA.NAME);
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 4px' }}>Name</h2>
      <p style={{ fontSize: 13, color: 'var(--muted)', margin: '4px 22px 14px' }}>Your name is used to personalize your content</p>
      <div style={{ padding: '0 22px' }}>
        <input value={v} onChange={e => setV(e.target.value)} style={{
          width: '100%', height: 44, padding: '0 14px', borderRadius: 999, border: 0,
          background: '#E9E6F2', fontSize: 14, color: 'var(--ink)', outline: 0,
        }}/>
      </div>
      <div style={{ flex: 1 }}/>
      <div style={{ padding: '0 22px 12px' }}>
        <DarkButton onClick={onClose}>Save</DarkButton>
      </div>
      <SimpleKeyboard/>
    </div>
  );
}

// ─── Sound (volume slider)
function SoundScreen({ onClose }) {
  const [vol, setVol] = useState(0.4);
  const ref = useRef(null);
  const onSlide = (e) => {
    const rect = ref.current.getBoundingClientRect();
    const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    setVol(x);
  };
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 4px' }}>Sound</h2>
      <p style={{ fontSize: 13, color: 'var(--ink-2)', margin: '6px 22px 18px' }}>Set the volume you'd like</p>
      <div style={{ padding: '0 22px' }}>
        <p style={{ fontSize: 10, fontWeight: 700, color: 'var(--muted)', letterSpacing: '0.14em', margin: '0 0 8px' }}>THEME SOUND</p>
        <div ref={ref} onPointerDown={(e) => { onSlide(e);
          const onMove = (ev) => onSlide(ev);
          window.addEventListener('pointermove', onMove);
          window.addEventListener('pointerup', () => window.removeEventListener('pointermove', onMove), { once: true });
        }} style={{
          height: 14, borderRadius: 999, background: '#E9E6F2', position: 'relative', cursor: 'grab',
        }}>
          <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${vol*100}%`, background: '#171B2A', borderRadius: '999px 0 0 999px' }}/>
          <div style={{ position: 'absolute', left: `calc(${vol*100}% - 9px)`, top: -2, width: 18, height: 18, borderRadius: 999, background: '#fff',
            boxShadow: '0 1px 4px rgba(0,0,0,0.15)' }}/>
        </div>
      </div>
    </div>
  );
}

// ─── Voice (list with radio)
function VoiceScreen({ onClose }) {
  const [v, setV] = useState('Daniel');
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>Voice</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
        {window.MIRRA.VOICES.map(voice => (
          <button key={voice.name} onClick={() => setV(voice.name)} style={{
            background: '#E9E6F2', borderRadius: 12, padding: '11px 14px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <span style={{ textAlign: 'left' }}>
              <div style={{ fontSize: 14, color: 'var(--ink)' }}>{voice.name}</div>
              <div style={{ fontSize: 11, color: 'var(--muted)' }}>{voice.locale}</div>
            </span>
            <span style={{ width: 22, height: 22, borderRadius: 999,
              border: v === voice.name ? 0 : '1.6px solid #B5B0A2',
              background: v === voice.name ? '#171B2A' : 'transparent', color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
              {v === voice.name && <Icon.check size={12} sw={2.8}/>}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Siri Shortcuts list + native modal
function SiriScreen({ onClose }) {
  const [showNative, setShowNative] = useState(false);
  const cats = ['General','Morning','Positive','Love','Work','Sports','Workout'];
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Back"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 12px' }}>Add Siri Shortcuts</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 0 }}>
        {cats.map((c,i) => (
          <button key={c} onClick={() => setShowNative(true)} style={{
            background: i % 2 === 0 ? '#E9E6F2' : 'transparent',
            padding: '13px 14px',
            display: 'flex', alignItems: 'center', gap: 14,
            borderRadius: i % 2 === 0 ? 12 : 0,
            marginBottom: 4,
          }}>
            <span style={{ width: 22, height: 22, borderRadius: 999, background: '#1A1A1A', color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon.plus size={12} sw={2.5}/>
            </span>
            <span style={{ fontSize: 15, color: 'var(--ink)' }}>{c}</span>
          </button>
        ))}
      </div>
      {showNative && <SiriShortcutNative onClose={() => setShowNative(false)}/>}
    </div>
  );
}
function SiriShortcutNative({ onClose }) {
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 130 }} onClick={onClose}>
      <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: 0, right: 0, top: 30, bottom: 0,
        background: '#fff', borderRadius: '14px 14px 0 0', padding: '20px 22px 30px',
        display: 'flex', flexDirection: 'column',
      }}>
        <button onClick={onClose} style={{ fontSize: 15, color: '#0A7AFF', alignSelf: 'flex-start' }}>Edit in Shortcuts</button>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'flex-start', paddingTop: 30, gap: 12 }}>
          <SiriOrb/>
          <p style={{ fontSize: 22, fontWeight: 800, margin: 0 }}>"Hey Siri,</p>
          <p style={{ fontSize: 22, fontWeight: 800, margin: 0 }}>Motivate me"</p>
          <p style={{ fontSize: 14, color: 'var(--ink-2)', margin: '12px 0 0' }}>Shortcut added. To use it, say this phrase to Siri.</p>
          <button style={{ color: '#0A7AFF', fontSize: 15 }}>Change Voice Phrase</button>
        </div>
        <button style={{ width: '100%', height: 50, borderRadius: 14, background: '#0A7AFF', color: '#fff', fontWeight: 700, fontSize: 17 }}>Done</button>
        <button style={{ marginTop: 12, color: '#0A7AFF', fontSize: 15 }}>Remove Shortcut</button>
      </div>
    </div>
  );
}
function SiriOrb() {
  return (
    <svg viewBox="0 0 80 80" style={{ width: 70, height: 70 }}>
      <defs>
        <radialGradient id="orb">
          <stop offset="0" stopColor="#fff"/>
          <stop offset="0.4" stopColor="#FFB3D9"/>
          <stop offset="0.7" stopColor="#9E8AE0"/>
          <stop offset="1" stopColor="#3A7DCC"/>
        </radialGradient>
      </defs>
      <circle cx="40" cy="40" r="32" fill="url(#orb)"/>
    </svg>
  );
}

// ─── Sign in
function SignInScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 30 }}>
        <MirraMark size={50}/>
        <h2 style={{ fontSize: 22, fontWeight: 800, margin: '14px 0 6px' }}>Keep your data safe</h2>
        <p style={{ fontSize: 13, color: 'var(--ink-2)', textAlign: 'center', margin: '0 0 24px', lineHeight: 1.5 }}>
          Create an account so you never lose<br/>favorites, collections, and settings when<br/>you reinstall or switch devices
        </p>
        <button style={{ width: '100%', height: 50, borderRadius: 999, background: '#171B2A', color: '#fff',
          fontSize: 15, fontWeight: 700, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
          <svg width="16" height="20" viewBox="0 0 17 21" fill="#fff"><path d="M14.7 16.1c-.3.7-.7 1.4-1.2 2-.7.8-1.2 1.4-1.7 1.7-.7.5-1.5.7-2.3.7-.6 0-1.3-.2-2.1-.5-.8-.3-1.6-.5-2.3-.5-.7 0-1.5.2-2.4.5C2 19.6 1.3 19.6 1 19.6c-.8 0-1.5-.5-2.3-1.5-.7-.9-1.3-2-1.7-3.2-.5-1.3-.7-2.6-.7-3.9 0-1.4.3-2.7.9-3.7.5-.8 1.1-1.5 1.9-2 .8-.5 1.7-.8 2.6-.8.7 0 1.6.2 2.7.6 1.1.4 1.7.6 2 .6.2 0 .9-.2 2.2-.7 1.2-.4 2.2-.6 3-.5 2.2.2 3.9 1.1 5 2.7-2 1.2-3 2.9-3 5.1 0 1.7.6 3.2 1.9 4.3.6.5 1.2.9 1.9 1.2-.1.4-.3.8-.5 1.2zM13.4 0c0 1-.4 2-1.2 3-.9 1-2 1.6-3.2 1.5 0-1 .4-2 1.1-3C10.8.6 11.9 0 13.4 0z"/></svg>
          Sign in with Apple
        </button>
        <button style={{ marginTop: 10, width: '100%', height: 50, borderRadius: 999,
          background: '#fff', border: '1.4px solid #171B2A', color: 'var(--ink)',
          fontSize: 15, fontWeight: 700, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
          <svg width="18" height="18" viewBox="0 0 18 18">
            <path d="M17.6 9.2c0-.6-.1-1.2-.2-1.8H9v3.4h4.8c-.2 1.1-.8 2.1-1.8 2.7v2.3h3c1.7-1.6 2.7-4 2.7-6.6z" fill="#4285F4"/>
            <path d="M9 18c2.4 0 4.5-.8 6-2.2l-3-2.3c-.8.6-1.9.9-3 .9-2.3 0-4.3-1.6-5-3.7H1v2.3C2.5 15.9 5.5 18 9 18z" fill="#34A853"/>
            <path d="M4 10.7c-.2-.6-.3-1.2-.3-1.7s.1-1.2.3-1.7V5H1c-.6 1.2-1 2.5-1 4s.4 2.8 1 4l3-2.3z" fill="#FBBC05"/>
            <path d="M9 3.6c1.3 0 2.5.5 3.4 1.3l2.5-2.5C13.4.8 11.4 0 9 0 5.5 0 2.5 2.1 1 5l3 2.3C4.7 5.2 6.7 3.6 9 3.6z" fill="#EA4335"/>
          </svg>
          Sign in with Google
        </button>
      </div>
      <p style={{ fontSize: 11, color: 'var(--muted)', textAlign: 'center', padding: '0 28px 28px', lineHeight: 1.5 }}>
        By signing in, you agree to our <u>Terms & Conditions</u> and <u>Privacy Policy</u>.
      </p>
    </div>
  );
}

// ─── Help (placeholder)
function HelpScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Preferences"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>Help</h2>
      <div style={{ padding: '0 22px', overflow: 'auto', flex: 1 }}>
        {['Getting started','Subscriptions & billing','Reminders & notifications','Widgets','Restore purchase','Contact support'].map(t => (
          <button key={t} style={{
            width: '100%', background: '#E9E6F2', borderRadius: 12, padding: '14px 14px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6,
          }}>
            <span style={{ fontSize: 14, color: 'var(--ink)' }}>{t}</span>
            <Icon.chevronRight size={16} stroke="var(--muted)"/>
          </button>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {
  PreferencesScreen, ManageSubScreen, ContentPrefsScreen, GenderScreen, MutedScreen,
  LanguageScreen, NameScreen, SoundScreen, VoiceScreen, SiriScreen, SignInScreen, HelpScreen,
});
