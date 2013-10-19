package codeCraft.debug{
	
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.describeType;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	
	import net.hires.debug.Stats;
	
	public class Debug {
		
		private static var printObject:Array = new Array();
		
		public static var stats:Stats;
		public static var statsAdded:Boolean = false;
		private static var frameCurrent:int = 0;
		
		public function initializeMonster():void{
			MonsterDebugger.initialize(this);
		}
		
		public static function initialize ():void{
			stats = new Stats();
			CodeCraft.addChild(stats);
			statsAdded = true;
			Events.listener(CodeCraft.getMainObject(),Event.ENTER_FRAME, detectChangeFrameMainObject);
		}
		
		public static function stop():void{
			CodeCraft.removeChild(stats);
			statsAdded = false;
			Events.removeListener(CodeCraft.getMainObject(),Event.ENTER_FRAME, detectChangeFrameMainObject);
		}
		
		private static function detectChangeFrameMainObject(event:Event):void {
			if(CodeCraft.getMainObject().currentFrame != frameCurrent){
				frameCurrent = CodeCraft.getMainObject().currentFrame;
				if (CodeCraft.getMainObject().contains(stats)) {
					CodeCraft.getMainObject().removeChild(stats);
					CodeCraft.getMainObject().addChild(stats);
				}
			}
		}
		
		public static function print(object:*, name:String = "trace", type:String = ''):void {
			if (object is Array) {
				trace(name + ': ARRAY');
				for (var i:int = 0; i < object.length; i++) {
					if(object[i] is MovieClip || object[i] is Object || object[i] is TextField){
						trace(i + ': ' + object[i] + ' - name: ' + object[i].name);
					}else {
						trace(i + ': ' + object[i]);
					}
				}
			}else {
				if(object is MovieClip || object is Object || object is TextField){
					trace(name + ": " + object + ' - name: ' + object.name);
				}else {
					trace(name + ": " + object + "");
				}
			}
		}
		
		public static function printFunction (object:* = null, textConsole:String = ''):void {
			var clip:MovieClip = new MovieClip();
			printObject.push([object, textConsole, clip]);
			clip.addEventListener(Event.ENTER_FRAME, printFunctionActive);
		}
		
		private static function printFunctionActive (event:Event):void {
			var position:Number = Arrays.indexOf(printObject,event.currentTarget,'todo');
			print(printObject[position][0],printObject[position][1]);
		}
	}
}