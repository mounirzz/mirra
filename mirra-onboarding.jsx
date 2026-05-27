// mirra-onboarding.jsx — all onboarding screens
// Globals used: Icon, MIRRA, DarkButton, GradButton, OptionPill, ProgressBar, SkipBtn, ...

// ─── Welcome (rainy cabin photo + "Swipe up" hint)
function WelcomeScreen({ onContinue }) {
  return (
    <div onClick={onContinue} style={{
      position: 'absolute', inset: 0,
      backgroundImage: `url(${window.MIRRA.PHOTOS.cabin})`,
      backgroundSize: 'cover', backgroundPosition: 'center',
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
      padding: '0 28px 50px', cursor: 'pointer',
    }}>
      <div/>
      <div className="anim-fadeslow" style={{ textAlign: 'center', marginBottom: 130 }}>
        <p className="serif" style={{
          color: '#fff', fontSize: 28, lineHeight: 1.15, margin: 0,
          textShadow: '0 2px 16px rgba(0,0,0,0.5)', fontWeight: 400,
        }}>Welcome to Mirra</p>
      </div>
      <div className="anim-fadeslow" style={{
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
        color: '#fff', animationDelay: '0.4s',
      }}>
        <div style={{ animation: 'bobUp 1.6s ease-in-out infinite alternate' }}>
          <Icon.swipeUp size={22} stroke="#fff" sw={1.6}/>
        </div>
        <span style={{ fontSize: 13, opacity: 0.85, letterSpacing: '0.02em' }}>Swipe up</span>
      </div>
      <style dangerouslySetInnerHTML={{__html: '@keyframes bobUp { from{transform:translateY(0);} to{transform:translateY(-6px);} }'}}/>
    </div>
  );
}

// ─── Intro: shelf + frames illustration + "Let's do it"
function PersonalizedShelf() {
  return (
    <svg viewBox="0 0 250 160" style={{ width: 250, height: 160 }}>
      {/* shelf */}
      <rect x="14" y="110" width="220" height="8" rx="1.5" fill="#1F2436"/>
      {/* reed diffuser */}
      <rect x="38" y="80" width="20" height="30" rx="3" fill="#2A2F40"/>
      <path d="M44 80 L42 64 M48 80 L48 56 M52 80 L54 66" stroke="#5A5F72" strokeWidth="1.5" strokeLinecap="round"/>
      {/* small frame */}
      <rect x="72" y="58" width="38" height="52" fill="#171B2A"/>
      <text x="78" y="100" fontFamily="Instrument Serif" fontSize="40" fill="#fff">"</text>
      {/* large gradient frame */}
      <defs>
        <linearGradient id="frgrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#B79DE8"/>
          <stop offset="0.5" stopColor="#E0AECB"/>
          <stop offset="1" stopColor="#F0B2A3"/>
        </linearGradient>
      </defs>
      <rect x="120" y="42" width="64" height="68" fill="#3A3F52"/>
      <rect x="124" y="46" width="56" height="60" fill="url(#frgrad)"/>
      <text x="138" y="92" fontFamily="Instrument Serif" fontSize="38" fill="#fff">"</text>
      {/* vase + leaves */}
      <ellipse cx="208" cy="100" rx="20" ry="10" fill="#2A2F40"/>
      <rect x="190" y="90" width="36" height="20" fill="#2A2F40"/>
      <ellipse cx="194" cy="74" rx="6" ry="14" fill="#4A4F62" transform="rotate(-18 194 74)"/>
      <ellipse cx="208" cy="64" rx="6" ry="16" fill="#4A4F62"/>
      <ellipse cx="222" cy="76" rx="5" ry="13" fill="#4A4F62" transform="rotate(20 222 76)"/>
    </svg>
  );
}
function IntroScreen({ onContinue }) {
  return (
    <div className="anim-fade" style={{ padding: '100px 28px 24px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 40 }}>
        <PersonalizedShelf/>
        <p className="serif" style={{ fontSize: 26, textAlign: 'center', lineHeight: 1.2, margin: 0, maxWidth: 280, fontWeight: 500 }}>
          Answer a few questions to get personalized quotes
        </p>
      </div>
      <GradButton onClick={onContinue}>Let's do it</GradButton>
    </div>
  );
}

// ─── Generic question screen
function QuestionScreen({ q, value, onChange, onContinue, onSkip, onBack, step, total }) {
  const sel = value || (q.multi ? [] : null);
  const isSel = (opt) => {
    const lab = typeof opt === 'string' ? opt : opt.label;
    return q.multi ? (sel || []).includes(lab) : sel === lab;
  };
  const toggle = (opt) => {
    const lab = typeof opt === 'string' ? opt : opt.label;
    if (q.multi) {
      const cur = Array.isArray(sel) ? sel : [];
      onChange(cur.includes(lab) ? cur.filter(x => x !== lab) : [...cur, lab]);
    } else {
      onChange(lab);
      setTimeout(onContinue, 240);
    }
  };
  const canContinue = q.multi ? (sel || []).length > 0 : !!sel;
  // For non-multi questions, "Continue" button is hidden (tap a choice auto-advances).
  // For multi, Continue is required.
  const tall = q.options.length > 8;
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 36 }}>
        <BackArrow onClick={onBack}/>
        <ProgressBar step={step} total={total}/>
        {q.skip ? <SkipBtn onClick={onSkip}/> : <span style={{ width: 34 }}/>}
      </div>
      <div style={{ padding: tall ? '18px 0 14px' : '24px 0 22px' }}>
        <h2 style={{ fontSize: 21, textAlign: 'center', margin: 0, lineHeight: 1.25,
          fontWeight: 700, color: 'var(--ink)' }}>{q.title}</h2>
        {q.subtitle && <p style={{ textAlign: 'center', color: 'var(--muted)', fontSize: 13, marginTop: 8 }}>{q.subtitle}</p>}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flex: 1, overflow: 'auto' }}>
        {q.options.map((opt, i) => {
          const lab = typeof opt === 'string' ? opt : opt.label;
          const glyph = typeof opt === 'object' ? opt.glyph : null;
          const G = glyph ? Icon[glyph] : null;
          return (
            <OptionPill key={i} selected={isSel(opt)} onClick={() => toggle(opt)}
              icon={G ? <G size={20}/> : null}
              dense={tall}>{lab}</OptionPill>
          );
        })}
      </div>
      {q.multi && (
        <div style={{ paddingTop: 16 }}>
          <DarkButton onClick={onContinue} disabled={!canContinue}>Continue</DarkButton>
        </div>
      )}
    </div>
  );
}

