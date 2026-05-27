// mirra-library.jsx — favorites, collections, own quotes, history, explore topics
// Globals: Icon, MIRRA, HeaderBar, BackArrow, CloseBtn, DarkButton, SearchField, FollowChip, ...

// ─── Favorites
function FavoritesScreen({ onClose, state, dispatch, openShare, openQuote }) {
  const [sortOpen, setSortOpen] = useState(false);
  const [following, setFollowing] = useState(true);
  const list = state.favorites.length
    ? state.favorites.map(i => ({ idx: i, text: window.MIRRA.AFFIRMATIONS[i] }))
    : window.MIRRA.AFFIRMATIONS.slice(0, 6).map((t, i) => ({ idx: i, text: t }));
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<BackArrow onClick={onClose}/>}
        right={<div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={() => setSortOpen(!sortOpen)} style={{ color: 'var(--ink)' }}><Icon.arrowSortVert size={18}/></button>
          <FollowChip following={following} onClick={() => setFollowing(!following)}/>
        </div>}
      />
      <div style={{ padding: '10px 22px 0' }}>
        <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 0 12px' }}>My favorites</h2>
        <SearchField placeholder="Search"/>
        <button style={{
          marginTop: 12, width: '100%', height: 48, borderRadius: 999,
          background: '#171B2A', color: '#fff', fontWeight: 600, fontSize: 14,
        }}>Show all in feed</button>
      </div>
      <div style={{ padding: '50px 22px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 10, position: 'relative' }}>
        {list.map(item => (
          <FavRow key={item.idx} text={item.text}
            onTap={() => openQuote?.(item.idx)}
            onShare={() => openShare(item.idx)}
            onUnfav={() => dispatch({ type: 'toggleFav', idx: item.idx })}/>
        ))}
      </div>
      {sortOpen && (
        <div className="anim-fade" style={{ position: 'absolute', inset: 0, zIndex: 50 }} onClick={() => setSortOpen(false)}>
          <div className="anim-pop" onClick={e => e.stopPropagation()} style={{
            position: 'absolute', top: 64, right: 56,
            background: '#fff', borderRadius: 14, padding: 4, minWidth: 160,
            boxShadow: '0 12px 28px rgba(0,0,0,0.18)',
          }}>
            {['Newest first','Oldest first','A-Z'].map(o => (
              <button key={o} onClick={() => setSortOpen(false)} style={{
                width: '100%', textAlign: 'left', padding: '12px 14px', fontSize: 14, color: 'var(--ink)',
                borderBottom: o !== 'A-Z' ? '0.5px solid rgba(0,0,0,0.08)' : 'none',
              }}>{o}</button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
function FavRow({ text, onTap, onShare, onUnfav }) {
  return (
    <div onClick={onTap} style={{ background: '#E9E6F2', borderRadius: 14, padding: '12px 14px', cursor: 'pointer' }}>
      <p style={{ margin: 0, fontSize: 14, lineHeight: 1.45, color: 'var(--ink)' }}>{text}</p>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 8 }}>
        <span style={{ fontSize: 11, color: 'var(--muted-2)' }}>Fri, Sep 19, 2025</span>
        <div style={{ display: 'flex', gap: 14 }}>
          <button onClick={(e) => { e.stopPropagation(); onUnfav(); }}><Icon.heartFill size={18}/></button>
          <button onClick={(e) => e.stopPropagation()}><Icon.bookmark size={18} stroke="var(--ink)"/></button>
          <button onClick={(e) => { e.stopPropagation(); onShare(); }}><Icon.shareIOS size={18} stroke="var(--ink)"/></button>
        </div>
      </div>
    </div>
  );
}

// ─── Collection-quote viewer (full-screen quote with header)
function CollectionQuoteScreen({ onClose, quote, title = 'My favorites', following = true }) {
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0 }}>
      <QuoteBg theme="cabin">
        <div style={{
          position: 'absolute', top: 56, left: 18, right: 18, zIndex: 5,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <BackArrow onClick={onClose} dark/>
          <span style={{ color: '#fff', fontSize: 14, fontWeight: 600 }}>{title}</span>
          <FollowChipDark following={following}/>
        </div>
        <div style={{
          position: 'absolute', inset: 0, padding: '120px 28px 150px',
          display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center',
        }}>
          <p className="serif" style={{ color: '#fff', fontSize: 21, lineHeight: 1.45, margin: 0,
            textShadow: '0 2px 16px rgba(0,0,0,0.5)' }}>{quote}</p>
        </div>
        <div style={{
          position: 'absolute', left: 0, right: 0, bottom: 60,
          display: 'flex', justifyContent: 'center', gap: 32, zIndex: 4,
        }}>
          <button style={{ color: '#fff' }}><Icon.shareIOS size={24} stroke="#fff" sw={1.4}/></button>
          <button style={{ color: '#fff' }}><Icon.heart size={24} stroke="#fff" sw={1.4}/></button>
        </div>
      </QuoteBg>
    </div>
  );
}
function FollowChipDark({ following }) {
  return (
    <button style={{
      padding: '4px 11px', borderRadius: 999,
      background: 'rgba(0,0,0,0.25)', backdropFilter: 'blur(10px)',
      border: '1px solid rgba(255,255,255,0.3)',
      color: '#fff', fontSize: 12, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', gap: 4,
    }}>{following && <Icon.check size={11} sw={2.5} stroke="#fff"/>}{following ? 'Following' : 'Follow'}</button>
  );
}

// ─── Collections list
function CollectionsScreen({ onClose, state, onOpenCollection }) {
  const collections = state.collections;
  if (collections.length === 0) {
    return (
      <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
        <HeaderBar left={<BackArrow onClick={onClose}/>} right={<button style={{ fontSize: 15 }}>Add new</button>}/>
        <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>My collections</h2>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 28 }}>
          <CollectionsEmpty/>
          <p style={{ fontSize: 18, fontWeight: 700, textAlign: 'center', margin: '20px 0 8px' }}>You don't have any collections yet</p>
          <p style={{ fontSize: 13, color: 'var(--muted)', textAlign: 'center', lineHeight: 1.45 }}>
            Create collections to group quotes you want to save together, like 'Loving myself' or 'Reaching my goals'.
          </p>
        </div>
        <div style={{ padding: '0 22px 28px' }}>
          <DarkButton>Create collection</DarkButton>
        </div>
      </div>
    );
  }
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>} right={<button style={{ fontSize: 15 }}>Add new</button>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>My collections</h2>
      <div style={{ padding: '0 22px', overflow: 'auto', flex: 1 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {collections.map(c => (
            <button key={c} onClick={() => onOpenCollection(c)} style={{
              background: '#E9E6F2', borderRadius: 14, padding: '14px 16px',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              textAlign: 'left',
            }}>
              <span>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{c}</div>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>1 quote</div>
              </span>
              <Icon.chevronRight size={18} stroke="var(--muted)"/>
            </button>
          ))}
        </div>
        <SectionLabel>Suggestions</SectionLabel>
        <div style={{ background: '#E9E6F2', borderRadius: 14, padding: '12px 16px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span>
            <div style={{ fontSize: 15, fontWeight: 600 }}>Most shared - Collection</div>
            <div style={{ fontSize: 12, color: 'var(--muted)' }}>5 quotes</div>
          </span>
          <button style={{ width: 28, height: 28, borderRadius: 999, border: '1.5px solid var(--ink)',
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon.plus size={14} sw={2.5}/></button>
        </div>
      </div>
    </div>
  );
}
function CollectionsEmpty() {
  return (
    <svg viewBox="0 0 160 130" style={{ width: 140, height: 110 }}>
      <rect x="20" y="50" width="120" height="22" rx="3" fill="#C7C2D8" stroke="#1A1A1A" strokeWidth="1.5"/>
      <rect x="30" y="72" width="100" height="22" rx="3" fill="#A19BB2" stroke="#1A1A1A" strokeWidth="1.5"/>
      <rect x="40" y="94" width="80" height="22" rx="3" fill="#7C7596" stroke="#1A1A1A" strokeWidth="1.5"/>
      <circle cx="80" cy="42" r="14" fill="#1A1A1A"/>
      <text x="80" y="49" textAnchor="middle" fontFamily="Instrument Serif" fontSize="18" fill="#fff">"</text>
    </svg>
  );
}

// ─── Collection detail view
function CollectionDetailScreen({ onClose, name = 'Motivations', state, openShare, openQuote }) {
  const list = window.MIRRA.AFFIRMATIONS.slice(4, 5);
  const [following, setFollowing] = useState(false);
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<BackArrow onClick={onClose}/>}
        right={<div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button><Icon.arrowSortVert size={18}/></button>
          <button><Icon.ellipsis size={18}/></button>
          <FollowChip following={following} onClick={() => setFollowing(!following)}/>
        </div>}
      />
      <div style={{ padding: '10px 22px 0' }}>
        <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 0 12px' }}>{name}</h2>
        <SearchField placeholder="Search"/>
        <button style={{
          marginTop: 12, width: '100%', height: 48, borderRadius: 999,
          background: '#171B2A', color: '#fff', fontWeight: 600, fontSize: 14,
        }}>Show all in feed</button>
      </div>
      <div style={{ padding: '14px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 10 }}>
        {list.map((t, i) => (
          <div key={i} style={{ background: '#E9E6F2', borderRadius: 14, padding: '12px 14px' }}>
            <p style={{ margin: 0, fontSize: 14, lineHeight: 1.45, color: 'var(--ink)' }}>{t}</p>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 8 }}>
              <span style={{ fontSize: 11, color: 'var(--muted-2)' }}>Fri, Sep 19, 2025</span>
              <div style={{ display: 'flex', gap: 14 }}>
                <Icon.heartFill size={17}/>
                <Icon.bookmarkFill size={17}/>
                <Icon.shareIOS size={17}/>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Add to collection sheet (in-app picker, with empty + filled states)
function AddToCollectionSheet({ onClose, state, dispatch, onCreate }) {
  const collections = state.collections;
  if (collections.length === 0) {
    return (
      <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 100 }} onClick={onClose}>
        <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
          position: 'absolute', left: 0, right: 0, top: 100, bottom: 0,
          background: 'var(--bg)', borderRadius: '24px 24px 0 0',
          padding: '14px 22px 28px', display: 'flex', flexDirection: 'column',
        }}>
          <HeaderBar tight
            left={<button onClick={onClose} style={{ fontSize: 15 }}>Cancel</button>}
            right={<button onClick={onCreate} style={{ fontSize: 15 }}>Add new</button>}
          />
          <h2 style={{ fontSize: 20, fontWeight: 800, margin: '12px 0 14px' }}>Add to collection</h2>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 12 }}>
            <CollectionsEmpty/>
            <p style={{ fontSize: 18, fontWeight: 700, textAlign: 'center', margin: '14px 0 8px' }}>You don't have any collections yet</p>
            <p style={{ fontSize: 13, color: 'var(--muted)', textAlign: 'center', lineHeight: 1.45 }}>
              Create collections to group quotes you want to save together, like 'Loving myself' or 'Reaching my goals'.
            </p>
          </div>
          <DarkButton onClick={onCreate}>Create collection</DarkButton>
        </div>
      </div>
    );
  }
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 100 }} onClick={onClose}>
      <div className="anim-slideup" onClick={e => e.stopPropagation()} style={{
        position: 'absolute', left: 0, right: 0, top: 100, bottom: 0,
        background: 'var(--bg)', borderRadius: '24px 24px 0 0',
        padding: '14px 22px 28px', display: 'flex', flexDirection: 'column',
      }}>
        <HeaderBar tight
          left={<button onClick={onClose} style={{ fontSize: 15 }}>Close</button>}
          right={<button onClick={onCreate} style={{ fontSize: 15 }}>Add new</button>}
        />
        <h2 style={{ fontSize: 20, fontWeight: 800, margin: '12px 0 14px' }}>My collections</h2>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {collections.map(c => (
            <button key={c} onClick={() => { onClose(); }} style={{
              background: '#E9E6F2', borderRadius: 14, padding: '14px 16px',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              textAlign: 'left',
            }}>
              <span style={{ fontSize: 15, color: 'var(--ink)' }}>{c}</span>
              <Icon.bookmarkFill size={18}/>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Own Quotes (empty + with items)
function OwnQuotesScreen({ onClose, state, dispatch, openAdd }) {
  const [menuFor, setMenuFor] = useState(null);
  const [following, setFollowing] = useState(true);
  const list = state.ownQuotes || [];
  const hasItems = list.length > 0;
  if (!hasItems) return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>} right={<button onClick={openAdd} style={{ fontSize: 15 }}>Add</button>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 0' }}>Your own quotes</h2>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 28 }}>
        <OwnQuotesEmpty/>
        <p style={{ fontSize: 18, fontWeight: 700, textAlign: 'center', margin: '24px 0 0' }}>You haven't added any quotes yet</p>
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton onClick={openAdd}>Add quote</DarkButton>
      </div>
    </div>
  );
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<BackArrow onClick={onClose}/>}
        right={<div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button><Icon.arrowSortVert size={18}/></button>
          <button><Icon.ellipsis size={18}/></button>
          <FollowChip following={following} onClick={() => setFollowing(!following)}/>
        </div>}
      />
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 12px' }}>Your own quotes</h2>
      <div style={{ padding: '0 22px', flex: 1, overflow: 'auto' }}>
        <SearchField placeholder="Search"/>
        <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 8, position: 'relative' }}>
          {list.map((q, i) => (
            <div key={i} style={{ background: '#E9E6F2', borderRadius: 14, padding: '12px 14px', position: 'relative' }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                <p style={{ margin: 0, fontSize: 14, fontWeight: 600 }}>{q}</p>
                <button onClick={() => setMenuFor(menuFor === i ? null : i)}><Icon.ellipsisV size={18}/></button>
              </div>
              <div style={{ fontSize: 11, color: 'var(--muted-2)', marginTop: 4 }}>Fri, Sep 19, 2025</div>
              {menuFor === i && (
                <div className="anim-pop" style={{
                  position: 'absolute', top: 32, right: 8, zIndex: 5,
                  background: '#fff', borderRadius: 12, padding: 4, minWidth: 160,
                  boxShadow: '0 12px 28px rgba(0,0,0,0.18)',
                }}>
                  <button style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', fontSize: 14, color: 'var(--ink)' }}>
                    Edit <Icon.pencil size={16}/>
                  </button>
                  <div style={{ height: '0.5px', background: 'rgba(0,0,0,0.08)', marginInline: 12 }}/>
                  <button style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', fontSize: 14, color: '#E25C5C' }}>
                    Delete <Icon.trash size={16}/>
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: '0 22px 28px' }}>
        <DarkButton onClick={openAdd}>Add quote</DarkButton>
      </div>
    </div>
  );
}
function OwnQuotesEmpty() {
  return (
    <svg viewBox="0 0 160 160" style={{ width: 150, height: 150 }}>
      <text x="80" y="40" textAnchor="middle" fontFamily="Instrument Serif" fontSize="22" fill="#171B2A">"</text>
      <text x="105" y="55" textAnchor="middle" fontFamily="Instrument Serif" fontSize="18" fill="#9A93A8">"</text>
      <text x="75" y="76" textAnchor="middle" fontFamily="Instrument Serif" fontSize="20" fill="#171B2A">"</text>
      <path d="M40 90 L120 90 L130 100 L115 150 L45 150 L30 100 Z" fill="#C7C2D8" stroke="#1A1A1A" strokeWidth="1.5"/>
      <path d="M40 90 L65 100 L95 100 L120 90" fill="none" stroke="#1A1A1A" strokeWidth="1.5"/>
      <path d="M30 100 L45 100 L65 100" stroke="#1A1A1A" strokeWidth="1.5" fill="none"/>
      <text x="65" y="125" fontFamily="Instrument Serif" fontSize="18" fill="#777" transform="rotate(-15 65 125)">"</text>
    </svg>
  );
}

// ─── Add quote screen (with keyboard)
function AddOwnQuoteScreen({ onClose, onSave }) {
  const [text, setText] = useState('You can do it, Julia!');
  const [author, setAuthor] = useState('');
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose} label="Back"/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 0' }}>Add new</h2>
      <p style={{ fontSize: 13, color: 'var(--muted)', margin: '6px 22px 12px' }}>Add your own quote. It will only be visible to you.</p>
      <div style={{ padding: '4px 22px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        <input value={text} onChange={e => setText(e.target.value)}
          placeholder="Your quote"
          style={{ height: 44, padding: '0 16px', borderRadius: 999, border: 0, background: '#E9E6F2', fontSize: 14, color: 'var(--ink)', outline: 0 }}/>
        <input value={author} onChange={e => setAuthor(e.target.value)}
          placeholder="Author (optional)"
          style={{ height: 44, padding: '0 16px', borderRadius: 999, border: 0, background: '#E9E6F2', fontSize: 14, color: 'var(--ink-2)', outline: 0,
            opacity: author ? 1 : 0.6 }}/>
      </div>
      <div style={{ flex: 1 }}/>
      <div style={{ padding: '0 22px 14px' }}>
        <DarkButton onClick={() => { onSave(text); onClose(); }}>Save</DarkButton>
      </div>
      <SimpleKeyboard keyboardType="number"/>
    </div>
  );
}

// ─── Tiny keyboard renderer (visual only)
function SimpleKeyboard({ keyboardType = 'text' }) {
  const numberRow = ['1','2','3','4','5','6','7','8','9','0'];
  const numSymRow = ['-','/',':',';','(',')','₱','&','@','"'];
  const punctRow = ['.',',','?','!','\''];
  const letters1 = ['q','w','e','r','t','y','u','i','o','p'];
  const letters2 = ['a','s','d','f','g','h','j','k','l'];
  const letters3 = ['z','x','c','v','b','n','m'];
  const Key = ({ ch, w, bg = '#fff', flex }) => (
    <div style={{
      flex: flex ? 1 : undefined, width: w, minWidth: 0,
      height: 38, borderRadius: 6, background: bg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: '0 1px 0 rgba(0,0,0,0.08)',
      fontFamily: '-apple-system, "SF Pro", system-ui', fontSize: 20, fontWeight: 500, color: '#222',
    }}>{ch}</div>
  );
  const Row = ({ cols, gap = 5, pad = 4 }) => (
    <div style={{ display: 'flex', gap, padding: `0 ${pad}px`, justifyContent: 'center' }}>{cols}</div>
  );
  if (keyboardType === 'number') return (
    <div style={{ background: 'rgba(220,220,225,0.92)', backdropFilter: 'blur(20px)', padding: '8px 0 4px',
      display: 'flex', flexDirection: 'column', gap: 6 }}>
      <Row cols={numberRow.map(c => <Key key={c} ch={c} flex/>)}/>
      <Row cols={numSymRow.map(c => <Key key={c} ch={c} flex/>)}/>
      <Row cols={[
        <Key key="123" ch="#+=" w={42} bg="#ACAFB7"/>,
        ...punctRow.map(c => <Key key={c} ch={c} flex/>),
        <Key key="del" ch="⌫" w={42} bg="#ACAFB7"/>,
      ]}/>
      <Row cols={[
        <Key key="abc" ch="ABC" w={60} bg="#ACAFB7"/>,
        <Key key="space" ch="space" flex/>,
        <Key key="ret" ch="return" w={60} bg="#ACAFB7"/>,
      ]}/>
    </div>
  );
  return (
    <div style={{ background: 'rgba(220,220,225,0.92)', backdropFilter: 'blur(20px)', padding: '8px 0 4px',
      display: 'flex', flexDirection: 'column', gap: 6 }}>
      <Row cols={letters1.map(c => <Key key={c} ch={c} flex/>)}/>
      <Row cols={letters2.map(c => <Key key={c} ch={c} flex/>)}/>
      <Row cols={[
        <Key key="shift" ch="⇧" w={32} bg="#ACAFB7"/>,
        ...letters3.map(c => <Key key={c} ch={c} flex/>),
        <Key key="del" ch="⌫" w={32} bg="#ACAFB7"/>,
      ]}/>
      <Row cols={[
        <Key key="123" ch="123" w={50} bg="#ACAFB7"/>,
        <Key key="space" ch="space" flex/>,
        <Key key="ret" ch="return" w={64} bg="#ACAFB7"/>,
      ]}/>
    </div>
  );
}

// ─── History
function HistoryScreen({ onClose }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<BackArrow onClick={onClose}/>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 14px' }}>History</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {window.MIRRA.AFFIRMATIONS.map((t, i) => (
          <div key={i} style={{ background: '#E9E6F2', borderRadius: 12, padding: '12px 14px' }}>
            <p style={{ margin: 0, fontSize: 14, lineHeight: 1.45, color: 'var(--ink)' }}>{t}</p>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 14, marginTop: 8, color: 'var(--ink)' }}>
              {i < 3 ? <Icon.heartFill size={17}/> : <Icon.heart size={17}/>}
              <Icon.bookmark size={17}/>
              <Icon.shareIOS size={17}/>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Explore topics
function ExploreScreen({ onClose, openAuthor, openTopic, openFavorites, openCollections, openOwn, openRecent }) {
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar
        left={<button onClick={onClose} style={{ fontSize: 15, color: 'var(--ink)' }}>Close</button>}
        center="Explore topics"
        right={<button style={{ fontSize: 15, color: 'var(--ink)' }}>Edit</button>}
      />
      <div style={{ padding: '50px 22px 22px', overflow: 'auto', flex: 1 }}>
        <SearchField placeholder="Search topics"/>
        {/* quick tiles */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8, marginTop: 14 }}>
          <QuickTile label="My favorites" icon={<Icon.heart size={20}/>} onClick={openFavorites}/>
          <QuickTile label="My collections" icon={<Icon.bookmark size={20}/>} onClick={openCollections}/>
          <QuickTile label="My own quotes" icon={<Icon.pencil size={20}/>} onClick={openOwn}/>
          <QuickTile label="Recent quotes" icon={<Icon.refresh size={20}/>} onClick={openRecent}/>
        </div>
        {/* Most popular */}
        <h3 style={{ fontSize: 17, fontWeight: 800, margin: '24px 0 10px' }}>Most popular</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {['Encouraging words','New beginnings','Affirmations','Fake people','Self-worth','Bible verses'].map((t, i) => (
            <RowLink key={t} icon={<Icon.quote size={18}/>} label={t} chevron checked={t==='Affirmations'} onClick={() => openTopic(t)}/>
          ))}
        </div>
        {/* Zodiac */}
        <h3 style={{ fontSize: 17, fontWeight: 800, margin: '20px 0 10px' }}>Zodiac signs</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {['Capricorn','Pisces','Gemini'].map(z => {
            const G = Icon[z.toLowerCase()];
            return <RowLink key={z} icon={G ? <G size={18}/> : null} label={z} chevron onClick={() => openTopic(z)}/>;
          })}
        </div>
        {/* Authors */}
        <h3 style={{ fontSize: 17, fontWeight: 800, margin: '20px 0 10px' }}>Popular authors</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {window.MIRRA.AUTHORS.slice(0,6).map(a => (
            <RowLink key={a} icon={<Icon.quote size={18}/>} label={a} chevron onClick={() => openAuthor(a)}/>
          ))}
        </div>
      </div>
    </div>
  );
}
function QuickTile({ label, icon, onClick }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      background: '#E9E6F2', borderRadius: 14, padding: '14px 14px',
      display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 14, height: 76,
      position: 'relative',
    }}>
      <span style={{ fontSize: 14, fontWeight: 600 }}>{label}</span>
      <span style={{ position: 'absolute', right: 12, bottom: 12, color: 'var(--ink)' }}>{icon}</span>
    </button>
  );
}
function RowLink({ icon, label, chevron, onClick, checked }) {
  return (
    <button onClick={onClick} className="no-tap" style={{
      width: '100%', background: '#E9E6F2', borderRadius: 12, padding: '13px 14px',
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      {icon && <span style={{ color: 'var(--ink)' }}>{icon}</span>}
      <span style={{ flex: 1, fontSize: 14, color: 'var(--ink)', textAlign: 'left' }}>{label}</span>
      {checked && <span style={{ width: 20, height: 20, borderRadius: 999, background: '#171B2A', color: '#fff', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}><Icon.check size={11} sw={2.8}/></span>}
      {chevron && <Icon.chevronRight size={16} stroke="var(--muted)"/>}
    </button>
  );
}

// ─── Topics you follow (multi-section)
function TopicsFollowScreen({ onClose }) {
  const [follows, setFollows] = useState(new Set(['General','My favorites','Encouraging words','Affirmations','Self-worth','Bible verses','Love','Fitness','New beginnings','Fake people']));
  const toggle = (t) => {
    const n = new Set(follows);
    n.has(t) ? n.delete(t) : n.add(t);
    setFollows(n);
  };
  const Group = ({ title, items, action }) => (
    <>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 16, marginBottom: 8 }}>
        <h3 style={{ fontSize: 16, fontWeight: 800, margin: 0 }}>{title}</h3>
        {action}
      </div>
      <div style={{ background: '#E9E6F2', borderRadius: 14, padding: '4px 14px' }}>
        {items.map((t, i) => (
          <div key={t} style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '10px 0', borderBottom: i < items.length - 1 ? '0.5px solid rgba(0,0,0,0.08)' : 'none',
          }}>
            <span style={{ fontSize: 14, color: 'var(--ink)' }}>{t}</span>
            <FollowChip following={follows.has(t)} onClick={() => toggle(t)}/>
          </div>
        ))}
      </div>
    </>
  );
  return (
    <div className="anim-slideup" style={{ position: 'absolute', inset: 0, background: '#fff', display: 'flex', flexDirection: 'column' }}>
      <HeaderBar left={<button onClick={onClose} style={{ fontSize: 15 }}>Close</button>}/>
      <h2 style={{ fontSize: 22, fontWeight: 800, margin: '4px 22px 12px' }}>Topics you follow</h2>
      <div style={{ padding: '0 22px 22px', overflow: 'auto', flex: 1 }}>
        <SearchField placeholder="Search"/>
        <Group title="Following" items={['General','My favorites','My own quotes']}/>
        <Group title="Most popular" items={window.MIRRA.TOPICS_POPULAR}
          action={<button style={{ fontSize: 13, color: 'var(--ink)', fontWeight: 500 }}>Following</button>}/>
        <Group title="Personal growth" items={window.MIRRA.TOPICS_GROWTH}
          action={<button style={{ fontSize: 13, color: 'var(--ink)', fontWeight: 500 }}>Follow all</button>}/>
      </div>
    </div>
  );
}

