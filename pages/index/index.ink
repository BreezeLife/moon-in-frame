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
    showHome: true, showCountdown: false, showFirst: false,
    showSecond: false, showGreeting: false, moonClass: 'moonlight'
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
    if (event && event.code === 'Enter') {
      if (typeof event.preventDefault === 'function') event.preventDefault();
      this.handleTap();
    }
  },

  goHome() {
    this.clearTimers();
    this.setData({
      phase: 'home', countdown: '3', showHome: true,
      showCountdown: false, showFirst: false, showSecond: false,
      showGreeting: false, moonClass: 'moonlight'
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
      showFirst: phase === 'first' || phase === 'second',
      showSecond: phase === 'second',
      showGreeting: phase === 'closing' || phase === 'finished',
      moonClass: phase === 'second' ? 'moonlight moonlight-glow' : 'moonlight moonlight-rise'
    });
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
        <button class="language" catchtap="selectZh">中文</button>
        <button class="language" catchtap="selectJa">日本語</button>
        <button class="language" catchtap="selectKo">한국어</button>
      </view>
      <button class="start" catchtap="startExperience">{{startLabel}}</button>
    </view>

    <text class="countdown" ink:if="{{showCountdown}}">{{countdown}}</text>

    <view class="landscape" ink:if="{{showFirst}}">
      <view class="horizon horizon-back"></view>
      <view class="horizon horizon-front"></view>
      <view class="water water-one"></view>
      <view class="water water-two"></view>
      <view class="water water-three"></view>
      <view class="{{moonClass}}"></view>
    </view>

    <view class="poem" ink:if="{{showFirst}}">
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
        <text class="char char-1" ink:if="{{greeting1_1}}">{{greeting1_1}}</text>
        <text class="char char-2" ink:if="{{greeting1_2}}">{{greeting1_2}}</text>
        <text class="char char-3" ink:if="{{greeting1_3}}">{{greeting1_3}}</text>
        <text class="char char-4" ink:if="{{greeting1_4}}">{{greeting1_4}}</text>
        <text class="char char-5" ink:if="{{greeting1_5}}">{{greeting1_5}}</text>
        <text class="char char-6" ink:if="{{greeting1_6}}">{{greeting1_6}}</text>
        <text class="char char-7" ink:if="{{greeting1_7}}">{{greeting1_7}}</text>
        <text class="char char-8" ink:if="{{greeting1_8}}">{{greeting1_8}}</text>
      </view>
      <view class="poem-column greeting-wrap">
        <text class="char char-1" ink:if="{{greeting2_1}}">{{greeting2_1}}</text>
        <text class="char char-2" ink:if="{{greeting2_2}}">{{greeting2_2}}</text>
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

.title { font-size: 25px; line-height: 34px; }

.language-row {
  display: flex;
  width: 190px;
  justify-content: space-between;
  margin-top: 42px;
}

button {
  color: #59ff78;
  background-color: transparent;
  border: 1px solid #59ff78;
  border-radius: 4px;
  padding: 4px;
  font-size: 12px;
}

.language { width: 60px; height: 30px; }
.start { width: 92px; height: 34px; margin-top: 36px; }

.countdown {
  position: absolute;
  top: 145px;
  left: 0;
  width: 190px;
  font-size: 36px;
  line-height: 52px;
}

.landscape {
  position: absolute;
  top: 0;
  left: 0;
  width: 190px;
  height: 352px;
  overflow: hidden;
}
.horizon {
  position: absolute;
  width: 130px;
  height: 1px;
  background-color: rgba(89, 255, 120, 0.28);
  transform: rotate(-8deg);
}
.horizon-back { top: 102px; left: -13px; }
.horizon-front { top: 109px; right: -22px; transform: rotate(6deg); }
.water {
  position: absolute;
  height: 1px;
  background-color: rgba(89, 255, 120, 0.19);
}
.water-one { top: 120px; left: 62px; width: 68px; }
.water-two { top: 128px; left: 78px; width: 36px; }
.water-three { top: 136px; left: 84px; width: 26px; }
.moonlight {
  position: absolute;
  top: 21px;
  left: 94px;
  width: 1px;
  height: 77px;
  background-color: rgba(89, 255, 120, 0.68);
  transform: rotate(12deg);
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
  font-size: 18px;
  font-family: 'Kaiti SC', 'STKaiti', 'KaiTi', 'Songti SC', serif;
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
  top: 151px;
  left: 0;
  width: 190px;
  display: flex;
  flex-direction: row-reverse;
  justify-content: center;
}
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
</style>