// ─── Splash screen between question groups
function SplashScreen({ title, illustration, onContinue, onBack }) {
  const Art = {
    compass: <SplashCompass/>,
    arch: <SplashArch/>,
    plant: <SplashPlant/>,
  }[illustration];
  return (
    <div className="anim-fade" style={{ padding: '50px 28px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 28, paddingTop: 24 }}>
        {Art}
        <p className="serif" style={{ fontSize: 24, textAlign: 'center', lineHeight: 1.2, margin: 0, maxWidth: 290, fontWeight: 500 }}>
          {title}
        </p>
      </div>
      <DarkButton onClick={onContinue}>Continue</DarkButton>
    </div>
  );
}

function SplashCompass() {
  return (
    <svg viewBox="0 0 240 180" style={{ width: 240, height: 180 }}>
      <defs><radialGradient id="cgrad"><stop offset="0" stopColor="#E0AECB"/><stop offset="1" stopColor="#B79DE8"/></radialGradient></defs>
      {/* compass base */}
      <ellipse cx="120" cy="160" rx="80" ry="6" fill="rgba(0,0,0,0.08)"/>
      <circle cx="120" cy="100" r="62" fill="#E9E6F2" stroke="#171B2A" strokeWidth="2"/>
      <circle cx="120" cy="100" r="50" fill="#fff"/>
      <circle cx="120" cy="100" r="50" fill="url(#cgrad)" opacity="0.35"/>
      {/* needle */}
      <path d="M120 60 L128 100 L120 140 L112 100 Z" fill="#171B2A"/>
      <path d="M120 60 L128 100 L120 100 Z" fill="#F0B2A3"/>
      <circle cx="120" cy="100" r="6" fill="#171B2A"/>
      {/* tick marks */}
      <text x="120" y="55" textAnchor="middle" fontFamily="Instrument Serif" fontSize="11" fill="#171B2A">N</text>
      <text x="172" y="103" textAnchor="middle" fontFamily="Instrument Serif" fontSize="11" fill="#171B2A">E</text>
      <text x="120" y="155" textAnchor="middle" fontFamily="Instrument Serif" fontSize="11" fill="#171B2A">S</text>
      <text x="68" y="103" textAnchor="middle" fontFamily="Instrument Serif" fontSize="11" fill="#171B2A">W</text>
    </svg>
  );
}
function SplashArch() {
  return (
    <svg viewBox="0 0 240 200" style={{ width: 240, height: 200 }}>
      <defs><linearGradient id="agrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#F0B2A3"/><stop offset="1" stopColor="#B79DE8"/></linearGradient></defs>
      {/* arch with sunrise */}
      <path d="M70 170 L70 100 A50 50 0 0 1 170 100 L170 170 Z" fill="url(#agrad)"/>
      <path d="M70 170 L70 100 A50 50 0 0 1 170 100 L170 170 Z" fill="none" stroke="#171B2A" strokeWidth="2"/>
      <circle cx="120" cy="110" r="22" fill="#fff" opacity="0.7"/>
      {/* plant */}
      <rect x="38" y="140" width="22" height="30" rx="2" fill="#2A2F40"/>
      <ellipse cx="42" cy="128" rx="4" ry="14" fill="#4A4F62" transform="rotate(-15 42 128)"/>
      <ellipse cx="52" cy="124" rx="4" ry="16" fill="#4A4F62"/>
      <path d="M44 140 L42 130 M50 140 L52 124 M56 140 L58 132" stroke="#5A5F72" strokeWidth="1"/>
      {/* ground */}
      <line x1="20" y1="170" x2="220" y2="170" stroke="#171B2A" strokeWidth="2"/>
      <ellipse cx="210" cy="170" rx="18" ry="3" fill="rgba(0,0,0,0.1)"/>
    </svg>
  );
}
function SplashPlant() {
  return (
    <svg viewBox="0 0 240 200" style={{ width: 240, height: 200 }}>
      <defs><linearGradient id="pgrad" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      {/* phone */}
      <rect x="90" y="50" width="78" height="120" rx="14" fill="#171B2A"/>
      <rect x="96" y="58" width="66" height="104" rx="8" fill="url(#pgrad)" opacity="0.6"/>
      <text x="129" y="118" textAnchor="middle" fontFamily="Instrument Serif" fontSize="40" fill="#fff">"</text>
      {/* plant in vase */}
      <ellipse cx="50" cy="170" rx="26" ry="6" fill="rgba(0,0,0,0.08)"/>
      <path d="M28 170 L34 138 L60 138 L66 170 Z" fill="#3A3F52"/>
      <path d="M28 170 L34 138 L60 138 L66 170 Z" fill="none" stroke="#171B2A" strokeWidth="1.5"/>
      <ellipse cx="34" cy="120" rx="6" ry="18" fill="#4A4F62" transform="rotate(-20 34 120)"/>
      <ellipse cx="47" cy="112" rx="6" ry="20" fill="#4A4F62"/>
      <ellipse cx="60" cy="120" rx="6" ry="18" fill="#4A4F62" transform="rotate(20 60 120)"/>
      {/* ground line */}
      <line x1="20" y1="180" x2="220" y2="180" stroke="#171B2A" strokeWidth="1.5"/>
    </svg>
  );
}

// ─── Goals textarea
function GoalsScreen({ value, onChange, onContinue, onBack, onSkip, step, total }) {
  const max = 250;
  const cur = (value || '').length;
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 36 }}>
        <BackArrow onClick={onBack}/>
        <ProgressBar step={step} total={total}/>
        <SkipBtn onClick={onSkip}/>
      </div>
      <div style={{ padding: '24px 0 18px' }}>
        <h2 style={{ fontSize: 21, textAlign: 'center', margin: 0, lineHeight: 1.25, fontWeight: 700 }}>What are your goals right now?</h2>
        <p style={{ textAlign: 'center', color: 'var(--muted)', fontSize: 13, marginTop: 8 }}>Use your goals to personalize your motivation.</p>
      </div>
      <textarea
        value={value || ''}
        onChange={e => onChange(e.target.value.slice(0, max))}
        placeholder="My goal is to…"
        style={{
          flex: 1, minHeight: 200, width: '100%',
          padding: '14px 16px', border: '1.4px solid #E5E0D2', borderRadius: 18,
          fontFamily: 'inherit', fontSize: 15, color: 'var(--ink)',
          background: '#fff', resize: 'none', outline: 0,
        }}/>
      <div style={{ textAlign: 'right', fontSize: 11, color: 'var(--muted)', padding: '6px 0 12px' }}>
        {cur}/{max}
      </div>
      <DarkButton onClick={onContinue} disabled={cur === 0}>Continue</DarkButton>
    </div>
  );
}