// ─── Topic / Author detail (full-screen quote with header)
function TopicDetailScreen({ onClose, title, withAuthor, theme = 'cabin' }) {
  const [following, setFollowing] = useState(false);
  const q = withAuthor
    ? "A lie can travel halfway around the world while the truth is putting on its shoes."
    : "Sometimes what you're most afraid of doing is the one thing that will set you free.";
  return (
    <div className="anim-fade" style={{ position: 'absolute', inset: 0 }}>
      <QuoteBg theme={theme}>
        <div style={{
          position: 'absolute', top: 56, left: 18, right: 18, zIndex: 5,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <BackArrow onClick={onClose} dark/>
          <span style={{ color: '#fff', fontSize: 14, fontWeight: 600 }}>{title}</span>
          <FollowChipDark following={following}/>
        </div>
        <div style={{
          position: 'absolute', inset: 0, padding: '120px 28px 150px',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center',
        }}>
          <p className="serif" style={{ color: '#fff', fontSize: 22, lineHeight: 1.45, margin: 0,
            textShadow: '0 2px 16px rgba(0,0,0,0.5)' }}>{q}</p>
          {withAuthor && <p style={{ color: '#fff', fontSize: 14, marginTop: 14, opacity: 0.8 }}>-{title}</p>}
        </div>
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 60,
          display: 'flex', justifyContent: 'center', gap: 32 }}>
          <Icon.shareIOS size={24} stroke="#fff" sw={1.4}/>
          <Icon.heart size={24} stroke="#fff" sw={1.4}/>
        </div>
      </QuoteBg>
    </div>
  );
}

Object.assign(window, {
  FavoritesScreen, FavRow, CollectionQuoteScreen, FollowChipDark,
  CollectionsScreen, CollectionDetailScreen, AddToCollectionSheet,
  OwnQuotesScreen, AddOwnQuoteScreen, SimpleKeyboard,
  HistoryScreen, ExploreScreen, TopicsFollowScreen, TopicDetailScreen,
});
