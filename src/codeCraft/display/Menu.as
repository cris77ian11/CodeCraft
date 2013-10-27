package codeCraft.display
{
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.events.Events;
	import codeCraft.media.Audio;
	
	public class Menu
	{	
		
		
		/*********************************************************************************************************
		 * 
		 * Contenido de carga del menu principal diseñado para el curso de ingles, permite que esten sobre cualquier
		 * elemento de la multimedia
		 * 
		 * ******************************************************************************************************/
		
		
		/* MovieClip principal que almacena o contiene todos los botones del menu, no almacena los submenus */
		private static var _container:MovieClip;
		/* se ingresan los botones de izquierda a derecha */
		private static var _buttons:Array;
		/* campo 1 container, campo 2 menu sonido, campo 3 menu grabacion*/
		private static var _position:Array;
		/* Almacena el estado de los botones del menu para saber si son o no visibles */
		private static var _statusButtons:Array;
		
		
		/**
		 * Se encarga de cargar un contenedor que almacena los botones del menu principal de navegacion, el contenedor
		 * es cargado por encima de los demas elementos, cuando se detecte que se cargo un nuevo elemento autimaticamente
		 * el contenedor es eliminado y vuele a cargar de nuevo, tambien se encarga de poner el efecto de desactivado
		 * para los botones del menu
		 * @param container MovieClip principal con los botones del menu
		 * @param buttons Array con los botones del menu, de izquerda a derecha
		 * @param position Array con posicion para ubicar el container
		 * @param statusButtons Array con valores de tipo Boolean que indican el estado, true activo, false desabilitado de los botones
		 */
		public static function loadMainMenu (container:MovieClip, buttons:Array, position:Array = null, statusButtons:Array = null):void
		{
			_container = container;
			_buttons = buttons;
			_position = position;
			//se verifica si no es null, de serlo se crea un array nuevo para evitar problemas en loadButtons
			if(statusButtons == null)
			{
				statusButtons = new Array();	
			}
			_statusButtons = statusButtons;
			//se verifica si el contenedor ya se cargo y si se puede cargar
			if(!(CodeCraft.getMainObject().contains(_container)) && position != null)
			{
				CodeCraft.addChild(_container,null,_position[0],_position[1]);
				CodeCraft.mainMenuLoaded = true;
			}
			loadButtons();
		}
		
		/**
		 * Vuelve a cargar el estado de los botones
		 * @param statusButtons Array con valores de tipo Boolean que indican el estado, true activo, false desabilitado de los botones 
		 */
		public static function mainMenuReload (statusButtons:Array = null):void
		{
			if(statusButtons != null)
			{
				_statusButtons = statusButtons;
			}
			loadButtons();
		}
		
		/**
		 * Se encarga de leer el estado de los botones
		 */
		private static function loadButtons():void 
		{
			
			for (var i:uint = 0; i < _buttons.length; i++)
			{
				//se verifica que la posicion del array no este vacia antes de aplicar las acciones
				if(_statusButtons[i] != undefined && _statusButtons[i])
				{
					CodeCraft.property(_buttons[i], {alpha: 1});
				}
				else
				{
					CodeCraft.property(_buttons[i], {alpha: 0.2});
				}
			}
		}
		
		
		/*********************************************************************************************************
		 * 
		 * Contenido de carga del menu de opciones del programa, administra principalmente los botones de fullScreen
		 * sonido y sonido del fondo. permite que siempre este sobre los demas elementos de la multimedia
		 * 
		 * ******************************************************************************************************/
		
		
		private static var _containerMenuOptions:MovieClip;
		private static var _buttonSound:MovieClip;
		private static var _buttonSoundBackground:MovieClip;
		private static var _buttonFullScreen:MovieClip;
		private static var _positionMenuOptions:Array;
		/* Detecta el estado de la pantalla si esta normal false o en pantalla completa true */
		private static var _fullScreenActive:Boolean = false;
		
		
		/**
		 * Carga el menu de las opciones de la presentacion, encargado de manejar la pantalla completa y el control del sonido
		 * general de la multimedia, el sonido del fondo solo se recude el volumen, mientras que el boton del sonido de la
		 * presentacion detiene el sonido por completo y luego lo vuelve a reproducir desde el inicio, si se llega a cargar
		 * una presentacion de tipo sequence, el boton de sonido solo reduce el volumen pero el audio seguira sonando de fondo.
		 * @param container MovieClip que se encarga de almacenar los tres botones del menu
		 * @param sound MovieClip que manejara las funciones del sonido de las presentaciones, debe tener dos etiquetas en los fotogramas, normal y silencio
		 * @param soundBackground MovieClip que maneja el sonido del fondo de la presentacion, debe tener dos etiquetas en los fotogramas, normal y silencio
		 * @param fullScreen MovieClip encargado de activar o desactivar la pantalla completa en la presentacion
		 * @param position Array con las posicion para ubicar el contenedor del menu
		 */
		public static function loadOptionsMenu (container:* = null, sound:* = null, soundBackground:* = null, fullScreen:* = null, position:Array = null):void
		{
			_containerMenuOptions = container;
			_buttonSound = sound;
			_buttonSoundBackground = soundBackground;
			_buttonFullScreen = fullScreen;
			//se verifica si el array de la posicion es null, si lo es se asigna un valor por defecto para ubicar el elmento container
			if(position == null)
			{
				trace(1);
				position = new Array(CodeCraft.getMainObject().stage.stageWidth - (container.width + 5), 5);
			}
			_positionMenuOptions = position;
			
			//Carga el listener del boton de pantalla completa si este es un movieclip
			if(_buttonFullScreen is MovieClip)
			{
				Events.listener(_buttonFullScreen,MouseEvent.CLICK,fullScreenMode,true,true);
				Events.listener(CodeCraft.getMainObject().stage,FullScreenEvent.FULL_SCREEN, detectFullScreen);
			}
			//se carga los listener para el boton de sonido
			if(_buttonSound is MovieClip)
			{
				//el listener es redireccionado a la clase audio que es la encargada de manipular esto
				Events.listener(_buttonSound,MouseEvent.CLICK, Audio.stopPresetation,true,true);
				Button.over(_buttonSound,1,null,true);
			}
			//se carga el lisener para el boton del sonido 
			if(_buttonSoundBackground is MovieClip)
			{
				Events.listener(_buttonSoundBackground,MouseEvent.CLICK, Audio.stopBackground,true,true);
				Button.over(_buttonSoundBackground,1,2,true);
			}
			
			CodeCraft.addChild(_containerMenuOptions,null,_positionMenuOptions);
			CodeCraft.optionsMenuLoaded = true;
		}
		
		
		/**
		 * Activa el fullScreen al presionar el boton, es necesario para que esto funcione agregar las siguientes
		 * sentencias Html en el lugar donde se agrego el swf para poder activar esta opcion
		 * 
		 * <object> 
		 *	    ... 
		 *	    <param name="allowFullScreen" value="true" /> 
		 *	    <embed ... allowfullscreen="true" /> 
		 *	</object>
		 * 
		 * @param event Object del MouseEvent
		 */
		private static function fullScreenMode (event:MouseEvent):void
		{
			if(_fullScreenActive)
			{
				//restaura la pantalla a su estado normal
				CodeCraft.getMainObject().stage.displayState = StageDisplayState.NORMAL;
			}
			else
			{
				//ubica la pantalla en formato completo
				CodeCraft.getMainObject().stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}

		/**
		 * Se encarga de dectectar el estado actual de la pantalla si se encuentra en estado normal
		 * o en pantalla completa
		 * @param event Object del FullScreenEvent
		 */
		private static function detectFullScreen (event:FullScreenEvent):void
		{
			if(event.fullScreen)
			{
				//pantalla completa activo
				_fullScreenActive = true;
			}
			else 
			{
				//pantalla normal
				_fullScreenActive = false;
			}
		}
		
		
	}
}