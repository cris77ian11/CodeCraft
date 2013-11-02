package codeCraft.events {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import codeCraft.display.Button;
	
	public class Events {
	
		public static function listener(object:*, accion:*, method:*, modeButton:Boolean = true, over:Boolean = false):void 
		{
			if(object != null && object != undefined)
			{
				var clipTemp:*;
				if (object is Array) 
				{
					for (var i:uint = 0; i < object.length; i++) 
					{
						if(object[i] is Array)
						{
						 	listener(object[i],accion,method,modeButton,over);	
						}
						else
						{
							if(object[i] != null && object[i] != undefined)
							{
								object[i].addEventListener(accion, method);
							}
						}
					}
					clipTemp = object[0];
				}
				else
				{
					object.addEventListener(accion, method);
					clipTemp = object;
				}
				//se detecta si la funcion es un MouseEvent para agregar el buttonMode
				if (modeButton && (accion == MouseEvent.CLICK || accion == MouseEvent.MOUSE_DOWN) && (clipTemp.hasEventListener(MouseEvent.CLICK) || clipTemp.hasEventListener(MouseEvent.MOUSE_DOWN))) 
				{
					Button.button(object);
				}
				if(over)
				{
					Button.over(object);
				}
			}
		}
		
		public static function removeListener(object:*, accion:*, method:*, modeButton:Boolean = true):void 
		{
			if(object != null || object != undefined  && (object is MovieClip || object is Object))
			{
				var clipTemp:*;
				if(object is Array)
				{
					clipTemp = object[0];
				}
				else 
				{
					clipTemp = object;
				}
				if (modeButton && (accion == MouseEvent.CLICK || accion == MouseEvent.MOUSE_DOWN) && (clipTemp.hasEventListener(MouseEvent.CLICK) || clipTemp.hasEventListener(MouseEvent.MOUSE_DOWN))) 
				{
					Button.button(object, !modeButton);
					Button.removeOver(object);
				}
				
				if (object is Array) 
				{
					for (var i:uint = 0; i < object.length; i++) 
					{
						if(object[i] is Array)
						{
							removeListener(object[i],accion,method,modeButton);
						}
						else
						{
							if(object[i].hasEventListener (accion))
							{
								object[i].removeEventListener (accion, method);
							}	
						}
					}
				} 
				else 
				{
					if(object.hasEventListener (accion))
					{
						object.removeEventListener (accion, method);
					}
				}
			}
		}
		
	}
}