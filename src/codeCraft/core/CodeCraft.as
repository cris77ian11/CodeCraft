package codeCraft.core
{
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.system.System;
	import flash.text.TextField;
	
	import codeCraft.debug.Debug;
	import codeCraft.display.Button;
	import codeCraft.error.Validation;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	import codeCraft.utils.Audio;
	
	
	
	public class CodeCraft 
	{
		
		//si se cambia el valor de esta variable la mascara quedara desactivda y se podra ver el contenido fuera de la resolucion prestablecida para los multimedias
		public static var activeMask:Boolean = true;
		private static var maskStage:Shape = new Shape();
		
		//menu the options, sound and fullScreen
		private static var menuOptions:MovieClip;
		private static var buttonSound:MovieClip;
		private static var buttonSoundBackground:MovieClip;
		private static var buttonFullScreen:MovieClip;
		private static var menuOptionsLoaded:Boolean = false;
		private static var fullScreenActive:Boolean = false;
		public static var soundActive:Boolean = false;
		
		//almacene el objeto padre, root o contenedor de la multimedia
		private static var mainObject:Object;
		
		private static var foco:Object = null;
		private static var functionReturnPreload:Function;
		private static var frameCurrent:int = 1;
		
		//opciones del preload
		private static var preloadAnimation:MovieClip;
		private static var textoPreload:TextField = new TextField();
		
		/*
		█████████████████████████████████████████████████████████████████████████████████████████████
		FUNCIONES GENERALES
		█████████████████████████████████████████████████████████████████████████████████████████████
		*/
		
		public static function initialize (object:Object, functionPreloadComplete:* = null):void
		{
			CodeCraft.mainObject = object;
			//create rectangle for mask stage
			maskStage.graphics.beginFill(0x000000, 1);
			maskStage.graphics.drawRect(0, 0, 1024, 640);
			maskStage.graphics.endFill();
			
			mainObject.stage.scaleMode = StageScaleMode.SHOW_ALL;
			mainObject.stage.align = StageAlign.TOP;
			
			if(functionPreloadComplete != null)
			{
				mainObject.stop();
				functionReturnPreload = functionPreloadComplete;
				preloadAnimation = new Preload();
				addChild(preloadAnimation);
				Events.listener(mainObject.loaderInfo,ProgressEvent.PROGRESS, preloadUpdate);
			}
		}
		
		private static function preloadUpdate (event:Event):void
		{
			var byteLoaded:Number = mainObject.loaderInfo.bytesLoaded;
			var byteTotal:Number = mainObject.loaderInfo.bytesTotal;
			var value:Number = Math.round(100*byteLoaded/byteTotal);
			preloadAnimation.animationBar.animation.x = (431 * value)/100;
			preloadAnimation.animationProgressText.progressText.x = (428 * value)/100;
			preloadAnimation.animationProgressText.progressText.progressText.text = value + "%";
			if(byteLoaded >= byteTotal)
			{
				Events.removeListener(mainObject,Event.ENTER_FRAME, preloadUpdate);
				removeAll();
				mainObject.gotoAndStop(2);
				functionReturnPreload();
			}
		}
		
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
								object[i].gotoAndStop(frame[i]);
							}
						} 
						else if (frame == 0) 
						{
							for (var j:uint = 0; j < object.length; j++) 
							{
								if(frameInitial == object[j].totalFrames)
								{
									frameInitial -= (j + 1);
								}
								object[j].gotoAndStop(frameInitial + j);
							}
						} 
						else 
						{
							for (var k:uint = 0; k < object.length; k++) 
							{
								object[k].gotoAndStop(frame);
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
				Validation.error('CodeCraft initialize no se a ejecutado aun');
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
								if(signo == '-')
								{
									_distanciaEspacio = object[i].height + espacio;
									_posY1[i] = object[i - 1].y - _distanciaEspacio;
									_posX2[i] = object[i - 1].x - _distanciaEspacio;
								}
								else
								{
									_distanciaEspacio = object[i].height + espacio;
									_posY1[i] = object[i - 1].y + _distanciaEspacio;
									_posX2[i] = object[i - 1].x + _distanciaEspacio;
								}
							}
							if (i == columnas) 
							{
								//se posiciona de nuevo los elementos
								if(signo == '-')
								{
									_distanciaColumna = object[i - 1].width + 10 + espacioColumna;
									_posX1[i] = object[i - 1].x - _distanciaColumna; 
									_posY2[i] = object[i - 1].y - _distanciaColumna;
								}
								else
								{
									_distanciaColumna = object[i - 1].width + 10 + espacioColumna;
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
									_posX1[i] = _posX1[i - 1];
									_posY2[i] = _posY2[i - 1];
								}
							}
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
							//limpiar el valor de la variable
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
				
				//verify if menu is loaded in the stage
				if(menuOptionsLoaded)
				{
					if (mainObject.contains(menuOptions))
					{
						mainObject.removeChild(menuOptions);
						mainObject.addChild(menuOptions);
					}
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
			else
			{
				Debug.print("El object es un valor null para la funcion removeChild");
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
			if(menuOptionsLoaded)
			{
				mainObject.addChild(menuOptions);
			}
		}
		
		public static function addMenu(container:* = null, sound:* = null, soundBackground:* = null, fullScreen:* = null, position:Array = null):void
		{
			var enabledTemp:Array = new Array(fullScreen,sound,soundBackground);
			if(container == null)
			{
				container = new MenuOpciones();
				sound = container.soundButton;
				fullScreen = container.fullScreenButton;
				if(enabledTemp[2] == false)
				{
					sound.x = 34;
					fullScreen.x = 91;
					if(enabledTemp[0] == false)
					{
						sound.x = 62;
					}
				}
				soundBackground = container.musicButton;
			}
			if(position == null)
			{
				position = new Array(mainObject.stage.stageWidth - (container.width + 5), 5);
			}
			menuOptions = container;
			if(fullScreen != null && !(fullScreen is Boolean))
			{
				buttonFullScreen = fullScreen;
				Events.listener(buttonFullScreen,MouseEvent.CLICK,fullScreenMode,true,true);
				mainObject.stage.addEventListener(FullScreenEvent.FULL_SCREEN, detectFullScreen);
				mainObject.stage.addEventListener(KeyboardEvent.KEY_DOWN, fullScreenKeyBoard);
			}
			else 
			{
				buttonFullScreen = new MovieClip();
			}
			if(sound != null && !(sound is Boolean))
			{
				buttonSound = sound;
				Events.listener(buttonSound,MouseEvent.CLICK, Audio.stopPresetation,true,true);
				Button.over(buttonSound,1,null,true);
			}
			else 
			{
				buttonSound = new MovieClip();
			}
			if(soundBackground != null && !(soundBackground is Boolean))
			{
				buttonSoundBackground = soundBackground;
				Events.listener(buttonSoundBackground,MouseEvent.CLICK, Audio.stopBackground,true,true);
				Button.over(buttonSoundBackground,1,2,true);
			}
			else 
			{
				buttonSoundBackground = new MovieClip();
			}
			addChild(menuOptions,null,position[0],position[1]);
			menuOptionsLoaded = true;
			soundActive = true; 
			
			var buttonsTemp:Array = new Array(buttonFullScreen, buttonSound,buttonSoundBackground);
			visibility(buttonsTemp,enabledTemp);
			
			if(mainObject.totalFrames > 1)
			{
				Events.listener(mainObject,Event.ENTER_FRAME, detectChangeFrameMainObject);
			}
		}
		
		private static function detectChangeFrameMainObject(event:Event):void 
		{
			if(mainObject.currentFrame != frameCurrent)
			{
				frameCurrent = mainObject.currentFrame;
				if (mainObject.contains(menuOptions)) 
				{
					mainObject.removeChild(menuOptions);
					mainObject.addChild(menuOptions);
				}
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
				Validation.error('CodeCraft initialize no se a ejecutado aun');
			}
		}
		
		public static function centerElement (object:*):Array 
		{
			var arrayTemp:Array = new Array ();
			arrayTemp[0] = object.x + (object.width / 2);
			arrayTemp[1] = object.y + (object.height / 2);
			return arrayTemp;
		}
		
		/*
		█████████████████████████████████████████████████████████████████████████████████████████████
		FULL SCREEN AND BUTTONSOUND
		█████████████████████████████████████████████████████████████████████████████████████████████
		*/
		
		/**
		 * FullScreen presentation, embeded in html
		 * <object> 
		 *	    ... 
		 *	    <param name="allowFullScreen" value="true" /> 
		 *	    <embed ... allowfullscreen="true" /> 
		 *	</object>
		 * 
		 */
		private static function fullScreenMode (event:MouseEvent):void
		{
			if(fullScreenActive)
			{
				mainObject.stage.displayState = StageDisplayState.NORMAL;
			}
			else
			{
				mainObject.stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			relocatedElement();
		}
		
		private static function fullScreenKeyBoard (event:KeyboardEvent):void 
		{
			//La tecla 27 es la tecla de esc
			if(event.keyCode == 27)
			{
				relocatedElement();
			}
		}
		
		private static function relocatedElement():void
		{
			//relocated pop element
			//menuOptions.x = mainObject.stage.stageWidth - (menuOptions.width + 5);
		}
		
		private static function detectFullScreen (event:FullScreenEvent):void
		{
			if(event.fullScreen)
			{
				//fullScreen Active
				fullScreenActive = true;
			}
			else 
			{
				//fullScreeen inactive
				fullScreenActive = false;
			}
		}
		
		
		/*
		█████████████████████████████████████████████████████████████████████████████████████████████
		FUNCIONES DE PROPIEDADES O ATRIBUTOS
		█████████████████████████████████████████████████████████████████████████████████████████████
		*/
		
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
			catch(error:Error)
			{
				Validation.error('No se puede aplicar property al elemento o elementos');
			}
			
		}
		
		/*
		█████████████████████████████████████████████████████████████████████████████████████████████
		FUNCIONES PARA NUMEROS Y ALEATORIO
		█████████████████████████████████████████████████████████████████████████████████████████████
		*/
		
		
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