// ─── Topics multi-select (chips)
function TopicsScreen({ q, value, onChange, onContinue, onBack, onSkip, step, total }) {
  const sel = value || [];
  const toggle = (t) => onChange(sel.includes(t) ? sel.filter(x => x !== t) : [...sel, t]);
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 36 }}>
        <BackArrow onClick={onBack}/>
        <ProgressBar step={step} total={total}/>
        <SkipBtn onClick={onSkip}/>
      </div>
      <div style={{ padding: '20px 0 16px' }}>
        <h2 style={{ fontSize: 21, textAlign: 'center', margin: 0, lineHeight: 1.25, fontWeight: 700 }}>{q.title}</h2>
        {q.subtitle && <p style={{ textAlign: 'center', color: 'var(--muted)', fontSize: 13, marginTop: 6 }}>{q.subtitle}</p>}
      </div>
      <div style={{ flex: 1, overflow: 'auto', display: 'flex', flexWrap: 'wrap', gap: 8, alignContent: 'flex-start', paddingBottom: 12 }}>
        {q.options.map(t => (
          <TopicChip key={t} selected={sel.includes(t)} onClick={() => toggle(t)}>{t}</TopicChip>
        ))}
      </div>
      <DarkButton onClick={onContinue} disabled={sel.length === 0}>Continue</DarkButton>
    </div>
  );
}

// ─── Streak intro (1-day flame)
function StreakIntroScreen({ onContinue, onBack }) {
  const days = ['Fr','Sa','Su','Mo','Tu','We','Th'];
  return (
    <div className="anim-fade" style={{ padding: '50px 28px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24, paddingTop: 10 }}>
        <div style={{ position: 'relative' }}>
          <Icon.flame size={170}/>
          <span style={{
            position: 'absolute', left: 0, right: 0, top: 0, bottom: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: '#fff', fontFamily: 'Instrument Serif', fontSize: 50, marginTop: 22, fontWeight: 400,
          }}>1</span>
        </div>
        <p style={{ fontSize: 21, textAlign: 'center', lineHeight: 1.25, margin: 0, fontWeight: 700 }}>
          Stay motivated with a<br/>consistent daily routine
        </p>
        <div style={{ width: '100%', background: '#E9E6F2', borderRadius: 18, padding: '14px 16px 18px', textAlign: 'center' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: 4 }}>
            {days.map((d, i) => (
              <div key={d} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, flex: 1 }}>
                <span style={{ fontSize: 11, color: i === 0 ? 'var(--ink)' : 'var(--muted-2)', fontWeight: 600 }}>{d}</span>
                <div style={{
                  width: 32, height: 32, borderRadius: 999,
                  background: i === 0 ? 'linear-gradient(120deg,#B79DE8,#F0B2A3)' : 'rgba(155,150,170,0.2)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff',
                }}>{i === 0 && <Icon.check size={14} sw={2.5}/>}</div>
              </div>
            ))}
          </div>
          <p style={{ fontSize: 13, color: 'var(--ink-2)', margin: '12px 0 0' }}>Build a streak, one day at a time</p>
        </div>
      </div>
      <DarkButton onClick={onContinue}>Continue</DarkButton>
    </div>
  );
}

