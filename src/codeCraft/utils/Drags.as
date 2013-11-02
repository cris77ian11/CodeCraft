package codeCraft.utils {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.display.Button;
	import codeCraft.events.Events;
	
	public class Drags extends MovieClip {
		
		//almacena las instancias de los elementos que se van a mover y las opciones de posicion configuradas
		private static var arrayDrag:Array = new Array();
		//valor que permite indicar cuando un elemento este o no en movimiento
		private static var mover:Boolean = false; 
		//almacena las posiciones actuales de los elementos que se estan moviendo para luego ser reubicados
		private static var posicionDrag:Array = new Array(); 
		//indica que elemento es el que se le aplica la propiedad startDrag()
		private static var elementoEnMovimiento:Object = new Object(); 
		private static var exitStage:Boolean = false;
		
		private static var _rectangleLimit:Rectangle = null;
		
		public static function load(object:*, positionOrigin:Boolean = true, center:Boolean = false, rectangleLimit:Rectangle = null):void 
		{
			try 
			{
				var arrayTemp:Array = new Array();
				//se pasa en el listener el parametro del boton false para no aplicar el efecto de al dar clic el elemento se anime
				Events.listener(object, MouseEvent.MOUSE_DOWN, moveElement,false);
				//Events.listener(object, MouseEvent.MOUSE_UP, stopElement,false);
				Events.listener(CodeCraft.getMainObject().stage, MouseEvent.MOUSE_UP, stopElement,false);
				//se agrega solo el buttonMode a los elementos pero no se animan
				Button.button(object,true,false);
				arrayTemp = new Array(object, positionOrigin, center, rectangleLimit);
				arrayDrag.push(arrayTemp);
				//se carga el listener para comprobar cuando se salio del stage con el mouse
				CodeCraft.getMainObject().stage.addEventListener(Event.MOUSE_LEAVE, salirDelStage);
			}
			catch(error:Error)
			{
				Debug.print("Un parametro no esta permitido en la funcion.","Drags.load","Falla CodeCraft ");
			}
		}
		
		
		public static function remove(object:*, posicionArray:* = null):void {
			var position:int = -1;
			position = Arrays.indexOf(arrayDrag, object, 'todo');
			if (position != -1) {
				//se verifica si se esta moviendo algun elemento y se devuelve a la posicion
				if (mover) {
					verificarElementoDrag(elementoEnMovimiento);
				}
				if (posicionArray != null) {
					if (posicionArray is Number){
						Events.removeListener(object[posicionArray], MouseEvent.MOUSE_DOWN, moveElement,false);
						//Events.removeListener(object[posicionArray], MouseEvent.MOUSE_UP, stopElement,false);
						Events.removeListener(CodeCraft.getMainObject().stage, MouseEvent.MOUSE_UP, stopElement,false);
					}else {
						posicionArray = Arrays.indexOf(object, posicionArray, 'todo');
						Events.removeListener(object[posicionArray], MouseEvent.MOUSE_DOWN, moveElement,false);
						//Events.removeListener(object[posicionArray], MouseEvent.MOUSE_UP, stopElement,false);
						Events.removeListener(CodeCraft.getMainObject().stage, MouseEvent.MOUSE_UP, stopElement,false);
					}
				} else {
					Events.removeListener(object, MouseEvent.MOUSE_DOWN, moveElement,false);
					Events.removeListener(object, MouseEvent.MOUSE_UP, stopElement,false);
					arrayDrag.splice(position, 1);
				}
				//se verifica si el arreglo drag es vacio para eliminar el listener que detecta que se sale del stage
				if (arrayDrag.length == 0) {
					CodeCraft.getMainObject().removeEventListener(Event.MOUSE_LEAVE, salirDelStage);
				}
			}
		}
		
		private static function salirDelStage(event:Event):void {
			if (elementoEnMovimiento.name != undefined) {
				var position:int = -1;
				position = Arrays.indexOf(arrayDrag, elementoEnMovimiento, 'todo');
				//se indica que el objeto a dejado de moverse
				mover = false;
				elementoEnMovimiento.stopDrag();
				elementoEnMovimiento.x = posicionDrag[0];
				elementoEnMovimiento.y = posicionDrag[1];
				//se limpia el elementoEnMovimiento para la propiedad salirDelStage
				elementoEnMovimiento = new Object();
			}
		}
		
		private static function moverElementoDrag(e:MouseEvent):void 
		{
			verificarElementoDrag(e.currentTarget);
		}
		
		private static function moveElement (event:MouseEvent):void
		{
			if(elementoEnMovimiento.name == undefined)
			{
				var position:int = -1;
				elementoEnMovimiento = event.currentTarget;
				position = Arrays.indexOf(arrayDrag, elementoEnMovimiento, 'todo');
				posicionDrag[0] = elementoEnMovimiento.x;
				posicionDrag[1] = elementoEnMovimiento.y;
				//se agrega y elimimina del stage para posicionar sobre los demas elementos
				CodeCraft.removeChild(elementoEnMovimiento);
				CodeCraft.addChild(elementoEnMovimiento, null, posicionDrag[0], posicionDrag[1]);
				//se verifica i tiene limitante
				if(arrayDrag[position][3] != null)
				{
					elementoEnMovimiento.startDrag(arrayDrag[position][2],arrayDrag[position][3]);
				}
				else
				{
					elementoEnMovimiento.startDrag(arrayDrag[position][2]);
				}
			}
		}
		
		private static function stopElementstage (event:MouseEvent):void
		{
			
		}
			
		private static function stopElement(event:MouseEvent):void
		{
			if(elementoEnMovimiento.name != undefined)
			{
				var position:int = -1;
				position = Arrays.indexOf(arrayDrag, elementoEnMovimiento, 'todo');
				//se indica que el objeto a dejado de moverse
				mover = false;
				elementoEnMovimiento.stopDrag();
				if (arrayDrag[position][1])
				{
					elementoEnMovimiento.x = posicionDrag[0];
					elementoEnMovimiento.y = posicionDrag[1];
				}
				//se limpia el elementoEnMovimiento para la propiedad salirDelStage
				elementoEnMovimiento = new Object();
			}
		}
		
		private static function verificarElementoDrag(object:* = null):void {
			var position:int = -1;
			if (object != null) {
				elementoEnMovimiento = object;
			}
			position = Arrays.indexOf(arrayDrag, elementoEnMovimiento, 'todo');
			if (mover) {
				//se indica que el objeto a dejado de moverse
				mover = false;
				elementoEnMovimiento.stopDrag();
				if (arrayDrag[position][1] || exitStage) {
					exitStage = false;
					elementoEnMovimiento.x = posicionDrag[0];
					elementoEnMovimiento.y = posicionDrag[1];
				}
				//se limpia el elementoEnMovimiento para la propiedad salirDelStage
				elementoEnMovimiento = new Object();
			} else {
				//indica que el objeto se esta moviendo
				mover = true; 
				posicionDrag[0] = elementoEnMovimiento.x;
				posicionDrag[1] = elementoEnMovimiento.y;
				//se agrega y elimimina del stage para posicionar sobre los demas elementos
				CodeCraft.removeChild(elementoEnMovimiento);
				CodeCraft.addChild(elementoEnMovimiento, null, posicionDrag[0], posicionDrag[1]);
				elementoEnMovimiento.startDrag(arrayDrag[position][2]);
			}
		}
		
	}
}