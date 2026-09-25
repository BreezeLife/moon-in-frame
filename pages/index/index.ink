<script def>
{
  "description": "A transparent, trilingual Mid-Autumn poem performance for Rokid Glasses.",
  "schema": { "data": { "type": "object", "properties": {} } }
}
</script>

<script setup>
const CONTENT = {
  zh: {
    title: '月入镜', first: ['海上生明月'], second: ['天涯共此时'], greeting: ['中秋快乐'],
    start: '开始'
  },
  ja: {
    title: '月を映す', first: ['海に月が昇る'], second: ['離れていても、', '同じ月を'],
    greeting: ['よいお月見を'], start: '始める'
  },
  ko: {
    title: '달을 담다', first: ['바다 위로 달이', '떠오르고'], second: ['멀리 있어도', '같은 달 아래'],
    greeting: ['즐거운 한가위', '보내세요'], start: '시작'
  }
};

const PHASE_LENGTH = { countdown: 3000, first: 5000, second: 5000, closing: 2000 };

function poemFields(content) {
  const fields = {};
  ['first', 'second', 'greeting'].forEach((group) => {
    const lines = content[group] || [];
    for (let row = 0; row < 2; row += 1) {
      const chars = Array.from(lines[row] || '');
      for (let index = 0; index < 8; index += 1) {
        fields[group + (row + 1) + '_' + (index + 1)] = chars[index] || '';
      }
    }
  });
  return fields;
}

export default {
  data: Object.assign({
    language: 'zh', title: CONTENT.zh.title,
    startLabel: CONTENT.zh.start, phase: 'home', countdown: '3',
    showHome: true, showCountdown: false, showScene: false, showFirst: false, showPoem: false,
    showSecond: false, showGreeting: false, moonClass: 'moonlight', poemClass: '',
    zhClass: 'language-selected', jaClass: '', koClass: '', greetingClass: 'greeting-zh'
  }, poemFields(CONTENT.zh)),

  onLoad() {
    this._phaseTimer = null;
    this._tapTimer = null;
    this._phaseStartedAt = 0;
  },

  onUnload() {
    this.clearTimers();
  },

  clearTimers() {
    if (this._phaseTimer) clearTimeout(this._phaseTimer);
    if (this._tapTimer) clearTimeout(this._tapTimer);
    if (this._poemFadeTimer) clearTimeout(this._poemFadeTimer);
    this._phaseTimer = null;
    this._tapTimer = null;
  },

  selectZh() { this.setLanguage('zh'); },
  selectJa() { this.setLanguage('ja'); },
  selectKo() { this.setLanguage('ko'); },

  setLanguage(language) {
    if (this.data.phase !== 'home') return;
    const content = CONTENT[language];
    this.setData(Object.assign({
      language, title: content.title, startLabel: content.start,
      zhClass: language === 'zh' ? 'language-selected' : '',
      jaClass: language === 'ja' ? 'language-selected' : '',
      koClass: language === 'ko' ? 'language-selected' : '',
      greetingClass: 'greeting-' + language
    }, poemFields(content)));
  },

  cycleLanguage(step) {
    if (this.data.phase !== 'home') return;
    const languages = ['zh', 'ja', 'ko'];
    const current = languages.indexOf(this.data.language);
    this.setLanguage(languages[(current + step + languages.length) % languages.length]);
  },

  startExperience() {
    if (this.data.phase !== 'home') return;
    this.enterPhase('countdown');
  },

  handleTap() {
    if (this._tapTimer) {
      clearTimeout(this._tapTimer);
      this._tapTimer = null;
      this.goHome();
      return;
    }
    this._tapTimer = setTimeout(() => {
      this._tapTimer = null;
      if (this.data.phase === 'home') this.startExperience();
      else this.nextPhase();
    }, 280);
  },

  onKeyUp(event) {
    if (event && event.code === 'ArrowUp') {
      if (typeof event.preventDefault === 'function') event.preventDefault();
      this.cycleLanguage(-1);
      return;
    }
    if (event && event.code === 'ArrowDown') {
      if (typeof event.preventDefault === 'function') event.preventDefault();
      this.cycleLanguage(1);
      return;
    }
    if (event && event.code === 'Enter') {
      if (typeof event.preventDefault === 'function') event.preventDefault();
      this.handleTap();
    }
  },

  goHome() {
    this.clearTimers();
    this.setData({
      phase: 'home', countdown: '3', showHome: true,
      showCountdown: false, showScene: false, showFirst: false, showPoem: false, showSecond: false,
      showGreeting: false, moonClass: 'moonlight', poemClass: ''
    });
  },

  nextPhase() {
    const next = {
      countdown: 'first', first: 'second', second: 'closing',
      closing: 'finished', finished: 'home'
    }[this.data.phase];
    if (next === 'home') this.goHome();
    else if (next) this.enterPhase(next);
  },

  enterPhase(phase) {
    if (this._phaseTimer) clearTimeout(this._phaseTimer);
    this._phaseTimer = null;
    this._phaseStartedAt = Date.now();
    this.setData({
      phase,
      countdown: '3',
      showHome: false,
      showCountdown: phase === 'countdown',
      showScene: phase !== 'countdown' && phase !== 'home',
      showFirst: phase !== 'home',
      showPoem: phase === 'first' || phase === 'second' || phase === 'closing',
      showSecond: phase === 'second',
      showGreeting: phase === 'closing' || phase === 'finished',
      moonClass: 'moonlight moonlight-rise', poemClass: phase === 'closing' ? 'poem-fade' : ''
    });
    if (phase === 'closing') this.setData({ showPoem: false });
    if (phase === 'countdown') this.tickCountdown();
    else if (PHASE_LENGTH[phase]) {
      this._phaseTimer = setTimeout(() => this.nextPhase(), PHASE_LENGTH[phase]);
    }
  },

  tickCountdown() {
    const elapsed = Date.now() - this._phaseStartedAt;
    const remaining = 3 - Math.floor(elapsed / 1000);
    if (remaining <= 0) {
      this.enterPhase('first');
      return;
    }
    this.setData({ countdown: String(remaining) });
    this._phaseTimer = setTimeout(() => this.tickCountdown(),
      Math.max(20, 1000 - (elapsed % 1000)));
  }
};
</script>

