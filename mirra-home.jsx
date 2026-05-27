// mirra-home.jsx — home feed, share sheet, edit theme, themes browser
// Globals: Icon, MIRRA, HeaderBar, CloseBtn, BackArrow, DarkButton, GradButton, Toast

// ─── QuoteBg: cinematic photo + dim overlay (used in feed and share preview)
function QuoteBg({ theme, children, dim = 0.36 }) {
  const t = window.MIRRA.THEMES.find(x => x.id === theme) || window.MIRRA.THEMES[0];
  const plain = !t.photo && !t.dark;
  return (
    <div style={{
      position: 'absolute', inset: 0, overflow: 'hidden',
      background: plain ? 'var(--bg)' : (t.dark ? '#0A0A0A' : '#1A1A1A'),
    }}>
      {t.photo && (
        <>
          <div style={{ position: 'absolute', inset: 0,
            backgroundImage: `url(${t.photo})`, backgroundSize: 'cover', backgroundPosition: 'center' }}/>
          <div style={{ position: 'absolute', inset: 0,
            background: `linear-gradient(180deg, rgba(0,0,0,${dim*0.4}) 0%, rgba(0,0,0,${dim*0.6}) 60%, rgba(0,0,0,${dim*1.4}) 100%)` }}/>
        </>
      )}
      {children}
    </div>
  );
}

// ─── HomeScreen: vertical snap scroller of quote cards
function HomeScreen({ state, dispatch, openShare, openTheme, openCollections, openProfile, openExplore, showTip5, showStreak }) {
  const ref = useRef(null);
  const [active, setActive] = useState(0);
  const [heartBurst, setHeartBurst] = useState(0);

  const onScroll = () => {
    const el = ref.current;
    if (!el) return;
    const i = Math.round(el.scrollTop / el.clientHeight);
    if (i !== active) setActive(i);
  };

  const list = window.MIRRA.AFFIRMATIONS;
  const favCount = state.favorites.length;

  return (
    <div ref={ref} onScroll={onScroll} style={{
      position: 'absolute', inset: 0, overflow: 'auto', scrollSnapType: 'y mandatory',
    }}>
      {list.map((q, i) => (
        <QuoteCard
          key={i}
          quote={q}
          theme={state.theme}
          favorited={state.favorites.includes(i)}
          favCount={favCount}
          showProgress={favCount < 5}
          onFavorite={() => {
            const has = state.favorites.includes(i);
            dispatch({ type: 'toggleFav', idx: i });
            if (!has) setHeartBurst(b => b + 1);
          }}
          onShare={() => openShare(i)}
          onTheme={openTheme}
          onProfile={openProfile}
          onExplore={openExplore}
          heartBurst={heartBurst}
        />
      ))}
      {showStreak && <StreakBanner/>}
      {showTip5 && active === 1 && <Tip5Overlay/>}
    </div>
  );
}

