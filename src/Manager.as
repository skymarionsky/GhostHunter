package
{
  import starling.display.MovieClip;
  import starling.display.Sprite;
  import starling.textures.Texture;
  import starling.textures.TextureAtlas;

  public class Manager
  {
    [Embed(source="../media/player.xml", mimeType="application/octet-stream")]
    static private const _atlasXML:Class;
    
    [Embed(source="../media/player.png"]
    static private const _atlasTexture:Class;
    
    private var _atlas:TextureAtlas;
    
    public const moveVelocityX:Number = 300/ghostHunter.FPS;
    public const moveVelocityY:Number = 300/ghostHunter.FPS;
    public const shootInterval:Number = 0.25;//sec
    public const defaultGhostSpeed:Number = 50/ghostHunter.FPS;
    
    public var mSprite:Sprite;
    public var mMC:MovieClip;
    public var mIsMovingUp:Boolean = false;
    public var mIsMovingDown:Boolean = false;
    public var mIsMovingLeft:Boolean = false;
    public var mIsMovingRight:Boolean = false;
    public var mCurrentVelocityX:Number = 0;
    public var mCurrentVelocityY:Number = 0;
    public var mShotSpeed:Number = 1000/ghostHunter.FPS;
    public var mIsShooting:Boolean = false;
    public var mCurrentMousePosX:Number;
    public var mCurrentMousePosY:Number;
    public var mCntShotInterval:Number = shootInterval;
    public var mShotHitSizeX:int = 4;
    public var mShotHitSizeY:int = 4;
    public var mLevel:int = 1;
    public var mKillCnt:int = 0;
    public var mGhostCnt:int = 0;
    public var mStopAddingGhost:Boolean = false;
    public var mDamageEffectRemainFrame:int = 0;
    public var mLife:int = 5;
    
    public function Manager()
    {
      // init texture atlas
      var texture:Texture = Texture.fromBitmap(new _atlasTexture());
      var xml:XML = XML(new _atlasXML());
      _atlas = new TextureAtlas(texture, xml);
      
      // create player
      mMC = new MovieClip(_atlas.getTextures("player"), 2);
      mMC.x = 400;
      mMC.y = 300;
      mMC.alignPivot();
    }
    
    public function nextLevel():void
    {
      mLevel++;
      mStopAddingGhost = false;
      mGhostCnt = 0;
    }
    
    
    public function getShotTexture():Texture
    {
      return _atlas.getTexture("effects");      
    }
    
    public function getTileTexture():Texture
    {
      return _atlas.getTexture("tiles");
    }
    
    public function getGraveTexture():Texture
    {
      return _atlas.getTexture("grave");
    }
    
    public function getGhostMovieClip():Vector.<Texture>
    {
      return _atlas.getTextures("ghost");
    }
    
    public function getExplosionMovieClip():Vector.<Texture>
    {
      return _atlas.getTextures("explosion");
    }
    
    public function getLifeTexture():Texture
    {
      return _atlas.getTexture("life");
    }
    
    public function getGameOverTexture():Texture
    {
      return _atlas.getTexture("gameover");
    }
    
    public function ghostReachedToGrave():void
    {
      mDamageEffectRemainFrame = ghostHunter.FPS/2;
      mLife--;
      trace("life =",mLife);
    }
    
  }
}