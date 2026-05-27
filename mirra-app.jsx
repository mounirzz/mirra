// mirra-app.jsx — orchestrator + navigator
const { useReducer: useR } = React;

const INITIAL = {
  step: 'welcome',
  onbStep: 0,
  answers: {},
  iconChoice: 'i2',
  theme: 'cabin',
  favorites: [],
  saved: [],
  collections: [],
  ownQuotes: [],
  streak: 1,
  overlay: null,  // tip5 | streakBanner | mixSheet | feedSetUp | themeChangedToast | savedToast | textCopied
  modal: null,    // screens
  modalIdx: 0,
};

function reducer(state, action) {
  switch (action.type) {
    case 'goto': return { ...state, step: action.step };
    case 'answer': return { ...state, answers: { ...state.answers, [action.id]: action.value } };
    case 'onbNext': return { ...state, onbStep: state.onbStep + 1 };
    case 'onbBack': return { ...state, onbStep: Math.max(0, state.onbStep - 1) };
    case 'setIcon': return { ...state, iconChoice: action.id };
    case 'setTheme': return { ...state, theme: action.id };
    case 'toggleFav': {
      const has = state.favorites.includes(action.idx);
      return { ...state, favorites: has ? state.favorites.filter(i => i !== action.idx) : [...state.favorites, action.idx] };
    }
    case 'addCollection': return { ...state, collections: [...state.collections, action.name] };
    case 'addOwnQuote': return { ...state, ownQuotes: [...state.ownQuotes, action.quote] };
    case 'openModal': return { ...state, modal: action.name, modalIdx: action.idx ?? state.modalIdx };
    case 'closeModal': return { ...state, modal: null };
    case 'pushModal': return { ...state, modalStack: [...(state.modalStack || []), state.modal], modal: action.name };
    case 'openOverlay': return { ...state, overlay: action.name };
    case 'closeOverlay': return { ...state, overlay: null };
    default: return state;
  }
}

