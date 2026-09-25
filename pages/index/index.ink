<script def>
{
  "description": "A transparent, trilingual Mid-Autumn poem performance for Rokid Glasses.",
  "schema": { "data": { "type": "object", "properties": {} } }
}
</script>

<script setup>
const CONTENT = {
  zh: {
    title: '月入镜', firstA: '海上生明月', firstB: '',
    secondA: '天涯共此时', secondB: '', greetingA: '中秋快乐', greetingB: '',
    start: '开始'
  },
  ja: {
    title: '月を映す', firstA: '海に月が昇る', firstB: '',
    secondA: '離れていても、', secondB: '同じ月を',
    greetingA: 'よいお月見を', greetingB: '', start: '始める'
  },
  ko: {
    title: '달을 담다', firstA: '바다 위로 달이', firstB: '떠오르고',
    secondA: '멀리 있어도', secondB: '같은 달 아래',
    greetingA: '즐거운 한가위', greetingB: '보내세요', start: '시작'
  }
};

const PHASE_LENGTH = { countdown: 3000, first: 5000, second: 5000, closing: 2000 };

export default {
  data: {
    language: 'zh', title: CONTENT.zh.title,
    firstA: CONTENT.zh.firstA, firstB: '', secondA: CONTENT.zh.secondA,
    secondB: '', greetingA: CONTENT.zh.greetingA, greetingB: '',
    startLabel: CONTENT.zh.start, phase: 'home', countdown: '3',
    showHome: true, showCountdown: false, showFirst: false,
    showSecond: false, showGreeting: false, moonClass: 'moon moon-low'
  },

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
    this.setData({
      language, title: content.title, firstA: content.firstA,
      firstB: content.firstB, secondA: content.secondA,
      secondB: content.secondB, greetingA: content.greetingA,
      greetingB: content.greetingB, startLabel: content.start
    });
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
      showGreeting: false, moonClass: 'moon moon-low'
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
      moonClass: phase === 'second' ? 'moon moon-glow' : 'moon moon-raised'
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

    <view class="performance" ink:if="{{showFirst}}">
      <view class="{{moonClass}}"></view>
      <view class="poem">
        <view class="poem-line">
          <text>{{firstA}}</text>
          <text ink:if="{{firstB}}">{{firstB}}</text>
        </view>
        <view class="poem-line second-line" ink:if="{{showSecond}}">
          <text>{{secondA}}</text>
          <text ink:if="{{secondB}}">{{secondB}}</text>
        </view>
      </view>
    </view>

    <view class="closing" ink:if="{{showGreeting}}">
      <text>{{greetingA}}</text>
      <text ink:if="{{greetingB}}">{{greetingB}}</text>
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

.performance { position: relative; width: 190px; height: 100%; }
.moon {
  position: absolute;
  left: 47px;
  top: 18px;
  width: 94px;
  height: 94px;
  border: 1px solid #59ff78;
  border-radius: 50%;
  background-color: transparent;
}
.moon-raised { animation: moon-rise 5s ease-out both; }
.moon-glow { box-shadow: 0 0 9px rgba(89, 255, 120, 0.22); }

.poem {
  position: absolute;
  top: 150px;
  left: 0;
  width: 190px;
}
.poem-line {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-height: 48px;
  font-size: 17px;
  line-height: 25px;
  white-space: nowrap;
  animation: line-in 900ms ease-out both;
}
.second-line { margin-top: 20px; }

.closing {
  position: absolute;
  top: 151px;
  left: 0;
  width: 190px;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 19px;
  line-height: 28px;
  white-space: nowrap;
  animation: line-in 700ms ease-out both;
}

@keyframes moon-rise {
  from { transform: translateY(18px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
@keyframes line-in {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
