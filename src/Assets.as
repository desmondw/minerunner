package  
{
	public class Assets 
	{
		[Embed(source = "../bin/assets/startScreen.png")] public static var startScreen:Class;
		[Embed(source = "../bin/assets/controlsScreen.png")] public static var controlsScreen:Class;
		[Embed(source = "../bin/assets/gameOverSplash.png")] public static var gameOverSplash:Class;
		
		[Embed(source = "../bin/assets/player.png")] public static var player:Class;
		[Embed(source = "../bin/assets/map.png")] public static var map:Class;
		[Embed(source = "../bin/assets/fog.png")] public static var fog:Class;
		
		public function Assets() 
		{
			
		}
	}
}