// ─── Reminders setup (with notification preview + count stepper + start/end)
function RemindersSetupScreen({ onContinue, onBack, onAllow, demoOpen }) {
  const [count, setCount] = useState(10);
  const [start, setStart] = useState('9:00 AM');
  const [end, setEnd] = useState('10:00 PM');
  const [picker, setPicker] = useState(null);
  const [showAllow, setShowAllow] = useState(false);

  const setSafe = (which, v) => { (which === 'start' ? setStart : setEnd)(v); setPicker(null); };

  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <div style={{ padding: '12px 0 16px' }}>
        <h2 style={{ fontSize: 20, textAlign: 'center', margin: 0, lineHeight: 1.25, fontWeight: 700 }}>Get quotes throughout the day</h2>
        <p style={{ textAlign: 'center', color: 'var(--muted)', fontSize: 13, marginTop: 6 }}>Small doses of motivation can make a big difference in your life</p>
      </div>
      {/* notification preview */}
      <div style={{
        background: 'rgba(245,242,235,0.96)', backdropFilter: 'blur(20px)',
        borderRadius: 16, padding: '10px 12px',
        display: 'flex', gap: 10, alignItems: 'flex-start',
        boxShadow: '0 10px 24px -8px rgba(0,0,0,0.15)',
        marginBottom: 14,
      }}>
        <MirraMark size={34}/>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 13, fontWeight: 600 }}>Mirra</span>
            <span style={{ fontSize: 11, color: 'var(--muted)' }}>Now</span>
          </div>
          <p style={{ fontSize: 13, color: 'var(--ink-2)', margin: '1px 0 0', lineHeight: 1.35 }}>
            One day, you'll be at the place you always wanted to be.
          </p>
        </div>
      </div>
      <div style={{ background: '#E9E6F2', borderRadius: 16, overflow: 'hidden' }}>
        <Row label="How many a day">
          <Stepper value={count} min={1} max={20} onChange={setCount}/>
        </Row>
        <RowDivider/>
        <Row label="Start at" onClick={() => setPicker('start')}>
          <ValuePill>{start}</ValuePill>
        </Row>
        <RowDivider/>
        <Row label="End at" onClick={() => setPicker('end')}>
          <ValuePill>{end}</ValuePill>
        </Row>
      </div>
      <div style={{ flex: 1, minHeight: 14 }}/>
      <DarkButton onClick={() => setShowAllow(true)}>Allow and save</DarkButton>

      {picker && <TimeWheelSheet initial={picker === 'start' ? start : end} onClose={() => setPicker(null)} onSave={v => setSafe(picker, v)}/>}
      {showAllow && (
        <NativeAlert
          icon={<MirraMark size={42}/>}
          title='"Mirra" Would Like to Send You Notifications'
          message="Notifications may include alerts, sounds, and icon badges. These can be configured in Settings."
          actions={[
            { label: "Don't Allow", onClick: () => { setShowAllow(false); onContinue(); } },
            { label: "Allow", primary: true, onClick: () => { setShowAllow(false); onContinue(); } },
          ]}/>
      )}
    </div>
  );
}
function Row({ label, children, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '14px 16px', cursor: onClick ? 'pointer' : 'default',
    }}>
      <span style={{ fontSize: 15, fontWeight: 500 }}>{label}</span>
      {children}
    </div>
  );
}
function RowDivider() { return <div style={{ height: '0.5px', background: 'rgba(0,0,0,0.1)', marginInline: 16 }}/>; }
function ValuePill({ children }) {
  return <span style={{ padding: '4px 10px', borderRadius: 7, background: 'rgba(0,0,0,0.06)', fontSize: 13, fontWeight: 500 }}>{children}</span>;
}
function Stepper({ value, min, max, onChange }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <button onClick={() => onChange(Math.max(min, value-1))} className="no-tap" style={{
        width: 26, height: 26, borderRadius: 999, background: 'rgba(0,0,0,0.06)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><Icon.minus size={12} sw={2.5}/></button>
      <span style={{ fontSize: 14, fontWeight: 600, minWidth: 30, textAlign: 'center' }}>
        {value}<span style={{ color: 'var(--muted)' }}>x</span>
      </span>
      <button onClick={() => onChange(Math.min(max, value+1))} className="no-tap" style={{
        width: 26, height: 26, borderRadius: 999, background: '#171B2A', color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}><Icon.plus size={12} sw={2.5}/></button>
    </div>
  );
}

// Time wheel (iOS-style)
function TimeWheelSheet({ initial, onClose, onSave }) {
  const m0 = initial.match(/(\d+):(\d+)\s?(AM|PM)/i);
  const [h, sh] = useState(m0 ? parseInt(m0[1],10) : 9);
  const [m, sm] = useState(m0 ? parseInt(m0[2],10) : 0);
  const [pm, spm] = useState(m0 ? m0[3].toUpperCase() === 'PM' : false);
  const fmt = `${h}:${m.toString().padStart(2,'0')} ${pm ? 'PM' : 'AM'}`;
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.3)', zIndex: 150 }} onClick={onClose}>
      <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: 16, right: 16, bottom: 70,
        background: 'rgba(245,242,235,0.96)', backdropFilter: 'blur(20px)',
        borderRadius: 18, padding: 12,
      }}>
        <div style={{ position: 'relative', height: 170, display: 'flex' }}>
          <div style={{ position: 'absolute', left: 0, right: 0, top: '50%', transform: 'translateY(-50%)', height: 36, borderRadius: 8, background: 'rgba(0,0,0,0.06)' }}/>
          <Wheel value={h}  onChange={sh}  items={Array.from({length:12}, (_,i)=>i+1)}/>
          <Wheel value={m}  onChange={sm}  items={Array.from({length:60}, (_,i)=>i)} pad/>
          <Wheel value={pm?'PM':'AM'} onChange={(v) => spm(v==='PM')} items={['AM','PM']}/>
        </div>
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 16, padding: '4px 8px 0' }}>
          <button onClick={onClose} style={{ fontSize: 15, color: '#0A7AFF' }}>Cancel</button>
          <button onClick={() => onSave(fmt)} style={{ fontSize: 15, color: '#0A7AFF', fontWeight: 600 }}>Done</button>
        </div>
      </div>
    </div>
  );
}
function Wheel({ value, onChange, items, pad }) {
  const idx = items.indexOf(value);
  return (
    <div style={{ flex: 1, height: 170, position: 'relative', textAlign: 'center',
      maskImage: 'linear-gradient(180deg, transparent 0%, #000 40%, #000 60%, transparent 100%)',
    }}>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
        {items.map((it, i) => {
          const offset = i - idx;
          if (Math.abs(offset) > 2) return null;
          const opacity = 1 - Math.abs(offset) * 0.35;
          return (
            <div key={i} onClick={() => onChange(it)} style={{
              position: 'absolute', top: '50%', transform: `translate(0, ${offset*30-50}%)`,
              fontSize: 21, fontWeight: 500, opacity, color: 'var(--ink)', cursor: 'pointer',
            }}>{pad ? it.toString().padStart(2,'0') : it}</div>
          );
        })}
      </div>
    </div>
  );
}

