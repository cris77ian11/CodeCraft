package codeCraft.media
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.events.Events;
	import codeCraft.utils.Timers;


	public class MediaPlayer extends MovieClip
	{

		private static var _buttonSound:MovieClip;
		/* Contenine los botones del menu para realizar la reproduccion, se pone null para cuando se elimine se compare si ya fue cargado o no */
		private static var _container:MovieClip = null;
		private static var _buttonPlay:MovieClip;
		private static var _botonRetroceder:MovieClip;
		private static var _botonAdelantar:MovieClip;
		private static var _barraProgreso:MovieClip;
		private static var _barraControl:MovieClip;
		/* Es la funcion que devolvera apenas termine la carga del audio que se esta reproducciendo y pasen dos segundos */
		private static var _functionReturn:Function;
		/* Indica si se permite o no la reproduccion de los listener */
		private static var _statusSound:Boolean = true;
		private static var _sound:Sound;
		private static var _channelSound:SoundChannel = new SoundChannel();
		private static var _duration:Number = 0;
		private static var _currentPosition:Number = 0;
		private static var _soundTransform:SoundTransform = new SoundTransform();
		private static var _volumen:Number = 1;


		/**
		 *
		 */
		public static function load (buttonSound:MovieClip,containerMediaPlayer:MovieClip, buttonPlay:MovieClip, buttonPrev:MovieClip, buttonNext:MovieClip, progressBar:MovieClip, controlBar:MovieClip, position:Array = null, functionReturn:Function = null):void
		{
			if (_container != null)
			{
				remove();
			}
			_buttonSound = buttonSound;
			_container = containerMediaPlayer;
			_buttonPlay = buttonPlay;
			_botonAdelantar = buttonNext;
			_botonRetroceder = buttonPrev;
			_barraProgreso = progressBar;
			_barraControl = controlBar;
			_functionReturn = functionReturn;
			//verificar si los elementos estan cargados en el stage de lo contrario cargarlos
			if(_buttonSound != null)
			{
				if(!(CodeCraft.getMainObject().contains(_buttonSound)))
				{
					CodeCraft.addChild(_buttonSound,null,position[0]);
				}

			}
			if(!(CodeCraft.getMainObject().contains(_container)))
			{
				CodeCraft.addChild(_container,null,position[1]);
			}
			//se detiene el boton de play
			_buttonPlay.gotoAndStop("play");
			_barraProgreso.scaleX = 0;
			//se oculta el contenedor de los botones de multimedia
			_container.visible = false;
			if(_buttonSound != null)
			{
				Events.listener(_buttonSound,MouseEvent.CLICK, clicSound,true,true);
			}
			else
			{
				//reinicia los valores antes de realizar la animacion
				CodeCraft.property(_container,{alpha:1, scaleY: 1, scaleX: 1});
				_container.visible = true;
				TweenMax.from(_container,0.7,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeOut, onComplete: showContainerComplete});
			}
		}

		/**
		 * Elimina el rreproductor de musica
		 */
		public static function remove():void
		{
			_channelSound.stop();
			//se comprueba que el elemento ya haya sido creado
			if (_container != null)
			{
				Audio.setVolumenBackground(1);
				Events.removeListener(_buttonSound,MouseEvent.CLICK, clicSound,true);
				//se verifica si es visible para hacer la animacion que lo oculta
				if(_container.visible)
				{
					TweenMax.to(_container,0.5,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: removeComplete});
				}
				//si no es visible se llama directamente a la funcion que lo elimin
				else
				{
					removeComplete();
				}
			}
		}


		/**
		 * Carga la url que tiene el audio para ser reproducido
		 * @param ruta String con url donde se almacena el audio
		 */
		public static function loadSound (ruta:* = null):void
		{
			if(ruta != null)
			{
				var url:URLRequest = new URLRequest(ruta);
				_sound = new Sound(url);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, errorLoadSound);
			}
			else
			{
				Debug.print("La ruta es un valor null.","MediaPlayer.loadSound","Mensaje no se asuste ");
			}
		}

		/**
		 * Se ejecuta si la url no se puede cargar
		 */
		private static function errorLoadSound(event:IOErrorEvent):void
		{
			Debug.print("Verifique la url del audio, al parecer no existe tal ruta.","MediaPlayer.loadSound","Falla CodeCraft ");
		}


		/**
		 *
		 * @param enabled Boolean que indica si se debe activar los controles true, o si se desactivan false
		 */
		public static function statusSound(enabled:Boolean = false):void
		{
			if(_buttonPlay != null)
			{
				if(enabled)
				{
					_statusSound = true;
					_buttonPlay.gotoAndStop("play");
				}
				else
				{
					_statusSound = false;
					_channelSound.stop();
					_buttonPlay.gotoAndStop("pause");
					//se oculta y se prohibe el llamado de la funciones
					TweenMax.to(_container,0.5,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: showContainerComplete});
				}
			}
		}

		/**
		 * Funcion que se activa cuando se presiona el boton del sonido, inicia la animacion para mostrar el cotenedor
		 * tambien desabilita el listener del boton que activo la funcion, cuando termine la animacion reactiva el listener
		 * para poder realizar la animacion
		 * @param event Object del MouseEvent
		 */
		private static function clicSound(event:MouseEvent):void
		{
			//se verifica si hay un audio para mostrar el menu
			if(_sound != null)
			{
				Events.removeListener(_buttonSound,MouseEvent.CLICK, clicSound,true);
				if(_container.visible)
				{
					TweenMax.to(_container,0.5,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: showContainerComplete});
				}
				else
				{
					//reinicia los valores antes de realizar la animacion
					CodeCraft.property(_container,{alpha:1, scaleY: 1, scaleX: 1});
					_container.visible = true;
					TweenMax.from(_container,0.7,{alpha: 0,scaleX: 0, scaleY: 0, ease: Back.easeOut, onComplete: showContainerComplete});
				}
			}
		}

		/**
		 * Se carga cuando termina la animacion de mostrar o ocultar el menu del reproductor
		 */
		private static function showContainerComplete ():void
		{
			Events.listener(_buttonSound,MouseEvent.CLICK, clicSound,true,true);
			//si el boton es visible, tambien si esl estado de los controles es activo
			if(_container.alpha == 1 && _statusSound)
			{
				Events.listener(_buttonPlay,MouseEvent.CLICK, clicPlay,true,true);
				Events.listener(_botonRetroceder,MouseEvent.MOUSE_DOWN, prevDown,true,true);
				Events.listener(_botonAdelantar,MouseEvent.MOUSE_DOWN, nextDown,true,true);
				Events.listener(_barraControl,MouseEvent.MOUSE_DOWN, barDown,true,false);
				Events.listener(_botonRetroceder,MouseEvent.MOUSE_UP, prevDown,true,false);
				Events.listener(_botonAdelantar,MouseEvent.MOUSE_UP, nextDown,true,false);
				Events.listener(_container,Event.ENTER_FRAME, soundProgress);
			}
			else
			{
				Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
				Events.removeListener(_botonRetroceder,MouseEvent.MOUSE_DOWN, prevDown,true);
				Events.removeListener(_botonAdelantar,MouseEvent.MOUSE_DOWN, nextDown,true);
				Events.removeListener(_barraControl,MouseEvent.MOUSE_DOWN, barDown,true);
				Events.removeListener(_botonRetroceder,MouseEvent.MOUSE_UP, prevDown,true);
				Events.removeListener(_botonAdelantar,MouseEvent.MOUSE_UP, nextDown,true);
				Events.removeListener(_container,Event.ENTER_FRAME, soundProgress);
				_container.visible = false;
			}
		}

		private static function clicPlay (event:Event):void
		{
			if(_buttonPlay.currentLabel == "play")
			{
				reproducirAudio();
			}
			else
			{
				detenerAudio();
			}
		}

		private static function prevDown (event:MouseEvent):void
		{
			//si el mouse es presionado
			if(event.type == "mouseDown")
			{
				_volumen = 0;
				Events.listener(_botonRetroceder,Event.ENTER_FRAME, changeAudioPrev);
			}
			else
			{
				_volumen = 1;
				Events.removeListener(_botonRetroceder,Event.ENTER_FRAME, changeAudioPrev);
			}
			changeVolumen();
		}

		private static function nextDown (event:MouseEvent):void
		{
			//si el mouse es presionado
			if(event.type == "mouseDown")
			{
				_volumen = 0;
				Events.listener(_botonAdelantar,Event.ENTER_FRAME, changeAudioNext);
			}
			else
			{
				_volumen = 1;
				Events.removeListener(_botonAdelantar,Event.ENTER_FRAME, changeAudioNext);
			}
			changeVolumen();
		}

		private static function changeAudioPrev (event:Event):void
		{
			//se verifica si esta al final de la barra de progreso para poder devolverla
			if(_barraProgreso.scaleX >= 1)
			{
				_barraProgreso.scaleX = 0.9;
			}
			var position:Number = (_channelSound.position - 250);
			_channelSound.stop();
			_channelSound = _sound.play(position);
			changeVolumen();
		}

		private static function changeAudioNext (event:Event):void
		{
			var position:Number = (_channelSound.position + 150);
			_channelSound.stop();
			_channelSound = _sound.play(position);
			changeVolumen();
		}

		private static function barDown (event:MouseEvent):void
		{
			//si el mouse es presionado
			if(event.type == "mouseDown")
			{
				_volumen = 0;
				Events.removeListener(_container,Event.ENTER_FRAME, soundProgress);
				Events.listener(_barraControl,Event.ENTER_FRAME, soundScrub);
				Events.listener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, barDown,true);
			}
			else
			{
				_volumen = 1;
				Events.listener(_container,Event.ENTER_FRAME, soundProgress);
				Events.removeListener(_barraControl,Event.ENTER_FRAME, soundScrub);
				Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, barDown,true);
			}
			changeVolumen();
		}

		/**
		 * Se ejecuta muentras se este moviendo el mouse sobre la barra para controlar el progreso
		 * del audio
		 * @param event Object de Event
		 */
		private static function soundScrub(event:Event):void
		{
			var soundDist:Number = (CodeCraft.getMainObject().mouseX - _container.x - _barraControl.x) / _barraControl.width;
			if(soundDist < 0)
			{
				soundDist = 0;
			}
			if(soundDist > 1)
			{
				soundDist = 1;
			}
			_channelSound.stop();
			_channelSound = _sound.play(Math.floor(_duration * soundDist));
			_barraProgreso.scaleX = soundDist;
			changeVolumen();
		}

		/**
		 * Se ejecuta mientras essta sonando el audio y su objetivo es hacer que la barra se mueva
		 * para dar el efecto de que el audio esta cargando
		 * @param event Object del MouseEvent
		 */
		private static function soundProgress(event:Event):void
		{
			var loadTime:Number = _sound.bytesLoaded / _sound.bytesTotal;
			var loadPercent:uint = Math.round(100 * loadTime);
			var estimatedLength:int = Math.ceil(_sound.length / (loadTime));
			var playbackPercent:uint = Math.round(100 * (_channelSound.position / estimatedLength));
			if(_barraProgreso.scaleX < 1 && _barraProgreso.scaleX >= 0)
			{
				_barraProgreso.scaleX = playbackPercent/100;
				_duration = estimatedLength;
			}
			else
			{
				detenerAudio();
			}
		}

		/**
		 * Se ejecuta para volver el boton de volumen a su forma original despues de terminar el audio
		 */
		private static function soundComplete (event:Event):void
		{
			Events.removeListener(_channelSound,Event.SOUND_COMPLETE, soundComplete);
			detenerAudio();
		}

		/**
		 *
		 */
		private static function changeVolumen ():void
		{
			Events.removeListener(_channelSound,Event.SOUND_COMPLETE, soundComplete);
			_soundTransform.volume = _volumen;
			_channelSound.soundTransform = _soundTransform;
			Events.listener(_channelSound,Event.SOUND_COMPLETE, soundComplete);
			//al presionar si el audio estaba detenido se iniciara nuevamente
			if(_volumen == 1)
			{
				_buttonPlay.gotoAndStop("pause");
			}
		}

		/**
		 * Elimina los listener y limpia las variables para eliminar todo por completo
		 */
		private static function removeComplete():void
		{
			
			Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
			Events.removeListener(_botonRetroceder,MouseEvent.MOUSE_DOWN, prevDown,true);
			Events.removeListener(_botonAdelantar,MouseEvent.MOUSE_DOWN, nextDown,true);
			Events.removeListener(_barraControl,MouseEvent.MOUSE_DOWN, barDown,true);
			Events.removeListener(_botonRetroceder,MouseEvent.MOUSE_UP, prevDown,true);
			Events.removeListener(_botonAdelantar,MouseEvent.MOUSE_UP, nextDown,true);
			Events.removeListener(_barraControl,MouseEvent.MOUSE_UP, barDown,true);
			Events.removeListener(_container,Event.ENTER_FRAME, soundProgress);
			_barraProgreso.scaleX = 0;
			CodeCraft.removeChild(_container);
			_botonAdelantar = null;
			_buttonPlay = null;
			_botonRetroceder = null;
			_buttonSound = null;
			_container = null;
			_sound = null;
			_barraProgreso = null;
			_channelSound = null;
			_barraControl = null;
			_functionReturn = null;
		}

		private static function detenerAudio():void
		{
			//se verifica  si tiene una funcion que devolver
			if(_functionReturn != null)
			{
				Timers.timer(2,_functionReturn);
			}
			_currentPosition = _channelSound.position;
			_channelSound.stop();
			_buttonPlay.gotoAndStop("play");
			Audio.setVolumenBackground(1);
			Events.removeListener(_channelSound,Event.SOUND_COMPLETE, soundComplete);
		}

		private static function reproducirAudio ():void
		{
			Audio.stopAllSound(false);
			//se verifica si la barra de audio esta en el limite
			if(_barraProgreso.scaleX >= 1)
			{
				_currentPosition = 0;
				_barraProgreso.scaleX = 0;
			}
			_channelSound = _sound.play(_currentPosition);
			_buttonPlay.gotoAndStop("pause");
			Events.listener(_channelSound,Event.SOUND_COMPLETE, soundComplete);
		}

	}
}