function QuoteCard({ quote, theme, favorited, favCount, showProgress, onFavorite, onShare, onTheme, onProfile, onExplore, heartBurst }) {
  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%', scrollSnapAlign: 'start', minHeight: '100%',
    }}>
      <QuoteBg theme={theme}>
        {/* Top center: heart progress (only until 5 favorited) */}
        {showProgress && (
          <div style={{
            position: 'absolute', top: 64, left: '50%', transform: 'translateX(-50%)',
            display: 'flex', alignItems: 'center', gap: 8, zIndex: 4,
            color: '#fff',
          }}>
            <Icon.heart size={16} stroke="#fff"/>
            <span style={{ fontSize: 12, fontWeight: 600 }}>{favCount}/5</span>
            <div style={{ width: 120, height: 3, borderRadius: 4, background: 'rgba(255,255,255,0.3)', overflow: 'hidden' }}>
              <div style={{
                width: `${Math.min(1, favCount/5)*100}%`, height: '100%',
                background: '#fff', transition: 'width 0.3s ease',
              }}/>
            </div>
          </div>
        )}

        {/* Center: quote */}
        <div style={{
          position: 'absolute', inset: 0, padding: '120px 28px 150px',
          display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center',
        }}>
          <p className="serif anim-fadeslow" style={{
            color: '#fff', fontSize: 22, lineHeight: 1.45, margin: 0,
            textShadow: '0 2px 16px rgba(0,0,0,0.5)', maxWidth: 320, fontWeight: 400,
          }}>{quote}</p>
        </div>

        {/* Bottom center: share + heart (no chrome, just icons) */}
        <div style={{
          position: 'absolute', left: 0, right: 0, bottom: 96,
          display: 'flex', justifyContent: 'center', gap: 36, zIndex: 4,
        }}>
          <button onClick={onShare} className="no-tap" style={{ color: '#fff', padding: 4 }}>
            <Icon.shareIOS size={26} stroke="#fff" sw={1.4}/>
          </button>
          <button onClick={onFavorite} className="no-tap" style={{ color: '#fff', padding: 4, position: 'relative' }}>
            {favorited
              ? <Icon.heartFill size={26} stroke="#fff" fill="#fff"/>
              : <Icon.heart size={26} stroke="#fff" sw={1.4}/>}
            {/* heart burst animation */}
            {heartBurst > 0 && (
              <span key={heartBurst} style={{
                position: 'absolute', left: '50%', top: '50%',
                transform: 'translate(-50%,-50%)', pointerEvents: 'none',
                animation: 'heartBurst 700ms ease-out forwards',
              }}>
                <Icon.heartFill size={26} stroke="#fff" fill="#fff"/>
              </span>
            )}
          </button>
        </div>

        {/* Bottom row: Mix / paint + profile */}
        <div style={{
          position: 'absolute', left: 14, right: 14, bottom: 42, zIndex: 5,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <button onClick={onExplore} className="no-tap" style={{
            display: 'flex', alignItems: 'center', gap: 6,
            background: 'rgba(0,0,0,0.34)', backdropFilter: 'blur(10px)',
            color: '#fff', padding: '7px 13px 7px 8px', borderRadius: 999,
            position: 'relative',
          }}>
            <Icon.grid size={18} stroke="#fff"/>
            <span style={{ fontSize: 12, fontWeight: 500 }}>Mix</span>
            <span style={{
              position: 'absolute', top: -6, left: -4,
              background: '#F0B2A3', color: '#1A1A1A',
              padding: '1px 7px', fontSize: 9, fontWeight: 700, borderRadius: 999,
            }}>NEW</span>
          </button>
          <div style={{ display: 'flex', gap: 6 }}>
            <button onClick={onTheme} className="no-tap" style={{
              width: 36, height: 36, borderRadius: 999,
              background: 'rgba(0,0,0,0.34)', backdropFilter: 'blur(10px)', color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><Icon.paint size={17} stroke="#fff"/></button>
            <button onClick={onProfile} className="no-tap" style={{
              width: 36, height: 36, borderRadius: 999,
              background: 'rgba(0,0,0,0.34)', backdropFilter: 'blur(10px)', color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><Icon.user size={17} stroke="#fff"/></button>
          </div>
        </div>
      </QuoteBg>
      <style dangerouslySetInnerHTML={{__html:`
        @keyframes heartBurst {
          0% { opacity: 1; transform: translate(-50%,-50%) scale(1); }
          50% { transform: translate(-50%,-50%) scale(1.8); opacity: 1; }
          100% { transform: translate(-50%,-50%) scale(3); opacity: 0; }
        }
      `}}/>
    </div>
  );
}

// ─── Streak banner (drops down from top of feed)
function StreakBanner() {
  const days = ['Fr','Sa','Su','Mo','Tu','We','Th'];
  return (
    <div className="anim-pop" style={{
      position: 'absolute', top: 54, left: 14, right: 14, zIndex: 70,
      background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
      borderRadius: 22, padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12,
      boxShadow: '0 12px 28px -8px rgba(0,0,0,0.25)',
    }}>
      <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon.flame size={48}/>
        <span style={{ position: 'absolute', color: '#fff', fontSize: 15, fontWeight: 700,
          fontFamily: 'Instrument Serif', marginTop: 6 }}>1</span>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 700 }}>New streak started</div>
        <div style={{ display: 'flex', gap: 4, marginTop: 6 }}>
          {days.map((d, i) => (
            <div key={d} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 1, flex: 1 }}>
              <span style={{ fontSize: 9, color: 'var(--muted)' }}>{d}</span>
              <div style={{ width: 16, height: 16, borderRadius: 999,
                background: i === 0 ? 'linear-gradient(120deg,#B79DE8,#F0B2A3)' : 'rgba(0,0,0,0.08)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}>
                {i === 0 && <Icon.check size={9} sw={3} stroke="#fff"/>}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── "Favorite 5" coachmark
function Tip5Overlay({ onDismiss }) {
  return (
    <div onClick={onDismiss} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)', zIndex: 80 }}>
      <div className="anim-pop" style={{
        position: 'absolute', right: 60, bottom: 174,
        width: 52, height: 52, borderRadius: 999,
        boxShadow: '0 0 0 9999px rgba(0,0,0,0.55), 0 0 0 4px rgba(255,255,255,0.2)',
        background: 'rgba(255,255,255,0.04)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon.heart size={22} stroke="#fff" sw={1.4}/>
      </div>
      <div className="anim-pop" style={{
        position: 'absolute', right: 26, bottom: 245,
        background: '#fff', padding: '10px 12px', borderRadius: 14,
        maxWidth: 200, fontSize: 13, color: 'var(--ink)', lineHeight: 1.35,
        boxShadow: '0 12px 28px rgba(0,0,0,0.2)',
      }}>
        Get started: favorite 5 quotes to personalize your feed
        <div style={{ position: 'absolute', right: 26, bottom: -7,
          width: 14, height: 14, background: '#fff', transform: 'rotate(45deg)' }}/>
      </div>
    </div>
  );
}

// ─── "Your feed's set up" toast (full-width pill)
function FeedSetUpToast() {
  return (
    <div className="anim-pop" style={{
      position: 'absolute', top: 60, left: 14, right: 14, zIndex: 70,
      background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
      borderRadius: 16, padding: '12px 14px', display: 'flex', gap: 10, alignItems: 'flex-start',
      boxShadow: '0 12px 28px -8px rgba(0,0,0,0.22)',
    }}>
      <Icon.heart size={20} stroke="var(--ink)"/>
      <span style={{ fontSize: 13, color: 'var(--ink)', lineHeight: 1.35 }}>
        Your feed's set up! Personalize it even more by adding more quotes to favorites.
      </span>
    </div>
  );
}

// ─── "Theme changed!" toast (with social actions)
function ThemeChangedToast({ onClose }) {
  useEffect(() => { const t = setTimeout(onClose, 4500); return () => clearTimeout(t); }, []);
  return (
    <div className="anim-pop" style={{
      position: 'absolute', top: 60, left: 14, right: 14, zIndex: 70,
      background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
      borderRadius: 18, padding: '10px 12px 12px',
      boxShadow: '0 12px 28px -8px rgba(0,0,0,0.22)',
    }}>
      <p style={{ fontSize: 13, fontWeight: 600, margin: '4px 0 8px 4px' }}>Theme changed! Want to share this quote?</p>
      <div style={{ display: 'flex', justifyContent: 'space-around', gap: 4 }}>
        {[
          { name: 'Facebook', color: '#1877F2', glyph: <Icon.fb size={20} stroke="#fff"/> },
          { name: 'TikTok',   color: '#000',    glyph: <Icon.tiktok size={20} stroke="#fff"/> },
          { name: 'Facebook Stories', color: '#1877F2', glyph: <Icon.fb size={20} stroke="#fff"/> },
          { name: 'Share via…', color: '#EAEAE5', glyph: <Icon.shareIOS size={20} stroke="var(--ink)"/> },
        ].map(s => (
          <div key={s.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 60 }}>
            <div style={{ width: 38, height: 38, borderRadius: 999, background: s.color,
              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{s.glyph}</div>
            <span style={{ fontSize: 10, color: 'var(--ink)' }}>{s.name}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Saved toast (with mini collection thumbnail)
function SavedToast() {
  return (
    <Toast>
      <span style={{ width: 22, height: 22, borderRadius: 4,
        backgroundImage: `url(${window.MIRRA.PHOTOS.cabin})`, backgroundSize: 'cover' }}/>
      Saved!
    </Toast>
  );
}

// ─── Spread the Motivation popup (small "Want to share?" before share opens)
function SpreadCard({ onClose, onShare }) {
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 120 }} onClick={onClose}>
      <div className="anim-pop" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%,-50%)',
        background: 'var(--bg)', borderRadius: 22, padding: '22px 22px 18px', width: '78%', textAlign: 'center',
        boxShadow: '0 24px 40px rgba(0,0,0,0.3)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>
          <Icon.shareIOS size={32}/>
        </div>
        <h3 style={{ fontSize: 18, fontWeight: 700, margin: '0 0 6px' }}>Spread the Motivation</h3>
        <p style={{ fontSize: 13, color: 'var(--muted)', margin: '0 0 14px', lineHeight: 1.4 }}>
          Share an inspiring quote with someone who might need it today.
        </p>
        <DarkButton onClick={onShare}>Share a quote</DarkButton>
        <button onClick={onClose} style={{ width: '100%', padding: 12, fontSize: 14, color: 'var(--muted)', marginTop: 6 }}>Not now</button>
      </div>
    </div>
  );
}

// ─── Share Sheet (custom sheet with mini quote card preview + actions)
function ShareSheet({ onClose, quote, theme, onCopy, onAddCollection, onSaveVideo, openEditTheme }) {
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.45)', zIndex: 100 }} onClick={onClose}>
      <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: 0, right: 0, top: 60, bottom: 0,
        background: 'var(--bg)', borderRadius: '24px 24px 0 0',
        padding: '14px 18px 22px', display: 'flex', flexDirection: 'column',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <CloseBtn onClick={onClose}/>
          <span style={{ fontSize: 14, fontWeight: 600 }}>Share</span>
          <span style={{ width: 32 }}/>
        </div>
        {/* mini preview card (matches current theme) */}
        <div style={{
          width: '74%', aspectRatio: '9/16', margin: '12px auto 18px',
          borderRadius: 16, overflow: 'hidden', position: 'relative',
          background: '#1A1A1A',
          boxShadow: '0 16px 32px -8px rgba(0,0,0,0.35)',
        }}>
          <QuoteBg theme={theme} dim={0.36}>
            <div style={{ position: 'absolute', inset: 0, padding: '0 20px',
              display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
              <p className="serif" style={{ color: '#fff', fontSize: 13, lineHeight: 1.45, margin: 0,
                textShadow: '0 2px 12px rgba(0,0,0,0.5)' }}>{quote}</p>
            </div>
          </QuoteBg>
        </div>
        {/* 3 chip buttons */}
        <div style={{ display: 'flex', gap: 10 }}>
          <ShareChip icon={<Icon.download size={18}/>} label="Save video" onClick={onSaveVideo}/>
          <ShareChip icon={<Icon.bookmark size={18}/>} label="Add to collection" onClick={onAddCollection}/>
          <ShareChip icon={<Icon.copy size={18}/>} label="Copy text" onClick={onCopy}/>
        </div>
        {/* social row */}
        <div style={{ display: 'flex', gap: 14, paddingTop: 18, overflowX: 'auto', marginInline: -2, paddingInline: 2 }}>
          <SocialBtn label="Edit theme" onClick={openEditTheme}>
            <MiniThemeTile theme={theme}/>
          </SocialBtn>
          <SocialBtn label="Facebook" bg="#1877F2"><Icon.fb size={22} stroke="#fff"/></SocialBtn>
          <SocialBtn label="TikTok" bg="#000"><Icon.tiktok size={22} stroke="#fff"/></SocialBtn>
          <SocialBtn label="Facebook Stories" bg="#1877F2">
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
              <Icon.fb size={22} stroke="#fff"/>
              <span style={{ position: 'absolute', width: 10, height: 10, borderRadius: 999, background: '#1877F2', border: '1.5px solid #fff', bottom: -2, right: -2,
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 8, color: '#fff' }}>+</span>
            </div>
          </SocialBtn>
          <SocialBtn label="Facebook Reels" bg="#1877F2">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.8"><rect x="4" y="6" width="16" height="12" rx="2"/><path d="M10 9l5 3-5 3z" fill="#fff"/></svg>
          </SocialBtn>
        </div>
      </div>
    </div>
  );
}
function ShareChip({ icon, label, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      padding: '10px 6px', borderRadius: 12,
      background: '#fff', border: '1px solid var(--line)',
      fontSize: 12, fontWeight: 500, color: 'var(--ink)',
    }}>{icon}<span style={{ whiteSpace: 'nowrap' }}>{label}</span></button>
  );
}
function SocialBtn({ children, label, bg, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, minWidth: 60,
    }}>
      <div style={{
        width: 46, height: 46, borderRadius: 999, background: bg || 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{children}</div>
      <span style={{ fontSize: 10.5, color: 'var(--muted)', textAlign: 'center', maxWidth: 64, lineHeight: 1.2 }}>{label}</span>
    </button>
  );
}
function MiniThemeTile({ theme }) {
  const t = window.MIRRA.THEMES.find(x => x.id === theme) || window.MIRRA.THEMES[0];
  return (
    <div style={{
      width: 46, height: 46, borderRadius: 10, overflow: 'hidden', position: 'relative',
      background: t.photo ? `url(${t.photo})` : (t.dark ? '#1A1A1A' : '#fff'),
      backgroundSize: 'cover', backgroundPosition: 'center',
      border: '1px solid var(--line)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {t.photo && <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.18)' }}/>}
      <span className="serif" style={{ fontSize: 6, color: t.photo || t.dark ? '#fff' : 'var(--ink)', position: 'relative',
        padding: '2px 4px', textAlign: 'center', lineHeight: 1.1, maxWidth: 42 }}>
        My positive thoughts shape my feelings
      </span>
    </div>
  );
}

// ─── iOS native share sheet (the system one for "Save video")
function IOSShareSheet({ onClose, quote }) {
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 130 }} onClick={onClose}>
      <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: 8, right: 8, bottom: 8,
        background: 'rgba(245,242,235,0.96)', backdropFilter: 'blur(20px)',
        borderRadius: 14, padding: '14px 14px 6px',
        boxShadow: '0 16px 36px rgba(0,0,0,0.2)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
          <div style={{
            width: 50, height: 50, borderRadius: 6,
            backgroundImage: `url(${window.MIRRA.PHOTOS.cabin})`, backgroundSize: 'cover',
          }}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 500, color: 'var(--ink)', maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              A600B61C-9E7C-4480-94D6-B01B7D…
            </div>
            <div style={{ fontSize: 11, color: 'var(--muted)' }}>Video · 13.9 MB</div>
          </div>
          <CloseBtn onClick={onClose} light/>
        </div>
        <div style={{ display: 'flex', gap: 14, paddingBottom: 14, overflowX: 'auto' }}>
          {[
            { name: 'AirDrop', bg: 'linear-gradient(135deg,#1B7FFF,#9EE3FF)', glyph: '◉' },
            { name: 'JW Library', bg: '#5B2C8F', glyph: 'JW' },
            { name: 'Messages', bg: '#34C759', glyph: '💬' },
            { name: 'Mail', bg: 'linear-gradient(135deg,#1B7FFF,#9EE3FF)', glyph: '✉' },
            { name: 'WhatsApp', bg: '#25D366', glyph: '☎' },
          ].map(s => (
            <div key={s.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 60 }}>
              <div style={{ width: 56, height: 56, borderRadius: 14, background: s.bg,
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 18 }}>{s.glyph}</div>
              <span style={{ fontSize: 11, color: 'var(--ink)' }}>{s.name}</span>
            </div>
          ))}
        </div>
        <div style={{ borderTop: '0.5px solid rgba(0,0,0,0.1)', paddingTop: 8 }}>
          {['Copy','Save Video','New Quick Note','Add Tags','Save to Files','Download in SHAREit'].map((a,i) => (
            <div key={a} style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '11px 6px', borderBottom: i < 5 ? '0.5px solid rgba(0,0,0,0.08)' : 'none',
            }}>
              <span style={{ fontSize: 15, color: 'var(--ink)' }}>{a}</span>
              <span style={{ fontSize: 18, color: 'var(--ink)' }}>{
                a === 'Copy' ? '◫' : a === 'Save Video' ? '↓' : a === 'New Quick Note' ? '✎' :
                a === 'Add Tags' ? '⌗' : a === 'Save to Files' ? '📁' : '↓'
              }</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Edit Theme overlay (text styling on top of a quote bg)
function EditThemeOverlay({ onClose, state, dispatch, quote, onApply }) {
  const [tab, setTab] = useState('text'); // 'background' | 'text'
  const [size, setSize] = useState(20);
  const [theme, setTheme] = useState(state.theme);
  const [fontIdx, setFontIdx] = useState(0);
  const [color, setColor] = useState('#fff');
  const fonts = ['Mirra-Serif', 'Mirra-Mono', 'Mirra-Sans'];
  const palette = ['#FFFFFF','#1A1A1A','#7B7B7B','#B79DE8','#F0B2A3','#F8D2A8','#B6E1C1','#8CC8E5','#E25C5C'];

  const fontFamily = fonts[fontIdx] === 'Mirra-Serif' ? 'Instrument Serif, serif'
    : fonts[fontIdx] === 'Mirra-Mono' ? 'Geist Mono, monospace' : 'Geist, sans-serif';

  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: '#000', zIndex: 110 }}>
      <QuoteBg theme={theme} dim={0.16}>
        {/* top bar */}
        <div style={{ position: 'absolute', top: 56, left: 16, right: 16, display: 'flex', justifyContent: 'space-between', zIndex: 5 }}>
          <CloseBtn onClick={onClose} light/>
          <button onClick={() => { onApply?.(theme); onClose(); }} style={{
            padding: '7px 14px', borderRadius: 999,
            background: 'rgba(255,255,255,0.96)', color: '#1A1A1A', fontSize: 14, fontWeight: 600,
          }}>Done</button>
        </div>
        {/* quote */}
        <div style={{
          position: 'absolute', inset: 0, padding: '0 28px 230px',
          display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center',
        }}>
          <p style={{
            color, fontSize: size, lineHeight: 1.45, margin: 0,
            textShadow: theme !== 'plain' ? '0 2px 12px rgba(0,0,0,0.5)' : 'none',
            fontFamily, fontWeight: 400,
          }}>{quote}</p>
        </div>
        {/* size slider (right side, only when Text tab) */}
        {tab === 'text' && (
          <div style={{
            position: 'absolute', right: 16, top: 140, bottom: 220,
            width: 4, background: 'rgba(255,255,255,0.4)', borderRadius: 4,
          }}>
            <div style={{
              position: 'absolute', left: -8, top: `${100 - ((size-14)/(32-14))*100}%`,
              width: 20, height: 20, borderRadius: 999, background: '#171B2A',
              border: '2px solid #fff', transform: 'translate(0,-50%)', cursor: 'grab',
            }}
            onPointerDown={(e) => {
              const target = e.currentTarget.parentElement;
              const rect = target.getBoundingClientRect();
              const onMove = (ev) => {
                const y = (ev.clientY - rect.top) / rect.height;
                const v = 32 - Math.max(0, Math.min(1, y)) * (32 - 14);
                setSize(Math.round(v));
              };
              window.addEventListener('pointermove', onMove);
              window.addEventListener('pointerup', () => window.removeEventListener('pointermove', onMove), { once: true });
            }}/>
          </div>
        )}
        {/* bottom toolbar + tab switcher */}
        <div style={{
          position: 'absolute', left: 14, right: 14, bottom: 34,
          display: 'flex', flexDirection: 'column', gap: 8, zIndex: 5,
        }}>
          {tab === 'text' && (
            <FontPickerRow value={fontIdx} onChange={setFontIdx} fonts={fonts}/>
          )}
          {tab === 'text' && (
            <ColorRow value={color} onChange={setColor} palette={palette}/>
          )}
          <div style={{
            background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
            borderRadius: 14, padding: 8, display: 'flex', justifyContent: 'space-around',
          }}>
            {tab === 'background' ? (
              <>
                <ToolBtn><Icon.cameraIcon size={20}/></ToolBtn>
                <ToolBtn><Icon.leaf size={20}/></ToolBtn>
                <ToolBtn><Icon.colorWheel size={20}/></ToolBtn>
              </>
            ) : (
              <>
                <ToolBtn><Icon.textAa size={20}/></ToolBtn>
                <ToolBtn><Icon.colorWheel size={20}/></ToolBtn>
                <ToolBtn><Icon.alignEq size={20}/></ToolBtn>
                <ToolBtn><Icon.textA size={20}/></ToolBtn>
              </>
            )}
          </div>
          <div style={{
            background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
            borderRadius: 12, padding: 4, display: 'flex',
          }}>
            {['Background','Text'].map(t2 => (
              <button key={t2} onClick={() => setTab(t2.toLowerCase())} style={{
                flex: 1, padding: '9px 0', borderRadius: 9, fontSize: 13, fontWeight: 600,
                background: tab === t2.toLowerCase() ? '#171B2A' : 'transparent',
                color: tab === t2.toLowerCase() ? '#fff' : 'var(--ink)',
              }}>{t2}</button>
            ))}
          </div>
        </div>
      </QuoteBg>
    </div>
  );
}
function ToolBtn({ children, onClick }) {
  return <button onClick={onClick} className="no-tap" style={{ width: 38, height: 38, borderRadius: 999, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{children}</button>;
}
function FontPickerRow({ value, onChange, fonts }) {
  return (
    <div style={{
      background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
      borderRadius: 14, padding: 8, display: 'flex', alignItems: 'center', gap: 8,
      overflowX: 'auto',
    }}>
      <button onClick={() => onChange(Math.max(0, value-1))} style={{ width: 28, height: 28, color: 'var(--ink)' }}><Icon.chevronLeft size={16}/></button>
      <button style={{ width: 28, height: 28, color: 'var(--ink)' }}><Icon.ellipsis size={16}/></button>
      {fonts.map((f, i) => (
        <button key={f} onClick={() => onChange(i)} style={{
          padding: '6px 14px', borderRadius: 9,
          background: i === value ? '#171B2A' : 'transparent',
          color: i === value ? '#fff' : 'var(--ink)',
          fontSize: 12, fontWeight: 700, whiteSpace: 'nowrap',
          fontFamily: f === 'Mirra-Serif' ? 'Instrument Serif' : f === 'Mirra-Mono' ? 'Geist Mono' : 'Geist',
          fontStyle: f === 'Mirra-Serif' ? 'normal' : 'normal',
        }}>{f}</button>
      ))}
    </div>
  );
}
function ColorRow({ value, onChange, palette }) {
  return (
    <div style={{
      background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
      borderRadius: 14, padding: 8, display: 'flex', alignItems: 'center', gap: 8,
      overflowX: 'auto',
    }}>
      <button style={{ width: 28, height: 28, color: 'var(--ink)' }}><Icon.chevronLeft size={16}/></button>
      <button style={{
        width: 26, height: 26, borderRadius: 999, padding: 3,
        background: 'conic-gradient(from 0deg, #F0B2A3, #F8D2A8, #CFE0B8, #B79DE8, #E8B5D5, #F0B2A3)',
      }}><div style={{ width: '100%', height: '100%', borderRadius: 999, background: '#fff' }}/></button>
      {palette.map(c => (
        <button key={c} onClick={() => onChange(c)} style={{
          width: 26, height: 26, borderRadius: 999, background: c,
          border: c === value ? '2px solid #1A1A1A' : '1px solid rgba(0,0,0,0.15)',
          flexShrink: 0,
        }}/>
      ))}
    </div>
  );
}

// ─── Themes browser (full sheet)
function ThemesScreen({ onClose, state, dispatch, openMixes }) {
  const [tab, setTab] = useState('All');
  const tabs = ['+ Create','All','New','Seasonal','Most popular','Recent'];
  const themes = window.MIRRA.THEMES;
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '50px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <CloseBtn onClick={onClose}/>
        <span style={{ width: 32 }}/>
      </div>
      <div style={{ padding: '4px 20px 0' }}>
        <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 0 14px' }}>Themes</h2>
        <div style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 14 }}>
          {tabs.map(t => (
            <button key={t} onClick={() => setTab(t)} style={{
              padding: '7px 14px', borderRadius: 999,
              background: tab === t ? '#171B2A' : '#E9E6F2',
              color: tab === t ? '#fff' : 'var(--ink)',
              fontSize: 13, fontWeight: 500, whiteSpace: 'nowrap', flexShrink: 0,
            }}>{t}</button>
          ))}
        </div>
      </div>
      <div style={{ padding: '0 20px 22px', overflow: 'auto', flex: 1 }}>
        {/* Theme mixes section */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <h3 style={{ fontSize: 17, fontWeight: 800, margin: 0 }}>Theme mixes</h3>
          <button onClick={openMixes} style={{ fontSize: 13, color: 'var(--ink)', fontWeight: 500 }}>See all</button>
        </div>
        <div style={{ display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 14, marginInline: -2 }}>
          {window.MIRRA.THEME_MIXES.slice(0, 4).map(m => (
            <MixCard key={m.id} mix={m} onClick={openMixes}/>
          ))}
        </div>
        {/* For you grid */}
        <h3 style={{ fontSize: 17, fontWeight: 800, margin: '8px 0 12px' }}>For you</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 10 }}>
          {themes.map(t => (
            <ThemeTile key={t.id} t={t} selected={state.theme === t.id} onClick={() => { dispatch({ type: 'setTheme', id: t.id }); onClose(); dispatch({ type: 'openOverlay', name: 'themeChangedToast' }); setTimeout(() => dispatch({ type: 'closeOverlay' }), 4500); }} small/>
          ))}
        </div>
      </div>
    </div>
  );
}
function MixCard({ mix, onClick }) {
  const photo = mix.photo;
  const text = mix.label;
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: 130, aspectRatio: '2.2/1', borderRadius: 12, position: 'relative', overflow: 'hidden',
      flexShrink: 0,
      background: photo ? `url(${photo})` : (mix.dark ? '#171B2A' : (mix.purple ? '#4226A8' : '#EFE9DC')),
      backgroundSize: 'cover', backgroundPosition: 'center',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {photo && <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.05) 30%, rgba(0,0,0,0.4) 100%)' }}/>}
      <span className={mix.mono ? 'mono' : 'serif'} style={{
        fontSize: 14, fontWeight: mix.bold ? 800 : 500,
        fontStyle: mix.italic ? 'italic' : 'normal',
        color: photo || mix.dark || mix.purple ? '#fff' : 'var(--ink)',
        textTransform: mix.caps ? 'uppercase' : 'none',
        letterSpacing: mix.caps ? '0.06em' : 0,
        position: 'relative',
        textShadow: photo ? '0 2px 8px rgba(0,0,0,0.4)' : 'none',
      }}>{text}</span>
    </button>
  );
}