// ─── App icon picker (24 choices, 4 cols)
function IconPickerScreen({ onContinue, onBack, value, onChange, showAlert, setShowAlert }) {
  const choices = window.MIRRA.ICON_CHOICES;
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <h2 style={{ fontSize: 21, textAlign: 'center', margin: '14px 0 22px', lineHeight: 1.25, fontWeight: 700 }}>Which icon style do you like the most?</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10, flex: 1, overflow: 'auto', alignContent: 'start' }}>
        {choices.map(c => <IconTile key={c.id} c={c} selected={value === c.id} onClick={() => { onChange(c.id); }}/>)}
      </div>
      <div style={{ marginTop: 14 }}><DarkButton onClick={onContinue}>Continue</DarkButton></div>
      {showAlert && (
        <NativeAlert icon={<MirraMark size={42}/>}
          title='You have changed the icon for "Mirra".'
          actions={[{ label: 'OK', primary: true, onClick: () => setShowAlert(false) }]}/>
      )}
    </div>
  );
}
function IconTile({ c, selected, onClick }) {
  const isBg = typeof c.bg === 'string' && c.bg.startsWith('http');
  const bgProps = isBg
    ? { backgroundImage: `url(${c.bg})`, backgroundSize: 'cover', backgroundPosition: 'center' }
    : { background: c.bg };
  return (
    <button onClick={onClick} className="no-tap" style={{
      aspectRatio: '1', borderRadius: 14, position: 'relative', overflow: 'hidden',
      ...bgProps, color: c.dark ? '#fff' : 'var(--ink)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      padding: c.text || c.wordmark ? 6 : 0,
      border: selected ? '2.5px solid #171B2A' : '1px solid rgba(0,0,0,0.04)',
    }}>
      {c.glyph && <span className="serif" style={{ fontSize: c.biggerGlyph ? 30 : 22, lineHeight: 1 }}>{c.glyph}</span>}
      {c.text && <span style={{ fontSize: 8.5, fontWeight: 800, textAlign: 'center', lineHeight: 1.15, whiteSpace: 'pre-line' }}>{c.text}</span>}
      {c.wordmark && <span style={{ fontSize: 7, fontWeight: 800, letterSpacing: '0.06em', whiteSpace: 'pre-line', textAlign: 'center' }}>{c.wordmark}</span>}
      {c.ring && <span style={{ position: 'absolute', inset: 5, borderRadius: 10, border: `1.5px solid ${c.dark ? '#fff' : '#1A1A1A'}` }}/>}
    </button>
  );
}