<page class="stage" bindtap="handleTap">
  <view class="composition">
    <view class="home" ink:if="{{showHome}}">
      <text class="title">{{title}}</text>
      <view class="language-row">
        <button class="language {{zhClass}}" catchtap="selectZh">中文</button>
        <button class="language {{jaClass}}" catchtap="selectJa">日本語</button>
        <button class="language {{koClass}}" catchtap="selectKo">한국어</button>
      </view>
      <button class="start" catchtap="startExperience">{{startLabel}}</button>
    </view>

    <view class="countdown-screen" ink:if="{{showCountdown}}">
      <view class="moon-progress">
        <view class="orb orb-one"></view><view class="orb orb-two"></view>
        <view class="orb orb-three"></view><view class="orb orb-four"></view><view class="orb orb-five"></view>
      </view>
    </view>

    <view class="landscape" ink:if="{{showScene}}">
      <view class="pixel-stars stars-far"></view>
      <view class="pixel-stars stars-a"></view>
      <view class="pixel-stars stars-b"></view>
      <view class="pixel-stars stars-c"></view>
      <view class="meteor meteor-a"></view>
      <view class="meteor meteor-b"></view>
      <view class="meteor meteor-c"></view>
      <view class="ridge ridge-far"></view>
      <view class="ridge ridge-left"></view>
      <view class="ridge ridge-right"></view>
      <view class="shore shore-left"></view>
      <view class="shore shore-right"></view>
      <view class="water water-a"></view>
      <view class="water water-b"></view>
      <view class="water water-c"></view>
      <view class="water water-d"></view>
      <view class="water water-e"></view>
      <view class="water water-f"></view>
      <view class="water water-g"></view>
      <view class="water water-h"></view>
      <view class="reflection reflection-a"></view>
      <view class="reflection reflection-b"></view>
      <view class="reflection reflection-c"></view>
    </view>

    <view class="poem {{poemClass}}" ink:if="{{showPoem}}">
      <view class="poem-column first-column">
        <text class="char char-1" ink:if="{{first1_1}}">{{first1_1}}</text>
        <text class="char char-2" ink:if="{{first1_2}}">{{first1_2}}</text>
        <text class="char char-3" ink:if="{{first1_3}}">{{first1_3}}</text>
        <text class="char char-4" ink:if="{{first1_4}}">{{first1_4}}</text>
        <text class="char char-5" ink:if="{{first1_5}}">{{first1_5}}</text>
        <text class="char char-6" ink:if="{{first1_6}}">{{first1_6}}</text>
        <text class="char char-7" ink:if="{{first1_7}}">{{first1_7}}</text>
        <text class="char char-8" ink:if="{{first1_8}}">{{first1_8}}</text>
      </view>
      <view class="poem-column first-wrap">
        <text class="char char-1" ink:if="{{first2_1}}">{{first2_1}}</text>
        <text class="char char-2" ink:if="{{first2_2}}">{{first2_2}}</text>
        <text class="char char-3" ink:if="{{first2_3}}">{{first2_3}}</text>
        <text class="char char-4" ink:if="{{first2_4}}">{{first2_4}}</text>
        <text class="char char-5" ink:if="{{first2_5}}">{{first2_5}}</text>
        <text class="char char-6" ink:if="{{first2_6}}">{{first2_6}}</text>
        <text class="char char-7" ink:if="{{first2_7}}">{{first2_7}}</text>
        <text class="char char-8" ink:if="{{first2_8}}">{{first2_8}}</text>
      </view>
      <view class="second-group" ink:if="{{showSecond}}">
      <view class="poem-column second-column">
        <text class="char char-1" ink:if="{{second1_1}}">{{second1_1}}</text>
        <text class="char char-2" ink:if="{{second1_2}}">{{second1_2}}</text>
        <text class="char char-3" ink:if="{{second1_3}}">{{second1_3}}</text>
        <text class="char char-4" ink:if="{{second1_4}}">{{second1_4}}</text>
        <text class="char char-5" ink:if="{{second1_5}}">{{second1_5}}</text>
        <text class="char char-6" ink:if="{{second1_6}}">{{second1_6}}</text>
        <text class="char char-7" ink:if="{{second1_7}}">{{second1_7}}</text>
        <text class="char char-8" ink:if="{{second1_8}}">{{second1_8}}</text>
      </view>
      <view class="poem-column second-wrap">
        <text class="char char-1" ink:if="{{second2_1}}">{{second2_1}}</text>
        <text class="char char-2" ink:if="{{second2_2}}">{{second2_2}}</text>
        <text class="char char-3" ink:if="{{second2_3}}">{{second2_3}}</text>
        <text class="char char-4" ink:if="{{second2_4}}">{{second2_4}}</text>
        <text class="char char-5" ink:if="{{second2_5}}">{{second2_5}}</text>
        <text class="char char-6" ink:if="{{second2_6}}">{{second2_6}}</text>
        <text class="char char-7" ink:if="{{second2_7}}">{{second2_7}}</text>
        <text class="char char-8" ink:if="{{second2_8}}">{{second2_8}}</text>
      </view>
      </view>
    </view>

    <view class="closing {{greetingClass}}" ink:if="{{showGreeting}}">
      <view class="poem-column greeting-column">
        <text class="greeting-char" ink:if="{{greeting1_1}}">{{greeting1_1}}</text>
        <text class="greeting-char" ink:if="{{greeting1_2}}">{{greeting1_2}}</text>
        <text class="greeting-char" ink:if="{{greeting1_3}}">{{greeting1_3}}</text>
        <text class="greeting-char" ink:if="{{greeting1_4}}">{{greeting1_4}}</text>
        <text class="greeting-char" ink:if="{{greeting1_5}}">{{greeting1_5}}</text>
        <text class="greeting-char" ink:if="{{greeting1_6}}">{{greeting1_6}}</text>
        <text class="greeting-char" ink:if="{{greeting1_7}}">{{greeting1_7}}</text>
        <text class="greeting-char" ink:if="{{greeting1_8}}">{{greeting1_8}}</text>
      </view>
      <view class="poem-column greeting-wrap">
        <text class="greeting-char" ink:if="{{greeting2_1}}">{{greeting2_1}}</text>
        <text class="greeting-char" ink:if="{{greeting2_2}}">{{greeting2_2}}</text>
        <text class="char char-3" ink:if="{{greeting2_3}}">{{greeting2_3}}</text>
        <text class="char char-4" ink:if="{{greeting2_4}}">{{greeting2_4}}</text>
        <text class="char char-5" ink:if="{{greeting2_5}}">{{greeting2_5}}</text>
        <text class="char char-6" ink:if="{{greeting2_6}}">{{greeting2_6}}</text>
        <text class="char char-7" ink:if="{{greeting2_7}}">{{greeting2_7}}</text>
        <text class="char char-8" ink:if="{{greeting2_8}}">{{greeting2_8}}</text>
      </view>
    </view>
  </view>
