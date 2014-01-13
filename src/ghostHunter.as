package
{
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  
  import starling.core.Starling;
  
  [SWF(frameRate=60,backgroundColor="#5588FF",width=800,height=600)]
  public class ghostHunter extends Sprite
  {
    private var _starling:Starling;
    public static var stage:Stage;
    public static var FPS:int = 60;
    
    public function ghostHunter()
    {
      if(stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void
    {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      removeEventListener(Event.ADDED_TO_STAGE, init);
      ghostHunter.stage = stage;
      
      // initialize starling
      _starling = new Starling(Main, stage);
      _starling.showStats = true;
      _starling.showStatsAt("left","top");
      _starling.start();
    }
  }
}