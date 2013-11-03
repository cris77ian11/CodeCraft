package codeCraft.media
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.events.Events;
	
	
	public class Record
	{
		
		/* Almacenara los botones para grabar y reproducir, se da el valor null para indicar que no se a cargado */
		private static var _container:MovieClip = null;
		private static var _buttonRecord:MovieClip;
		private static var _buttonPlay:MovieClip;
		private static var _buttonMicrophone:MovieClip;
		/* Indica que se ha grabado un audio y activa el boton de reproduccion */
		private static var _soundLoad:Boolean = false;
		private static var _microphone:Microphone;
		private static var _sound:Sound = new Sound();
		private static var _soundChannel:SoundChannel = new SoundChannel();
		/* Indicara si se dio permiso o no al microfono para la grabacion */
		private static var _statusMicrophone:Boolean = false;
		private static var _soundBytes:ByteArray = new ByteArray();
		private static var _soundO:ByteArray = new ByteArray();
		
		
		/**
		 * Carga el boton de microfono para realiar la grabacion del audio y tambien carga el contenedor de los
		 * botones de grabacion y reproduccion del audio.
		 * @param buttonMicrophone MovieClip que se encarga de cargar el container
		 * @param containerMicrophone Movieclip que almacena los botones de grabar y reproducir el audio
		 * @param buttonRecord MovieClip con dos fotogramas con etiquetas grabar y detener, inicia la grabacion del audio
		 * @param buttonPlay MovieClip con dos fotogramas con etiquetas play y pause, inicia la reproduccion del audio que se haya grabado
		 * @param position Array con la posicion para ubicar el contenedor y el boton del microfono, campo 1 para microfono, campo 2 para contenedor
		 */
		public static function load (buttonMicrophone:MovieClip, containerMicrophone:MovieClip, buttonRecord:MovieClip, buttonPlay:MovieClip, position:Array = null):void 
		{
			_buttonMicrophone = buttonMicrophone;
			_container = containerMicrophone;
			_buttonRecord = buttonRecord;
			_buttonPlay = buttonPlay;
			
			//se optiene los permisos para uso del microfono
			_microphone = Microphone.getMicrophone();
			
			//verificar si los elementos estan cargados en el stage de lo contrario cargarlos
			if(_buttonMicrophone != null)
			{
				if(!(CodeCraft.getMainObject().contains(_buttonMicrophone)))
				{
					CodeCraft.addChild(_buttonMicrophone,null,position[0]);
				}	
			}
			if(!(CodeCraft.getMainObject().contains(_container)))
			{
				CodeCraft.addChild(_container,null,position[1]);
			}
			//se detiene el boton de play y grabar y agrea alpha para el efecto de desactivar el boton de play
			_buttonRecord.gotoAndStop("grabar");
			_buttonPlay.gotoAndStop("play");
			_buttonPlay.alpha = 0.2;
			//se carga un listener que detecta si se permitio o no el uso del microfono asi como su existencia
			_microphone.addEventListener(StatusEvent.STATUS, statusMicrophone);
			_statusMicrophone = true;
			if(_buttonMicrophone == null)
			{
				//reinicia los valores antes de realizar la animacion
				CodeCraft.property(_container,{alpha:1, scaleY: 1, scaleX: 1});
				_container.visible = true;
				TweenMax.from(_container,0.7,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeOut});
				Events.listener(_buttonRecord,MouseEvent.CLICK, clicRecord,true,true);
			}
			else
			{
				//se oculta el contenedor de los botones de grabacion
				_container.visible = false;
				//se inicia el microfono desactivado por defecto
				CodeCraft.property(_buttonMicrophone,{alpha: 1});
				Events.listener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true,true);
			}
		}
		
		/**
		 * Elimina el elemento y las funciones que se encargar de realizar la grabación
		 */
		public static function remove ():void 
		{
			//se verifica si elemento ya fue creado para poder eliminarlo
			if (_container != null)
			{
				Events.removeListener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true);
				//se verifica si el elemento esta actualmente visible para hacer la animacion de que se oculta
				if(_container.visible)
				{
					stopPlay();
					stopRecord();
					TweenMax.to(_container,0.5,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: removeComplete});
				}
				//si el elemento no esta visible se procede a llamar a la funcion para eliminar directamente
				else
				{
					removeComplete();
				}
			}
		}
		
		/**
		 * Devuelve el estado del microfono, true para indicar que se autorizo el uso, false para indicar
		 * que no se autirizo el uso del microfono y se encuentra desabilitado
		 */
		public static function getStatusMicrophone():Boolean
		{
			return _statusMicrophone;
		}
		
		/**
		 * Se encarga de detectar que permiso se le dio al microfono, o si se encuentra activo
		 * @param event Object del StatusEvent
		 */
		private static function statusMicrophone (event:StatusEvent):void
		{
			//el uso del microfono esta permitido
			if(event.code == "Microphone.Unmuted")
			{
				CodeCraft.property(_buttonMicrophone,{alpha: 1});
				Events.listener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true,true);
				_statusMicrophone = true;
			}
			//no se permitio el uso del microfono
			else 
			{
				//se desabilida el boton del microfono para no ser usado
				CodeCraft.property(_buttonMicrophone,{alpha: 0.2});
				Events.removeListener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true);
				_statusMicrophone = false;
				//habilita el panel de seguridad de flash para permitir recordar la seleccion
				Security.showSettings(SecurityPanel.PRIVACY);
			}
		}
		
		/**
		 * Se activa al presionar el boton del icono del microfono, y inicia la animacion para ocultar o mostrar el 
		 * contenedor de los controles de grabacion del sonido, se elimina el listener del microfono para poder
		 * realizar la animacion, y se carga nuevamente cuando esta termine
		 * @param event Object del MouseEvent 
		 */
		private static function clicMicrophone(event:MouseEvent):void 
		{
			//se elimina el lister pero se carga nuevamente apenas termine la animacion
			Events.removeListener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true);
			//si el contenido con los dos botones de play y grabar son visibles
			if(_container.visible)
			{
				stopPlay();
				stopRecord();
				TweenMax.to(_container,0.5,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: showContainerComplete});
			}
			else
			{
				//reinicia los valores antes de realizar la animacion
				CodeCraft.property(_container,{alpha:1, scaleY: 1, scaleX: 1});
				CodeCraft.property(_buttonPlay,{alpha: 0.1});
				_container.visible = true;
				TweenMax.from(_container,0.7,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeOut, onComplete: showContainerComplete});
			}
		}
		
		/**
		 * Se ejecuta despues de terminar la animacion de mostrar el menu de grabacion y agrega nuevamente
		 * el listener para el boton del microfono y asi poder cerrar el menu y carga el listener de los
		 * botones del menu
		 */
		private static function showContainerComplete ():void 
		{
			Events.listener(_buttonMicrophone,MouseEvent.CLICK, clicMicrophone,true,true);
			//si el boton es visible
			if(_container.alpha == 1)
			{
				Events.listener(_buttonRecord,MouseEvent.CLICK, clicRecord,true,true);
			}
			else
			{
				Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
				Events.removeListener(_buttonRecord,MouseEvent.CLICK, clicRecord,true);
				_container.visible = false;
			}
		}

		/**
		 * Se ejecuta al presionar el boton de play y se encarga de reproducir el audio grabado por
		 * el microfono
		 * @param event Object del MouseEvent
		 */		
		private static function clicPlay (event:MouseEvent):void 
		{
			if(_buttonPlay.currentLabel == "play")
			{
				//se detienen los audios para que se pueda escuchar solo el audio de la grabacion
				Audio.stopAllSound(false);
				_soundO.position = 0;
				Events.listener(_sound, SampleDataEvent.SAMPLE_DATA, initializePlay);
				_soundChannel=_sound.play();
				Events.listener(_soundChannel,Event.SOUND_COMPLETE, playSoundComplete);
				_buttonPlay.gotoAndStop("pause");
			}
			else
			{
				stopPlay();
			}
		}
		
		/**
		 * Se ejecuta al presionar el boton de grabar, este detecta que si se presiona el boton en el
		 * estado detener detiene la grabacion y indica a la variable _sounLoad que ya se termino de grabar
		 * @param event Object del MouseEvent
		 */
		private static function clicRecord (event:MouseEvent):void 
		{
			//se detiene el audio del fondo y el audio de presentacion para evitar que queden grabados
			Audio.stopAllSound(false);
			if(_buttonRecord.currentLabel == "grabar")
			{
				//se detiene la reproduccion por si hay un aduio que estubiera cargando
				stopPlay();
				// el valor de 50 indica un audio en un rango normal de audicion
				_microphone.gain = 50;
				//frecuencia de captura del sonido en KHZ
				_microphone.rate = 40;
				_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, initializeRecord);
				//se pasa al fotograma para detener
				_buttonRecord.gotoAndStop("detener");
				CodeCraft.property(_buttonPlay,{alpha: 0.1});
				Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
				//se llama ala funcion del MediaPlayer para que evite que se de clic para reproducir mientras se graba
				MediaPlayer.statusSound(false);
			}
			else
			{
				_soundLoad = true;
				stopRecord();
			}
		}
		
		/**
		 * Se ejecuta cuando termina de ejecutarse el audio del play, este detiene la reproduccion
		 * y restaura los valores
		 * @param event Object del Event
		 */
		private static function playSoundComplete(event:Event):void 
		{
			stopPlay();
			//se restaura el audio de fondo
			Audio.setVolumenBackground(1);
		}
		
		/**
		 * Inicia la grabacion del audio y lo almacena en un arrayByte
		 * @param event Object del SampleDataEvent
		 */
		private static function initializeRecord (event:SampleDataEvent):void 
		{
			while (event.data.bytesAvailable)
			{
				var sample:Number = event.data.readFloat();
				_soundBytes.writeFloat(sample);
			}
		}
		
		/**
		 * Se encarga de leer lo que se almaceno en el arrayByte y lo reproduce
		 * @param event Object de SampleDataEvent
		 */
		private static function initializePlay (event:SampleDataEvent):void
		{
			for (var i:int = 0; i < 8192; i++)
			{
				if (_soundO.bytesAvailable < 4)
				{
					break;
				}
				var sample:Number = _soundO.readFloat();
				//The sound data received from microphone is mono data
				//-so you need to feed it twice for left and right track
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}
		
		
		/**
		 * Se detiene la reproduccion del audio que este ejecutandose en ese momento
		 */
		private static function stopPlay():void
		{
			Events.removeListener(_sound, SampleDataEvent.SAMPLE_DATA, initializePlay);
			_soundChannel.stop()
			Events.removeListener(_soundChannel, Event.SOUND_COMPLETE,playSoundComplete);
			_buttonPlay.gotoAndStop("play");
			//se restaura el audio de fondo
			Audio.setVolumenBackground(0);
		}
		
		/**
		 * indica que la grabación se detuvo la grabacion por presionar el boton de detener grabacion
		 * o que se cerror la ventana del menu de grabacion
		 */
		private static function stopRecord():void 
		{
			//si se grabo algo entonces se habilita el boton de play
			if(_soundLoad)
			{
				Events.listener(_buttonPlay,MouseEvent.CLICK, clicPlay,true,true);
				CodeCraft.property(_buttonPlay,{alpha: 1});
			}
			
			_microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, initializeRecord);
			_soundBytes.position = 0;
			_soundO.length = 0
			_soundO.writeBytes(_soundBytes);
			_soundO.position = 0;
			_soundBytes.length = 0;
			_buttonRecord.gotoAndStop("grabar");
			//como termina la grabacion se reactiva el statusPlayer
			MediaPlayer.statusSound(true);
			//se restaura el audio de fondo
			Audio.setVolumenBackground(1);
		}
		
		/**
		 * Elimina el container del menu del escenario  quita todos los listener que se activaron
		 */
		private static function removeComplete ():void 
		{
			Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
			Events.removeListener(_buttonRecord,MouseEvent.CLICK, clicRecord,true);
			CodeCraft.removeChild(_container);
			_buttonMicrophone = null;
			_buttonPlay = null;
			_buttonRecord = null;
			_container = null;
		}
		
	}
}