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
		
		public static function print(object:*, name:String = "Trace", type:String = ''):void 
		{
			try
			{
				if (object is Array) 
				{
					trace(type + name + ': ARRAY');
					for (var i:int = 0; i < object.length; i++) 
					{
						if(object[i] is Array)
						{
							print(object[i]," __ Array " + i,type);
						}
						else
						{
							if(object[i] is String || object[i] is Number || object[i] is Boolean)
							{
								trace(i + ': ' + object[i]);
							}
							else 
							{
								trace(i + ': ' + object[i] + ' - name: ' + object[i].name);
							}
						}
					}
				}
				else 
				{
					if(object is String || object is Number || object is Boolean)
					{
						trace(type + name + ": " + object + "");
					}
					else 
					{
						trace(type + name + ": " + object + ' - name: ' + object.name);
					}
				}
			}
			catch(error:Error)
			{
				trace("Error CodeCraft Debug.print: Un valor que se trata de imprimir no es admitido, puede tener algun valor null.");
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