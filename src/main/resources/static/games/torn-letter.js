class TornLetterScene extends Phaser.Scene {
  constructor() {
    super('TornLetterScene');
    this.pieces = [];
    this.timeLeft = 60;
    this.timerEvent = null;
    this.completeText = '';
    this.skipAllowed = true;
    this.gameEnded = false;
    this.lastTapData = { id: null, time: 0 };
    this.wasDragged = false;
  }
  init(data = {}) {
    this.pieceData = Array.isArray(data.pieceData) ? data.pieceData : this.makeDemoPieces();
    this.completeText = data.completeText || 'Письмо восстановлено. В тексте указано место встречи.';
    this.skipAllowed = data.skipAllowed !== false;
    this.timeLeft = 60; this.pieces = []; this.gameEnded = false;
    this.lastTapData = { id: null, time: 0 };
  }
  create() {
    this.cameras.main.setBackgroundColor('#1a140f');
    this.createBackground(); this.createFrame(); this.createUi();
    this.createPieceTextures(); this.spawnPieces(); this.updateTimer(); this.startTimer();
  }
  createBackground() {
    const g = this.add.graphics();
    g.fillGradientStyle(0x2b2018, 0x2b2018, 0x140f0c, 0x140f0c, 1);
    g.fillRect(0, 0, 800, 600);
    for (let i = 0; i < 20; i++) {
      const alpha = Phaser.Math.FloatBetween(0.02, 0.06);
      this.add.rectangle(Phaser.Math.Between(0,800), Phaser.Math.Between(0,600), Phaser.Math.Between(120,280), Phaser.Math.Between(12,26), 0xffffff, alpha).setAngle(Phaser.Math.Between(-30,30));
    }
  }
  createFrame() {
    const x = 150, y = 130, w = 500, h = 300;
    const frame = this.add.graphics();
    frame.fillStyle(0x111318, 0.18); frame.fillRoundedRect(x, y, w, h, 24);
    frame.lineStyle(3, 0xffcf6b, 0.45); frame.strokeRoundedRect(x, y, w, h, 24);
    frame.lineStyle(1, 0xffffff, 0.08); frame.strokeRoundedRect(x+8, y+8, w-16, h-16, 18);
    this.frameGlow = this.add.rectangle(400, 280, 500, 300, 0xffcf6b, 0).setStrokeStyle(0,0,0);
    this.add.text(400, 148, 'Соберите письмо', { fontFamily: 'Arial', fontSize: '24px', color: '#f2f5fb', fontStyle: 'bold' }).setOrigin(0.5);
  }
  createUi() {
    this.timerText = this.add.text(400, 34, '01:00', { fontFamily: 'Arial', fontSize: '28px', color: '#ffcf6b', fontStyle: 'bold' }).setOrigin(0.5);
    if (this.skipAllowed) {
      const btn = this.add.rectangle(718, 34, 128, 42, 0xc24d5f, 1).setInteractive({ useHandCursor: true });
      btn.setStrokeStyle(1, 0xffffff, 0.18);
      this.add.text(718, 34, 'Пропустить', { fontFamily: 'Arial', fontSize: '18px', color: '#ffffff', fontStyle: 'bold' }).setOrigin(0.5);
      btn.on('pointerdown', () => this.endGame(false));
      btn.on('pointerover', () => btn.setFillStyle(0xd85f73, 1));
      btn.on('pointerout', () => btn.setFillStyle(0xc24d5f, 1));
    }
  }
  createPieceTextures() {
    this.pieceData.forEach((data, i) => {
      const key = data.key || ('piece' + i);
      const width = 120 + (i % 2) * 8, height = 92 + (i % 3) * 4;
      data.textureWidth = width; data.textureHeight = height; data.key = key;
      if (this.textures.exists(key)) return;
      const g = this.add.graphics();
      g.fillStyle(0xf6ebd2, 1); g.lineStyle(2, 0xbfa37b, 0.9);
      g.beginPath(); g.moveTo(10, 8); g.lineTo(width-18, 10); g.lineTo(width-8, 22); g.lineTo(width-12, height-12); g.lineTo(20, height-8); g.lineTo(8, height-20); g.closePath(); g.fillPath(); g.strokePath();
      g.fillStyle(0x876f57, 0.22);
      for (let y = 18; y < height - 12; y += 14) g.fillRect(16, y, width - 32, 4);
      g.generateTexture(key, width + 2, height + 2); g.destroy();
    });
  }
  spawnPieces() {
    this.pieceData.forEach((data, index) => {
      const piece = this.add.image(data.x, data.y, data.key || ('piece' + index));
      piece.setInteractive({ draggable: true, useHandCursor: true });
      piece.setRotation(Phaser.Math.DegToRad(data.rotation || 0));
      piece.correctX = data.correctX; piece.correctY = data.correctY; piece.correctRotation = data.correctRotation || 0;
      piece.startX = data.x; piece.startY = data.y; piece.locked = false; piece.pieceId = data.key || ('piece' + index);
      const w = data.textureWidth || piece.width, h = data.textureHeight || piece.height;
      const glow = this.add.rectangle(piece.x, piece.y, w + 14, h + 14, 0xffcf6b, 0);
      glow.setDepth(piece.depth - 1); piece.glow = glow;
      this.pieces.push(piece);
    });
    this.wasDragged = false;
    this.input.on('dragstart', (p, o) => { if (o.locked || this.gameEnded) return; this.wasDragged = false; o.setDepth(999); o.glow.setFillStyle(0xffcf6b, 0.14); this.tweens.add({ targets: o, scale: 1.03, duration: 100 }); });
    this.input.on('drag', (p, o, dx, dy) => { if (o.locked || this.gameEnded) return; this.wasDragged = true; o.x = dx; o.y = dy; o.glow.x = dx; o.glow.y = dy; });
    this.input.on('dragend', (p, o) => { if (o.locked || this.gameEnded) return; o.glow.setFillStyle(0xffcf6b, 0); this.trySnapPiece(o); });
    this.input.on('gameobjectdown', (p, o) => {
      if (this.gameEnded || o.locked || !this.pieces.includes(o)) return;
      if (this.wasDragged) return;
      const now = this.time.now;
      if (this.lastTapData.id === o.pieceId && now - this.lastTapData.time < 300) { this.rotatePiece(o); this.lastTapData = { id: null, time: 0 }; }
      else this.lastTapData = { id: o.pieceId, time: now };
    });
  }
  rotatePiece(piece) { if (piece.locked) return; this.tweens.add({ targets: piece, angle: piece.angle + 180, duration: 180, ease: 'Cubic.easeOut', onUpdate: () => { piece.glow.angle = piece.angle; } }); }
  trySnapPiece(piece) {
    const dist = Phaser.Math.Distance.Between(piece.x, piece.y, piece.correctX, piece.correctY);
    const currentRot = Phaser.Math.Angle.WrapDegrees(piece.angle);
    const targetRot = Phaser.Math.Angle.WrapDegrees(piece.correctRotation);
    const rotDiff = Math.abs(Phaser.Math.Angle.ShortestBetween(currentRot, targetRot));
    if (dist < 25 && rotDiff < 15) {
      piece.locked = true; piece.disableInteractive();
      this.tweens.add({ targets: [piece, piece.glow], x: piece.correctX, y: piece.correctY, angle: piece.correctRotation, duration: 180, ease: 'Back.easeOut' });
      this.tweens.add({ targets: piece, scale: 1, duration: 120 });
      this.flashSnap(piece.correctX, piece.correctY); this.checkSolved();
    } else {
      this.tweens.add({ targets: [piece, piece.glow], x: piece.startX, y: piece.startY, angle: piece.angle, duration: 300, ease: 'Back.easeOut' });
      this.tweens.add({ targets: piece, scale: 1, duration: 120 });
    }
  }
  flashSnap(x, y) { const flash = this.add.circle(x, y, 32, 0xffcf6b, 0.28); this.tweens.add({ targets: flash, alpha: 0, scale: 1.8, duration: 260, onComplete: () => flash.destroy() }); }
  checkSolved() { if (this.pieces.every(p => p.locked)) { this.frameSuccess(); this.time.delayedCall(900, () => this.endGame(true)); } }
  frameSuccess() {
    this.tweens.add({ targets: this.frameGlow, alpha: { from: 0, to: 0.22 }, duration: 260, yoyo: true, repeat: 2 });
    const txtBg = this.add.rectangle(400, 502, 620, 86, 0x0e1118, 0.88).setStrokeStyle(1, 0xffcf6b, 0.25);
    const txt = this.add.text(400, 502, this.completeText, { fontFamily: 'Arial', fontSize: '18px', color: '#f2f5fb', align: 'center', wordWrap: { width: 580 } }).setOrigin(0.5);
    this.tweens.add({ targets: [txtBg, txt], alpha: { from: 0, to: 1 }, duration: 260 });
  }
  startTimer() { this.timerEvent = this.time.addEvent({ delay: 1000, loop: true, callback: () => { if (this.gameEnded) return; this.timeLeft -= 1; this.updateTimer(); if (this.timeLeft <= 0) { this.cameras.main.shake(300, 0.01); this.endGame(false); } } }); }
  updateTimer() { const m = Math.floor(this.timeLeft / 60), s = String(this.timeLeft % 60).padStart(2, '0'); this.timerText.setText(String(m).padStart(2,'0') + ':' + s); this.timerText.setColor(this.timeLeft <= 10 ? '#ff5d6c' : '#ffcf6b'); }
  endGame(success) {
    if (this.gameEnded) return; this.gameEnded = true;
    if (this.timerEvent) this.timerEvent.remove(false);
    const payload = { deductionSuccess: success, rewardXP: success ? 45 : 8, newEvidence: success ? this.completeText : '' };
    this.time.delayedCall(success ? 1300 : 300, () => { if (this.scene.get('MainGame')) this.scene.start('MainGame', payload); else { this.game.events.emit('torn-letter-complete', payload); this.scene.stop(); } });
  }
  makeDemoPieces() {
    return [
      { key:'piece0', x:78,  y:110, correctX:248, correctY:200, correctRotation:0 },
      { key:'piece1', x:704, y:120, correctX:368, correctY:200, correctRotation:0 },
      { key:'piece2', x:84,  y:280, correctX:488, correctY:200, correctRotation:180 },
      { key:'piece3', x:702, y:285, correctX:248, correctY:308, correctRotation:180 },
      { key:'piece4', x:118, y:486, correctX:368, correctY:308, correctRotation:0 },
      { key:'piece5', x:682, y:486, correctX:488, correctY:308, correctRotation:180 }
    ];
  }
}
window.TornLetterScene = TornLetterScene;
