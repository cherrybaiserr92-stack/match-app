class DetectiveMahjong extends Phaser.Scene {
  constructor() {
    super('DetectiveMahjong');
    this.tileSize = 60;
    this.layerOffset = 3;
    this.selectedTile = null;
    this.tileMap = [];
    this.tileSprites = new Map();
    this.errorsLeft = 5;
    this.maxTime = 180;
    this.timeLeft = 180;
    this.hintUsed = false;
    this.shuffleUsed = false;
    this.gameEnded = false;
    this.startTimestamp = 0;
  }
  init(data = {}) {
    this.rawTiles = Array.isArray(data.tiles) ? data.tiles.map(t => ({ ...t })) : this.makeDemoTiles();
    this.compatibility = this.makeSymmetricCompatibility(data.compatibility || this.defaultCompatibility());
    this.maxTime = data.maxTime || 180;
    this.timeLeft = this.maxTime;
    this.errorsLeft = data.maxErrors || 5;
    this.selectedTile = null;
    this.hintUsed = false;
    this.shuffleUsed = false;
    this.gameEnded = false;
    this.tileSprites = new Map();
  }
  create() {
    this.cameras.main.setBackgroundColor('#111318');
    this.startTimestamp = this.time.now;
    this.createBackground();
    this.createUiShell();
    this.createParticles();
    this.buildBoard();
    this.refreshAllTileStates();
    this.startTimer();
  }
  createBackground() {
    const w = this.scale.width, h = this.scale.height;
    const bg = this.add.graphics();
    bg.fillGradientStyle(0x161922, 0x161922, 0x090b10, 0x090b10, 1);
    bg.fillRect(0, 0, w, h);
    const glow1 = this.add.circle(140, 100, 180, 0xf0a93a, 0.06);
    const glow2 = this.add.circle(700, 140, 160, 0x5aa9ff, 0.05);
    this.tweens.add({ targets: glow1, alpha: { from: 0.04, to: 0.09 }, duration: 2800, yoyo: true, repeat: -1, ease: 'Sine.easeInOut' });
    this.tweens.add({ targets: glow2, alpha: { from: 0.03, to: 0.07 }, duration: 3600, yoyo: true, repeat: -1, ease: 'Sine.easeInOut' });
  }
  createUiShell() {
    const top = this.add.graphics();
    top.fillStyle(0x151922, 0.82);
    top.fillRoundedRect(16, 14, 768, 56, 18);
    top.lineStyle(1, 0xffffff, 0.08);
    top.strokeRoundedRect(16, 14, 768, 56, 18);
    this.add.text(32, 24, 'ДЕТЕКТИВНЫЙ МАДЖОНГ', { fontFamily: 'Arial', fontSize: '22px', color: '#f2f5fb', fontStyle: 'bold' });
    this.timerText = this.add.text(520, 24, '', { fontFamily: 'Arial', fontSize: '22px', color: '#ffcf6b', fontStyle: 'bold' });
    this.errorText = this.add.text(680, 24, '', { fontFamily: 'Arial', fontSize: '20px', color: '#ff6b7b', fontStyle: 'bold' });
    this.subText = this.add.text(32, 558, 'Соединяй логически связанные улики', { fontFamily: 'Arial', fontSize: '16px', color: '#9eabc4' });
    this.hintBtn = this.createButton(20, 520, 150, 52, 'Подсказка', 0x29c47c, () => this.useHint());
    this.shuffleBtn = this.createButton(182, 520, 170, 52, 'Перемешать', 0x4d8ef7, () => this.shuffleRemaining());
    this.skipBtn = this.createButton(620, 520, 160, 52, 'Пропустить', 0xc24d5f, () => this.endGame(false));
    this.updateHud();
  }
  createButton(x, y, w, h, label, color, onClick) {
    const wrap = this.add.container(x, y);
    const shadow = this.add.rectangle(0, 4, w, h, 0x000000, 0.24).setOrigin(0, 0);
    const bg = this.add.rectangle(0, 0, w, h, color, 1).setOrigin(0, 0).setInteractive({ useHandCursor: true });
    bg.setStrokeStyle(1, 0xffffff, 0.18);
    const txt = this.add.text(w / 2, h / 2, label, { fontFamily: 'Arial', fontSize: '20px', color: '#ffffff', fontStyle: 'bold' }).setOrigin(0.5);
    wrap.add([shadow, bg, txt]);
    bg.on('pointerover', () => this.tweens.add({ targets: wrap, scaleX: 1.03, scaleY: 1.03, duration: 120 }));
    bg.on('pointerout', () => this.tweens.add({ targets: wrap, scaleX: 1, scaleY: 1, duration: 120 }));
    bg.on('pointerdown', () => { this.tweens.add({ targets: wrap, scaleX: 0.97, scaleY: 0.97, duration: 80, yoyo: true }); onClick(); });
    wrap.bg = bg;
    return wrap;
  }
  createParticles() {
    const g = this.add.graphics();
    g.fillStyle(0xffcf6b, 1);
    g.fillCircle(4, 4, 4);
    g.generateTexture('spark-particle', 8, 8);
    g.destroy();
    this.matchParticles = this.add.particles(0, 0, 'spark-particle', { speed: { min: 20, max: 110 }, scale: { start: 1, end: 0 }, lifespan: 520, quantity: 0, blendMode: 'ADD' });
  }
  buildBoard() {
    this.rawTiles.forEach(tile => {
      const pos = this.getTilePosition(tile, 70, 90);
      const view = this.createTileView(tile, pos.x, pos.y);
      this.tileSprites.set(tile.id, view);
    });
    this.tileMap = [...this.rawTiles];
  }
  getTilePosition(tile, boardLeft, boardTop) {
    return { x: boardLeft + tile.col * 66 + tile.layer * this.layerOffset, y: boardTop + tile.row * 70 + tile.layer * this.layerOffset };
  }
  createTileView(tile, x, y) {
    const color = this.typeColors()[tile.type] || 0x4d8ef7;
    const container = this.add.container(x, y);
    container.setSize(this.tileSize, this.tileSize);
    const shadow = this.add.rectangle(4, 5, this.tileSize, this.tileSize, 0x000000, 0.26).setOrigin(0);
    const bg = this.add.rectangle(0, 0, this.tileSize, this.tileSize, color, 1).setOrigin(0).setStrokeStyle(1, 0xffffff, 0.08);
    const inner = this.add.rectangle(6, 6, this.tileSize - 12, this.tileSize - 12, 0x10131a, 0.14).setOrigin(0);
    const glyph = this.add.text(this.tileSize / 2, this.tileSize / 2 - 4, this.shortType(tile.type), { fontFamily: 'Arial', fontSize: '28px', fontStyle: 'bold', color: '#ffffff' }).setOrigin(0.5);
    const label = this.add.text(this.tileSize / 2, this.tileSize - 11, this.typeLabel(tile.type), { fontFamily: 'Arial', fontSize: '10px', color: '#eef3ff' }).setOrigin(0.5);
    const frame = this.add.rectangle(0, 0, this.tileSize, this.tileSize).setOrigin(0).setStrokeStyle(0, 0xffffff, 0);
    const hoverGlow = this.add.rectangle(-2, -2, this.tileSize + 4, this.tileSize + 4, 0xffcf6b, 0).setOrigin(0);
    container.add([hoverGlow, shadow, bg, inner, glyph, label, frame]);
    container.setDepth(100 + tile.layer * 10 + tile.row);
    container.setInteractive({ useHandCursor: true });
    container.on('pointerover', () => { if (this.gameEnded || !this.isTileFree(tile)) return; this.tweens.killTweensOf(container); this.tweens.add({ targets: container, scaleX: 1.03, scaleY: 1.03, duration: 120 }); hoverGlow.setFillStyle(0xffcf6b, 0.14); });
    container.on('pointerout', () => { if (this.gameEnded || !this.isTileFree(tile)) return; this.tweens.add({ targets: container, scaleX: 1, scaleY: 1, duration: 120 }); hoverGlow.setFillStyle(0xffcf6b, 0); });
    container.on('pointerdown', () => this.onTileClick(tile));
    container.bg = bg; container.frame = frame; container.hoverGlow = hoverGlow; container.shadow = shadow; container.glyph = glyph; container.label = label;
    return container;
  }
  onTileClick(tile) {
    if (this.gameEnded) return;
    if (!this.isTileFree(tile)) return;
    if (!this.selectedTile) return this.selectTile(tile);
    if (this.selectedTile.id === tile.id) return this.clearSelection();
    if (this.areCompatible(this.selectedTile.type, tile.type)) this.matchSuccess(this.selectedTile, tile);
    else this.matchFail(this.selectedTile, tile);
  }
  selectTile(tile) {
    this.clearSelection();
    this.selectedTile = tile;
    const view = this.tileSprites.get(tile.id);
    if (!view) return;
    view.frame.setStrokeStyle(4, 0xffcf6b, 1);
    this.tweens.add({ targets: view, y: view.y - 4, duration: 120, yoyo: true });
  }
  clearSelection() {
    if (!this.selectedTile) return;
    const view = this.tileSprites.get(this.selectedTile.id);
    if (view) view.frame.setStrokeStyle(0, 0xffffff, 0);
    this.selectedTile = null;
  }
  matchSuccess(a, b) {
    const viewA = this.tileSprites.get(a.id), viewB = this.tileSprites.get(b.id);
    this.clearSelection();
    this.emitMatchParticles(viewA.x + 30, viewA.y + 30);
    this.emitMatchParticles(viewB.x + 30, viewB.y + 30);
    [viewA, viewB].forEach(view => {
      if (!view) return;
      view.disableInteractive();
      this.tweens.add({ targets: view, scaleX: 0.2, scaleY: 0.2, alpha: 0, angle: Phaser.Math.Between(-20, 20), duration: 260, ease: 'Back.easeIn', onComplete: () => view.destroy() });
    });
    this.tileMap = this.tileMap.filter(t => t.id !== a.id && t.id !== b.id);
    this.tileSprites.delete(a.id); this.tileSprites.delete(b.id);
    this.time.delayedCall(280, () => { this.refreshAllTileStates(); this.checkCompletion(); });
  }
  matchFail(a, b) {
    this.errorsLeft -= 1; this.updateHud();
    const va = this.tileSprites.get(a.id), vb = this.tileSprites.get(b.id);
    [va, vb].forEach(v => { if (!v) return; v.frame.setStrokeStyle(4, 0xff5d6c, 1); this.tweens.add({ targets: v, x: v.x + 5, duration: 45, yoyo: true, repeat: 3 }); });
    this.cameras.main.shake(180, 0.005);
    this.time.delayedCall(260, () => { [va, vb].forEach(v => { if (v) v.frame.setStrokeStyle(0, 0xffffff, 0); }); this.clearSelection(); this.refreshAllTileStates(); this.checkFailure(); });
  }
  emitMatchParticles(x, y) { if (this.matchParticles) this.matchParticles.emitParticleAt(x, y, 14); }
  startTimer() {
    this.timerEvent = this.time.addEvent({ delay: 1000, loop: true, callback: () => { if (this.gameEnded) return; this.timeLeft -= 1; this.updateHud(); if (this.timeLeft <= 0) this.endGame(false); } });
  }
  updateHud() {
    const m = Math.floor(this.timeLeft / 60), s = String(this.timeLeft % 60).padStart(2, '0');
    this.timerText.setText('⏱ ' + m + ':' + s);
    this.errorText.setText('Ошибки: ' + this.errorsLeft);
    this.timerText.setColor(this.timeLeft < 15 ? '#ff5d6c' : '#ffcf6b');
    this.hintBtn.alpha = this.hintUsed ? 0.45 : 1;
    this.shuffleBtn.alpha = this.shuffleUsed ? 0.45 : 1;
  }
  refreshAllTileStates() {
    this.tileMap.forEach(tile => {
      const view = this.tileSprites.get(tile.id);
      if (!view) return;
      const free = this.isTileFree(tile);
      view.bg.setAlpha(free ? 1 : 0.45); view.glyph.setAlpha(free ? 1 : 0.55); view.label.setAlpha(free ? 0.95 : 0.45); view.shadow.setAlpha(free ? 0.26 : 0.14);
      if (view.input) view.input.enabled = free;
      if (!free) view.hoverGlow.setFillStyle(0xffcf6b, 0);
    });
  }
  isTileFree(tile) {
    const rect = this.tileRect(tile);
    const blockedAbove = this.tileMap.some(other => { if (other.id === tile.id) return false; if (other.layer >= tile.layer) return false; return Phaser.Geom.Intersects.RectangleToRectangle(rect, this.tileRect(other)); });
    if (blockedAbove) return false;
    let leftBlocked = false, rightBlocked = false;
    this.tileMap.forEach(other => { if (other.id === tile.id || other.layer !== tile.layer) return; if (Math.abs(other.row - tile.row) > 0) return; if (other.col === tile.col - 1) leftBlocked = true; if (other.col === tile.col + 1) rightBlocked = true; });
    return !(leftBlocked && rightBlocked);
  }
  tileRect(tile) { const p = this.getTilePosition(tile, 70, 90); return new Phaser.Geom.Rectangle(p.x, p.y, this.tileSize, this.tileSize); }
  areCompatible(typeA, typeB) { return !!((this.compatibility[typeA] && this.compatibility[typeA].includes(typeB)) || (this.compatibility[typeB] && this.compatibility[typeB].includes(typeA))); }
  useHint() {
    if (this.hintUsed || !this.selectedTile || this.gameEnded) return;
    const source = this.selectedTile;
    const available = this.tileMap.filter(t => t.id !== source.id && this.isTileFree(t) && this.areCompatible(source.type, t.type));
    if (!available.length) return;
    this.hintUsed = true; this.updateHud();
    available.forEach(tile => { const view = this.tileSprites.get(tile.id); if (!view) return; view.frame.setStrokeStyle(4, 0x35d49b, 1); this.tweens.add({ targets: view, alpha: { from: 1, to: 0.6 }, duration: 220, yoyo: true, repeat: 5 }); });
    this.time.delayedCall(3000, () => { available.forEach(tile => { const view = this.tileSprites.get(tile.id); if (view) view.frame.setStrokeStyle(0, 0xffffff, 0); }); if (this.selectedTile) { const sv = this.tileSprites.get(this.selectedTile.id); if (sv) sv.frame.setStrokeStyle(4, 0xffcf6b, 1); } });
  }
  shuffleRemaining() {
    if (this.shuffleUsed || this.gameEnded) return;
    this.shuffleUsed = true; this.updateHud();
    const alive = [...this.tileMap];
    const positions = alive.map(t => ({ row: t.row, col: t.col, layer: t.layer }));
    Phaser.Utils.Array.Shuffle(positions);
    alive.forEach((tile, i) => { tile.row = positions[i].row; tile.col = positions[i].col; tile.layer = positions[i].layer; });
    alive.forEach(tile => { const view = this.tileSprites.get(tile.id); const pos = this.getTilePosition(tile, 70, 90); if (!view) return; this.tweens.add({ targets: [view], x: pos.x, y: pos.y, duration: 420, ease: 'Cubic.easeOut' }); });
    this.time.delayedCall(450, () => { this.refreshAllTileStates(); this.ensureHasMoveOrEnd(); });
  }
  ensureHasMoveOrEnd() {
    const freeTiles = this.tileMap.filter(t => this.isTileFree(t));
    let hasMove = false;
    for (let i = 0; i < freeTiles.length; i++) { for (let j = i + 1; j < freeTiles.length; j++) { if (this.areCompatible(freeTiles[i].type, freeTiles[j].type)) { hasMove = true; break; } } if (hasMove) break; }
    if (!hasMove && !this.shuffleUsed) this.subText.setText('Нет ходов. Используй перемешивание.');
    else if (!hasMove) this.endGame(false);
    else this.subText.setText('Соединяй логически связанные улики');
  }
  checkCompletion() { if (!this.tileMap.length) return this.endGame(true); this.ensureHasMoveOrEnd(); }
  checkFailure() { if (this.errorsLeft <= 0) this.endGame(false); }
  endGame(success) {
    if (this.gameEnded) return;
    this.gameEnded = true;
    if (this.timerEvent) this.timerEvent.remove(false);
    const timeSpent = Math.max(0, Math.floor((this.time.now - this.startTimestamp) / 1000));
    const overlay = this.add.rectangle(400, 300, 800, 600, 0x05070a, 0.72);
    const title = this.add.text(400, 250, success ? 'ДЕЛО ПРОДВИНУЛОСЬ' : 'СЛЕД ОБРЫВАЕТСЯ', { fontFamily: 'Arial', fontSize: '34px', fontStyle: 'bold', color: success ? '#35d49b' : '#ff5d6c' }).setOrigin(0.5);
    const desc = this.add.text(400, 305, success ? ('Поле очищено за ' + timeSpent + ' сек.') : ('Осталось тайлов: ' + this.tileMap.length), { fontFamily: 'Arial', fontSize: '20px', color: '#f2f5fb', align: 'center' }).setOrigin(0.5);
    this.tweens.add({ targets: [overlay, title, desc], alpha: { from: 0, to: 1 }, duration: 300 });
    this.time.delayedCall(1400, () => {
      const payload = { deductionSuccess: success, rewardXP: success ? 50 : 10, evidenceGained: success ? 'Связь подтверждена.' : '' };
      if (this.scene.get('MainGame')) this.scene.start('MainGame', payload);
      else { this.game.events.emit('detective-mahjong-complete', payload); this.scene.stop(); }
    });
  }
  makeSymmetricCompatibility(source) {
    const out = {};
    Object.keys(source).forEach(a => { out[a] = out[a] || []; source[a].forEach(b => { if (!out[a].includes(b)) out[a].push(b); out[b] = out[b] || []; if (!out[b].includes(a)) out[b].push(a); }); });
    return out;
  }
  shortType(type) { const map = { fingerprint:'F', suspect:'S', weapon:'W', motive:'M', victim:'V', witness:'WT', clue:'C', alibi:'A', archive:'AR' }; return map[type] || type.slice(0,1).toUpperCase(); }
  typeLabel(type) { const map = { fingerprint:'след', suspect:'подозр.', weapon:'орудие', motive:'мотив', victim:'жертва', witness:'свидет.', clue:'улика', alibi:'алиби', archive:'архив' }; return map[type] || type; }
  typeColors() { return { fingerprint:0x5aa9ff, suspect:0xff8a5c, weapon:0xff5d6c, motive:0xf0a93a, victim:0xa98bff, witness:0x35d49b, clue:0x6be0ff, alibi:0xffcf6b, archive:0x7d91b8 }; }
  defaultCompatibility() { return { fingerprint:['suspect','weapon'], suspect:['fingerprint','witness','motive'], weapon:['fingerprint','victim'], victim:['weapon','motive'], motive:['victim','suspect'], witness:['suspect','clue'], clue:['witness','archive'], archive:['clue'], alibi:['suspect'] }; }
  makeDemoTiles() {
    const types = ['fingerprint','suspect','weapon','motive','victim','witness','clue','archive'];
    const tiles = []; let id = 1; let pairSeed = [];
    for (let i = 0; i < 18; i++) { const t = types[i % types.length]; const compat = this.defaultCompatibility()[t]?.[0] || t; pairSeed.push(t, compat); }
    const layout = [
      { layer: 2, cells: [[2,3],[2,4],[3,3],[3,4]] },
      { layer: 1, cells: [[1,2],[1,3],[1,4],[1,5],[2,2],[2,5],[3,2],[3,5],[4,3],[4,4]] },
      { layer: 0, cells: [[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[1,1],[1,6],[2,1],[2,6],[3,1],[3,6],[4,1],[4,2],[4,5],[4,6],[5,2],[5,3],[5,4],[5,5]] }
    ];
    let pi = 0;
    layout.forEach(block => { block.cells.forEach(([row, col]) => { tiles.push({ id: 't' + (id++), type: pairSeed[pi % pairSeed.length], layer: block.layer, row, col }); pi++; }); });
    return Phaser.Utils.Array.Shuffle(tiles);
  }
}
window.DetectiveMahjong = DetectiveMahjong;
