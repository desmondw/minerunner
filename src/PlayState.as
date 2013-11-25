package
{
	import org.flixel.*;
	import flash.ui.Mouse;
	
	public class PlayState extends FlxState
	{
		//classes
		public var level:Level;
		
		//static variables
		public static var tileSize:int = 32;
		
		override public function create():void
		{
			FlxG.fade(0xffffffff, 1, true); //fades in from white on start
			
			level = new Level(20, 14, 0, tileSize);
			level.newGame();
			
			GUI.intialize();
			
			add(level.group);
			add(GUI.group);
		}
		
		override public function update():void
		{
			super.update();
			Mouse.show();
			
			GUI.update();
			
			if (level.gameOver)
			{
				//wait for player to click, then start new game
				if (FlxG.mouse.justPressed())
				{
					GUI.gameOverSplash.visible = false;
					GUI.time.reset();
					GUI.time.start();
					level.newGame();
				}
			}
			else
				level.update();
		}
	}
}