// ─── Theme Mixes (2-col category grid)
function ThemeMixesScreen({ onClose, onPickMix }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<BackArrow onClick={onClose} label="Themes"/>}
        center="Theme mixes"
        right={<button style={{ fontSize: 15, color: 'var(--ink)', fontWeight: 500 }}>Create</button>}
      />
      <div style={{ padding: '14px 18px 22px', overflow: 'auto', flex: 1 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 10 }}>
          {window.MIRRA.THEME_MIXES.map(m => <BigMixCard key={m.id} mix={m} onClick={onClose}/>)}
        </div>
      </div>
    </div>
  );
}
function BigMixCard({ mix, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      aspectRatio: '1.55', borderRadius: 14, position: 'relative', overflow: 'hidden',
      background: mix.photo ? `url(${mix.photo})` : (mix.dark ? '#171B2A' : (mix.purple ? '#4226A8' : '#EFE9DC')),
      backgroundSize: 'cover', backgroundPosition: 'center',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {mix.photo && <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.05) 30%, rgba(0,0,0,0.55) 100%)' }}/>}
      <span className={mix.mono ? 'mono' : 'serif'} style={{
        fontSize: 18, fontWeight: mix.bold ? 800 : 500,
        fontStyle: mix.italic ? 'italic' : 'normal',
        color: mix.photo || mix.dark || mix.purple ? '#fff' : 'var(--ink)',
        textTransform: mix.caps ? 'uppercase' : 'none',
        letterSpacing: mix.caps ? '0.06em' : 0,
        position: 'relative',
        textShadow: mix.photo ? '0 2px 8px rgba(0,0,0,0.4)' : 'none',
      }}>{mix.label}</span>
    </button>
  );
}