// ─── Theme picker (onboarding, 6 cards)
function ThemePickerScreen({ value, onChange, onContinue, onBack }) {
  const themes = window.MIRRA.THEMES.slice(0, 6).map((t,i) => ({...t, special: i===2 ? 'video' : (i===0 ? 'animated' : null)}));
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <h2 style={{ fontSize: 21, textAlign: 'center', margin: '40px 0 30px', lineHeight: 1.25, fontWeight: 700 }}>
        Which theme would you like<br/>to start with?
      </h2>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, width: '100%' }}>
          {themes.map(t => <ThemeTile key={t.id} t={t} selected={value === t.id} onClick={() => onChange(t.id)}/>)}
        </div>
      </div>
      <div style={{ marginTop: 22 }}><DarkButton onClick={onContinue} disabled={!value}>Continue</DarkButton></div>
    </div>
  );
}
function ThemeTile({ t, selected, onClick, small, special }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      aspectRatio: small ? '3/4' : '3/4', borderRadius: 12, position: 'relative', overflow: 'hidden',
      background: t.photo ? `url(${t.photo})` : (t.dark ? '#1A1A1A' : '#EFE9DC'),
      backgroundSize: 'cover', backgroundPosition: 'center',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      border: selected ? '2px solid #171B2A' : '1px solid rgba(0,0,0,0.06)',
      color: t.photo || t.dark ? '#fff' : 'var(--ink)',
    }}>
      {t.photo && <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, transparent 30%, rgba(0,0,0,0.4) 100%)' }}/>}
      <span className={t.photo || t.dark ? 'serif' : 'serif'} style={{
        fontSize: small ? 18 : 24, position: 'relative',
        textShadow: t.photo ? '0 2px 6px rgba(0,0,0,0.4)' : 'none',
      }}>Aa</span>
      {(t.animated || special) && (
        <span style={{
          position: 'absolute', top: 6, left: 6,
          width: 18, height: 18, borderRadius: 999, background: 'rgba(0,0,0,0.4)', color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(8px)',
        }}>
          <svg width="9" height="9" viewBox="0 0 12 12" fill="#fff"><path d="M3 2l7 4-7 4z"/></svg>
        </span>
      )}
      {selected && (
        <span style={{
          position: 'absolute', top: 6, right: 6,
          width: 20, height: 20, borderRadius: 999, background: 'rgba(0,0,0,0.5)', color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(8px)',
        }}><Icon.check size={11} sw={2.6}/></span>
      )}
    </button>
  );
}

