package
{
  import starling.display.MovieClip;
  import starling.textures.Texture;
  
  public class Ghost extends MovieClip
  {
    public var mDirection:Number;
    public var mSpeed:Number;
    public var mHitSizeX:int;
    public var mHitSizeY:int;
    public var mIsBoss:Boolean = false;
    public var mIsVoid:Boolean = false;
    
    private var _targetX:int;
    private var _targetY:int;
    
    public function Ghost(textures:Vector.<Texture>, fps:Number=2)
    {
      super(textures, fps);
      mHitSizeX = width;
      mHitSizeY = height;
    }
    
    public function init(startX,startY,targetX,targetY):void
    {
      mDirection = Math.atan2(targetY-startY,targetX-startX);
      this.x = startX;
      this.y = startY;
      _targetX = targetX;
      _targetY = targetY;
    }
    
    /**
     * return true: moved , false: reached to target
     */
    public function updateMove():Boolean
    {
      if(Math.abs(_targetX - this.x) < mHitSizeX && Math.abs(_targetY - this.y) < mHitSizeY){
        // reached to target grave
        return false;
      }
      this.x += Math.cos(mDirection) * mSpeed;
      this.y += Math.sin(mDirection) * mSpeed;
      return true;
    }
  }
}