function MirraApp({ jumpTo }) {
  const [state, dispatch] = useR(reducer, INITIAL);
  const questions = window.MIRRA.ONBOARDING;

  useEffect(() => {
    if (!jumpTo) return;
    // Reset to home or onboarding step before applying modal/overlay
    if (jumpTo.modal) dispatch({ type: 'openModal', name: jumpTo.modal, idx: jumpTo.idx || 0 });
    if (jumpTo.overlay) dispatch({ type: 'openOverlay', name: jumpTo.overlay });
    if (jumpTo.step) dispatch({ type: 'goto', step: jumpTo.step });
    if (jumpTo.onbStep !== undefined) {
      dispatch({ type: 'goto', step: 'questions' });
      // hacky: directly set onbStep
      for (let i = 0; i < jumpTo.onbStep; i++) dispatch({ type: 'onbNext' });
    }
  }, [jumpTo && jumpTo._key]);

  // ───── ONBOARDING navigation
  const q = questions[state.onbStep];
  const onbTotal = questions.length;
  const advance = () => {
    if (state.onbStep < onbTotal - 1) dispatch({ type: 'onbNext' });
    else dispatch({ type: 'goto', step: 'streakIntro' });
  };
  const back = () => {
    if (state.onbStep > 0) dispatch({ type: 'onbBack' });
    else dispatch({ type: 'goto', step: 'intro' });
  };

  // ───── BODY
  let body = null;
  if (state.step === 'welcome') {
    body = <WelcomeScreen onContinue={() => dispatch({ type: 'goto', step: 'intro' })}/>;
  } else if (state.step === 'intro') {
    body = <IntroScreen onContinue={() => dispatch({ type: 'goto', step: 'questions' })}/>;
  } else if (state.step === 'questions') {
    if (q.kind === 'splash') {
      body = <SplashScreen title={q.title} illustration={q.illustration} onContinue={advance} onBack={back}/>;
    } else if (q.kind === 'goals') {
      body = <GoalsScreen value={state.answers[q.id]} onChange={v => dispatch({type:'answer', id: q.id, value: v})}
        onContinue={advance} onBack={back} onSkip={advance} step={state.onbStep} total={onbTotal}/>;
    } else if (q.kind === 'topics') {
      body = <TopicsScreen q={q} value={state.answers[q.id]} onChange={v => dispatch({type:'answer', id: q.id, value: v})}
        onContinue={advance} onBack={back} onSkip={advance} step={state.onbStep} total={onbTotal}/>;
    } else {
      body = <QuestionScreen q={q} value={state.answers[q.id]} onChange={v => dispatch({type:'answer', id: q.id, value: v})}
        onContinue={advance} onBack={back} onSkip={advance} step={state.onbStep} total={onbTotal}/>;
    }
  } else if (state.step === 'streakIntro') {
    body = <StreakIntroScreen onContinue={() => dispatch({ type: 'goto', step: 'reminders' })} onBack={() => dispatch({ type: 'goto', step: 'questions' })}/>;
  } else if (state.step === 'reminders') {
    body = <RemindersSetupScreen onContinue={() => dispatch({ type: 'goto', step: 'bundleOnb' })} onBack={() => dispatch({ type: 'goto', step: 'streakIntro' })}/>;
  } else if (state.step === 'bundleOnb') {
    body = <BundleScreen onClose={() => dispatch({ type: 'goto', step: 'iconPickerOnb' })}
      onClaim={() => dispatch({ type: 'goto', step: 'iconPickerOnb' })} fromOnboarding/>;
  } else if (state.step === 'iconPickerOnb') {
    body = <IconPickerScreen value={state.iconChoice} onChange={(id) => dispatch({type:'setIcon', id})}
      onContinue={() => dispatch({ type: 'goto', step: 'themePicker' })}
      onBack={() => dispatch({ type: 'goto', step: 'bundleOnb' })}
      showAlert={false} setShowAlert={() => {}}/>;
  } else if (state.step === 'themePicker') {
    body = <ThemePickerScreen value={state.theme} onChange={(id) => dispatch({type:'setTheme', id})}
      onContinue={() => dispatch({ type: 'goto', step: 'trialIntro' })}
      onBack={() => dispatch({ type: 'goto', step: 'iconPickerOnb' })}/>;
  } else if (state.step === 'trialIntro') {
    body = <FreeTrialIntroScreen onContinue={() => dispatch({ type: 'goto', step: 'trialHow' })}
      onBack={() => dispatch({ type: 'goto', step: 'themePicker' })}/>;
  } else if (state.step === 'trialHow') {
    body = <FreeTrialHowScreen onContinue={() => dispatch({ type: 'goto', step: 'addWidget' })}
      onBack={() => dispatch({ type: 'goto', step: 'trialIntro' })}
      onSkip={() => dispatch({ type: 'goto', step: 'addWidget' })}/>;
  } else if (state.step === 'addWidget') {
    body = <AddWidgetScreen onContinue={() => dispatch({ type: 'goto', step: 'trialStarted' })}
      onBack={() => dispatch({ type: 'goto', step: 'trialHow' })}
      onSkip={() => dispatch({ type: 'goto', step: 'trialStarted' })}/>;
  } else if (state.step === 'trialStarted') {
    body = <TrialStartedScreen onContinue={() => dispatch({ type: 'goto', step: 'premiumWelcome' })}
      onLater={() => dispatch({ type: 'goto', step: 'premiumWelcome' })}/>;
  } else if (state.step === 'premiumWelcome') {
    body = <PremiumWelcomeScreen onContinue={() => {
      dispatch({ type: 'goto', step: 'home' });
      setTimeout(() => dispatch({ type: 'openOverlay', name: 'streakBanner' }), 200);
      setTimeout(() => dispatch({ type: 'closeOverlay' }), 3500);
      setTimeout(() => dispatch({ type: 'openOverlay', name: 'tip5' }), 3700);
    }}/>;
  } else if (state.step === 'home') {
    body = <HomeScreen state={state} dispatch={dispatch}
      openShare={(idx) => dispatch({ type: 'openModal', name: 'shareSheet', idx })}
      openTheme={() => dispatch({ type: 'openModal', name: 'themes' })}
      openProfile={() => dispatch({ type: 'openModal', name: 'profile' })}
      openExplore={() => dispatch({ type: 'openModal', name: 'explore' })}
      openCollections={(idx) => dispatch({ type: 'openModal', name: 'addToCollection', idx })}
      showTip5={state.overlay === 'tip5'}
      showStreak={state.overlay === 'streakBanner'}/>;
  }

  // overlays/modals
  const focused = window.MIRRA.AFFIRMATIONS[state.modalIdx] || window.MIRRA.AFFIRMATIONS[0];

  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', borderRadius: 'inherit' }}>
      {body}

      {/* ── Overlays */}
      {state.overlay === 'mixSheet' && <ExploreScreen onClose={() => dispatch({ type: 'closeOverlay' })} openAuthor={()=>{}} openTopic={()=>{}} openFavorites={()=>{}} openCollections={()=>{}} openOwn={()=>{}} openRecent={()=>{}}/>}
      {state.overlay === 'feedSetUp' && <FeedSetUpToast/>}
      {state.overlay === 'themeChangedToast' && <ThemeChangedToast onClose={() => dispatch({ type: 'closeOverlay' })}/>}
      {state.overlay === 'savedToast' && <SavedToast/>}
      {state.overlay === 'textCopied' && <Toast><Icon.copy size={14}/> Text copied!</Toast>}
      {state.overlay === 'editTheme' && <EditThemeOverlay onClose={() => dispatch({ type: 'closeOverlay' })} state={state} dispatch={dispatch} quote={focused}/>}
      {state.overlay === 'spreadCard' && <SpreadCard onClose={() => dispatch({ type: 'closeOverlay' })} onShare={() => { dispatch({ type: 'closeOverlay' }); dispatch({ type: 'openModal', name: 'shareSheet' }); }}/>}
      {state.overlay === 'rateDialog' && <RateDialog stage="rate" onCancel={() => dispatch({ type: 'closeOverlay' })}
        onSubmit={() => dispatch({ type: 'openOverlay', name: 'rateDialog2' })}/>}
      {state.overlay === 'rateDialog2' && <RateDialog stage="thanks" onWriteReview={() => dispatch({ type: 'closeOverlay' })} onOK={() => dispatch({ type: 'closeOverlay' })}/>}

      {/* ── Modals */}
      {state.modal === 'shareSheet' && (
        <ShareSheet onClose={() => dispatch({ type: 'closeModal' })} quote={focused} theme={state.theme}
          onCopy={() => { dispatch({ type: 'closeModal' }); dispatch({ type: 'openOverlay', name: 'textCopied' }); setTimeout(() => dispatch({ type: 'closeOverlay' }), 1400); }}
          onAddCollection={() => dispatch({ type: 'openModal', name: 'addToCollection' })}
          onSaveVideo={() => dispatch({ type: 'openModal', name: 'iosShare' })}
          openEditTheme={() => { dispatch({ type: 'closeModal' }); dispatch({ type: 'openOverlay', name: 'editTheme' }); }}/>
      )}
      {state.modal === 'iosShare' && <IOSShareSheet onClose={() => dispatch({ type: 'closeModal' })} quote={focused}/>}
      {state.modal === 'addToCollection' && (
        <AddToCollectionSheet onClose={() => dispatch({ type: 'closeModal' })} state={state} dispatch={dispatch}
          onCreate={() => { dispatch({ type: 'addCollection', name: 'Motivations' }); dispatch({ type: 'closeModal' });
            dispatch({ type: 'openOverlay', name: 'savedToast' }); setTimeout(() => dispatch({ type: 'closeOverlay' }), 1500); }}/>
      )}
      {state.modal === 'themes' && <ThemesScreen onClose={() => dispatch({ type: 'closeModal' })} state={state} dispatch={dispatch}
        openMixes={() => dispatch({ type: 'openModal', name: 'themeMixes' })}/>}
      {state.modal === 'themeMixes' && <ThemeMixesScreen onClose={() => dispatch({ type: 'openModal', name: 'themes' })}/>}

      {state.modal === 'profile' && (
        <ProfileScreen onClose={() => dispatch({ type: 'closeModal' })} state={state} dispatch={dispatch}
          openHistory={() => dispatch({ type: 'openModal', name: 'history' })}
          openFavorites={() => dispatch({ type: 'openModal', name: 'favorites' })}
          openCollections={() => dispatch({ type: 'openModal', name: 'collections' })}
          openOwn={() => dispatch({ type: 'openModal', name: 'ownQuotes' })}
          openRecent={() => dispatch({ type: 'openModal', name: 'history' })}
          openTopicsFollow={() => dispatch({ type: 'openModal', name: 'topicsFollow' })}
          openReminders={() => dispatch({ type: 'openModal', name: 'reminders' })}
          openAppIcon={() => dispatch({ type: 'openModal', name: 'appIcon' })}
          openWidgets={() => dispatch({ type: 'openModal', name: 'widgets' })}
          openWatch={() => dispatch({ type: 'openModal', name: 'watch' })}
          openBundle={() => dispatch({ type: 'openModal', name: 'bundle' })}
          openPreferences={() => dispatch({ type: 'openModal', name: 'preferences' })}/>
      )}
      {state.modal === 'favorites' && <FavoritesScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}
        state={state} dispatch={dispatch}
        openShare={(idx) => dispatch({ type: 'openModal', name: 'shareSheet', idx })}
        openQuote={(idx) => dispatch({ type: 'openModal', name: 'collectionQuote', idx })}/>}
      {state.modal === 'collectionQuote' && <CollectionQuoteScreen onClose={() => dispatch({ type: 'openModal', name: 'favorites' })} quote={focused}/>}
      {state.modal === 'collections' && <CollectionsScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}
        state={state} onOpenCollection={(c) => dispatch({ type: 'openModal', name: 'collectionDetail' })}/>}
      {state.modal === 'collectionDetail' && <CollectionDetailScreen onClose={() => dispatch({ type: 'openModal', name: 'collections' })} state={state}/>}
      {state.modal === 'ownQuotes' && <OwnQuotesScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}
        state={state} dispatch={dispatch} openAdd={() => dispatch({ type: 'openModal', name: 'addOwn' })}/>}
      {state.modal === 'addOwn' && <AddOwnQuoteScreen onClose={() => dispatch({ type: 'openModal', name: 'ownQuotes' })}
        onSave={(q) => dispatch({ type: 'addOwnQuote', quote: q })}/>}
      {state.modal === 'history' && <HistoryScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'topicsFollow' && <TopicsFollowScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'reminders' && <RemindersScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'appIcon' && <AppIconScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'widgets' && <WidgetsScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'watch' && <WatchScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}/>}
      {state.modal === 'bundle' && <BundleScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}
        onClaim={() => dispatch({ type: 'closeModal' })}/>}
      {state.modal === 'explore' && <ExploreScreen onClose={() => dispatch({ type: 'closeModal' })}
        openTopic={() => dispatch({ type: 'openModal', name: 'topicDetail' })}
        openAuthor={() => dispatch({ type: 'openModal', name: 'authorDetail' })}
        openFavorites={() => dispatch({ type: 'openModal', name: 'favorites' })}
        openCollections={() => dispatch({ type: 'openModal', name: 'collections' })}
        openOwn={() => dispatch({ type: 'openModal', name: 'ownQuotes' })}
        openRecent={() => dispatch({ type: 'openModal', name: 'history' })}/>}
      {state.modal === 'topicDetail' && <TopicDetailScreen onClose={() => dispatch({ type: 'openModal', name: 'explore' })} title="Encouraging words"/>}
      {state.modal === 'authorDetail' && <TopicDetailScreen onClose={() => dispatch({ type: 'openModal', name: 'explore' })} title="Mark Twain" withAuthor/>}

      {state.modal === 'preferences' && <PreferencesScreen onClose={() => dispatch({ type: 'openModal', name: 'profile' })}
        openManageSub={() => dispatch({ type: 'openModal', name: 'manageSub' })}
        openContentPrefs={() => dispatch({ type: 'openModal', name: 'contentPrefs' })}
        openGender={() => dispatch({ type: 'openModal', name: 'gender' })}
        openMuted={() => dispatch({ type: 'openModal', name: 'muted' })}
        openLanguage={() => dispatch({ type: 'openModal', name: 'language' })}
        openName={() => dispatch({ type: 'openModal', name: 'name' })}
        openSound={() => dispatch({ type: 'openModal', name: 'sound' })}
        openVoice={() => dispatch({ type: 'openModal', name: 'voice' })}
        openSiri={() => dispatch({ type: 'openModal', name: 'siri' })}
        openSignIn={() => dispatch({ type: 'openModal', name: 'signin' })}
        openHelp={() => dispatch({ type: 'openModal', name: 'help' })}/>}
      {state.modal === 'manageSub' && <ManageSubScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'contentPrefs' && <ContentPrefsScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'gender' && <GenderScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'muted' && <MutedScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'language' && <LanguageScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'name' && <NameScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'sound' && <SoundScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'voice' && <VoiceScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'siri' && <SiriScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'signin' && <SignInScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
      {state.modal === 'help' && <HelpScreen onClose={() => dispatch({ type: 'openModal', name: 'preferences' })}/>}
    </div>
  );
}