// ─── How free trial works (with lock/bell/crown timeline)
function FreeTrialIntroScreen({ onContinue, onBack }) {
  return (
    <div className="anim-fade" style={{ padding: '50px 28px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onBack}/></div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
        <h2 style={{ fontSize: 22, textAlign: 'center', margin: 0, lineHeight: 1.3, fontWeight: 700 }}>
          We offer<br/>
          <span style={{
            background: 'linear-gradient(120deg,#B79DE8,#F0B2A3)',
            WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent',
          }} className="serif">3 days for free</span><br/>
          so everyone can feel<br/>motivated with daily quotes
        </h2>
      </div>
      <DarkButton onClick={onContinue}>Continue</DarkButton>
    </div>
  );
}

// ─── How free trial works (lock → bell → crown timeline)
function FreeTrialHowScreen({ onContinue, onBack, onSkip }) {
  const [remind, setRemind] = useState(true);
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 36 }}>
        <BackArrow onClick={onBack}/>
        <CloseBtn onClick={onSkip}/>
      </div>
      <h2 style={{ fontSize: 22, textAlign: 'center', margin: '14px 0 28px', lineHeight: 1.25, fontWeight: 700 }}>
        How your free trial works
      </h2>
      <div style={{ position: 'relative', padding: '0 8px', marginBottom: 24 }}>
        <div style={{ position: 'absolute', left: 28, top: 18, bottom: 18, width: 2, background: 'linear-gradient(180deg,#171B2A 0%,#171B2A 50%,#E0AECB 100%)' }}/>
        <TrialStep icon={<Icon.lock size={20} stroke="#fff"/>} title="Today: Unlock everything" body="Get all premium quotes, themes & widgets."/>
        <TrialStep icon={<Icon.bell size={20} stroke="#fff"/>} title="In 2 days: Trial reminder" body="We'll notify you before the trial ends."/>
        <TrialStep icon={<Icon.crown size={20} stroke="#fff"/>} title="Day 3: Trial ends, subscription starts" body="$59.99/year. Cancel anytime."/>
      </div>
      <div style={{
        background: '#E9E6F2', borderRadius: 16, padding: '14px 16px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <span style={{ fontSize: 14, fontWeight: 500 }}>Reminder before trial ends</span>
        <Switch on={remind} onChange={setRemind}/>
      </div>
      <div style={{ flex: 1, minHeight: 16 }}/>
      <GradButton onClick={onContinue}>Start 3-day free trial</GradButton>
      <p style={{ fontSize: 11, color: 'var(--muted)', textAlign: 'center', marginTop: 10 }}>
        3 days free, then $59.99/year. Cancel anytime.
      </p>
    </div>
  );
}
function TrialStep({ icon, title, body }) {
  return (
    <div style={{ display: 'flex', gap: 14, padding: '6px 0 18px' }}>
      <span style={{ width: 38, height: 38, borderRadius: 999, background: '#171B2A',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, zIndex: 1 }}>{icon}</span>
      <div>
        <div style={{ fontSize: 15, fontWeight: 700 }}>{title}</div>
        <div style={{ fontSize: 13, color: 'var(--muted)', marginTop: 2, lineHeight: 1.35 }}>{body}</div>
      </div>
    </div>
  );
}

// ─── Welcome to Premium
function PremiumWelcomeScreen({ onContinue }) {
  const marks = Array.from({length:11}).map((_,i)=>({
    x: 50 + Math.cos(i*0.85)*22 + ((i%3-1)*8),
    y: 22 + (i%3)*10,
    size: 16 + (i%5)*4,
    op: 0.18 + (i%5)*0.13,
    delay: i*70,
  }));
  return (
    <div className="anim-fade" style={{ padding: '80px 28px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ minHeight: 36 }}/>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'flex-end', paddingBottom: 36, gap: 32 }}>
        <div style={{ position: 'relative', width: 220, height: 130 }}>
          {marks.map((m,i) => (
            <span key={i} className="anim-pop serif" style={{
              position: 'absolute', left: `${m.x}%`, top: `${m.y}%`, transform: 'translate(-50%,-50%)',
              fontSize: m.size, color: 'var(--ink)', opacity: m.op,
              animationDelay: `${m.delay}ms`,
            }}>"</span>
          ))}
        </div>
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ fontSize: 22, margin: 0, lineHeight: 1.2, fontWeight: 700 }}>
            Welcome to<br/>Mirra Premium
          </h2>
          <p style={{ color: 'var(--muted)', fontSize: 13, marginTop: 14, lineHeight: 1.5 }}>
            Start your journey towards achieving your<br/>goals and fulfilling your dreams
          </p>
        </div>
      </div>
      <DarkButton onClick={onContinue}>Continue</DarkButton>
    </div>
  );
}

// ─── Self-Growth bundle teaser (mid-onboarding)
function BundleScreen({ onClose, onClaim, fromOnboarding }) {
  const apps = [
    { name: 'Mirra',          sub: 'Reminders to think positive', installed: true,  color: '#171B2A', glyph: '"' },
    { name: 'I am',           sub: 'Affirmations to empower daily', color: '#F0B2A3', text: 'i am' },
    { name: 'Loving Kindness',sub: 'Daily meditation mantras', color: 'linear-gradient(135deg,#D6C5EC,#F0B2A3)', text: '✿' },
    { name: 'Moodlight',      sub: 'Mood tracker & self-help', color: '#1F1F2A', glyph: '☾' },
    { name: 'Vocabulary',     sub: 'Improve vocabulary every day', color: '#E5DFD0', text: 'V', dark: false },
    { name: 'Facts',          sub: 'Learn new interesting trivia', color: '#B79DE8', glyph: 'i' },
  ];
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <div style={{ minHeight: 36 }}><BackArrow onClick={onClose}/></div>
      <h2 className="serif" style={{ fontSize: 24, textAlign: 'center', margin: '4px 0 4px', lineHeight: 1.2, fontWeight: 500 }}>
        Your <span style={{ fontWeight: 600 }}>Self-Growth</span><br/>Essentials bundle
      </h2>
      <p className="serif" style={{ textAlign: 'center', fontSize: 22, margin: '6px 0 0', fontWeight: 500,
        background: 'linear-gradient(120deg,#B79DE8,#F0B2A3)',
        WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent',
      }}>with 50% off</p>
      <p style={{ color: 'var(--muted)', fontSize: 13, textAlign: 'center', margin: '10px 0 14px', lineHeight: 1.45 }}>
        The complete mental well-being<br/>and growth toolkit in one app bundle.
      </p>
      <div style={{
        border: '1.5px solid var(--line-2)', borderRadius: 14,
        padding: '12px 14px', textAlign: 'center', position: 'relative', marginBottom: 16,
      }}>
        <span style={{
          position: 'absolute', top: -10, left: '50%', transform: 'translateX(-50%)',
          background: 'linear-gradient(120deg,#B79DE8,#F0B2A3)', color: '#fff',
          fontSize: 10, fontWeight: 700, padding: '3px 12px', borderRadius: 999, letterSpacing: '0.02em',
        }}>Just for you</span>
        <div style={{ fontSize: 13, color: 'var(--muted)', textDecoration: 'line-through' }}>$279.98</div>
        <div style={{ fontSize: 17, fontWeight: 700, marginTop: 2 }}>Now $139.99 <span style={{ color: 'var(--muted)', fontWeight: 500, fontSize: 13 }}>/year</span></div>
      </div>
      <p style={{ textAlign: 'center', fontSize: 14, fontWeight: 700, margin: '0 0 10px' }}>Enjoy all apps in one subscription!</p>
      <div style={{ flex: 1, overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 6 }}>
        {apps.map(a => (
          <div key={a.name} style={{ display: 'flex', alignItems: 'center', gap: 11, background: '#E9E6F2', borderRadius: 12, padding: '8px 12px' }}>
            <span style={{
              width: 34, height: 34, borderRadius: 8, background: a.color, backgroundSize: 'cover',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              color: '#fff', fontFamily: 'Instrument Serif', fontSize: 22, fontWeight: 400,
            }}>{a.glyph || (a.text && <span style={{ fontSize: 12, fontWeight: 700 }}>{a.text}</span>)}</span>
            <span style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>{a.name}</div>
              <div style={{ fontSize: 11, color: 'var(--muted)' }}>{a.sub}</div>
            </span>
            {a.installed && <span style={{ fontSize: 11, border: '1px solid var(--line-2)', padding: '3px 8px', borderRadius: 999, color: 'var(--ink-2)' }}>Installed</span>}
          </div>
        ))}
      </div>
      <div style={{ paddingTop: 10 }}>
        <p style={{ textAlign: 'center', fontSize: 11, color: 'var(--muted)', margin: '0 0 8px' }}>
          <span style={{ textDecoration: 'line-through' }}>$279.98</span> now just $139.99/year
        </p>
        <GradButton onClick={onClaim}>Claim my offer</GradButton>
      </div>
    </div>
  );
}

