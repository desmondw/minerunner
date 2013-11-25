package  
{
	import org.flixel.*;
	import flash.ui.Mouse;
	
	public class StartState extends FlxState
	{
		private var splash:FlxSprite = new FlxSprite(0, 0, Assets.startScreen);
		
		public function StartState() 
		{
			add(splash);
		}
		
		override public function create():void 
		{
			FlxG.fade(0x00ffffff, 1, true);
		}
		
		override public function update():void 
		{
			Mouse.show();
			
			if (FlxG.mouse.justPressed())
				FlxG.fade(0xffffffff, 1, false, nextState);
		}
		
		private function nextState():void 
		{
			FlxG.switchState(new ControlsState());
		}
	}
}