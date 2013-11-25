package  
{
	import org.flixel.*;
	
	public class Level
	{
		//map tiles
		public static const MAP_ONE:uint = 1;
		public static const MAP_TWO:uint = 2;
		public static const MAP_THREE:uint = 3;
		public static const MAP_FOUR:uint = 4;
		public static const MAP_FIVE:uint = 5;
		public static const MAP_SIX:uint = 6;
		public static const MAP_SEVEN:uint = 7;
		public static const MAP_EIGHT:uint = 8;
		public static const MAP_EMPTY:uint = 9;
		public static const MAP_MINE:uint = 10;
		public static const MAP_ENTRANCE:uint = 11;
		public static const MAP_EXIT:uint = 12;
		
		//fog tiles
		public static const FOG_CLEAR:uint = 0;
		public static const FOG_PRECLEAR:uint = 1;
		public static const FOG_FOG:uint = 2;
		public static const FOG_FLAG:uint = 3;
		
		
		
		public var group:FlxGroup = new FlxGroup();
		
		//objects
		public var map:FlxTilemap;
		public var fog:FlxTilemap;
		public var player:FlxSprite;
		
		//size and positioning
		public var widthInTiles:uint;
		public var heightInTiles:uint;
		public var levelOffsetX:int;
		public var levelOffsetY:int;
		
		//game info
		public static var numMines:uint;
		public static var floor:uint;
		
		//visual changes
		public var gameOver:Boolean;
		private var fogOn:Boolean;
		private var fogArray:Array;
		
		public function Level(widthInTiles:uint, heightInTiles:uint, levelOffsetX:int, levelOffsetY:int)
		{
			this.widthInTiles = widthInTiles;
			this.heightInTiles = heightInTiles;
			this.levelOffsetX = levelOffsetX;
			this.levelOffsetY = levelOffsetY;
			
			initialize();
		}
		
		private function initialize():void
		{
			//map
			map = new FlxTilemap();
			map.x = levelOffsetX;
			map.y = levelOffsetY;
			group.add(map);
			
			//fog
			fog = new FlxTilemap();
			fog.x = levelOffsetX;
			fog.y = levelOffsetY;
			group.add(fog);
			
			//player
			player = new FlxSprite();
			player.loadGraphic(Assets.player, true);
			player.addAnimation("alive", new Array(1, 0), 2);
			player.addAnimation("dead", new Array(2, 2), 2);
			group.add(player);
			
			FlxG.state.add(group);
		}
		
		public function newGame():void 
		{
			//variable reset
			gameOver = false;
			player.play("alive");
			fogOn = true;
			floor = 0;
			numMines = 38;
			
			//generate first floor
			newFloor();
		}
		
		public function newFloor():void 
		{
			//update floor info
			floor++;
			numMines += 2;
			
			//generate new floor
			newMap();
			newFog();
			
			//reset player
			player.x = levelOffsetX;
			player.y = levelOffsetY;
		}
		
		private function newMap():void 
		{
			//set up entrance and exit
			var data:Array = new Array(widthInTiles * heightInTiles);
			
			for (var i:uint = 0; i < data.length; i++)
				data[i] = MAP_EMPTY;
				
			data[0] = MAP_ENTRANCE; //entrance
			data[widthInTiles * heightInTiles - 1] = MAP_EXIT; //exit
				
			//add mines (not near entrance or exit)
			for (var i:uint = 0; i < numMines; i++)
			{
				var rand:int = Math.floor(Math.random() * (widthInTiles * heightInTiles));
				
				//test if usable tile - if its near an entrance or exit or already used by a mine
				if (data[rand] != MAP_EMPTY || rand == 1 || rand == widthInTiles || rand == widthInTiles + 1 || rand == widthInTiles * heightInTiles - 2 || rand == widthInTiles * (heightInTiles - 1) - 1 || rand == widthInTiles * (heightInTiles - 1) - 2)
					i--; //run the loop iteration again for placing this mine
				else
					data[rand] = MAP_MINE; //place mine
			}
			
			//calculate and add numbered tiles
			for (var i:uint = 0; i < data.length; i++)
			{
				if (data[i] == MAP_EMPTY)
					data[i] = placeNumberedTile(data, i);
			}
				
			map.loadMap(FlxTilemap.arrayToCSV(data, widthInTiles), Assets.map, PlayState.tileSize, PlayState.tileSize);
			map.setTileProperties(0, FlxObject.NONE);
			map.setTileProperties(MAP_ONE, FlxObject.NONE);
			map.setTileProperties(MAP_TWO, FlxObject.NONE);
			map.setTileProperties(MAP_THREE, FlxObject.NONE);
			map.setTileProperties(MAP_FOUR, FlxObject.NONE);
			map.setTileProperties(MAP_FIVE, FlxObject.NONE);
			map.setTileProperties(MAP_SIX, FlxObject.NONE);
			map.setTileProperties(MAP_SEVEN, FlxObject.NONE);
			map.setTileProperties(MAP_EIGHT, FlxObject.NONE);
			map.setTileProperties(MAP_MINE, FlxObject.ANY);
			map.setTileProperties(MAP_EMPTY, FlxObject.NONE);
			map.setTileProperties(MAP_ENTRANCE, FlxObject.NONE);
			map.setTileProperties(MAP_EXIT, FlxObject.NONE);
			
			//if there is no path from the mines, create new minefield
			if (!pathfindMines())
				newMap();
		}
		
		private function placeNumberedTile(data:Array, index:uint):uint 
		{
			var count:uint = 0;
			
			//if tile exists in the array, and is a mine and is not wrapping the grid, add it to the count
			if (index - widthInTiles - 1 >= 0 && data[index - widthInTiles - 1] == MAP_MINE && (index - widthInTiles - 1 + 1) % 20 != 0) //top-left
				count++;
			if (index - widthInTiles >= 0 && data[index - widthInTiles] == MAP_MINE) //top
				count++;
			if (index - widthInTiles + 1 >= 0 && data[index - widthInTiles + 1] == MAP_MINE && (index - widthInTiles + 1) % 20 != 0) //top-right
				count++;
			if (index - 1 >= 0 && data[index - 1] == MAP_MINE && (index - 1 + 1) % 20 != 0) //left
				count++;
			if (index + 1 >= 0 && data[index + 1] == MAP_MINE && (index + 1 )% 20 != 0) //right
				count++;
			if (index + widthInTiles - 1 >= 0 && data[index + widthInTiles - 1] == MAP_MINE && (index + widthInTiles - 1 + 1) % 20 != 0) //bottom-left
				count++;
			if (index + widthInTiles >= 0 && data[index + widthInTiles] == MAP_MINE) //bottom
				count++;
			if (index + widthInTiles + 1 >= 0 && data[index + widthInTiles + 1] == MAP_MINE && (index + widthInTiles + 1) % 20 != 0) //bottom-right
				count++;
			
			//if there are no mines, return the default tile
			if (count == 0)
				count = MAP_EMPTY;
			
			return count;
		}
		
		private function pathfindMines():Boolean 
		{
			var startPt:FlxPoint = new FlxPoint(levelOffsetX, levelOffsetY); //entrance
			var endPt:FlxPoint = new FlxPoint(levelOffsetX + (widthInTiles - 1) * PlayState.tileSize, levelOffsetY + (heightInTiles - 1) * PlayState.tileSize); //exit
			var path:FlxPath = map.findPath(startPt, endPt);
			
			if (path != null)
				return true; //there is a path
			return false; //there is no path
		}
		
		private function newFog():void 
		{
			var data:Array = new Array(widthInTiles * heightInTiles);
			
			for (var i:uint = 0; i < data.length; i++)
				data[i] = FOG_FOG;
			
			//entrance
			data[0] = FOG_PRECLEAR;
			data[1] = FOG_PRECLEAR;
			data[widthInTiles] = FOG_PRECLEAR;
			data[widthInTiles + 1] = FOG_PRECLEAR;
			
			//exit
			data[widthInTiles * heightInTiles - 1] = FOG_PRECLEAR;
			data[widthInTiles * heightInTiles - 2] = FOG_PRECLEAR;
			data[widthInTiles * heightInTiles - widthInTiles - 1] = FOG_PRECLEAR;
			data[widthInTiles * heightInTiles - widthInTiles - 2] = FOG_PRECLEAR;
				
			fog.loadMap(FlxTilemap.arrayToCSV(data, widthInTiles), Assets.fog, PlayState.tileSize, PlayState.tileSize);
			fog.setTileProperties(FOG_CLEAR, FlxObject.NONE);
			fog.setTileProperties(FOG_FOG, FlxObject.ANY);
			fog.setTileProperties(FOG_FLAG, FlxObject.ANY);
			fog.setTileProperties(FOG_PRECLEAR, FlxObject.NONE);
		}
		
		public function update():void
		{
			if (FlxG.mouse.justPressed())
				mouseClick();
		}
		
		private function mouseClick():void 
		{
			var tileX:int = (FlxG.mouse.getScreenPosition().x - levelOffsetX) / PlayState.tileSize;
			var tileY:int = (FlxG.mouse.getScreenPosition().y - levelOffsetY) / PlayState.tileSize;
			
			//if clicked on the map
			if (FlxG.mouse.getScreenPosition().x - levelOffsetX > 0 && FlxG.mouse.getScreenPosition().x - levelOffsetX < Game.SCREEN_WIDTH - levelOffsetX && FlxG.mouse.getScreenPosition().y - levelOffsetY > 0 && FlxG.mouse.getScreenPosition().y - levelOffsetY < Game.SCREEN_HEIGHT - levelOffsetY)
			{
				if (FlxG.keys.SHIFT) //if holding shift, check to set flag
				{
					if (fog.getTile(tileX, tileY) == FOG_FOG) //if tile has fog and no flag
						fog.setTile(tileX, tileY, FOG_FLAG);
					else if  (fog.getTile(tileX, tileY) == FOG_FLAG) //if tile has fog and flag
						fog.setTile(tileX, tileY, FOG_FOG);
				}
				else //else check to move
				{
					//if clicked tile is accessible and not a flag
					if (fog.getTile(tileX, tileY) != FOG_FLAG && tileAdjacentCleared(tileX, tileY))
						movePlayer(tileX * PlayState.tileSize + levelOffsetX, tileY * PlayState.tileSize + levelOffsetY);
				}
			}
		}
		
		//tests if tile is adjacent to a cleared tile
		private function tileAdjacentCleared(tileX:uint, tileY:uint):Boolean
		{
			//uses pathfinding to avoid skipping to end
			
			//if cleared
			if (tileX - 1 >= 0 && tileY - 1 >= 0 && movePathfind(tileX - 1, tileY - 1)) //top-left
				return true;
			if (tileY - 1 >= 0 && movePathfind(tileX, tileY - 1)) //top
				return true;
			if (tileX + 1 < widthInTiles && tileY - 1 >= 0 && movePathfind(tileX + 1, tileY - 1)) //top-right
				return true;
			if (tileX - 1 >= 0 && movePathfind(tileX - 1, tileY)) //left
				return true;
			if (tileX + 1 < widthInTiles && movePathfind(tileX + 1, tileY)) //right
				return true;
			if (tileX - 1 >= 0 && tileY + 1 < heightInTiles && movePathfind(tileX - 1, tileY + 1)) //bottom-left
				return true;
			if (tileY + 1 < heightInTiles && movePathfind(tileX, tileY + 1)) //bottom
				return true;
			if (tileX + 1 < widthInTiles && tileY + 1 < heightInTiles && movePathfind(tileX + 1, tileY + 1)) //bottom-right
				return true;
			
			return false;
		}
		
		private function movePathfind(tileX:uint, tileY:uint):Boolean 
		{
			var playerPt:FlxPoint = new FlxPoint(player.x, player.y);
			var endPt:FlxPoint = new FlxPoint(tileX * PlayState.tileSize + levelOffsetX, tileY * PlayState.tileSize + levelOffsetY);
			var path:FlxPath = fog.findPath(playerPt, endPt, true, false);// , false);
			
			if (path != null)
				return true;
			return false;
		}
		
		private function movePlayer(x:uint, y:uint):void 
		{
			player.x = x;
			player.y = y;
			
			var tileX:uint = (x - levelOffsetX) / PlayState.tileSize;
			var tileY:uint = (y - levelOffsetY) / PlayState.tileSize;
			var newTile:uint = map.getTile(tileX, tileY);
			
			if (newTile == MAP_MINE) //if mine
				showGameOver();
			else if (newTile == MAP_EXIT) //if exit
				newFloor();
			else //if safe
			{
				if (newTile == MAP_EMPTY) //if an empty tile
					showClearTile(tileX, tileY); //clear fog from nearby empty tiles
				else //a numbered tile
					fog.setTile(tileX, tileY, FOG_CLEAR); //clear fog from tile
			}
		}
		
		//recursively clears empty tiles
		private function showClearTile(tileX:uint, tileY:uint):void
		{
			fog.setTile(tileX, tileY, FOG_CLEAR); //clear fog from tile
			
			//check each surrounding tile. if numbered, unfog. if clear/default, recursion.
			if (tileX - 1 >= 0 && tileY - 1 >= 0 && fog.getTile(tileX - 1, tileY - 1) != FOG_CLEAR) //top-left
			{
				if (map.getTile(tileX - 1, tileY - 1) == MAP_EMPTY)
					showClearTile(tileX - 1, tileY - 1);
				else
					fog.setTile(tileX - 1, tileY - 1, FOG_CLEAR);
			}
			if (tileY - 1 >= 0 && fog.getTile(tileX, tileY - 1) != FOG_CLEAR) //top
			{
				if (map.getTile(tileX, tileY - 1) == MAP_EMPTY)
					showClearTile(tileX, tileY - 1);
				else
					fog.setTile(tileX, tileY - 1, FOG_CLEAR);
			}
			if (tileX + 1 < widthInTiles && tileY - 1 >= 0 && fog.getTile(tileX + 1, tileY - 1) != FOG_CLEAR) //top-right
			{
				if (map.getTile(tileX + 1, tileY - 1) == MAP_EMPTY)
					showClearTile(tileX + 1, tileY - 1);
				else
					fog.setTile(tileX + 1, tileY - 1, FOG_CLEAR);
			}
			if (tileX - 1 >= 0 && fog.getTile(tileX - 1, tileY) != FOG_CLEAR) //left
			{
				if (map.getTile(tileX - 1, tileY) == MAP_EMPTY)
					showClearTile(tileX - 1, tileY);
				else
					fog.setTile(tileX - 1, tileY, FOG_CLEAR);
			}
			if (tileX + 1 < widthInTiles && fog.getTile(tileX + 1, tileY) != FOG_CLEAR) //right
			{
				if (map.getTile(tileX + 1, tileY) == MAP_EMPTY)
					showClearTile(tileX + 1, tileY);
				else
					fog.setTile(tileX + 1, tileY, FOG_CLEAR);
			}
			if (tileX - 1 >= 0 && tileY + 1 < heightInTiles && fog.getTile(tileX - 1, tileY + 1) != FOG_CLEAR) //bottom-left
			{
				if (map.getTile(tileX - 1, tileY + 1) == MAP_EMPTY)
					showClearTile(tileX - 1, tileY + 1);
				else
					fog.setTile(tileX - 1, tileY + 1, FOG_CLEAR);
			}
			if (tileY + 1 < heightInTiles && fog.getTile(tileX, tileY + 1) != FOG_CLEAR) //bottom
			{
				if (map.getTile(tileX, tileY + 1) == MAP_EMPTY)
					showClearTile(tileX, tileY + 1);
				else
					fog.setTile(tileX, tileY + 1, FOG_CLEAR);
			}
			if (tileX + 1 < widthInTiles && tileY + 1 < heightInTiles && fog.getTile(tileX + 1, tileY + 1) != FOG_CLEAR) //bottom-right
			{
				if (map.getTile(tileX + 1, tileY + 1) == MAP_EMPTY)
					showClearTile(tileX + 1, tileY + 1);
				else
					fog.setTile(tileX + 1, tileY + 1, FOG_CLEAR);
			}
		}
		
		private function showGameOver():void 
		{
			player.play("dead");
			fogOn = true;
			toggleFog();
			gameOver = true;
			GUI.time.stop();
			
			//splash game over screen
			GUI.gameOverSplash.visible = true;
		}
		
		//shown on game over and used for debugging
		public function toggleFog():void 
		{
			if (fogOn)
			{
				fogArray = fog.getData();
				
				var data:Array = new Array(widthInTiles * heightInTiles);
				for (var i:uint = 0; i < data.length; i++)
					data[i] = FOG_CLEAR;
				fog.loadMap(FlxTilemap.arrayToCSV(data, widthInTiles), Assets.fog, PlayState.tileSize, PlayState.tileSize);
				fog.setDirty();
			}
			else
			{
				fog.loadMap(FlxTilemap.arrayToCSV(fogArray, widthInTiles), Assets.fog, PlayState.tileSize, PlayState.tileSize);
				fog.setDirty();
			}
			
			fogOn = !fogOn;
		}
	}
}
