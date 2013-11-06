package codeCraft.core
{

	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import codeCraft.debug.Debug;
	import codeCraft.display.Menu;
	import codeCraft.error.Validation;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;


	public class CodeCraft
	{

		/* Indicara la resolucion por defecto que debera tener la multimedia, esto con el fin de aplicar la mascara */
		public static var _resolutionScreen:Array = new Array(1000, 640);

		//si se cambia el valor de esta variable la mascara quedara desactivda y se podra ver el contenido fuera de la resolucion prestablecida para los multimedias
		public static var activeMask:Boolean = true;
		private static var maskStage:Shape = new Shape();

		/* Variables utilizadas para el manejo de los menus de la clase Menu */
		public static var mainMenu:MovieClip = new MovieClip;
		public static var optionsMenu:MovieClip = new MovieClip;
		public static var mainMenuLoaded:Boolean = false;
		public static var optionsMenuLoaded:Boolean = false;

		//almacene el objeto padre, root o contenedor de la multimedia
		private static var mainObject:Object;

		private static var foco:Object = null;
		private static var functionReturnPreload:Function;
		private static var frameCurrent:int = 1;

		/* MovieClip que realiza la ainmacion de la precarga */
		private static var _preloadAnimation:MovieClip;
		/* Modificacion del menu contextual, el clic derecho  */
		private static var _menuContext:ContextMenu = new ContextMenu();


		/*********************************************************************************************************
		 *
		 * funciones de uso general de la libreria
		 *
		 * ******************************************************************************************************/


		/**
		 * Es funcion obligatoria para iniciar la libreria de la codecraft y hacer uso de las funciones, la precarga esta
		 * prediseñada y almacenada en un swc, la precarga se debe configurar en el panel de ActionScrip la carga de
		 * la clase en el fotograma 2 y tener dos fotogramas disponibles en la linea de tiempo del documento fla.
		 * @param object Indica cual es el objeto principal donde actuara la libreria, una clase, un movieclip o el stage
		 * @param functionPreloadComplete Indica la funcion que se devolvera cuando finalice el proceso de precarga, por defecto es null indicando que no hay precarga
		 */
		public static function initialize (object:Object, functionPreloadComplete:* = null):void
		{ 
			CodeCraft.mainObject = object;
			//crea el recuadro que hace de mascara para recortar elescenario
			maskStage.graphics.beginFill(0x000000, 1);
			maskStage.graphics.drawRect(0, 0, _resolutionScreen[0], _resolutionScreen[1]);
			maskStage.graphics.endFill();

			mainObject.stage.scaleMode = StageScaleMode.SHOW_ALL;
			mainObject.stage.align = StageAlign.TOP;

			if(functionPreloadComplete != null)
			{
				mainObject.stop();
				functionReturnPreload = functionPreloadComplete;
				_preloadAnimation = new Preload();
				addChild(_preloadAnimation);
				Events.listener(mainObject.loaderInfo,ProgressEvent.PROGRESS, preloadUpdate);
			}

			//se cambia el mensaje del menu de contextualizacion
			var menuItem:ContextMenuItem =  new  ContextMenuItem("Línea de producción Quindío");
			_menuContext.customItems.push(menuItem);
			_menuContext.hideBuiltInItems();
			mainObject.contextMenu = _menuContext;

			//se habilita el dominio de seguridad externo para que se pueda accedera los demas elementos
			Security.allowDomain("*");
		}

		/**
		 * Se utiliza para mostrar la animacion de la carga de la barra de progreso
		 * @param event Object del MouseEvent
		 */
		private static function preloadUpdate (event:Event):void
		{
			try
			{
				var byteLoaded:Number = mainObject.loaderInfo.bytesLoaded;
				var byteTotal:Number = mainObject.loaderInfo.bytesTotal;
				var value:Number = Math.round(100*byteLoaded/byteTotal);
				_preloadAnimation.animationBar.animation.x = (431 * value)/100;
				_preloadAnimation.animationProgressText.progressText.x = (428 * value)/100;
				_preloadAnimation.animationProgressText.progressText.progressText.text = value + "%";
				//al terminar la carga total del documento fla
				if(byteLoaded >= byteTotal)
				{
					Events.removeListener(mainObject,Event.ENTER_FRAME, preloadUpdate);
					removeAll();
					mainObject.gotoAndStop(2);
					functionReturnPreload();
					_preloadAnimation = null;
				}
			}
			catch(e:Error)
			{
				Debug.print("Error al momento de realizar la precarga del contenido.","CodeCraft.preloadUpdate","Error CodCraft ");
			}
		}

		/**
		 *
		 */
		public static function getMainObject():*
		{
			if(CodeCraft.mainObject == null)
			{
				Validation.error('CodeCraft initialize no se a ejecutado aun');
				return new Object();
			}
			else
			{
				return CodeCraft.mainObject;
			}
		}

		public static function getChildren (parent:*, frame:int = 0):Array
		{
			var arrayChildren:Array = new Array();
			if(parent is Object || parent is MovieClip)
			{
				if(frame != 0)
				{
					parent.gotoAndStop(frame)
				}
				for(var i:uint = 0; i < parent.numChildren; i++)
				{
					var object:* = parent.getChildAt(i);
					arrayChildren.push(object);
				}
			}
			else
			{
				Validation.error('El elemento parent de getChildren no es un Object o movieClip por lo que no se puede obtener los children');
			}
			return arrayChildren;
		}

		public static function store(object:Object, cantidad:Number = 1, nameObject:String = "clip_"):Array
		{
			var arrayTemp:Array = new Array();
			try
			{
				for (var i:uint = 0; i < cantidad; i++)
				{
					var newObject:Object = new object();
					newObject.name = nameObject + i;
					arrayTemp.push(newObject);
				}
			}
			catch(error:Error)
			{
				Validation.error('No es posible cargar el object de vinculacion AS de la biblioteca');
			}
			return arrayTemp;
		}

		public static function stopFrame(object:*, frame:* = 1, frameInitial:Number = 1):void
		{
			try
			{
				if(object != null)
				{
					if (object is Array)
					{
						if (frame is Array)
						{
							for (var i:uint = 0; i < object.length; i++)
							{
								if(object[i] is Array)
								{
									stopFrame(object[i],frame[i],frameInitial);
								}
								else
								{
									object[i].gotoAndStop(frame[i]);
								}
							}
						}
						else if (frame is Number && frame == 0)
						{
							for (var j:uint = 0; j < object.length; j++)
							{
								if(object[j] is Array)
								{
									stopFrame(object[j],frame,frameInitial);
								}
								else
								{
									if(frameInitial == object[j].totalFrames)
									{
										frameInitial -= (j + 1);
									}
									object[j].gotoAndStop(frameInitial + j);
								}
							}
						}
						else
						{
							for (var k:uint = 0; k < object.length; k++)
							{
								if(object[k] is Array)
								{
									stopFrame(object[k],frame,frameInitial);
								}
								else
								{
									try
									{
										object[k].gotoAndStop(frame);
									}
									catch(error:Error)
									{
										Debug.print("El label no existe.","CodeCraft.stopFrame","Falla CodeCraft ");
									}
								}
							}
						}
					}
					else if (frame is Array)
					{
						object.gotoAndStop(frame[0]);
					}
					else
					{
						object.gotoAndStop(frame);
					}
				}
			}
			catch (error:Error)
			{
				Validation.error('El object de la funcion stopFrame no es un elemento valido');
			}
		}

		public static function visibility(object:*, enabled:* = false):void
		{
			if (object != null)
			{
				var valueVisible:Array;
				if (enabled is Array)
				{
					valueVisible = enabled;
				}
				else
				{
					if(enabled == null)
					{
						enabled = false;
					}
					valueVisible = Arrays.fill(enabled, object.length);
				}
				if(object is Array)
				{
					for (var i:uint = 0; i < object.length; i++)
					{
						if(object[i] != null)
						{
							object[i].visible = valueVisible[i];
						}
					}
				}
				else
				{
					object.visible = valueVisible[0];
				}
			}
			else
			{
				Validation.error('Se a pasado null o un valor no valido de la funcion visibility');
			}
		}

		//Funciones para la carga de elementos al objeto padre

		public static function addChild(object:*, container:* = null, posX:* = 0, posY:Number = 0, eje:String = 'y', espacio:Number = 10, columnas:Number = NaN, espacioColumna:Number = 10):void
		{
			var signo:String = '+';
			if(eje.length > 1)
			{
				signo = eje.substr(0,1);
				eje = eje.substr(1);
			}
			if(CodeCraft.mainObject == null)
			{
				Debug.print("CodeCraft initialize no se a ejecutado aun.","CodeCraft.addChild","Error CodeCraft ");
			}
			else
			{
				var _numeroColumna:Number;
				var _distanciaColumna:Number;
				var _distanciaEspacio:Number;
				//almacenara las posiciones del eje x
				var _posX1:Array = new Array();
				var _posX2:Array = new Array();
				//almacenara las posiciones para el eje y
				var _posY1:Array = new Array();
				var _posY2:Array = new Array();
				//se verifica si se agregaron columnas
				if (!isNaN(columnas) && object is Array && columnas != 0)
				{
					if (object.length - columnas == 1)
					{
						columnas = 2;
						_numeroColumna = 1;
					}
					else
					{
						columnas = object.length / columnas;
						columnas = Math.round(columnas);
						_numeroColumna = columnas;
					}
				}
				if (container == null)
				{
					container = mainObject;
				}
				//si el elemento que se va a cargar es una clase, es decir se pasa la vinculacion de la biblioteca
				//se conviente en object para ser cargado
				if(object is Class)
				{
					object = new object();
				}
				if (object is Array)
				{
					//carga si es una array
					for (var i:uint = 0; i < object.length; i++)
					{
						container.addChild(object[i]);
						if (posX is Array)
						{
							object[i].x = posX[i][0];
							object[i].y = posX[i][1];
						}
						else
						{
							if (i == 0 || columnas == i)
							{
								_posY1[i] = posY;
								_posX2[i] = posX;
							}
							else
							{
								//se verifica el sentido de la carga del elemento si es el eje x entonces el
								//espacio entre los elementos esta medido por su largo, de ser el eje y
								//el espacio esta medido por su ancho
								if(eje == "x")
								{
									_distanciaEspacio = object[i].width + espacio;
								}
								else
								{
									_distanciaEspacio = object[i].height + espacio;
								}
								//se verifica el sentido que se quiere para cargar los elementos, por defecto cargaran en x
								//de izquierda a derecha, y en y de arriba a abajo si se pone el signo menos ambos cargaran
								//en el lado contrario
								if(signo == '-')
								{
									_posY1[i] = object[i - 1].y - _distanciaEspacio;
									_posX2[i] = object[i - 1].x - _distanciaEspacio;
								}
								else
								{
									_posY1[i] = object[i - 1].y + _distanciaEspacio;
									_posX2[i] = object[i - 1].x + _distanciaEspacio;
								}
							}
							if (i == columnas)
							{
								//se verifica el sentido de la carga del elemento si es el eje x entonces el
								//espacio entre los elementos esta medido por su largo, de ser el eje y
								//el espacio esta medido por su ancho
								if(eje == "x")
								{
									_distanciaColumna = object[i - 1].height + espacioColumna ;
								}
								else
								{
									_distanciaColumna = object[i - 1].width + espacioColumna;
								}
								//se verifica el sentido que se quiere para cargar los elementos, por defecto cargaran en x
								//de izquierda a derecha, y en y de arriba a abajo si se pone el signo menos ambos cargaran
								//en el lado contrario
								if(signo == '-')
								{
									_posX1[i] = object[i - 1].x - _distanciaColumna;
									_posY2[i] = object[i - 1].y - _distanciaColumna;
								}
								else
								{
									_posX1[i] = object[i - 1].x + _distanciaColumna;
									_posY2[i] = object[i - 1].y + _distanciaColumna;
								}
								columnas += _numeroColumna;
							}
							else
							{
								if (i == 0)
								{
									_posX1[i] = posX;
									_posY2[i] = posY;
								}
								else
								{
									_posX1[i] = object[i - 1].x;
									_posY2[i] = object[i - 1].y;
								}
							}
							//Despues de capturar las pocisiones de las los elementos se cargan aqui
							if (eje == 'y')
							{
								object[i].x = _posX1[i];
								object[i].y = _posY1[i];
							}
							else
							{
								object[i].x = _posX2[i];
								object[i].y = _posY2[i];
							}
						}
					}
					object = null;
				}
				else
				{
					//automaticamente carga si es un solo objeto
					container.addChild(object);
					if (posX is Array)
					{
						if (posX[0] is Array)
						{
							object.x = posX[0][0];
							object.y = posX[0][1];
						}
						else
						{
							object.x = posX[0];
							object.y = posX[1];
						}
					}
					else
					{
						object.x = posX;
						object.y = posY;
					}
					object = null;
				}

				//verify if stats if add for reload
				if(Debug.statsAdded)
				{
					mainObject.removeChild(Debug.stats);
					mainObject.addChild(Debug.stats);
				}

				//la mascara define la zona de 1024 x 640 en la que se visualiza el contenido
				if (activeMask)
				{
					if (mainObject.contains(maskStage))
					{
						mainObject.removeChild(maskStage);
						mainObject.addChild(maskStage);
					}
					else
					{
						mainObject.addChild(maskStage);
					}
					mainObject.mask = maskStage;
				}

				//verifica si se tiene cargado el menu de opciones para volver a cargarlo y que asi este sobre los demas elementos
				if(optionsMenuLoaded && mainObject.contains(optionsMenu))
				{
					mainObject.removeChild(optionsMenu);
					mainObject.addChild(optionsMenu);
				}

				//verifica si se tiene cargado el menu principal para volver a cargarlo y que asi este sobre los demas elementos
				if(mainMenuLoaded && mainObject.contains(mainMenu))
				{
					mainObject.removeChild(mainMenu);
					mainObject.addChild(mainMenu);
				}
			}
			System.pauseForGCIfCollectionImminent(0.75);
		}

		public static function removeChild(object:*, container:* = null):void
		{
			if(object != null)
			{
				if (container == null)
				{
					container = mainObject;
				}
				if (object is Array)
				{
					for (var i:uint = 0; i < object.length; i++)
					{
						if (container.contains(object[i]))
						{
							container.removeChild(object[i]);
						}
					}
					object = null;
				}
				else
				{
					if (container.contains(object))
					{
						container.removeChild(object);
						object = null;
					}
				}
			}
			System.pauseForGCIfCollectionImminent(0.75);
		}

		public static function removeAll():void
		{
			//se ejecuta la accion de eliminar listener
			for (var i:uint = mainObject.numChildren; i > 0; i--)
			{
				mainObject.removeChildAt(i - 1);
			}
			//se verifica si se tiene los menus cargados, esto para que el elemento que se elimina
			//sea cargado nuevamente
			if(optionsMenuLoaded)
			{
				mainObject.addChild(optionsMenu);
			}
			if(mainMenuLoaded)
			{
				mainObject.addChild(mainMenu);
			}
		}


		public static function focoActive (object:* = null):void
		{
			if(mainObject != null)
			{
				if(object == null)
				{
					object = mainObject;
				}
				foco = object;
				mainObject.stage.stageFocusRect = false;
				mainObject.stage.focus = foco;
				//agerga listener para seguir cargando el foco
				Events.removeListener(mainObject.stage,MouseEvent.CLICK,focoNavigation,false);
				Events.listener(mainObject.stage,MouseEvent.CLICK,focoNavigation,false,false);
			}
			else
			{
				Debug.print("CodeCraft initialize no se a ejecutado aun.","CodeCraft.focoNavigation", "Falla CodeCraft ");
			}
		}

		internal static function focoNavigation(event:MouseEvent):void
		{
			if(mainObject != null)
			{
				mainObject.stage.stageFocusRect = false;
				if (foco != null)
				{
					mainObject.stage.focus = foco;
				}
				else
				{
					mainObject.stage.focus = mainObject;
				}
			}
			else
			{
				Debug.print("CodeCraft initialize no se a ejecutado aun.","CodeCraft.focoNavigation", "Falla CodeCraft ");
			}
		}

		public static function centerElement (object:*):Array
		{
			var arrayTemp:Array = new Array ();
			arrayTemp[0] = object.x + (object.width / 2);
			arrayTemp[1] = object.y + (object.height / 2);
			return arrayTemp;
		}




		/*********************************************************************************************************
		 *
		 * Contenido para funciones que aplican propiedades a los elementos de la multimedia
		 *
		 * ******************************************************************************************************/



		public static function scaleMode(object:*, value:Number = 1):void
		{
			property(object,{scaleX: value, scaleY: value});
		}
		public static function alphaMode(object:*, value:Number = 1):void
		{
			property(object,{alpha:value});
		}
		public static function rotationMode(object:*, value:Number = 1):void
		{
			property(object, {rotation: value});
		}

		public static function property (object:*, value:Object):void
		{
			try
			{
				if(object != null)
				{
					if(object is Array)
					{
						for (var i:uint = 0; i < object.length; i++)
						{
							for (var keyOne:Object  in value)
							{
								object[i][keyOne] = value[keyOne];
							}
						}
					}
					else
					{
						for (var keyTwo:Object in value)
						{
							object[keyTwo] = value[keyTwo];
						}
					}
				}
				else
				{
					Debug.print("El elemento object a aplicar las propiedades tiene el valor null.","CodeCraft.property","Falla CodeCraft ");
				}
			}
			catch(error:Error)
			{
				Debug.print("No se puede aplicar una propiedad al elemento o elementos","CodeCraft.property","Falla CodeCraft ");
			}

		}



		/*********************************************************************************************************
		 *
		 * Funciones matematicas de la liberia
		 *
		 * ******************************************************************************************************/




		public static function numbers(initial:int = 1, final:int = 10):Array
		{
			var _arrayTemp:Array = new Array();
			//se le aumenta un punto mas para que pueda entrar al for y completarlo
			var _fn:int = final + 1;
			for (var i:uint = initial; i < _fn; i++)
			{
				_arrayTemp.push(i);
			}
			return _arrayTemp;
		}

		public static function numberRandom (final:int = 100, initial:int = 1):Number
		{
			var _numero:Number = Math.round(Math.random() * (final - initial)) + initial;
			return _numero;
		}

	}
}