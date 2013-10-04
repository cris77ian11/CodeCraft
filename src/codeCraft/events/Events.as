package codeCraft.events {
	
	import codeCraft.debug.Debug;
	import codeCraft.display.Button;
	
	import flash.events.*;
	
	public class Events {
	
		public static function listener(object:*, accion:*, method:*, modeButton:Boolean = true, over:Boolean = false):void {
			if(object != null && object != undefined){
				var clipTemp:*;
				if (object is Array) {
					for (var i:uint = 0; i < object.length; i++) {
						if(object[i] != null && object[i] != undefined){
							object[i].addEventListener(accion, method);
						}
					}
					clipTemp = object[0];
				} else{
					object.addEventListener(accion, method);
					clipTemp = object;
				}
				//se detecta si la funcion es un MouseEvent para agregar el buttonMode
				if (modeButton && (clipTemp.hasEventListener(MouseEvent.CLICK) || clipTemp.hasEventListener(MouseEvent.MOUSE_DOWN) || clipTemp.hasEventListener(MouseEvent.MOUSE_UP))) {
					Button.button(object);
				}
				if(over){
					Button.over(object);
				}
			}
		}
		
		public static function removeListener(object:*, accion:*, method:*, modeButton:Boolean = true):void {
			if(object != null || object != undefined){
				var clipTemp:*;
				if(object is Array){
					clipTemp = object[0];
				}else {
					clipTemp = object;
				}
				if (modeButton && (clipTemp.hasEventListener(MouseEvent.CLICK) || clipTemp.hasEventListener(MouseEvent.MOUSE_DOWN) || clipTemp.hasEventListener(MouseEvent.MOUSE_UP))) {
					Button.button(object, !modeButton);
					Button.removeOver(object);
				}
				
				if (object is Array) {
					for (var i:uint = 0; i < object.length; i++) {
						if(object[i].hasEventListener (accion)){
							object[i].removeEventListener (accion, method);
						}
					}
				} else {
					if(object.hasEventListener (accion)){
						object.removeEventListener (accion, method);
					}
				}
			}
		}
		
	}
}