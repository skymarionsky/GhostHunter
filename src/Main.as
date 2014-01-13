package
{
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  
  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.MovieClip;
  import starling.display.QuadBatch;
  import starling.display.Sprite;
  import starling.events.EnterFrameEvent;
  import starling.events.Event;
  import starling.events.KeyboardEvent;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.text.TextField;
  import starling.textures.Texture;
  
  public class Main extends Sprite
  {
    private var _scene:Sprite;
    private var _player:Manager;
    private var _shot:Vector.<Image>;
    private var _grave:Vector.<Grave>;
    private var _passedTime:Number;
    private var _ghost:Vector.<Ghost>;
    private var _timer:Timer;
    private var _life:Vector.<Image>;
    private var _gamePaused:Boolean = false;
    private var _text:TextField;
    
    public function Main()
    {
      super();
      if(stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    public function init(e:Event = null):void
    {
      removeEventListener(Event.ADDED_TO_STAGE,init);
      
      var i:int,j:int,image:Image;
      
      // create scene and player
      _scene = new Sprite();
      _player = new Manager();
      _scene.addChild(_player.mMC);
      Starling.juggler.add(_player.mMC);
      addChild(_scene);
      
      // initialize shot
      _shot = new Vector.<Image>();
      
      // initialize grave
      _grave = new Vector.<Grave>();
      var graveImg:Grave = new Grave(_player.getGraveTexture(),10);
      graveImg.x = 400;
      graveImg.y = 300;
      graveImg.alignPivot();
      addChildAt(graveImg as Image,0);
      _grave.push(graveImg);
      
      // initialize ghost
      _ghost = new Vector.<Ghost>();
      
      // init background
      var tile:Texture = _player.getTileTexture();
      var quadBatch:QuadBatch = new QuadBatch();
      image = new Image(tile);
      quadBatch.addImage(image);
      for (i=0; i<ghostHunter.stage.stageWidth/image.width; ++i){
        for(j=0;j<ghostHunter.stage.stageHeight/image.height; ++j){
          quadBatch.addImage(image);
          image.y += image.height;
        }
        image.x += image.width;
        image.y = 0;
      }
      addChildAt(quadBatch,0);
      
      // init UI
      _life = new Vector.<Image>();
      var life:Texture = _player.getLifeTexture();
      for(i=0; i<_player.mLife; i++){
        image = new Image(life);
        image.x = 400+i*30;
        addChild(image);
        _life.push(image);
      }
      _text = new TextField(160, 80, "Phase: "+_player.mLevel);
      _text.fontSize = 16;
      _text.color = 0x000000;
      _text.x = 600;
      _text.y = -16;
      addChild(_text);
      
      // add event listners
      stage.addEventListener(EnterFrameEvent.ENTER_FRAME, loop);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
      stage.addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    private function onTouch(e:TouchEvent):void
    {
      var touch:Touch = e.getTouch(stage);
      if(touch){
        switch(touch.phase){
          case "began":
            _player.mIsShooting = true;
            break;
          case "ended":
            _player.mIsShooting = false;
            _player.mCntShotInterval = _player.shootInterval;
            break;
          case "hover":
          case "moved":
            _player.mCurrentMousePosX = touch.globalX;
            _player.mCurrentMousePosY = touch.globalY;
            break;
        }
      }
    }
    
    private function addShot(rad:Number):void
    {
      var shot:Image = new Image(_player.getShotTexture());
      shot.x = _player.mMC.x;
      shot.y = _player.mMC.y;
      shot.alignPivot();
      shot.rotation = rad;
      addChild(shot);
      _shot.push(shot);
    }
    
    private function loop(e:EnterFrameEvent):void
    {
      if(_gamePaused) return;
      _passedTime = e.passedTime;
      playerMove();
      playerShoot();
      updateShot();
      addGhost();
      updateGhost();
      screenEffect();
    }
    
    private function screenEffect():void
    {
      if(_player.mDamageEffectRemainFrame>0){
        _player.mDamageEffectRemainFrame--;
        if(_player.mDamageEffectRemainFrame == 0){
          this.x = 0;
          this.y = 0;
        }else{
          this.x = Math.random()*10 - 5;
          this.y = Math.random()*10 - 5;
        }
      }
    }
    
    private function addGhost():void
    {
      if(_player.mStopAddingGhost) return;
      if(Math.random() * ghostHunter.FPS < 1.5){
        var tx:int,ty:int;
        var ghost:Ghost = new Ghost(_player.getGhostMovieClip(),2);
        ghost.alignPivot();
        var targetGrave:Grave = _grave[0];
        if(Math.random()<0.5){
          tx = Math.random()*ghostHunter.stage.stageWidth;
          ty = (Math.random()<0.5)?0:ghostHunter.stage.stageHeight;
        }else{
          tx = (Math.random()<0.5)?0:ghostHunter.stage.stageWidth;
          ty = Math.random()*ghostHunter.stage.stageHeight;
        }
        ghost.init(tx,ty,targetGrave.x,targetGrave.y);
        ghost.mSpeed = _player.defaultGhostSpeed;
        _ghost.push(ghost);
        _scene.addChildAt(ghost as MovieClip,0);
        Starling.juggler.add(ghost);
        _player.mGhostCnt++;
        if(_player.mGhostCnt == (8 + 2*_player.mLevel)){
          ghost.mIsBoss = true;
          _player.mStopAddingGhost = true;
        }
      }
    }
    
    private function enterRespawnGhost(ghost:Ghost):void
    {
      ghost.mIsVoid = true;
      var tween:Tween = new Tween(ghost, 1.0, Transitions.EASE_IN);
      tween.animate("scaleX",2);
      tween.animate("scaleY",2);
      tween.fadeTo(0);
      tween.onComplete = respawnGhost;
      tween.onCompleteArgs = [ghost];
      Starling.juggler.add(tween);
    }
    
    private function respawnGhost(ghost:Ghost):void
    {
      var tx:int,ty:int;
      var targetGrave:Grave = _grave[0];
      if(Math.random()<0.5){
        tx = Math.random()*ghostHunter.stage.stageWidth;
        ty = (Math.random()<0.5)?0:ghostHunter.stage.stageHeight;
      }else{
        tx = (Math.random()<0.5)?0:ghostHunter.stage.stageWidth;
        ty = Math.random()*ghostHunter.stage.stageHeight;
      }
      ghost.scaleX = 1;
      ghost.scaleY = 1;
      ghost.alpha = 1;
      ghost.mIsVoid = false;
      ghost.init(tx,ty,targetGrave.x,targetGrave.y);
      ghost.mSpeed *= 1.05;// increase speed 5%
    }
    
    private function updateGhost():void
    {
      for(var i:int=0;i<_ghost.length;i++){
        if(!_ghost[i].updateMove() && !_ghost[i].mIsVoid){
          // reached to target grave -> player takes damage
          _player.ghostReachedToGrave();
          if(_player.mLife == 0) gameOver();
          respawnGhost(_ghost[i]);
          var img:Image = _life.pop();
          removeChild(img);
        }
      }
    }
    
    private function gameOver():void
    {
      _gamePaused = true;
      var img:Image = new Image(_player.getGameOverTexture());
      img.alignPivot();
      img.scaleX = 10;
      img.scaleY = 10;
      img.x = ghostHunter.stage.stageWidth >> 1;
      img.y = ghostHunter.stage.stageHeight >> 1;
      addChild(img);
    }
    
    private function playerShoot():void
    {
      if(!_player.mIsShooting)return;
      _player.mCntShotInterval += _passedTime;
      if( _player.mCntShotInterval < _player.shootInterval)return;
      _player.mCntShotInterval -= _player.shootInterval;
      //trace("mouse down",touch.globalX,touch.globalY);
      var tx:Number = _player.mCurrentMousePosX;
      var ty:Number = _player.mCurrentMousePosY;
      var px:Number = _player.mMC.x;
      var py:Number = _player.mMC.y;
      var rad:Number = Math.atan2(ty - py, tx - px);
      var deg:Number = rad;
      addShot(deg);
    }    
    
    
    private function updateShot():void
    {
      var isHit:Boolean = false;
      for(var i:int=0;i<_shot.length;i++){
        
        for(var j:int=0;j<_ghost.length;j++){
          if(!_ghost[j].mIsVoid &&
            Math.abs(_shot[i].x - _ghost[j].x) < (_ghost[j].mHitSizeX + _player.mShotHitSizeX) &&
            Math.abs(_shot[i].y - _ghost[j].y) < (_ghost[j].mHitSizeY + _player.mShotHitSizeY)){
              // hit to ghost
              _player.mKillCnt++;
              if(!_ghost[j].mIsBoss){
                enterRespawnGhost(_ghost[j]);
              }else{
                // hit to boss
                for(var k:int=_ghost.length-1;k>=0;k--){
                  addExplosion(_ghost[k].x,_ghost[k].y);
                  _scene.removeChild(_ghost[k]);
                  Starling.juggler.remove(_ghost[k]);
                  _ghost.splice(k,1);
                }
                _timer = new Timer(1500,1);
                _timer.addEventListener(TimerEvent.TIMER,startNextPhase);
                _timer.start();
              }
              removeChild(_shot[i]);
              _shot.splice(i,1);
              --i;
              isHit = true;
              break;
            }
        }
        if(isHit) continue;
        
        var tx:Number = Math.cos(_shot[i].rotation) * _player.mShotSpeed;
        var ty:Number = Math.sin(_shot[i].rotation) * _player.mShotSpeed;
        _shot[i].x += tx;
        _shot[i].y += ty;
        if(_shot[i].x<0 || _shot[i].x>ghostHunter.stage.stageWidth
          || _shot[i].y<0 || _shot[i].y>ghostHunter.stage.stageHeight)
        {
          // out of screen
          removeChild(_shot[i]);
          _shot.splice(i,1);
          --i;
        }
      }
    }
    
    private function addExplosion(posX:int,posY:int):void
    {
      var mc:MovieClip = new MovieClip(_player.getExplosionMovieClip(),6);
      mc.addEventListener(Event.COMPLETE,onMovieClipEnd);
      mc.alignPivot();
      mc.x = posX;
      mc.y = posY;
      mc.loop = false;
      addChild(mc);
      Starling.juggler.add(mc);
    }
    
    private function onMovieClipEnd(e:Event):void
    {
      removeChild(e.target as MovieClip);
      Starling.juggler.remove(e.target as MovieClip);
    }
    
    private function startNextPhase(e:TimerEvent):void
    {
      _timer.removeEventListener(TimerEvent.TIMER,startNextPhase); 
      _player.nextLevel();
      _text.text = "Phase: "+_player.mLevel;
    }
    
    private function onKeyUp(e:KeyboardEvent):void
    {
      //trace("keyup", e.keyCode, e.charCode, e.keyLocation);
      switch(e.keyCode)
      {
        case 87://w(up)
          _player.mIsMovingUp = false;
          break;
        case 83://s(down)
          _player.mIsMovingDown = false;
          break;
        case 65://a(left)
          _player.mIsMovingLeft = false;
          break;
        case 68://d(right)
          _player.mIsMovingRight = false;
          break;
        default:
          break;
      }
    }
    
    private function onKeyDown(e:KeyboardEvent):void
    {
      //trace("keydown", e.keyCode, e.charCode, e.keyLocation);
      switch(e.keyCode)
      {
        case 87://w(up)
          _player.mIsMovingUp = true;
          _player.mIsMovingDown = false;
          break;
        case 83://s(down)
          _player.mIsMovingDown = true;
          _player.mIsMovingUp = false;
          break;
        case 65://a(left)
          _player.mIsMovingLeft = true;
          _player.mIsMovingRight = false;
          break;
        case 68://d(right)
          _player.mIsMovingRight = true;
          _player.mIsMovingLeft = false;
          break;
        default:
          break;
      }
    }
    
    private function playerMove():void
    {
      if(!_player.mIsMovingDown && !_player.mIsMovingLeft && !_player.mIsMovingRight && !_player.mIsMovingUp) return;
      // check if player can move
      var tx:Number = (_player.mIsMovingLeft)?-_player.moveVelocityX:(_player.mIsMovingRight)?_player.moveVelocityX:0;
      var ty:Number = (_player.mIsMovingUp)?-_player.moveVelocityY:(_player.mIsMovingDown)?_player.moveVelocityY:0;
      if(tx!=0 && ty!=0){
        tx *= 0.71;
        ty *= 0.71;
      }
      if(_player.mMC.x + tx >= 0 && _player.mMC.x + tx <= ghostHunter.stage.stageWidth
        && _player.mMC.y + ty >= 0 && _player.mMC.y + ty <= ghostHunter.stage.stageHeight){
        _player.mMC.x += tx;
        _player.mMC.y += ty;
      }
      
    }
  }
}