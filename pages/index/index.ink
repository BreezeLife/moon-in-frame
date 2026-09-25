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
    showSecond: false, showGreeting: false, moonClass: 'moonlight', poemClass: ''
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
    this.setData(Object.assign({ language, title: content.title, startLabel: content.start }, poemFields(content)));
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
    if (phase === 'closing') this._poemFadeTimer = setTimeout(() => this.setData({ showPoem: false }), 900);
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
      <view class="pixel-stars stars-a"></view>
      <view class="pixel-stars stars-b"></view>
      <view class="pixel-mountain mountain-back"></view>
      <view class="pixel-mountain mountain-front"></view>
      <view class="water water-one"></view>
      <view class="water water-two"></view>
      <view class="water water-three"></view>
      <view class="{{moonClass}}"></view>
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

    <view class="closing" ink:if="{{showGreeting}}">
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
  overflow: hidden;
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
  left: 0;
  width: 190px;
  height: 352px;
  background-color: #000000;
  z-index: 5;
}

.landscape {
  position: absolute;
  top: 0;
  left: 0;
  width: 190px;
  height: 352px;
  overflow: hidden;
  image-rendering: pixelated;
}
.moon-progress { position: absolute; top: 164px; left: 9px; width: 172px; height: 29px; display: block; }
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
  width: 3px;
  height: 3px;
  background-color: rgba(89, 255, 120, 0.75);
  box-shadow: 18px 22px rgba(89,255,120,.42), 48px 44px rgba(89,255,120,.52), 82px 13px rgba(89,255,120,.34), 119px 55px rgba(89,255,120,.45), 153px 28px rgba(89,255,120,.3), 177px 72px rgba(89,255,120,.4);
  animation: pixel-twinkle 3.8s steps(2, end) infinite;
}
.stars-a { top: 19px; left: 7px; }
.stars-b { top: 63px; left: 25px; opacity: .55; transform: scale(.66); }
.pixel-mountain {
  position: absolute;
  height: 3px;
  background-color: rgba(89,255,120,.28);
  box-shadow: 8px -5px rgba(89,255,120,.28), 16px -10px rgba(89,255,120,.28), 24px -15px rgba(89,255,120,.28), 32px -10px rgba(89,255,120,.28), 40px -5px rgba(89,255,120,.28), 48px 0 rgba(89,255,120,.28), 56px -7px rgba(89,255,120,.28), 64px -14px rgba(89,255,120,.28), 72px -7px rgba(89,255,120,.28), 80px 0 rgba(89,255,120,.28);
}
.mountain-back { left: 7px; top: 101px; width: 88px; opacity: .5; }
.mountain-front { right: 4px; top: 112px; width: 98px; opacity: .75; transform: scale(.82); }
.water {
  position: absolute;
  height: 1px;
  background-color: rgba(89, 255, 120, 0.19);
}
.water-one { top: 120px; left: 62px; width: 68px; }
.water-two { top: 128px; left: 78px; width: 36px; }
.water-three { top: 136px; left: 84px; width: 26px; }
.water-one, .water-two, .water-three { box-shadow: 6px 3px rgba(89,255,120,.18), 15px -2px rgba(89,255,120,.22), 29px 4px rgba(89,255,120,.16); }
.moonlight {
  position: absolute;
  top: 21px;
  left: 94px;
  width: 3px;
  height: 77px;
  background-color: rgba(89, 255, 120, 0.68);
  box-shadow: 5px 8px rgba(89,255,120,.55), -5px 18px rgba(89,255,120,.42), 6px 33px rgba(89,255,120,.5), -4px 49px rgba(89,255,120,.38);
}
.moonlight-rise { animation: light-rise 5s ease-out both; }
.moonlight-glow { box-shadow: 0 0 8px rgba(89, 255, 120, 0.45); }

.poem {
  position: absolute;
  top: 151px;
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

@keyframes light-rise {
  from { opacity: 0; height: 15px; }
  to { opacity: 1; height: 77px; }
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