// ─── Side navigator (full screen registry)
const NAV_GROUPS = [
  { label: 'Onboarding', items: [
    { id: 'welcome', name: 'Welcome' },
    { id: 'intro',   name: "Get personalized" },
    { id: 'q0', name: 'Q · Gender', kind: 'onb', onbStep: 0 },
    { id: 'q1', name: 'Q · Age', kind: 'onb', onbStep: 1 },
    { id: 'q2', name: 'Q · Mood (curves)', kind: 'onb', onbStep: 2 },
    { id: 'q3', name: 'Q · Feeling source', kind: 'onb', onbStep: 3 },
    { id: 's1', name: 'Splash · Compass', kind: 'onb', onbStep: 4 },
    { id: 'q5', name: 'Q · Improve', kind: 'onb', onbStep: 5 },
    { id: 's2', name: 'Splash · Arch', kind: 'onb', onbStep: 8 },
    { id: 'q9', name: 'Q · Motivation source', kind: 'onb', onbStep: 9 },
    { id: 's3', name: 'Splash · Plant', kind: 'onb', onbStep: 15 },
    { id: 'q16', name: 'Q · Zodiac', kind: 'onb', onbStep: 16 },
    { id: 'q17', name: 'Goals (textarea)', kind: 'onb', onbStep: 17 },
    { id: 'q18', name: 'Topics (chips)', kind: 'onb', onbStep: 18 },
    { id: 'streakIntro', name: 'Streak intro' },
    { id: 'reminders', name: 'Reminders setup' },
    { id: 'bundleOnb', name: 'Self-growth bundle' },
    { id: 'iconPickerOnb', name: 'Icon picker' },
    { id: 'themePicker', name: 'Theme picker' },
    { id: 'trialIntro', name: 'Trial intro · 3 days free' },
    { id: 'trialHow', name: 'How free trial works' },
    { id: 'addWidget', name: 'Add widget' },
    { id: 'trialStarted', name: 'Trial started' },
    { id: 'premiumWelcome', name: 'Welcome to Premium' },
  ]},
  { label: 'Home', items: [
    { id: 'home', name: 'Feed (scroll ↑↓)' },
    { id: 'home_streak', name: 'Feed · Streak banner', overlay: 'streakBanner', step: 'home' },
    { id: 'home_tip', name: 'Feed · Favorite 5 tip', overlay: 'tip5', step: 'home' },
    { id: 'home_setup', name: 'Feed · "Feed set up"', overlay: 'feedSetUp', step: 'home' },
    { id: 'home_changed', name: 'Feed · Theme changed toast', overlay: 'themeChangedToast', step: 'home' },
  ]},
  { label: 'Quote actions', items: [
    { id: 'shareSheet', name: 'Share sheet', modal: 'shareSheet', step: 'home' },
    { id: 'iosShare', name: 'iOS share sheet', modal: 'iosShare', step: 'home' },
    { id: 'addToCollection', name: 'Add to collection', modal: 'addToCollection', step: 'home' },
    { id: 'editTheme', name: 'Edit theme overlay', overlay: 'editTheme', step: 'home' },
    { id: 'spread', name: 'Spread the Motivation', overlay: 'spreadCard', step: 'home' },
  ]},
  { label: 'Browse', items: [
    { id: 'themes', name: 'Themes', modal: 'themes', step: 'home' },
    { id: 'themeMixes', name: 'Theme mixes', modal: 'themeMixes', step: 'home' },
    { id: 'explore', name: 'Explore topics', modal: 'explore', step: 'home' },
    { id: 'topicDetail', name: '· Topic detail', modal: 'topicDetail', step: 'home' },
    { id: 'authorDetail', name: '· Author detail', modal: 'authorDetail', step: 'home' },
    { id: 'topicsFollow', name: 'Topics you follow', modal: 'topicsFollow', step: 'home' },
  ]},
  { label: 'Profile', items: [
    { id: 'profile', name: 'Profile (Mirra hub)', modal: 'profile', step: 'home' },
    { id: 'favorites', name: 'My favorites', modal: 'favorites', step: 'home' },
    { id: 'collectionQuote', name: '· Collection quote view', modal: 'collectionQuote', step: 'home' },
    { id: 'collections', name: 'Collections', modal: 'collections', step: 'home' },
    { id: 'collectionDetail', name: '· Collection detail', modal: 'collectionDetail', step: 'home' },
    { id: 'ownQuotes', name: 'Your own quotes', modal: 'ownQuotes', step: 'home' },
    { id: 'addOwn', name: '· Add own quote', modal: 'addOwn', step: 'home' },
    { id: 'history', name: 'History', modal: 'history', step: 'home' },
  ]},
  { label: 'Customize', items: [
    { id: 'reminders_m', name: 'Reminders', modal: 'reminders', step: 'home' },
    { id: 'appIcon', name: 'App icon', modal: 'appIcon', step: 'home' },
    { id: 'widgets', name: 'Widgets', modal: 'widgets', step: 'home' },
    { id: 'watch', name: 'Watch', modal: 'watch', step: 'home' },
    { id: 'bundle', name: 'Self-Growth bundle', modal: 'bundle', step: 'home' },
  ]},
  { label: 'Preferences', items: [
    { id: 'preferences', name: 'Preferences hub', modal: 'preferences', step: 'home' },
    { id: 'manageSub', name: 'Manage subscription', modal: 'manageSub', step: 'home' },
    { id: 'contentPrefs', name: 'Content preferences', modal: 'contentPrefs', step: 'home' },
    { id: 'gender', name: 'Gender identity', modal: 'gender', step: 'home' },
    { id: 'muted', name: 'Muted content', modal: 'muted', step: 'home' },
    { id: 'language', name: 'Language', modal: 'language', step: 'home' },
    { id: 'name', name: 'Name', modal: 'name', step: 'home' },
    { id: 'sound', name: 'Sound', modal: 'sound', step: 'home' },
    { id: 'voice', name: 'Voice', modal: 'voice', step: 'home' },
    { id: 'siri', name: 'Add Siri Shortcuts', modal: 'siri', step: 'home' },
    { id: 'signin', name: 'Sign in', modal: 'signin', step: 'home' },
    { id: 'help', name: 'Help', modal: 'help', step: 'home' },
  ]},
  { label: 'Dialogs', items: [
    { id: 'rateDialog', name: 'Rate · Step 1', overlay: 'rateDialog', step: 'home' },
    { id: 'rateDialog2', name: 'Rate · Step 2', overlay: 'rateDialog2', step: 'home' },
  ]},
];

