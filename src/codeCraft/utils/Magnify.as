package codeCraft.utils {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.events.Events;

	public class Magnify extends MovieClip {
		
		private static var options:Dictionary = new Dictionary();
		private static var overZoom:Boolean = false;
		
		private static var arrayZoomClip:Array = new Array();
		
		public static function load (clipMagnify:MovieClip, clipMagnifyContainer:MovieClip, normalClip:*, zoomClip:* = null, scale:Number = 1.5, positionX:Number = -1, positionY:Number = -1, hideMouse:Boolean = false):void{
			if (options['magnify'] == undefined){
				options['scale'] = scale;
				options['magnify'] = clipMagnify;
				options['clipMagnifyContainer'] = clipMagnifyContainer;
				options['hideMouse'] = hideMouse;
				if (!CodeCraft.getMainObject().contains(options['magnify'])){
					CodeCraft.addChild(options['magnify']);
				}
				if(normalClip is Array){ 
					options['normalClip'] = normalClip;
					if(zoomClip is Array){
						arrayZoomClip = zoomClip;
					}else{
						for(var i:uint = 0; i < options['normalClip'].length; i++){
							storeZoomClip(normalClip[i],zoomClip);
						}
					}
				}else{
					options['normalClip'] = new Array (normalClip);
					storeZoomClip(normalClip[0],zoomClip);
				}
				options['clipZoom'] = arrayZoomClip;
				if(positionX == -1){
					positionX = -(options['magnify'].width / 2);				
					positionY = -(options['magnify'].height / 2);				
				}
				options['x'] = positionX;
				options['y'] = positionY;
				if(hideMouse){
					Mouse.hide();
				}
				CodeCraft.property(options['clipZoom'],{scaleX:options['scale'],scaleY:options['scale']});
				//CodeCraft.addChild(options['clipZoom'],options['clipMagnifyContainer']);
				Events.listener(CodeCraft.getMainObject(),Event.ENTER_FRAME, moveStage);
			}
		}
		
		public static function remove ():void{
			Events.removeListener(CodeCraft.getMainObject(),Event.ENTER_FRAME, moveStage);
			Mouse.show();
			CodeCraft.removeChild(options['clipZoom'],options['clipMagnifyContainer']);
			CodeCraft.removeChild(options['magnify']);
			options = new Dictionary();
			arrayZoomClip = new Array();
		}
		
		private static function moveStage (event:Event):void{
			var dX:Number;
			var dY:Number;
			if(options['normalClip'] is Array){
				for (var i:uint = 0; i < options['normalClip'].length; i++){
					if(options['normalClip'][i].hitTestPoint(CodeCraft.getMainObject().mouseX,CodeCraft.getMainObject().mouseY)){
						//veriricar si ya se cargo de lo contrario se carga dentro de la lupa
						//if(!options['magnify'].contains(options['clipZoom'][i])){
							//CodeCraft.addChild(options['clipZoom'][i],options['clipMagnifyContainer']);
						//}
						dX = options['normalClip'][i].mouseX/options['normalClip'][i].width;
						dY = options['normalClip'][i].mouseY/options['normalClip'][i].height;
						options['magnify'].visible = true;
						options['magnify'].x = CodeCraft.getMainObject().mouseX - options['x'];
						options['magnify'].y = CodeCraft.getMainObject().mouseY + options['y'];
						options['clipZoom'][i].x = (-options['clipZoom'][i].width * dX);
						options['clipZoom'][i].y = (-options['clipZoom'][i].height * dY);
						if(options['hideMouse']){
							Mouse.hide();
						}
					}else {
						//se verifica para ver si esta cargado el elemento y se elimina si lo esta
						//if(options['magnify'].contains(options['clipZoom'][i])){
							//CodeCraft.removeChild(options['clipZoom'][i],options['clipMagnifyContainer']);
						//}
						options['magnify'][i].visible = false;
						Mouse.show();
					}
				}
			}else {
				if(options['normalClip'].hitTestPoint(CodeCraft.getMainObject().mouseX,CodeCraft.getMainObject().mouseY)){
					if(!options['magnify'].contains(options['clipZoom'])){
						CodeCraft.addChild(options['clipZoom'],options['clipMagnifyContainer']);
					}
					dX = options['normalClip'].mouseX/options['normalClip'].width;
					dY = options['normalClip'].mouseY/options['normalClip'].height;
					options['magnify'].visible = true;
					options['magnify'].x = CodeCraft.getMainObject().mouseX - options['x'];
					options['magnify'].y = CodeCraft.getMainObject().mouseY + options['y'];
					options['clipZoom'].x = (-options['clipZoom'].width * dX);
					options['clipZoom'].y = (-options['clipZoom'].height * dY);
					if(options['hideMouse']){
						Mouse.hide();
					}
				}else {
					if(options['magnify'].contains(options['clipZoom'])){
						CodeCraft.removeChild(options['clipZoom'],options['clipMagnifyContainer']);
					}
					options['magnify'].visible = false;
					Mouse.show();
				}
			}
		}
		
		private static function storeZoomClip (normalClip:*, zoomClip:*):void{
			if (zoomClip != null){
				if(zoomClip is MovieClip){
					arrayZoomClip.push(zoomClip);	
				}else {
					arrayZoomClip.push(new zoomClip());
				}
			}else {
				var claseClip:Class = Object(normalClip).constructor; 
				var newClip:MovieClip = new claseClip();
				arrayZoomClip.push(newClip);
			}
		}
	}
}