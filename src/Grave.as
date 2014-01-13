package
{
  import starling.display.Image;
  import starling.textures.Texture;
  
  public class Grave extends Image
  {
    public var hp:int; 
    
    public function Grave(texture:Texture,hp)
    {
      super(texture);
      this.hp = hp;
    }
    
    public function takedamage(damage=1):void
    {
      this.hp -= damage;
    }
    
    public function isDead():Boolean
    {
      if(this.hp <= 0) return true else return false;
    }
  }
}