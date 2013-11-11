package codeCraft.utils
{

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
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
		/* Almacena el elemento actual que se esta moviendo */
		private static var _elementoMovimientoActivo:*;
		/* distancia entre elementos y cantidad de columnas que se vana a ubicar */
		private static var _opcionesAddChild:Array;
		/* Indica si se verifica las colisiones por meido del texto que tienen en las cajas cada elemento, el texto es con el texto que se carga */
		private static var _textosVerificacion:Array;
		/* Almacena los textos cargados para cada contenido para verificar si son respuestas correctas o no */
		private static var _almacenarTextosVerificacion:Array;
		/* Almacena las funciones a retornar para cuando termine de realziar el proceso de comparacion, termina bien o mal */
		private static var _funcionesRetornar:Array;
		/* Almacena un array con valores Booleanos que corresponden a la cantidad de elementos objetivos de la colision, true indica que colisiono con el correcto y false con el malo */
		private static var _resultadoColision:Array;
		/* rectangulo que indica el area de colision para devolver */
		private static var _clipRetorno:Sprite;
		/* Indica el tipo de comparacion con el texto, si tiene que tener un orden o cualquier campo */
		private static var _comprobarTodos:Boolean = false;
		/* almacena los elementos que indica que elementos puede almacenarse en cada objetivo de colision */
		private static var _elementosObjetivosMultiple:Array;
		/* almacena elementos que se encuentran cargados en un elemento de objetivo */
		private static var  _elementosCargadosObjetivo:Array;
		/* Deja una copia original de los elementos de mover antes de ser desordenados con el fin de poder verificar si llega el caso de usarse un collision multiple */
		private static var _copiaElementosMover:Array;
		

		/**
		 * 
		 * @param elementosMover
		 * @param elementosObjetivo
		 * @param posicionelementos
		 * @param opcionesAddChild
		 * @param elementosPosicion
		 * @param botonComparacion
		 * @param areaRetorno
		 * @param textosVerificacion
		 * @param funcionesRetornar Es un array que contiene como primer parametro la funcion a retornar cuando se presiona el boton de comparar, luego una funcion que se utiliza para cuando gana, y por ultimo cuando pierde
		 */
		public static function load (elementosMover:Array, elementosObjetivo:Array, posicionelementos:Array, opcionesAddChild:Array = null, elementosPosicion:Array = null, botonComparacion:MovieClip = null, areaRetorno:Array = null, textosVerificacion:Array = null, funcionesRetornar:Array = null, elementosObjetivoPermitidos:Array = null):void
		{
			_elementosObjetivo = elementosObjetivo;
			_elementosMover = elementosMover;
			_copiaElementosMover = Arrays.clone(elementosMover);
			_elementosPosicion = elementosPosicion;
			_botonComparacion = botonComparacion;
			_elementosObjetivosMultiple = elementosObjetivoPermitidos;
			if(textosVerificacion != null)
			{
				if(textosVerificacion[0] is Array)
				{
					if(textosVerificacion[1] != undefined && textosVerificacion[1] is Boolean)
					{
						_comprobarTodos = textosVerificacion[1];
					}
					_textosVerificacion = textosVerificacion[0];
				}
				else
				{
					_textosVerificacion = textosVerificacion;
				}
			}
			else
			{
				_textosVerificacion = textosVerificacion;
			}
			_opcionesAddChild = opcionesAddChild;
			_posiciones = posicionelementos;
			_almacenarTextosVerificacion = new Array();
			_funcionesRetornar = funcionesRetornar;
			//se verifican las opciones de addchild
			if(_opcionesAddChild == null)
			{
				_opcionesAddChild = new Array("x",10,1,20);
			}
			else
			{
				if(_opcionesAddChild[0] == undefined)
				{
					_opcionesAddChild[0] = "x";
				}
				if(_opcionesAddChild[1] == undefined)
				{
					_opcionesAddChild[1] = 10;
				}
				if(_opcionesAddChild[2] == undefined)
				{
					_opcionesAddChild[2] = 1;
				}
				if(_opcionesAddChild[3] == undefined)
				{
					_opcionesAddChild[3] = 20;
				}
			}
			//se crea el elemento de limite
			if(areaRetorno != null && areaRetorno.length == 4)
			{
				//se verifica si tiene todos los parametros, eje x y y, y el ahcno y largo
				if(Arrays.verifyType(areaRetorno,Number))
				{
					_clipRetorno = new Sprite();
					_clipRetorno.graphics.beginFill(0x000000, 1);
					_clipRetorno.graphics.drawRect(areaRetorno[0],areaRetorno[1],areaRetorno[2],areaRetorno[3]);
					_clipRetorno.alpha = 0;
					CodeCraft.addChild(_clipRetorno,null);
				}
				else
				{
					_clipRetorno = null;
				}
			}
			else
			{
				_clipRetorno = null;
			}
			cargarElementos();
			listenerMovimientoDrag();
		}

		public static function remove ():void
		{
			if(_elementosMover != null)
			{
				eliminarListenerMovimientoDrag();
				eliminarElementos();
				CodeCraft.removeChild(_clipRetorno);
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
			//carga elementos, y se verifica si los elementos de posicion son para cargar un elemento por columnas, o tiene una ubicacion
			//especifica la ubicacion esacta de cada elemento
			var posicionMoverX:* = _posiciones[0];
			var posicionMoverY:Number = 0;
			var posicionObjetivoX:* = _posiciones[1];
			var posicionObjetivoY:Number = 0;
			
			if(!(_posiciones[0][0] is Array))
			{
				posicionMoverX = _posiciones[0][0];
				posicionMoverY = _posiciones[0][1];
			}
			if(!(_posiciones[1][0] is Array))
			{
				posicionObjetivoX = _posiciones[1][0];
				posicionObjetivoY = _posiciones[1][1];
			}			
			CodeCraft.addChild(_elementosMover,null,posicionMoverX,posicionMoverY,_opcionesAddChild[0],_opcionesAddChild[1],_opcionesAddChild[2],_opcionesAddChild[3]);
			CodeCraft.addChild(_elementosObjetivo,null,posicionObjetivoX,posicionObjetivoY,_opcionesAddChild[0],_opcionesAddChild[1],_opcionesAddChild[2],_opcionesAddChild[3]);
			if(_elementosPosicion != null)
			{
				var posicionPosicionX:* = _posiciones[2];
				var posicionPosicionY:Number = 0;
				if(!(_posiciones[2][0] is Array))
				{
					posicionPosicionX = _posiciones[2][0];
					posicionPosicionY = _posiciones[2][1];
				}	
				CodeCraft.addChild(_elementosPosicion,null,posicionPosicionX,posicionPosicionY,_opcionesAddChild[0],_opcionesAddChild[1],_opcionesAddChild[2],_opcionesAddChild[3]);
				CodeCraft.property(_elementosPosicion,{alpha:0});
			}
			TweenMax.allFrom(_elementosMover,1,{alpha:0,scaleX:0,scaleY:0,ease:Back.easeOut});
			TweenMax.allFrom(_elementosObjetivo,1,{alpha:0,scaleX:0,scaleY:0,ease:Back.easeOut});
			//se llena el array de los resultados de colision con el elemento objetivo
			var objetivo:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetivo = _elementosPosicion;
			}
			_resultadoColision = Arrays.fill(false,objetivo.length);
			_detectarColision = Arrays.fill(false,objetivo.length);
			//se verifica si hay habilitada la opcion de envedir elementos para crear el array que se encarga de crearlos
			if(_elementosObjetivosMultiple != null)
			{
				_elementosCargadosObjetivo = new  Array();
			}
		}

		private static function eliminarElementos():void
		{
			TweenMax.allTo(_elementosMover,0.2,{alpha:0,scaleX:0,scaleY:0,ease:Back.easeIn, onComplete: CodeCraft.removeChild, onCompleteParams: [_elementosMover]});
			TweenMax.allTo(_elementosObjetivo,0.2,{alpha:0,scaleX:0,scaleY:0,ease:Back.easeIn, onComplete: CodeCraft.removeChild, onCompleteParams: [_elementosObjetivo]});
			CodeCraft.removeChild(_elementosPosicion);
			_detectarColision = Arrays.fill(false,_elementosMover.length);
			_elementosObjetivo = null;
			_elementosMover = null;
			_elementosPosicion = null;
			_clipRetorno = null;
			_botonComparacion = null;
			_posiciones = null;
		}

		private static function listenerMovimientoDrag ():void
		{

			Drags.load(_elementosMover,true,true);
			if(_elementosObjetivosMultiple != null)
			{
				Events.listener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivoMultiple,false,false);
			}
			else
			{
				Events.listener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivo,false,false);
			}
			capturarPosicionElementosMover();
		}

		private static function eliminarListenerMovimientoDrag():void
		{
			Drags.remove(_elementosMover);
			if(_elementosObjetivosMultiple != null)
			{
				Events.removeListener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivoMultiple,false);
			}
			else
			{
				Events.removeListener(_elementosMover,MouseEvent.MOUSE_DOWN, capturarPosicionElementoObjetivo,false);
				Events.removeListener(_botonComparacion,MouseEvent.CLICK, verificarElementosMovimientoObjetivo,true);
			}
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
			var objetivoColision:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetivoColision = _elementosPosicion;
			}
			//verificamos en el array si tiene la posicion o colisiona con un elemento objetivo
			for(var i:int = 0; i < objetivoColision.length; i++)
			{
				if(objetivoColision[i].x == event.currentTarget.x  && objetivoColision[i].y == event.currentTarget.y)
				{
					_posicionElementoObjetivo = i;
				}
			}
		}

		private static function ubicarElementoMovimientoSoltado (event:MouseEvent):void
		{
			var objetivoColision:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetivoColision = _elementosPosicion;
			}
			Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, ubicarElementoMovimientoSoltado,false);
			//captura la posicion del array del elemento para poder manipular posicion en los arrays
			var posicionBoton:int = Arrays.indexOf(_elementosMover,_elementoMovimientoActivo);
			//indicara si se devolvio o no el objeto para verificar su posicion
			var elementoDevuelto:Boolean = false;
			//se verifica si el elemento lo devolvieron a la columna inicial
			if(_clipRetorno != null && CodeCraft.getMainObject().contains(_clipRetorno))
			{
				if(_clipRetorno.hitTestPoint(CodeCraft.getMainObject().mouseX, CodeCraft.getMainObject().mouseY))
				{
					_elementoMovimientoActivo.x = _posicionElementosMoverOrigen[posicionBoton][0];
					_elementoMovimientoActivo.y = _posicionElementosMoverOrigen[posicionBoton][1];
					if(_posicionElementoObjetivo != -1)
					{
						_detectarColision[_posicionElementoObjetivo] = false;
						_almacenarTextosVerificacion[_posicionElementoObjetivo] = "";
						_posicionElementoObjetivo = -1;
					}
					elementoDevuelto = true;
				}
			}
			
			if(elementoDevuelto == false)
			{
				//Como no se devolvio el elemento se recorre el array de objetivos para detectar una colision
				for(var i:int = 0; i < _elementosObjetivo.length; i++)
				{
					if(_elementosObjetivo[i].hitTestPoint(CodeCraft.getMainObject().mouseX,CodeCraft.getMainObject().mouseY))
					{
						//verificar si tiene otro elemento para devolverlos a la posicion de origen
						if(_detectarColision[i] == true)
						{
							for(var j:int = 0; j < _elementosMover.length; j++)
							{
								if(objetivoColision[i].x == _elementosMover[j].x && objetivoColision[i].y == _elementosMover[j].y)
								{
									_detectarColision[i] = false;
									_elementosMover[j].x = _posicionElementosMoverOrigen[j][0];
									_elementosMover[j].y = _posicionElementosMoverOrigen[j][1];
	 							}
							}
						}
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
						//se verifica si hay texto  y se carga en el elemento de objetivo
						if(_textosVerificacion != null)
						{
							_almacenarTextosVerificacion[i] = _elementoMovimientoActivo.texto.text;
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
			/* indicara si la pregunta es correcta por el medio de verificacion uque se haya usado */
			var respuestaCorrecta:Boolean = false;
			/* Almacena temprarlmente para verificar la colision */
			var objetoColision:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetoColision = _elementosPosicion;
			}
			CodeCraft.stopFrame(_elementosObjetivo,"normal");
			CodeCraft.stopFrame(_elementosMover,"normal");
			//recorre un array con los elementos objetivos y verifica por el nombre de instancia de los elementos,
			//leyendo el ultimo numero que indicara la posicion de los elementos en el array antes de desorndenarlos
			//pero recorre el array de elementos en movimiento para detectar cual esta cargado al elemento objetivo.
			for (var i:int = 0; i < objetoColision.length; i++)
			{
				nombreObjetivo = objetoColision[i].name.substr(objetoColision[i].name.length - 1);
				labelsObjetivo = objetoColision[i].currentLabels;
				//se busca el label mal y se carga si lo tiene
				numeroLabelObjetivo = verificarLabels(labelsObjetivo,"mal");
				if(numeroLabelObjetivo != -1 && objetoColision[i].currentLabel != "bien")
				{
					objetoColision[i].gotoAndStop(labelsObjetivo[numeroLabelObjetivo].name);

				}
				for (var j:int = 0; j < _elementosMover.length; j++)
				{
					respuestaCorrecta = false;
					nombreMovimiento = _elementosMover[j].name.substr(_elementosMover[j].name.length - 1);
					labelsMovimiento = _elementosMover[j].currentLabels;
					//se busca el label mal y se carga si lo tiene
					numeroLabelMovimiento = verificarLabels(labelsMovimiento,"mal");
					if(numeroLabelMovimiento != -1 && _elementosMover[j].currentLabel != "bien")
					{
						_elementosMover[j].gotoAndStop(labelsMovimiento[numeroLabelMovimiento].name);
					}
					//se comprueba si se activo la identificacion por medio de texto
					if(_textosVerificacion != null)
					{
						//se verifica si se quiere que se verifique los textos sin importar la posicion
						if(_comprobarTodos)
						{
							for(var k:int = 0; k < _textosVerificacion.length; k++)
							{
								if(_almacenarTextosVerificacion[i] == _textosVerificacion[k]
									&& objetoColision[i].x == _elementosMover[j].x
									&& objetoColision[i].y == _elementosMover[j].y)
								{
									respuestaCorrecta = true;
								}
							}
						}
						else
						{
							if(_almacenarTextosVerificacion[i] == _textosVerificacion[i]
								&& objetoColision[i].x == _elementosMover[j].x
								&& objetoColision[i].y == _elementosMover[j].y)
							{
								respuestaCorrecta = true;
							}
						}
					}
					else
					{
						if(nombreMovimiento == nombreObjetivo
							&& objetoColision[i].x == _elementosMover[j].x
							&& objetoColision[i].y == _elementosMover[j].y)
						{
							respuestaCorrecta = true;
						}
					}
					if(respuestaCorrecta)
					{
						//se buscan las labels de ambos elementos para indicar cual es la buena si no la tiene no se carga
						numeroLabelMovimiento = verificarLabels(labelsMovimiento,"bien");
						if(numeroLabelMovimiento != -1)
						{
							_elementosMover[j].gotoAndStop(labelsMovimiento[numeroLabelMovimiento].name);
						}
						numeroLabelObjetivo = verificarLabels(labelsObjetivo,"bien");
						if(numeroLabelObjetivo != -1)
						{
							objetoColision[i].gotoAndStop(labelsObjetivo[numeroLabelObjetivo].name);
						}
						_resultadoColision[i] = true;
						break;
					}
				}
			}
			//se verifica si hay funciones qeu devolver
			if(_funcionesRetornar != null)
			{
				var funcionTemporal:Function;
				if(_funcionesRetornar[0] != undefined && _funcionesRetornar[0] != null)
				{
					funcionTemporal = _funcionesRetornar[0];
					funcionTemporal();
				}
				//se verifica si gano o perdio la actividad
				if(Arrays.verifyFill(_resultadoColision,true))
				{
					//gano, por lo que se verifica si hay funcion de gano para devolver
					if(_funcionesRetornar[1] != undefined && _funcionesRetornar[1] != null)
					{
						funcionTemporal = _funcionesRetornar[1];
						funcionTemporal();
					}
				}
				else
				{
					//perdio y se verifica si hay funcion que devolver
					if(_funcionesRetornar[2] != undefined && _funcionesRetornar[2] != null)
					{
						funcionTemporal = _funcionesRetornar[2];
						funcionTemporal();
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
		
		
		
		/***************************************************************************************************************
		 * 
		 * Seccion encargada del manejo de la carga y verificacion de elementos multiples a un solo objetivo
		 * 
		 * ************************************************************************************************************/
		
		
		
		
		
		/**
		 * Funcion que se encaga de realizar el collision a los elementos pero permitiendo que estos carguen varios elementos en uno solo objetivo
		 * @param event Object de MouseEvent
		 */
		private static function capturarPosicionElementoObjetivoMultiple (event:MouseEvent):void
		{
			_elementoMovimientoActivo = event.currentTarget;
			Events.listener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, ubicarElementoMovimientoSoltadoMultiple,false,false);
		}
		
		/**
		 * Ubica los elementos del collision multiple
		 * @param event Object del MouseEvent
		 */
		private static function ubicarElementoMovimientoSoltadoMultiple (event:MouseEvent):void 
		{
			//se utiliza para capturar la posicion temporal del elemento en el array principal
			var posicionCargado:int;
			//captura la posicion del elmento dentreo de del array seleccionado por posicionCargado
			var posicionElementoCargado:int;
			//captura la posicion del array del elemento para poder manipular posicion en los arrays
			var posicionBoton:int = Arrays.indexOf(_elementosMover,_elementoMovimientoActivo);
			//indicara si se devolvio o no el objeto para verificar su posicion
			var elementoDevuelto:Boolean = false;
			//se verifica si el elemento lo devolvieron a la columna inicial
			if(_clipRetorno != null && CodeCraft.getMainObject().contains(_clipRetorno))
			{
				if(_clipRetorno.hitTestPoint(CodeCraft.getMainObject().mouseX, CodeCraft.getMainObject().mouseY))
				{
					_elementoMovimientoActivo.x = _posicionElementosMoverOrigen[posicionBoton][0];
					_elementoMovimientoActivo.y = _posicionElementosMoverOrigen[posicionBoton][1];
					_detectarColision[_posicionElementoObjetivo] = false;
					_almacenarTextosVerificacion[_posicionElementoObjetivo] = "";
					_posicionElementoObjetivo = -1;
					//se busca el elemento en el array del objetivo  cargado para verificar si ya se cargo para eliminarlo del array
					posicionCargado = Arrays.indexOf(_elementosCargadosObjetivo, _elementoMovimientoActivo,"all");
					if(posicionCargado != -1)
					{
						posicionElementoCargado = Arrays.indexOf(_elementosCargadosObjetivo[posicionCargado],_elementoMovimientoActivo);
						_elementosCargadosObjetivo[posicionCargado].splice(posicionElementoCargado,1);
						_elementosCargadosObjetivo = Arrays.reload(_elementosCargadosObjetivo);
					}
				}
			}
			//se recorre el arreglo con los elementos objetivos y se verifica si hay algun elemento cargado, se proceden a 
			//eliminar y luego se cargan de nuevo
			var objetivosColision:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetivosColision = _elementosPosicion;
			}
			//verificamos en el array si tiene la posicion o colisiona con un elemento objetivo
			for(var i:int = 0; i < _elementosObjetivo.length; i++)
			{
				if(_elementosObjetivo[i].hitTestPoint(CodeCraft.getMainObject().mouseX,CodeCraft.getMainObject().mouseY))
				{
					if(_elementosCargadosObjetivo[i] == undefined || _elementosCargadosObjetivo[i] == null)
					{
						_elementosCargadosObjetivo[i] = new  Array();
					}
					_detectarColision[i] = true;
					//se busca si el elemento ya fue cargado en otra parte y se elimina
					posicionCargado = Arrays.indexOf(_elementosCargadosObjetivo, _elementoMovimientoActivo,"all");
					if(posicionCargado != -1)
					{
						posicionElementoCargado = Arrays.indexOf(_elementosCargadosObjetivo[posicionCargado],_elementoMovimientoActivo);
						_elementosCargadosObjetivo[posicionCargado].splice(posicionElementoCargado,1);
						_elementosCargadosObjetivo = Arrays.reload(_elementosCargadosObjetivo);
					}
					_elementosCargadosObjetivo[i].push(_elementoMovimientoActivo);
					break;
				}
			}
			
			for(var j:int = 0; j < objetivosColision.length; j++)
			{
				if(_elementosCargadosObjetivo[j] != undefined)
				{
					CodeCraft.removeChild(_elementosCargadosObjetivo[j]);
					CodeCraft.addChild(_elementosCargadosObjetivo[j],null,objetivosColision[j].x,objetivosColision[j].y,_opcionesAddChild[0],_opcionesAddChild[1],_opcionesAddChild[2],_opcionesAddChild[3]);
				}
			}
			
			//verifica si se puede pasar el proceso de verificacion
			if(Arrays.verifyFill(_detectarColision,true))
			{
				CodeCraft.property(_botonComparacion,{alpha:1});
				Events.listener(_botonComparacion,MouseEvent.CLICK, verificarElementosMovimientoObjetivoMultiple,true,true);
			}
			Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, ubicarElementoMovimientoSoltadoMultiple,false);
		}
		
		
		private static function verificarElementosMovimientoObjetivoMultiple (event:MouseEvent):void 
		{
			/* Almacena temprarlmente para verificar la colision */
			var objetoColision:Array = _elementosObjetivo;
			if(_elementosPosicion != null)
			{
				objetoColision = _elementosPosicion;
			}
			CodeCraft.stopFrame(_elementosMover,"normal");
			CodeCraft.stopFrame(_elementosObjetivo,"normal");
			for (var i:int = 0; i < objetoColision.length; i++)
			{
				var estadoRespuesta:Boolean = false;
				var posicion:int;
				CodeCraft.stopFrame(_elementosCargadosObjetivo[i],"mal");
				for(var j:int = 0; j < _elementosObjetivosMultiple[i].length; j++)
				{
					posicion = Arrays.indexOf(_elementosCargadosObjetivo[i],_copiaElementosMover[_elementosObjetivosMultiple[i][j]]);
					if(posicion != -1)
					{
						CodeCraft.stopFrame(_elementosCargadosObjetivo[i][posicion],"bien");
					}
				}
			}
			//se verifica si hay funciones qeu devolver
			if(_funcionesRetornar != null)
			{
				var funcionTemporal:Function;
				if(_funcionesRetornar[0] != undefined && _funcionesRetornar[0] != null)
				{
					funcionTemporal = _funcionesRetornar[0];
					funcionTemporal();
				}
				//se verifica si gano o perdio la actividad
				if(Arrays.verifyFill(_resultadoColision,true))
				{
					//gano, por lo que se verifica si hay funcion de gano para devolver
					if(_funcionesRetornar[1] != undefined && _funcionesRetornar[1] != null)
					{
						funcionTemporal = _funcionesRetornar[1];
						funcionTemporal();
					}
				}
				else
				{
					//perdio y se verifica si hay funcion que devolver
					if(_funcionesRetornar[2] != undefined && _funcionesRetornar[2] != null)
					{
						funcionTemporal = _funcionesRetornar[2];
						funcionTemporal();
					}
				}
			}
		}
		
	}
}