const NAV_INDEX = {};
NAV_GROUPS.forEach(g => g.items.forEach(it => NAV_INDEX[it.id] = it));

function Navigator({ active, onPick, count }) {
  return (
    <div style={{
      width: 260, height: '94vh', overflow: 'auto',
      background: '#fff', borderRadius: 18,
      boxShadow: '0 12px 32px -10px rgba(0,0,0,0.18)',
      padding: '18px 14px 20px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 4px 12px', borderBottom: '1px solid var(--line)', marginBottom: 12 }}>
        <MirraMark size={22}/>
        <span style={{ fontFamily: 'Instrument Serif', fontSize: 22 }}>Mirra</span>
        <span style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', marginLeft: 'auto' }}>{count} screens</span>
      </div>
      {NAV_GROUPS.map(g => (
        <div key={g.label} style={{ marginBottom: 10 }}>
          <div style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 800, letterSpacing: '0.12em', textTransform: 'uppercase', padding: '6px 6px' }}>{g.label}</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {g.items.map(it => (
              <button key={it.id} onClick={() => onPick(it.id)} className="no-tap" style={{
                textAlign: 'left', padding: '6px 10px', borderRadius: 7, fontSize: 12,
                background: active === it.id ? 'var(--chip)' : 'transparent',
                color: active === it.id ? 'var(--ink)' : 'var(--ink-2)',
                fontWeight: active === it.id ? 600 : 500,
              }}>{it.name}</button>
            ))}
          </div>
        </div>
      ))}
      <div style={{ padding: '8px 6px 0', borderTop: '1px solid var(--line)', marginTop: 6 }}>
        <div style={{ fontSize: 11, color: 'var(--muted)', lineHeight: 1.4 }}>
          Tip: scroll the iPhone screen vertically to browse the affirmation feed.
        </div>
      </div>
    </div>
  );
}

