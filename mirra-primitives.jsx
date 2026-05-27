// mirra-primitives.jsx — shared UI primitives used across screens
const { useState, useEffect, useRef, useReducer, Fragment } = React;

// ── Buttons
function DarkButton({ children, onClick, disabled, full = true }) {
  return (
    <button onClick={onClick} disabled={disabled} className="no-tap" style={{
      width: full ? '100%' : 'auto', height: 56, borderRadius: 999,
      background: disabled ? '#D6D2C8' : '#171B2A',
      color: disabled ? '#9AA0AE' : '#fff',
      fontSize: 16, fontWeight: 700, letterSpacing: 0,
      boxShadow: disabled ? 'none' : '0 6px 16px -8px rgba(23,27,42,0.5)',
    }}>{children}</button>
  );
}
function GradButton({ children, onClick, full = true }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: full ? '100%' : 'auto', height: 56, borderRadius: 999,
      background: 'linear-gradient(120deg,#B79DE8 0%,#E0AECB 50%,#F0B2A3 100%)',
      color: '#fff', fontSize: 16, fontWeight: 700,
      boxShadow: '0 6px 16px -8px rgba(183,157,232,0.7)',
    }}>{children}</button>
  );
}
function OutlineButton({ children, onClick, full = true }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: full ? '100%' : 'auto', height: 56, borderRadius: 999,
      background: '#fff', border: '1.4px solid var(--ink)',
      color: 'var(--ink)', fontSize: 16, fontWeight: 700,
    }}>{children}</button>
  );
}

function HeaderBar({ left, center, right, tight }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: tight ? '50px 22px 0' : '50px 22px 0', minHeight: 38,
    }}>
      <div style={{ minWidth: 50, display: 'flex' }}>{left}</div>
      <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--ink)' }}>{center}</div>
      <div style={{ minWidth: 50, display: 'flex', justifyContent: 'flex-end' }}>{right}</div>
    </div>
  );
}
function BackArrow({ onClick, label, dark }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      color: dark ? '#fff' : 'var(--ink)', fontSize: 16, fontWeight: 500,
      padding: '6px 2px',
    }}>
      <Icon.chevronLeft size={22} sw={2}/>{label && <span style={{ marginLeft: -2 }}>{label}</span>}
    </button>
  );
}
function CloseBtn({ onClick, dark, light }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: 32, height: 32,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      color: dark ? '#fff' : 'var(--ink)',
      background: light ? 'rgba(255,255,255,0.95)' : 'transparent',
      borderRadius: light ? 999 : 0,
    }}><Icon.x size={20} sw={1.8}/></button>
  );
}
function SkipBtn({ onClick }) {
  return <button onClick={onClick} className="no-tap" style={{
    fontSize: 15, color: 'var(--muted)', padding: '6px 4px',
  }}>Skip</button>;
}

// Option pill (questions / preferences single+multi)
function OptionPill({ children, selected, onClick, icon, dense }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: '100%', height: dense ? 50 : 56, padding: dense ? '0 16px' : '0 20px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderRadius: 999, background: selected ? '#E9E6F2' : '#fff',
      border: `1.4px solid ${selected ? '#171B2A' : '#E5E0D2'}`,
      color: 'var(--ink)', fontSize: 15, fontWeight: 500,
      textAlign: 'left', transition: 'all 0.16s ease',
    }}>
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 12 }}>
        {icon && <span style={{ color: 'var(--ink-2)' }}>{icon}</span>}
        <span>{children}</span>
      </span>
      <span style={{
        width: 22, height: 22, borderRadius: 999, flexShrink: 0,
        background: selected ? '#171B2A' : 'transparent',
        border: selected ? '0' : '1.5px solid #C5C0B3',
        display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff',
      }}>{selected && <Icon.check size={12} sw={2.8}/>}</span>
    </button>
  );
}
// Topic chip (small selectable pill)
function TopicChip({ children, selected, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      padding: '8px 14px', borderRadius: 999,
      background: selected ? '#171B2A' : '#fff',
      color: selected ? '#fff' : 'var(--ink)',
      border: `1.4px solid ${selected ? '#171B2A' : '#E5E0D2'}`,
      fontSize: 13, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', gap: 6,
    }}>
      {children}
      {selected ? <Icon.check size={12} sw={2.8} stroke="#fff"/> : <Icon.plus size={12} sw={2.4}/>}
    </button>
  );
}

// Switch toggle (purple-pink gradient when on)
function Switch({ on, onChange }) {
  return (
    <button onClick={() => onChange(!on)} className="no-tap" style={{
      width: 46, height: 28, borderRadius: 999, padding: 2,
      background: on ? 'linear-gradient(90deg,#B79DE8,#F0B2A3)' : 'rgba(0,0,0,0.12)',
      display: 'flex', alignItems: 'center',
      justifyContent: on ? 'flex-end' : 'flex-start',
      transition: 'all 0.2s ease',
      flexShrink: 0,
    }}><span style={{ width: 24, height: 24, borderRadius: 999, background: '#fff', boxShadow: '0 1px 2px rgba(0,0,0,0.2)' }}/></button>
  );
}

// Chip list (e.g. Follow / Following)
function FollowChip({ following, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      padding: '5px 13px', borderRadius: 999, background: 'transparent',
      border: '1.2px solid #1A1A1A',
      fontSize: 13, fontWeight: 500, color: 'var(--ink)',
      display: 'inline-flex', alignItems: 'center', gap: 4,
    }}>{following && <Icon.check size={12} sw={2.5}/>}{following ? 'Following' : 'Follow'}</button>
  );
}

// Section label
function SectionLabel({ children, action }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '20px 6px 10px',
    }}>
      <h4 style={{
        fontSize: 11, fontWeight: 700, color: 'var(--muted)',
        letterSpacing: '0.14em', textTransform: 'uppercase', margin: 0,
      }}>{children}</h4>
      {action}
    </div>
  );
}

