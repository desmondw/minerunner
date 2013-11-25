package  
{
	import org.flixel.*;
	import flash.utils.Timer;
	
	public class GUI 
	{
		public static var group:FlxGroup = new FlxGroup();
		
		//GUI information
		public static var time:Timer;
		
		//info bar
		private static var floorMineText:FlxText;
		private static var timeText:FlxText;
		
		//game over screen
		public static var gameOverSplash:FlxSprite = new FlxSprite(0, 0, Assets.gameOverSplash);
		
		public static function intialize():void
		{
			time = new Timer(100); //tracks to the 1/10th second
			time.start();
			
			/*
			 * info bar
			*/
			//floor and mine count text
			floorMineText = new FlxText(0, -3, Game.SCREEN_WIDTH, "Floor:" + 0 + "  Mines:" + 0);
			floorMineText.size = PlayState.tileSize;
			group.add(floorMineText);
			
			//time text
			timeText = new FlxText(Game.SCREEN_WIDTH - (PlayState.tileSize * 7), -3, Game.SCREEN_WIDTH, getTime());
			timeText.size = PlayState.tileSize;
			group.add(timeText);
			
			/*
			 * game over screen
			*/
			gameOverSplash.visible = false;
			group.add(gameOverSplash);
		}
		
		public static function update():void 
		{
			timeText.text = getTime();
			floorMineText.text = "Floor:" + Level.floor + "  Mines:" + Level.numMines;
		}
		
		private static function getTime():String 
		{
			var theTime:uint = time.currentCount; //in ms
			
			var hours:uint = Math.floor(theTime / 36000);
			theTime -= hours * 36000;
			
			var minutes:uint = Math.floor(theTime / 600);
			theTime -= minutes * 600;
			
			var seconds:uint = Math.floor(theTime / 10);
			theTime -= seconds * 10;
			
			var ms:uint = theTime;
			
			
			
			return timeAddZero(hours) + ":" + timeAddZero(minutes) + ":" + timeAddZero(seconds) + ":" + ms;
		}
		
		private static function timeAddZero(num:uint):String
		{
			if (num > 9)
				return new String(num);
			else
				return new String("0" + num);
		}
	}
}