</page>

<style>
.stage {
  width: 100%;
  height: 100%;
  background-color: transparent;
  color: #59ff78;
}

.composition {
  position: relative;
  width: 190px;
  height: 100%;
  margin: 0 auto;
  overflow: visible;
  text-align: center;
}

.home {
  position: absolute;
  top: 66px;
  left: 0;
  width: 190px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.title { font-size: 25px; line-height: 34px; font-family: 'STXingkai', 'Xingkai SC', 'FZKai-Z03', 'Kaiti SC', serif; }

.language-row {
  display: flex;
  flex-direction: column;
  width: 190px;
  align-items: center;
  margin-top: 34px;
  gap: 8px;
}

button {
  color: #59ff78;
  background-color: transparent;
  border: 1px solid #59ff78;
  border-radius: 4px;
  padding: 4px;
  font-size: 12px;
}

.language { width: 150px; height: 38px; font-size: 15px; }
.language-selected { color: #07140a; background-color: #59ff78; box-shadow: 0 0 0 2px rgba(89,255,120,.35); }
.start { width: 110px; height: 36px; margin-top: 28px; font-size: 14px; }

.countdown-screen {
  position: absolute;
  top: 0;
  left: -145px;
  width: 480px;
  height: 352px;
  background-color: #000000;
  z-index: 5;
}

.landscape {
  position: absolute;
  top: 0;
  left: -145px;
  width: 480px;
  height: 352px;
  overflow: hidden;
  opacity: 0;
  animation: scene-in 1000ms steps(5, end) forwards;
}
.moon-progress { position: absolute; top: 164px; left: 154px; width: 172px; height: 29px; display: block; }
.orb { position: absolute; top: 0; width: 25px; height: 25px; border: 2px solid rgba(89,255,120,.76); border-radius: 50%; image-rendering: pixelated; opacity: .12; animation: orb-fill 3s steps(4, end) forwards; }
.orb-one { left: 0; }
.orb-two { left: 36px; }
.orb-three { left: 72px; }
.orb-four { left: 108px; }
.orb-five { left: 144px; }
.orb-two { animation-delay: .45s; }
.orb-three { animation-delay: .9s; }
.orb-four { animation-delay: 1.35s; }
.orb-five { animation-delay: 1.8s; }
.orb-one { background: rgba(89,255,120,.08); }
.orb-two { background: linear-gradient(90deg, rgba(89,255,120,.35) 50%, transparent 50%); }
.orb-three { background: linear-gradient(90deg, rgba(89,255,120,.6) 72%, transparent 72%); }
.orb-four { background: rgba(89,255,120,.82); }
.pixel-stars {
  position: absolute;
  width: 2px;
  height: 2px;
  background-color: rgba(89,255,120,.62);
  box-shadow: 19px 28px rgba(89,255,120,.38), 47px 69px rgba(89,255,120,.35), 84px 14px rgba(89,255,120,.46), 116px 91px rgba(89,255,120,.28), 152px 39px rgba(89,255,120,.48), 179px 72px rgba(89,255,120,.36), 218px 25px rgba(89,255,120,.55), 251px 87px rgba(89,255,120,.38), 283px 12px rgba(89,255,120,.32), 319px 59px rgba(89,255,120,.44), 352px 32px rgba(89,255,120,.3), 387px 98px rgba(89,255,120,.4), 423px 43px rgba(89,255,120,.54), 450px 74px rgba(89,255,120,.3);
  animation: pixel-twinkle 4s steps(3, end) infinite;
}
.stars-far { top: 16px; left: 10px; opacity: .38; animation-delay: 1.7s; }
.stars-a { top: 45px; left: 15px; }
.stars-b { top: 111px; left: 33px; opacity: .52; animation-delay: .9s; }
.stars-c { top: 178px; left: 6px; opacity: .4; animation-delay: 2.2s; }
.meteor {
  position: absolute;
  width: 5px;
  height: 5px;
  background-color: rgba(89,255,120,.85);
  box-shadow: 5px -5px rgba(89,255,120,.62), 10px -10px rgba(89,255,120,.42), 15px -15px rgba(89,255,120,.22);
  opacity: 0;
  animation: meteor-fall 5.2s steps(7, end) infinite;
}
.meteor-a { top: 49px; left: 99px; }
.meteor-b { top: 116px; left: 367px; animation-delay: 1.8s; }
.meteor-c { top: 90px; left: 257px; animation-delay: 3.5s; }
.ridge { position: absolute; height: 6px; background-color: rgba(89,255,120,.27); }
.ridge-far { top: 276px; left: 94px; width: 64px; box-shadow: 8px -6px rgba(89,255,120,.22), 16px -12px rgba(89,255,120,.22), 24px -12px rgba(89,255,120,.22), 32px -6px rgba(89,255,120,.22), 88px 0 rgba(89,255,120,.22), 96px -6px rgba(89,255,120,.22), 104px -12px rgba(89,255,120,.22), 112px -6px rgba(89,255,120,.22); }
.ridge-left { top: 285px; left: 0; width: 76px; box-shadow: 16px -6px rgba(89,255,120,.32), 32px -12px rgba(89,255,120,.32), 48px -18px rgba(89,255,120,.32), 64px -24px rgba(89,255,120,.32), 80px -18px rgba(89,255,120,.32), 96px -12px rgba(89,255,120,.32), 112px -6px rgba(89,255,120,.32); }
.ridge-right { top: 285px; right: 0; width: 76px; box-shadow: -16px -6px rgba(89,255,120,.32), -32px -12px rgba(89,255,120,.32), -48px -18px rgba(89,255,120,.32), -64px -12px rgba(89,255,120,.32), -80px -6px rgba(89,255,120,.32); }
.shore { position: absolute; top: 292px; height: 3px; background-color: rgba(89,255,120,.2); }
.shore-left { left: 0; width: 145px; }
.shore-right { right: 0; width: 128px; }
.water { position: absolute; height: 3px; background-color: rgba(89,255,120,.27); }
.water-a { top: 296px; left: 187px; width: 74px; }
.water-b { top: 304px; left: 155px; width: 40px; }
.water-c { top: 310px; left: 219px; width: 92px; }
.water-d { top: 319px; left: 72px; width: 84px; }
.water-e { top: 324px; left: 331px; width: 64px; }
.water-f { top: 333px; left: 179px; width: 112px; }
.water-g { top: 342px; left: 31px; width: 48px; }
.water-h { top: 346px; left: 384px; width: 70px; }
.reflection { position: absolute; height: 3px; background-color: rgba(89,255,120,.47); }
.reflection-a { top: 301px; left: 226px; width: 28px; }
.reflection-b { top: 316px; left: 213px; width: 53px; }
.reflection-c { top: 337px; left: 235px; width: 21px; }
.poem {
  position: absolute;
  top: 102px;
  left: 0;
  width: 190px;
  display: flex;
  flex-direction: row-reverse;
  justify-content: center;
  align-items: flex-start;
}
.poem-fade { animation: poem-out 850ms ease-out forwards; }
.second-group {
  display: flex;
  flex-direction: row-reverse;
  margin-right: 9px;
}
.poem-column {
  width: 35px;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.first-wrap, .second-wrap, .greeting-wrap { margin-right: 2px; }
.char {
  display: block;
  width: 35px;
  height: 22px;
  line-height: 22px;
  text-align: center;
  font-size: 22px;
  font-family: 'STXingkai', 'Xingkai SC', 'FZKai-Z03', 'Kaiti SC', 'STKaiti', serif;
  animation: character-in 250ms ease-out both;
}
.char-1 { animation-delay: 0ms; }
.char-2 { animation-delay: 300ms; }
.char-3 { animation-delay: 600ms; }
.char-4 { animation-delay: 900ms; }
.char-5 { animation-delay: 1200ms; }
.char-6 { animation-delay: 1500ms; }
.char-7 { animation-delay: 1800ms; }
.char-8 { animation-delay: 2100ms; }
.first-wrap .char-1, .second-wrap .char-1 { animation-delay: 2400ms; }
.first-wrap .char-2, .second-wrap .char-2 { animation-delay: 2700ms; }
.first-wrap .char-3, .second-wrap .char-3 { animation-delay: 3000ms; }
.first-wrap .char-4, .second-wrap .char-4 { animation-delay: 3300ms; }
.first-wrap .char-5, .second-wrap .char-5 { animation-delay: 3600ms; }
.first-wrap .char-6, .second-wrap .char-6 { animation-delay: 3900ms; }
.first-wrap .char-7, .second-wrap .char-7 { animation-delay: 4200ms; }
.first-wrap .char-8, .second-wrap .char-8 { animation-delay: 4500ms; }

.closing {
  position: absolute;
  top: 182px;
  left: 0;
  width: 190px;
  display: flex;
  flex-direction: row;
  justify-content: center;
  opacity: 0;
  animation: greeting-in 900ms ease-out 650ms forwards;
}
.closing .poem-column { width: auto; flex-direction: row; }
.greeting-char { width: 30px; font-size: 22px; font-family: 'STXingkai', 'Xingkai SC', 'FZKai-Z03', serif; }
.closing .greeting-char { font-size: 28px; width: 36px; }
.greeting-ja .greeting-char, .greeting-ko .greeting-char { font-size: 22px; width: 25px; }
.greeting-ko { flex-direction: column; align-items: center; }
.closing .char { font-size: 21px; }
.closing .char { animation-duration: 280ms; }
.closing .char-1 { animation-delay: 0ms; }
.closing .char-2 { animation-delay: 180ms; }
.closing .char-3 { animation-delay: 360ms; }
.closing .char-4 { animation-delay: 540ms; }
.closing .char-5 { animation-delay: 720ms; }
.closing .char-6 { animation-delay: 900ms; }
.closing .char-7 { animation-delay: 1080ms; }
.closing .char-8 { animation-delay: 1260ms; }
.closing .greeting-wrap .char-1 { animation-delay: 540ms; }
.closing .greeting-wrap .char-2 { animation-delay: 720ms; }
.closing .greeting-wrap .char-3 { animation-delay: 900ms; }
.closing .greeting-wrap .char-4 { animation-delay: 1080ms; }
.closing .greeting-wrap .char-5 { animation-delay: 1260ms; }

@keyframes meteor-fall {
  0%, 61%, 100% { opacity: 0; transform: translate(0, 0); }
  67% { opacity: .85; }
  82% { opacity: 0; transform: translate(-24px, 24px); }
}
@keyframes scene-in {
  from { opacity: 0; }
  to { opacity: 1; }
}
@keyframes character-in {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; }
}
@keyframes greeting-in {
  from { opacity: 0; transform: translateY(7px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes poem-out {
  from { opacity: 1; }
  to { opacity: 0; }
}
@keyframes orb-fill {
  from { opacity: .18; }
  to { opacity: 1; }
}
@keyframes pixel-twinkle {
  0%, 100% { opacity: .42; }
  48% { opacity: .9; }
  52% { opacity: .55; }
}
</style>