// ─── Add a widget walkthrough
function AddWidgetScreen({ onContinue, onBack, onSkip }) {
  return (
    <div className="anim-fade" style={{ padding: '50px 22px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 36 }}>
        <BackArrow onClick={onBack}/>
        {onSkip && <SkipBtn onClick={onSkip}/>}
      </div>
      <h2 style={{ fontSize: 22, margin: '6px 0 16px', fontWeight: 700 }}>Widgets</h2>
      <div style={{ background: '#E9E6F2', borderRadius: 22, padding: 16, marginBottom: 18 }}>
        <div style={{
          background: '#fff', borderRadius: 16, position: 'relative', padding: '24px 12px 12px',
          minHeight: 240, border: '1px solid var(--line)',
        }}>
          <div style={{ position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)', width: 60, height: 18, borderRadius: 999, background: '#171B2A' }}/>
          <div style={{ background: '#fff', borderRadius: 14, padding: 16, border: '1.5px dashed var(--ink-2)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: 90 }}>
            <p style={{ margin: 0, fontSize: 15, fontWeight: 600, textAlign: 'center' }}>You are stronger<br/>than you think.</p>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 8, marginTop: 14 }}>
            {Array.from({length:8}).map((_,i)=><div key={i} style={{ aspectRatio:'1', borderRadius: 9, background: 'rgba(0,0,0,0.08)' }}/>)}
          </div>
        </div>
      </div>
      <p style={{ fontSize: 15, fontWeight: 700, textAlign: 'center', margin: '0 0 8px' }}>Add a widget to your Home Screen</p>
      <ol style={{ fontSize: 13, color: 'var(--ink-2)', margin: 0, paddingInlineStart: 18, lineHeight: 1.6 }}>
        <li>On your Home Screen, touch and hold an empty area until the apps jiggle.</li>
        <li>Tap the Edit button in the upper corner to add the Mirra widget.</li>
      </ol>
      <div style={{ flex: 1, minHeight: 14 }}/>
      <DarkButton onClick={onContinue}>Install widget</DarkButton>
    </div>
  );
}

// ─── Trial started confirmation
function TrialStartedScreen({ onContinue, onLater }) {
  return (
    <div className="anim-fade" style={{ padding: '80px 28px 22px', display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24 }}>
        <BellArt/>
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ fontSize: 22, fontWeight: 700, margin: '0 0 8px', lineHeight: 1.2 }}>
            Your 3-day Premium<br/>trial has started!
          </h2>
          <p style={{ color: 'var(--muted)', fontSize: 13, lineHeight: 1.5, margin: 0 }}>
            Enable streak reminders so you don't break your routine.
          </p>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <DarkButton onClick={onContinue}>Remind me</DarkButton>
        <button onClick={onLater} style={{ padding: 12, fontSize: 14, color: 'var(--muted)', fontWeight: 600 }}>Maybe later</button>
      </div>
    </div>
  );
}
function BellArt() {
  return (
    <svg viewBox="0 0 200 200" style={{ width: 200, height: 200 }}>
      <defs><linearGradient id="bgrad" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#B79DE8"/><stop offset="1" stopColor="#F0B2A3"/></linearGradient></defs>
      <circle cx="100" cy="100" r="80" fill="url(#bgrad)" opacity="0.2"/>
      <g transform="translate(60, 50)">
        <path d="M40 10c-12 0-22 10-22 22v34l-8 12h60l-8-12V32c0-12-10-22-22-22z" fill="#fff" stroke="#171B2A" strokeWidth="2.5"/>
        <path d="M30 84a10 10 0 0020 0" fill="none" stroke="#171B2A" strokeWidth="2.5" strokeLinecap="round"/>
        <circle cx="40" cy="10" r="4" fill="#171B2A"/>
      </g>
    </svg>
  );
}

Object.assign(window, {
  WelcomeScreen, IntroScreen, QuestionScreen, SplashScreen, GoalsScreen, TopicsScreen,
  StreakIntroScreen, RemindersSetupScreen, IconPickerScreen, ThemePickerScreen,
  FreeTrialIntroScreen, FreeTrialHowScreen, PremiumWelcomeScreen,
  BundleScreen, AddWidgetScreen, TrialStartedScreen,
});
