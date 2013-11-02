package  codeCraft.utils {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class WordSearch extends MovieClip {
		// constants
		public static const puzzleSize:uint = 15;
		public static const spacing:Number = 24;
		public static const outlineSize:Number = 20;
		public static const offset:Point = new Point(15,15);
		public static const letterFormat:TextFormat = new TextFormat("Arial",18,0x000000,true,false,false,null,null,TextFormatAlign.CENTER);
		
		// words and grid
		private var wordList:Array;
		private var usedWords:Array;
		private var grid:Array;
		
		// game state
		private var dragMode:String;
		private var startPoint:Point;
		public var endPoint:Point;
		private var numFound:int;
		
		// sprites
		private var gameSprite:Sprite;
		private var outlineSprite:Sprite;
		private var oldOutlineSprite:Sprite;
		private var letterSprites:Sprite;
		private var wordsSprite:Sprite;
		
		
		public function startWordSearch():void {
			// word list
			wordList = ("Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune,Pluto").split(",");
			
			// set up the sprites
			gameSprite = new Sprite();
			addChild(gameSprite);
			
			oldOutlineSprite = new Sprite();
			gameSprite.addChild(oldOutlineSprite);
			
			outlineSprite = new Sprite();
			gameSprite.addChild(outlineSprite);
			
			letterSprites = new Sprite();
			gameSprite.addChild(letterSprites);
			
			wordsSprite = new Sprite();
			gameSprite.addChild(wordsSprite);
			
			// array of letters
			var letters:Array = placeLetters();
			
			// array of sprites
			grid = new Array();
			for(var x:int=0;x<puzzleSize;x++) {
				grid[x] = new Array();
				for(var y:int=0;y<puzzleSize;y++) {
					
					// create new letter field and sprite
					var newLetter:TextField = new TextField();
					newLetter.defaultTextFormat = letterFormat;
					newLetter.x = x*spacing + offset.x;
					newLetter.y = y*spacing + offset.y;
					newLetter.width = spacing;
					newLetter.height = spacing;
					newLetter.text = letters[x][y];
					newLetter.selectable = false;
					var newLetterSprite:Sprite = new Sprite();
					newLetterSprite.addChild(newLetter);
					letterSprites.addChild(newLetterSprite);
					grid[x][y] = newLetterSprite;
					
					// add event listeners
					newLetterSprite.addEventListener(MouseEvent.MOUSE_DOWN, clickLetter);
					newLetterSprite.addEventListener(MouseEvent.MOUSE_OVER, overLetter);
				}
			}
			
			// stage listener
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
			
			// create word list fields and sprites
			for(var i:int=0;i<usedWords.length;i++) {
				var newWord:TextField = new TextField();
				newWord.defaultTextFormat = letterFormat;
				newWord.x = 400;
				newWord.y = i*spacing+offset.y;
				newWord.width = 140;
				newWord.height = spacing;
				newWord.text = usedWords[i];
				newWord.selectable = false;
				wordsSprite.addChild(newWord);
			}
			
			// set game state
			dragMode = "none";
			numFound = 0;
		}
		
		// place the words in a grid of letters
		public function placeLetters():Array {
			
			// create empty grid
			var letters:Array = new Array();
			for(var x:int=0;x<puzzleSize;x++) {
				letters[x] = new Array();
				for(var y:int=0;y<puzzleSize;y++) {
					letters[x][y] = "*";
				}
			}
			
			// make copy of word list
			var wordListCopy:Array = wordList.concat();
			usedWords = new Array();
			
			// make 1000 attempts to add words
			var repeatTimes:int = 1000;
			repeatLoop:while (wordListCopy.length > 0) {
				if (repeatTimes-- <= 0) break;
				
				// pick a random word, location and direction
				var wordNum:int = Math.floor(Math.random()*wordListCopy.length);
				var word:String = wordListCopy[wordNum].toUpperCase();
				x = Math.floor(Math.random()*puzzleSize);
				y = Math.floor(Math.random()*puzzleSize);
				var dx:int = Math.floor(Math.random()*3)-1;
				var dy:int = Math.floor(Math.random()*3)-1;
				if ((dx == 0) && (dy == 0)) continue repeatLoop;
				
				// check each spot in grid to see if word fits
				letterLoop:for (var j:int=0;j<word.length;j++) {
					if ((x+dx*j < 0) || (y+dy*j < 0) || (x+dx*j >= puzzleSize) || (y+dy*j >= puzzleSize)) continue repeatLoop;
					var thisLetter:String = letters[x+dx*j][y+dy*j];
					if ((thisLetter != "*") && (thisLetter != word.charAt(j))) continue repeatLoop;
				}
				
				// insert word into grid
				insertLoop:for (j=0;j<word.length;j++) {
					letters[x+dx*j][y+dy*j] = word.charAt(j);
				}
				
				// remove word from list
				wordListCopy.splice(wordNum,1);
				usedWords.push(word);
			}
			
			// fill rest of grid with random letters
			for(x=0;x<puzzleSize;x++) {
				for(y=0;y<puzzleSize;y++) {
					if (letters[x][y] == "*") {
						letters[x][y] = String.fromCharCode(65+Math.floor(Math.random()*26));
					}
				}
			}
			
			return letters;
		}
		
		// player clicks down on a letter to start
		public function clickLetter(event:MouseEvent):void {
			var letter:String = event.currentTarget.getChildAt(0).text;
			startPoint = findGridPoint(event.currentTarget);
			dragMode = "drag";
		}
		
		// player dragging over letters
		public function overLetter(event:MouseEvent):void {
			if (dragMode == "drag") {
				endPoint = findGridPoint(event.currentTarget);
				
				// if valid range, show outline
				outlineSprite.graphics.clear();
				if (isValidRange(startPoint,endPoint)) {
					drawOutline(outlineSprite,startPoint,endPoint,0xFF0000);
				}
			}
		}
		
		// mouse released
		public function mouseRelease(event:MouseEvent):void {
			if (dragMode == "drag") {
				dragMode = "none";
				outlineSprite.graphics.clear();
				
				// get word and check it
				if (isValidRange(startPoint,endPoint)) {
					var word:String = getSelectedWord();
					checkWord(word);
				}
			}
		}
		
		// when a letter is clicked, find and return the x and y location
		public function findGridPoint(letterSprite:Object):Point {
			
			// loop through all sprites and find this one
			for(var x:int=0;x<puzzleSize;x++) {
				for(var y:int=0;y<puzzleSize;y++) {
					if (grid[x][y] == letterSprite) {
						return new Point(x,y);
					}
				}
			}
			return null;
		}
		
		// determine if range is in the same row, column, or a 45 degree diagonal
		public function isValidRange(p1:Point ,p2:Point):Boolean {
			if (p1.x == p2.x)
			{
				return true;
			}
			if (p1.y == p2.y)
			{
				return true;
			}
			if (Math.abs(p2.x-p1.x) == Math.abs(p2.y-p1.y))
			{
				return true;
			}
			return false;
		}
		
		// draw a thick line from one location to another
		public function drawOutline(s:Sprite,p1: Point,p2:Point,c:Number):void {
			var off:Point = new Point(offset.x+spacing/2, offset.y+spacing/2);
			s.graphics.lineStyle(outlineSize,c);
			s.graphics.moveTo(p1.x*spacing+off.x ,p1.y*spacing+off.y);
			s.graphics.lineTo(p2.x*spacing+off.x ,p2.y*spacing+off.y);
		}
		
		// find selected letters based on start and end points
		public function getSelectedWord():String {
			
			// determine dx and dy of selection, and word length
			var dx:Number = endPoint.x-startPoint.x;
			var dy:Number = endPoint.y-startPoint.y;
			var wordLength:Number = Math.max(Math.abs(dx),Math.abs(dy))+1;
			
			// get each character of selection
			var word:String = "";
			for(var i:int=0;i<wordLength;i++) {
				var x:Number = startPoint.x;
				if (dx < 0) x -= i;
				if (dx > 0) x += i;
				var y:Number = startPoint.y;
				if (dy < 0) y -= i;
				if (dy > 0) y += i;
				word += grid[x][y].getChildAt(0).text;
			}
			return word;
		}
		
		// check word against word list
		public function checkWord(word:String):void {
			
			// loop through words
			for(var i:int=0;i<usedWords.length;i++) {
				
				// compare word
				if (word == usedWords[i].toUpperCase()) {
					foundWord(word);
				}
				
				// compare word reversed
				var reverseWord:String = word.split("").reverse().join("");
				if (reverseWord == usedWords[i].toUpperCase()) {
					foundWord(reverseWord);
				}
			}
		}
		
		// word found, remove from list, make outline permanent
		public function foundWord(word:String):void {
			
			// draw outline in permanent sprite
			drawOutline(oldOutlineSprite,startPoint,endPoint,0xFF9999);
			
			// find text field and set it to gray
			for(var i:int=0;i<wordsSprite.numChildren;i++) {
				if (TextField(wordsSprite.getChildAt(i)).text.toUpperCase() == word) {
					TextField(wordsSprite.getChildAt(i)).textColor = 0xCCCCCC;
				}
			}
			
			// see if all have been found
			numFound++;
			if (numFound == usedWords.length) {
				endGame();
			}
		}
		
		public function endGame():void {
			gotoAndStop("gameover");
		}
		
		public function cleanUp():void {
			removeChild(gameSprite);
			gameSprite = null;
			grid = null;
		}
		
		
	}
	
}