function Root() {
  const [active, setActive] = useState('welcome');
  const [jumpKey, setJumpKey] = useState(0);
  const [scale, setScale] = useState(1);

  const pick = (id) => { setActive(id); setJumpKey(k => k + 1); };

  useEffect(() => {
    const compute = () => {
      const h = window.innerHeight, w = window.innerWidth;
      const fitH = Math.min(1, (h - 40) / 874);
      const fitW = Math.min(1, (w - 360) / 402);
      setScale(Math.max(0.55, Math.min(fitH, fitW, 1)));
    };
    compute();
    window.addEventListener('resize', compute);
    return () => window.removeEventListener('resize', compute);
  }, []);

  const it = NAV_INDEX[active] || { id: 'welcome' };
  const jumpTo = { _key: jumpKey, step: it.step || it.id, modal: it.modal, overlay: it.overlay, onbStep: it.kind === 'onb' ? it.onbStep : undefined };
  const totalCount = NAV_GROUPS.reduce((s, g) => s + g.items.length, 0);

  return (
    <div style={{
      position: 'fixed', inset: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 30,
      padding: '20px',
      background: 'radial-gradient(circle at 30% 20%, #F4EFE3 0%, #E9E4DA 60%, #DDD7C8 100%)',
      overflow: 'hidden',
    }}>
      <Navigator active={active} onPick={pick} count={totalCount}/>
      <div style={{ flexShrink: 0, transform: `scale(${scale})`, transformOrigin: 'center center' }}>
        <IOSDevice width={402} height={874}>
          <MirraApp key={jumpKey} jumpTo={jumpTo}/>
        </IOSDevice>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<Root/>);
