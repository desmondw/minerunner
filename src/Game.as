package
{
	import org.flixel.*;
	import flash.events.Event;
 
	public class Game extends FlxGame
	{
		public static var SCREEN_WIDTH:uint = 640;
		public static var SCREEN_HEIGHT:uint = 480;
		public static var ZOOM:uint = 1;
		
		override public function Game(main:Main)
		{
			super(SCREEN_WIDTH, SCREEN_HEIGHT, StartState, ZOOM);
		}
		
		override protected function onFocusLost(FlashEvent:Event = null):void
		{
			
		}
	}
}