// ─── Rate dialog (2-step)
function RateDialog({ stage, onCancel, onSubmit, onWriteReview, onOK }) {
  const [stars, setStars] = useState(5);
  if (stage === 'rate') return (
    <NativeAlert
      icon={<MirraMark size={42}/>}
      title="Enjoying Mirra?"
      message={<>Tap a star to rate it on the App Store.<div style={{ display: 'flex', gap: 6, justifyContent: 'center', marginTop: 10 }}>
        {[1,2,3,4,5].map(n => <button key={n} onClick={() => setStars(n)}>
          {n <= stars ? <Icon.starFill size={22} stroke="#0A7AFF" fill="#0A7AFF"/> : <Icon.star size={22} stroke="#0A7AFF"/>}
        </button>)}
      </div></>}
      actions={[
        { label: 'Cancel', onClick: onCancel },
        { label: 'Submit', primary: true, onClick: onSubmit },
      ]}/>
  );
  return (
    <NativeAlert
      icon={<MirraMark size={42}/>}
      title="Thanks for your feedback."
      message={<>You can also write a review.<div style={{ display: 'flex', gap: 4, justifyContent: 'center', marginTop: 8, color: '#F0AC2A' }}>
        {[1,2,3,4,5].map(n => <Icon.starFill key={n} size={16} stroke="#F0AC2A" fill="#F0AC2A"/>)}
      </div></>}
      actions={[
        { label: 'Write a Review', primary: true, onClick: onWriteReview },
        { label: 'OK', onClick: onOK },
      ]}/>
  );
}

Object.assign(window, {
  QuoteBg, HomeScreen, QuoteCard, StreakBanner, Tip5Overlay, FeedSetUpToast,
  ThemeChangedToast, SavedToast, SpreadCard,
  ShareSheet, IOSShareSheet, EditThemeOverlay,
  ThemesScreen, ThemeMixesScreen, ThemeTile, RateDialog,
});
