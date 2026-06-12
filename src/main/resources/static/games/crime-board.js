class CrimeBoardScene extends Phaser.Scene {
  constructor() {
    super('CrimeBoardScene');
    this.nodes = []; this.links = []; this.selected = null;
    this.requiredLinks = 0; this.completedLinks = 0;
    this.timeLeft = 75; this.timerEvent = null; this.gameEnded = false; this.hintUsed = false;
  }
  init(data = {}) {
    this.boardData = data.boardData || this.makeDemoBoard();
    this.timeLeft = data.maxTime || 75;
    this.nodes = []; this.links = []; this.selected = null;
    this.requiredLinks = 0; this.completedLinks = 0; this.timerEvent = null; this.gameEnded = false; this.hintUsed = false;
  }
  create() {
    this.normalizeBoardData();
    this.requiredLinks = this.links.filter(l => l.required).length;
    this.cameras.main.setBackgroundColor('#0f1117');
    this.createBackground(); this.createHud(); this.createBoard(); this.startTimer(); this.updateHud();
  }
  normalizeBoardData() {
    this.nodes = (this.boardData.nodes || []).map(n => ({ ...n }));
    this.links = (this.boardData.links || []).map(l => ({ ...l, done: !!l.done, required: l.required !== false }));
  }
  createBackground() {
    const g = this.add.graphics();
    g.fillGradientStyle(0x171b24, 0x171b24, 0x090b10, 0x090b10, 1); g.fillRect(0, 0, 800, 600);
    for (let i = 0; i < 9; i++) this.add.circle(Phaser.Math.Between(40,760), Phaser.Math.Between(60,560), Phaser.Math.Between(40,120), 0xffcf6b, 0.025);
    const v = this.add.graphics(); v.fillStyle(0x000000, 0.18); v.fillRect(0,0,800,36); v.fillRect(0,560,800,40);
  }
  createHud() {
    this.add.text(28, 22, 'ДОСКА УЛИК', { fontFamily: 'Arial', fontSize: '28px', fontStyle: 'bold', color: '#f2f5fb' });
    this.timerText = this.add.text(625, 22, '', { fontFamily: 'Arial', fontSize: '26px', fontStyle: 'bold', color: '#ffcf6b' });
    this.progressText = this.add.text(28, 58, '', { fontFamily: 'Arial', fontSize: '16px', color: '#9eabc4' });
    this.statusText = this.add.text(28, 556, 'Соедините связанные улики', { fontFamily: 'Arial', fontSize: '18px', color: '#9eabc4' });
    const skip = this.add.rectangle(720, 556, 136, 38, 0xc24d5f, 1).setInteractive({ useHandCursor: true });
    skip.setStrokeStyle(1, 0xffffff, 0.16);
    this.add.text(720, 556, 'Пропустить', { fontFamily: 'Arial', fontSize: '18px', fontStyle: 'bold', color: '#fff' }).setOrigin(0.5);
    skip.on('pointerdown', () => this.endGame(false));
    skip.on('pointerover', () => skip.setFillStyle(0xd45f72, 1));
    skip.on('pointerout', () => skip.setFillStyle(0xc24d5f, 1));
    this.hintBtn = this.add.rectangle(575, 556, 120, 38, 0x4d8ef7, 1).setInteractive({ useHandCursor: true });
    this.hintBtn.setStrokeStyle(1, 0xffffff, 0.16);
    this.add.text(575, 556, 'Подсказка', { fontFamily: 'Arial', fontSize: '18px', fontStyle: 'bold', color: '#fff' }).setOrigin(0.5);
    this.hintBtn.on('pointerdown', () => this.useHint());
  }
  createBoard() {
    this.linkGraphics = this.add.graphics();
    this.nodes.forEach(node => { const v = this.createNodeView(node); node.view = v.container; node.ring = v.ring; node.hit = v.hit; node.bg = v.bg; });
    this.redrawLinks();
  }
  createNodeView(node) {
    const container = this.add.container(node.x, node.y);
    const shadow = this.add.circle(4, 5, 38, 0x000000, 0.28);
    const bg = this.add.circle(0, 0, 38, node.color || 0x4d8ef7, 1).setStrokeStyle(2, 0xffffff, 0.10);
    const ring = this.add.circle(0, 0, 44, 0xffcf6b, 0).setStrokeStyle(0, 0, 0, 0);
    const icon = this.add.text(0, -6, node.icon || '•', { fontFamily: 'Arial', fontSize: '28px', fontStyle: 'bold', color: '#ffffff' }).setOrigin(0.5);
    const label = this.add.text(0, 42, node.label || 'Узел', { fontFamily: 'Arial', fontSize: '13px', color: '#e8edf7' }).setOrigin(0.5);
    container.add([ring, shadow, bg, icon, label]); container.setSize(90, 90);
    const hit = this.add.zone(node.x, node.y, 92, 92).setInteractive({ useHandCursor: true });
    hit.on('pointerdown', () => this.onNodeClick(node));
    hit.on('pointerover', () => { if (this.gameEnded) return; this.tweens.add({ targets: container, scaleX: 1.04, scaleY: 1.04, duration: 100 }); });
    hit.on('pointerout', () => this.tweens.add({ targets: container, scaleX: 1, scaleY: 1, duration: 100 }));
    return { container, ring, hit, bg };
  }
  onNodeClick(node) {
    if (this.gameEnded) return;
    if (!this.selected) { this.selected = node; node.ring.setStrokeStyle(4, 0xffcf6b, 1); this.statusText.setText('Выбрано: ' + node.label); return; }
    if (this.selected.id === node.id) { this.selected.ring.setStrokeStyle(0,0,0,0); this.selected = null; this.statusText.setText('Выбор снят'); return; }
    const pair = this.links.find(l => !l.done && ((l.a === this.selected.id && l.b === node.id) || (l.a === node.id && l.b === this.selected.id)));
    if (pair) { pair.done = true; this.completedLinks++; this.successLink(this.selected, node, pair); }
    else this.failLink(this.selected, node);
    this.selected.ring.setStrokeStyle(0,0,0,0); this.selected = null; this.redrawLinks(); this.updateHud();
    if (this.completedLinks >= this.requiredLinks) this.endGame(true);
  }
  successLink(a, b, link) {
    this.cameras.main.flash(120, 255, 207, 107, 0.08);
    this.drawAnimatedLink(a, b, 0x35d49b); this.pulseNode(a); this.pulseNode(b);
    this.statusText.setText('Связь: ' + a.label + ' → ' + b.label);
    if (link.text) this.showFloatingHint(link.text);
  }
  failLink(a, b) {
    [a, b].forEach(n => { n.ring.setStrokeStyle(4, 0xff5d6c, 1); this.tweens.add({ targets: n.view, x: n.view.x + 5, duration: 45, yoyo: true, repeat: 3 }); });
    this.cameras.main.shake(150, 0.004); this.statusText.setText('Эти улики не связаны напрямую');
    this.time.delayedCall(260, () => { a.ring.setStrokeStyle(0,0,0,0); b.ring.setStrokeStyle(0,0,0,0); });
  }
  useHint() {
    if (this.hintUsed || this.gameEnded) return; this.hintUsed = true; this.hintBtn.alpha = 0.45;
    const available = this.links.filter(l => !l.done && l.required);
    available.forEach(link => { const a = this.nodes.find(n => n.id === link.a); const b = this.nodes.find(n => n.id === link.b); if (!a || !b) return; [a, b].forEach(node => { node.ring.setStrokeStyle(4, 0x35d49b, 1); this.tweens.add({ targets: node.view, alpha: { from: 1, to: 0.5 }, duration: 200, yoyo: true, repeat: 2 }); }); });
    this.time.delayedCall(3000, () => this.nodes.forEach(node => node.ring.setStrokeStyle(0,0,0,0)));
  }
  pulseNode(node) { this.tweens.add({ targets: node.view, scaleX: 1.08, scaleY: 1.08, duration: 120, yoyo: true }); }
  drawAnimatedLink(a, b, color) { const t = this.add.graphics(); t.lineStyle(5, color, 0.95); t.lineBetween(a.x, a.y, b.x, b.y); t.alpha = 0; this.tweens.add({ targets: t, alpha: 1, duration: 160, yoyo: true, hold: 160, onComplete: () => t.destroy() }); }
  redrawLinks() {
    this.linkGraphics.clear();
    this.links.forEach(link => {
      const a = this.nodes.find(n => n.id === link.a); const b = this.nodes.find(n => n.id === link.b); if (!a || !b) return;
      if (link.done) this.linkGraphics.lineStyle(4, 0x35d49b, 0.88);
      else if (link.required) this.linkGraphics.lineStyle(2, 0xffffff, 0.08);
      else this.linkGraphics.lineStyle(1, 0xffffff, 0.03);
      this.linkGraphics.lineBetween(a.x, a.y, b.x, b.y);
    });
  }
  showFloatingHint(text) {
    const bg = this.add.rectangle(400, 92, 460, 42, 0x10141b, 0.88).setStrokeStyle(1, 0x35d49b, 0.24);
    const label = this.add.text(400, 92, text, { fontFamily: 'Arial', fontSize: '16px', color: '#f2f5fb' }).setOrigin(0.5);
    this.tweens.add({ targets: [bg, label], alpha: { from: 0, to: 1 }, duration: 140, yoyo: true, hold: 1200, onComplete: () => { bg.destroy(); label.destroy(); } });
  }
  startTimer() { this.timerEvent = this.time.addEvent({ delay: 1000, loop: true, callback: () => { if (this.gameEnded) return; this.timeLeft--; this.updateHud(); if (this.timeLeft <= 0) this.endGame(false); } }); }
  updateHud() { const m = Math.floor(this.timeLeft / 60), s = String(this.timeLeft % 60).padStart(2, '0'); this.timerText.setText('⏱ ' + m + ':' + s); this.timerText.setColor(this.timeLeft < 12 ? '#ff5d6c' : '#ffcf6b'); this.progressText.setText('Связей: ' + this.completedLinks + '/' + this.requiredLinks); }
  endGame(success) {
    if (this.gameEnded) return; this.gameEnded = true;
    if (this.timerEvent) this.timerEvent.remove(false);
    const overlay = this.add.rectangle(400, 300, 800, 600, 0x040608, 0.74);
    const title = this.add.text(400, 255, success ? 'ЦЕПОЧКА СОБРАНА' : 'ЛОГИКА РАЗОРВАНА', { fontFamily: 'Arial', fontSize: '34px', fontStyle: 'bold', color: success ? '#35d49b' : '#ff5d6c' }).setOrigin(0.5);
    const desc = this.add.text(400, 312, success ? 'Вы восстановили картину преступления.' : 'Не удалось связать улики вовремя.', { fontFamily: 'Arial', fontSize: '20px', color: '#f2f5fb', align: 'center' }).setOrigin(0.5);
    this.tweens.add({ targets: [overlay, title, desc], alpha: { from: 0, to: 1 }, duration: 240 });
    this.time.delayedCall(1200, () => {
      const payload = { deductionSuccess: success, rewardXP: success ? 55 : 10, evidenceGained: success ? 'Схема связей восстановлена.' : '' };
      if (this.scene.get('MainGame')) this.scene.start('MainGame', payload);
      else { this.game.events.emit('crime-board-complete', payload); this.scene.stop(); }
    });
  }
  makeDemoBoard() {
    return {
      nodes: [
        { id:'a', x:140, y:150, label:'След',    icon:'F',  color:0x5aa9ff },
        { id:'b', x:325, y:110, label:'Подозр.', icon:'S',  color:0xff8a5c },
        { id:'c', x:535, y:140, label:'Орудие',  icon:'W',  color:0xff5d6c },
        { id:'d', x:680, y:245, label:'Мотив',   icon:'M',  color:0xf0a93a },
        { id:'e', x:520, y:360, label:'Архив',   icon:'AR', color:0x7d91b8 },
        { id:'f', x:300, y:410, label:'Свидет.', icon:'WT', color:0x35d49b },
        { id:'g', x:150, y:330, label:'Улика',   icon:'C',  color:0x6be0ff }
      ],
      links: [
        { a:'a', b:'b', required:true,  text:'След указывает на круг подозреваемых.' },
        { a:'a', b:'c', required:true,  text:'На орудии найден отпечаток.' },
        { a:'b', b:'f', required:true,  text:'Свидетель видел подозреваемого.' },
        { a:'c', b:'d', required:true,  text:'Орудие связано с мотивом.' },
        { a:'g', b:'f', required:true,  text:'Улика подтверждена показаниями.' },
        { a:'e', b:'g', required:true,  text:'Архив раскрывает происхождение улики.' },
        { a:'b', b:'d', required:false, text:'Связь не прямая.' },
        { a:'a', b:'g', required:false, text:'Этого мало.' }
      ]
    };
  }
}
window.CrimeBoardScene = CrimeBoardScene;