// List group + row (preferences)
function ListGroup({ children, gap = 0 }) {
  return (
    <div style={{
      background: 'transparent',
      display: 'flex', flexDirection: 'column', gap,
    }}>{children}</div>
  );
}
function ListRow({ icon, label, detail, badge, onClick, danger, sub }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: '100%', padding: '13px 14px',
      display: 'flex', alignItems: 'center', gap: 12,
      background: '#E9E6F2', borderRadius: 14, marginBottom: 8,
      textAlign: 'left', color: danger ? '#E25C5C' : 'var(--ink)',
    }}>
      {icon && <span style={{ width: 22, color: danger ? '#E25C5C' : 'var(--ink)', display: 'inline-flex' }}>{icon}</span>}
      <span style={{ flex: 1, fontSize: 15, fontWeight: 500 }}>
        {label}
        {sub && <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>{sub}</div>}
      </span>
      {badge && <span style={{ background: '#F0B2A3', color: '#1A1A1A', fontSize: 9, fontWeight: 700, padding: '2px 6px', borderRadius: 999 }}>{badge}</span>}
      {detail !== undefined && <span style={{ fontSize: 13, color: 'var(--muted)' }}>{detail}</span>}
      <Icon.chevronRight size={16} stroke="#BFBBB0"/>
    </button>
  );
}

// Progress bar (onboarding)
function ProgressBar({ step, total }) {
  const w = Math.max(0, Math.min(1, (step + 1) / total));
  return (
    <div style={{ width: 110, height: 4, borderRadius: 4, background: 'rgba(0,0,0,0.08)', overflow: 'hidden' }}>
      <div style={{ width: `${w*100}%`, height: '100%',
        background: 'linear-gradient(90deg,#B79DE8,#F0B2A3)',
        transition: 'width 0.3s ease',
      }}/>
    </div>
  );
}

// Mirra brand mark (quote glyph in dark rounded square)
function MirraMark({ size = 30, dark = true, gradient = false }) {
  return (
    <span style={{
      width: size, height: size, borderRadius: size * 0.27,
      background: gradient ? 'linear-gradient(120deg,#B79DE8,#F0B2A3)' : (dark ? '#171B2A' : '#fff'),
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: '#fff',
      flexShrink: 0,
    }}>
      <span style={{
        fontFamily: 'Instrument Serif',
        fontSize: size * 0.65, lineHeight: 1, marginTop: size * 0.12,
        color: dark || gradient ? '#fff' : '#1A1A1A',
      }}>"</span>
    </span>
  );
}

// Search field
function SearchField({ placeholder = 'Search', value, onChange }) {
  return (
    <div style={{
      background: '#E9E6F2', height: 38, borderRadius: 999,
      padding: '0 14px', display: 'flex', alignItems: 'center', gap: 8,
    }}>
      <Icon.search size={16} stroke="var(--muted)"/>
      <input value={value || ''} onChange={e => onChange?.(e.target.value)}
        placeholder={placeholder} style={{
          flex: 1, border: 0, outline: 0, background: 'transparent',
          fontSize: 14, color: 'var(--ink)',
        }}/>
    </div>
  );
}

// iOS-style native alert (centered modal)
function NativeAlert({ icon, title, message, actions, onClose }) {
  return (
    <div className="anim-fade" style={{
      position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 200,
      display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 30,
    }} onClick={onClose}>
      <div className="anim-pop" onClick={e => e.stopPropagation()} style={{
        background: 'rgba(245,242,236,0.96)', backdropFilter: 'blur(20px)',
        borderRadius: 14, width: '100%', maxWidth: 280, overflow: 'hidden',
        boxShadow: '0 12px 32px rgba(0,0,0,0.2)',
      }}>
        <div style={{ padding: '20px 16px 16px', textAlign: 'center' }}>
          {icon && <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>{icon}</div>}
          {title && <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--ink)', marginBottom: 4 }}>{title}</div>}
          {message && <div style={{ fontSize: 13, color: 'var(--ink-2)', lineHeight: 1.4 }}>{message}</div>}
        </div>
        <div style={{ borderTop: '0.5px solid rgba(0,0,0,0.18)', display: 'flex' }}>
          {actions.map((a, i) => (
            <Fragment key={i}>
              {i > 0 && <div style={{ width: '0.5px', background: 'rgba(0,0,0,0.18)' }}/>}
              <button onClick={a.onClick} className="no-tap" style={{
                flex: 1, padding: '11px', fontSize: 16,
                color: a.primary ? '#0A7AFF' : '#0A7AFF',
                fontWeight: a.primary ? 600 : 400,
              }}>{a.label}</button>
            </Fragment>
          ))}
        </div>
      </div>
    </div>
  );
}

// Toast — top-of-screen pill notification
function Toast({ children, dark }) {
  return (
    <div className="anim-pop" style={{
      position: 'absolute', top: 60, left: '50%', transform: 'translateX(-50%)',
      background: '#fff', color: 'var(--ink)',
      padding: '8px 14px', borderRadius: 999,
      boxShadow: '0 10px 24px rgba(0,0,0,0.18)',
      fontSize: 13, fontWeight: 500, zIndex: 220,
      display: 'inline-flex', alignItems: 'center', gap: 8, maxWidth: 320,
    }}>{children}</div>
  );
}

Object.assign(window, {
  DarkButton, GradButton, OutlineButton, HeaderBar, BackArrow, CloseBtn, SkipBtn,
  OptionPill, TopicChip, Switch, FollowChip, SectionLabel, ListGroup, ListRow,
  ProgressBar, MirraMark, SearchField, NativeAlert, Toast,
});
