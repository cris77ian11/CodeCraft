package codeCraft.utils
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	
	public class Collision
	{
		
		/* Boton que permite verificar el estado de las selecciones */
		private static var _botonComparacion:MovieClip;
		/* Array que almacena una cantidad x de valores boolean para indicar si el objetivo de la colision se encuentra ya ocupado por otro elemento */
		private static var _detectarColision:Array;
		/* Indica la posicion para la carga de los elementos, los de mover, objetivo y los de posicion */
		private static var _posiciones:Array;
		/* Almacena en un array las posiciones de inicio de los elemtos que se estan moviendo, para reubicarlos cuando se devuelvan */
		private static var _posicionElementosMoverOrigen:Array;
		/* Son los que se van a mover  */
		public static var _elementosMover:Array = null;
		/* Son los que recibiran a los objetos qeu se estan moviendo */
		public static var _elementosObjetivo:Array;
		/* eleentos que indican donde se van a posicionar los elementos objetivos cuando colisionen */
		public static var _elementosPosicion:Array;
		/* Captura la posicion del elemento objetivo si es que tiene un elemento origen sobre el */
		private static var _posicionElementoObjetivo:int;
		/* Almacena la posicion mimina y maxima del eje x para indicar la region en la que el elemento en movimiento sera restaurado a la posicion origen*/
		private static var _limiteMovimiento:Array;
		/* Almacena el elemento actual que se esta moviendo */
		private static var _elementoMovimientoActivo:*;
		/* indica en que eje se va a posicionar los elementos en la funcion de carga */
		private static var _ejeUbicacion:String;
		/* indica la cantidad de columnas que va a formar el elemento de colision para ubicar las piezas */
		private static var _cantidadColumnas:int;
		
		public static function load (elementosMover:Array, elementosObjetivo:Array, posicionelementos:Array, ejeUbiacion:String = "x", cantidadColumnas:int = 1, elementosPosicion:Array = null, botonComparacion:MovieClip = null, areaRetorno:Array = null):void 
		{
			_elementosObjetivo = elementosObjetivo;
			_elementosMover = elementosMover;
			_elementosPosicion = elementosPosicion;
			_limiteMovimiento = areaRetorno;
			_botonComparacion = botonComparacion;
			_ejeUbicacion = ejeUbiacion;
			_posiciones = posicionelementos;
			_cantidadColumnas = cantidadColumnas;
			_detectarColision = Arrays.fill(false,_elementosMover.length);
			cargarElementos();
			listenerMovimientoDrag();
		}
		
		public static function remove ():void 
		{
			if(_elementosMover != null)
			{
				eliminarListenerMovimientoDrag();
				eliminarElementos();
			}
		}
		
		private static function cargarElementos():void 
		{
			//se desactiva el boton de comparacion
			CodeCraft.property(_botonComparacion,{alpha:0.3});
			//detectar numero del fotograma para los elementos que van a tener colision
			var numeroMovimiento:int = verificarLabels(_elementosMover[0].currentLabels,"normal");
			var numeroObjetivo:int = verificarLabels(_elementosObjetivo[0].currentLabels,"normal");
			if(numeroMovimiento != -1)
			{
				CodeCraft.stopFrame(_elementosMover,_elementosMover[0].currentLabels[numeroMovimiento].name);
			}
			if(numeroObjetivo != -1)
			{
				CodeCraft.stopFrame(_elementosObjetivo,_elementosObjetivo[0].currentLabels[numeroObjetivo].name);
			}
			//aleatorio elementos de movimiento
			_elementosMover = Arrays.random(_elementosMover);
			//carga elementos
			CodeCraft.addChild(_elementosMover,null,_posiciones[0][0],_posiciones[0][1],_ejeUbicacion,10,_cantidadColumnas,20);
			CodeCraft.addChild(_elementosObjetivo,null,_posiciones[1][0],_posiciones[1][1],_ejeUbicacion,10,_cantidadColumnas,20);
			if(_elementosPosicion != null)
			{
				CodeCraft.addChild(_elementosPosicion,null,_posiciones[2][0],_posiciones[2][1],_ejeUbicacion,10,_cantidadColumnas,20);
				CodeCraft.property(_elementosPosicion,{alpha:0});
			}
			TweenMax.allFrom(_elementosMover,1,{alpha:0,scaleX:0,scaleY:1,ease:Back.easeOut});
			TweenMax.allFrom(_elementosObjetivo,1,{alpha:0,scaleX:0,scaleY:1,ease:Back.easeOut});
		}
		
		private static function eliminarElementos():void 
		{
			TweenMax.allTo(_elementosMover,0.5,{alpha:0,scaleX:0,scaleY:1,ease:Back.easeIn, onComplete: CodeCraft.removeChild, onCompleteParams: [_elementosMover]});
			TweenMax.allTo(_elementosObjetivo,0.5,{alpha:0,scaleX:0,scaleY:1,ease:Back.easeIn, onComplete: CodeCraft.removeChild, onCompleteParams: [_elementosObjetivo]});
			CodeCraft.removeChild(_elementosPosicion);
			_detectarColision = Arrays.fill(false,_elementosMover.length);
			_elementosObjetivo = null;
			_elementosMover = null;
			_elementosPosicion = null;
			_limiteMovimiento = null;
			_botonComparacion = null;
			_posiciones = null;
		}
		
		private static function listenerMovimientoDrag ():void 
		{
			
			Drags.load(_elementosMover,true,true);
			Events.listener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivo,false,false);
			capturarPosicionElementosMover();
		}
		
		private static function eliminarListenerMovimientoDrag():void 
		{
			Drags.remove(_elementosMover);
			Events.removeListener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivo,false);
			Events.removeListener(_botonComparacion,MouseEvent.CLICK, verificarElementosMovimientoObjetivo,true);
		}
		
		private static function capturarPosicionElementosMover():void 
		{
			_posicionElementosMoverOrigen = new Array();
			for(var i:int = 0; i < _elementosMover.length; i++)
			{
				_posicionElementosMoverOrigen.push([_elementosMover[i].x,_elementosMover[i].y]);
			}
		}
		
		/**
		 *
		 */
		private static function capturarPosicionElementoObjetivo(event:MouseEvent):void
		{
			_posicionElementoObjetivo = -1;
			_elementoMovimientoActivo = event.currentTarget; 
			Events.listener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, ubicarElementoMovimientoSoltado,false,false);
			//verificamos en el array si tiene la posicion o colisiona con un elemento objetivo
			for(var i:int = 0; i < _elementosObjetivo.length; i++)
			{
				if(_elementosObjetivo[i].x == event.currentTarget.x  && _elementosObjetivo[i].y == event.currentTarget.y)
				{
					_posicionElementoObjetivo = i;
				}
			}
		}
		
		private static function ubicarElementoMovimientoSoltado (event:MouseEvent):void 
		{
			Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, ubicarElementoMovimientoSoltado,false);
			//captura la posicion del array del elemento para poder manipular posicion en los arrays
			var posicionBoton:int = Arrays.indexOf(_elementosMover,_elementoMovimientoActivo);
			//se verifica si el elemento lo devolvieron a la columna inicial
			if(CodeCraft.getMainObject().mouseX > _limiteMovimiento[0] && CodeCraft.getMainObject().mouseX < _limiteMovimiento[1])
			{
				_elementoMovimientoActivo.x = _posicionElementosMoverOrigen[posicionBoton][0];
				_elementoMovimientoActivo.y = _posicionElementosMoverOrigen[posicionBoton][1];
				if(_posicionElementoObjetivo != -1)
				{
					_detectarColision[_posicionElementoObjetivo] = false;		
					_posicionElementoObjetivo = -1;
				}
			}
			else 
			{
				//Como no se devolvio el elemento se recorre el array de objetivos para detectar una colision
				for(var i:int = 0; i < _elementosObjetivo.length; i++)
				{
					if(_elementosObjetivo[i].hitTestPoint(CodeCraft.getMainObject().mouseX,CodeCraft.getMainObject().mouseY) && _detectarColision[i] == false)
					{
						if(_elementosPosicion != null)
						{
							_elementoMovimientoActivo.x = _elementosPosicion[i].x;
							_elementoMovimientoActivo.y = _elementosPosicion[i].y;	
						}
						else
						{
							_elementoMovimientoActivo.x = _elementosObjetivo[i].x;
							_elementoMovimientoActivo.y = _elementosObjetivo[i].y;	
						}
						_detectarColision[i] = true;
						//se verifica si el elemento objetivo es el mismo que el quetenia antes de moverse si no es el mismo
						//se restaura el que tenga la posicion de origen del objetivo
						if(_posicionElementoObjetivo != i && _posicionElementoObjetivo != -1)
						{
							_detectarColision[_posicionElementoObjetivo] = false;
							_posicionElementoObjetivo = -1;
						}
						//se cierra el ciclo
						break;
					}
				}
			}
			//se recorre el array que detecta si se cargo un elemento a los objetivos de colision, si todos los objetivos
			//tienen un elemento cargado  se habilita el boton para verificar si la información es correcta
			if(Arrays.verifyFill(_detectarColision,true))
			{
				CodeCraft.property(_botonComparacion,{alpha:1});
				Events.listener(_botonComparacion,MouseEvent.CLICK, verificarElementosMovimientoObjetivo,true,true);
			}
		}
		
		/**
		 * 
		 */
		private static function verificarElementosMovimientoObjetivo (event:MouseEvent):void
		{
			var nombreObjetivo:String;
			var nombreMovimiento:String;
			var labelsObjetivo:Array;
			var labelsMovimiento:Array;
			var numeroLabelObjetivo:int;
			var numeroLabelMovimiento:int;
			//recorre un array con los elementos objetivos y verifica por el nombre de instancia de los elementos, 
			//leyendo el ultimo numero que indicara la posicion de los elementos en el array antes de desorndenarlos
			//pero recorre el array de elementos en movimiento para detectar cual esta cargado al elemento objetivo.
			for (var i:int = 0; i < _elementosObjetivo.length; i++)
			{
				nombreObjetivo = _elementosObjetivo[i].name.substr(_elementosObjetivo[i].name.length - 1);
				labelsObjetivo = _elementosObjetivo[i].currentLabels;
				//se busca el label mal y se carga si lo tiene
				numeroLabelObjetivo = verificarLabels(labelsObjetivo,"mal");
				if(numeroLabelObjetivo != -1)
				{
					_elementosObjetivo[i].gotoAndStop(labelsObjetivo[numeroLabelObjetivo].name);
					
				}
				for (var j:int = 0; j < _elementosMover.length; j++)
				{
					nombreMovimiento = _elementosMover[j].name.substr(_elementosMover[j].name.length - 1);
					labelsMovimiento = _elementosMover[j].currentLabels;
					//se busca el label mal y se carga si lo tiene
					numeroLabelMovimiento = verificarLabels(labelsMovimiento,"mal");
					if(numeroLabelMovimiento != -1)
					{
						_elementosMover[j].gotoAndStop(labelsMovimiento[numeroLabelMovimiento].name);
					}
					if(nombreMovimiento == nombreObjetivo 
						&& _elementosObjetivo[i].x == _elementosMover[j].x 
						&& _elementosObjetivo[i].y == _elementosMover[j].y)
					{
						////se buscan las labels de ambos elementos para indicar cual es la buena si no la tiene no se carga
						numeroLabelMovimiento = verificarLabels(labelsMovimiento,"bien");
						if(numeroLabelMovimiento != -1)
						{
							_elementosMover[j].gotoAndStop(labelsMovimiento[numeroLabelMovimiento].name);
						}
						numeroLabelObjetivo = verificarLabels(labelsObjetivo,"bien");
						if(numeroLabelObjetivo != -1)
						{
							_elementosObjetivo[i].gotoAndStop(labelsObjetivo[numeroLabelObjetivo].name);
						}
						break;
					}
				}
			}
		}
		
		/**
		 * verifica si existe un label en los elementos de la colision y devuelve la posicion
		 */
		private static function verificarLabels (labels:Array,labelBuscar:String = ""):int
		{
			var posicion:int = -1;
			if(labelBuscar != "")
			{
				for(var i:int = 0; i < labels.length; i++)
				{
					if(labels[i].name == labelBuscar)
					{
						posicion = i;
					}
				}
			}
			return posicion;
		}
	}
}