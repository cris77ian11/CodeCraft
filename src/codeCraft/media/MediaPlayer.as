package codeCraft.media
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.display.Button;
	import codeCraft.events.Events;

	public class MediaPlayer extends MovieClip
	{
		
		private static var _buttonSound:MovieClip;
		private static var _container:MovieClip;
		private static var _buttonPlay:MovieClip;
		private static var _buttonPrev:MovieClip;
		private static var _buttonNext:MovieClip;
		private static var _progressBar:MovieClip;
		private static var _controlBar:MovieClip;
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
		public static function load (buttonSound:MovieClip,containerMediaPlayer:MovieClip, buttonPlay:MovieClip, buttonPrev:MovieClip, buttonNext:MovieClip, progressBar:MovieClip, controlBar:MovieClip, position:Array = null):void 
		{
			_buttonSound = buttonSound;
			_container = containerMediaPlayer;
			_buttonPlay = buttonPlay;
			_buttonNext = buttonNext;
			_buttonPrev = buttonPrev;
			_progressBar = progressBar;
			_controlBar = controlBar;

			//verificar si los elementos estan cargados en el stage de lo contrario cargarlos
			if(!(CodeCraft.getMainObject().contains(_buttonSound)))
			{
				CodeCraft.addChild(_buttonSound,null,position[0]);
			}
			if(!(CodeCraft.getMainObject().contains(_container)))
			{
				CodeCraft.addChild(_container,null,position[1]);
			}
			//se detiene el boton de play
			_buttonPlay.gotoAndStop("play");
			_progressBar.scaleX = 0;
			//se oculta el contenedor de los botones de multimedia
			_container.visible = false;
			Events.listener(_buttonSound,MouseEvent.CLICK, clicSound,true,true);
		}
		
		/**
		 * Carga la url que tiene el audio para ser reproducido
		 * @param ruta String con url donde se almacena el audio
		 */
		public static function loadSound (ruta:* = null):void 
		{
			var url:URLRequest = new URLRequest(ruta);
			_sound = new Sound(url);
		}
		
		/**
		 * 
		 * @param enabled Boolean que indica si se debe activar los controles true, o si se desactivan false
		 */
		public static function statusSound(enabled:Boolean = false):void 
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
				Events.listener(_buttonPrev,MouseEvent.MOUSE_DOWN, prevDown,true,true);
				Events.listener(_buttonNext,MouseEvent.MOUSE_DOWN, nextDown,true,true);
				Events.listener(_controlBar,MouseEvent.MOUSE_DOWN, barDown,true,false);
				Events.listener(_buttonPrev,MouseEvent.MOUSE_UP, prevDown,true,false);
				Events.listener(_buttonNext,MouseEvent.MOUSE_UP, nextDown,true,false);
				Events.listener(_controlBar,MouseEvent.MOUSE_UP, barDown,true,false);
				Events.listener(_container,Event.ENTER_FRAME, soundProgress);
			}
			else
			{
				Events.removeListener(_buttonPlay,MouseEvent.CLICK, clicPlay,true);
				Events.removeListener(_buttonPrev,MouseEvent.MOUSE_DOWN, prevDown,true);
				Events.removeListener(_buttonNext,MouseEvent.MOUSE_DOWN, nextDown,true);
				Events.removeListener(_controlBar,MouseEvent.MOUSE_DOWN, barDown,true);
				Events.removeListener(_buttonPrev,MouseEvent.MOUSE_UP, prevDown,true);
				Events.removeListener(_buttonNext,MouseEvent.MOUSE_UP, nextDown,true);
				Events.removeListener(_controlBar,MouseEvent.MOUSE_UP, barDown,true);
				Events.removeListener(_container,Event.ENTER_FRAME, soundProgress);
				_container.visible = false;
			}
		}

		private static function clicPlay (event:Event):void 
		{
			if(_buttonPlay.currentLabel == "play")
			{
				Audio.stopAllSound(false);
				_channelSound = _sound.play(_currentPosition);
				_buttonPlay.gotoAndStop("pause");
			}
			else 
			{
				_currentPosition = _channelSound.position;
				_channelSound.stop();
				_buttonPlay.gotoAndStop("play");	
			}
		}
		
		private static function prevDown (event:MouseEvent):void
		{
			//si el mouse es presionado
			if(event.type == "mouseDown")
			{
				_volumen = 0;
				Events.listener(_buttonPrev,Event.ENTER_FRAME, changeAudioPrev);
			}
			else
			{
				_volumen = 1;
				Events.removeListener(_buttonPrev,Event.ENTER_FRAME, changeAudioPrev);
			}
			changeVolumen();
			//al presionar si el audio estaba detenido se iniciara nuevamente
			_buttonPlay.gotoAndStop("pause");
		}
		
		private static function nextDown (event:MouseEvent):void
		{
			//si el mouse es presionado
			if(event.type == "mouseDown")
			{
				_volumen = 0;
				Events.listener(_buttonNext,Event.ENTER_FRAME, changeAudioNext);
			}
			else 
			{
				_volumen = 1;
				Events.removeListener(_buttonNext,Event.ENTER_FRAME, changeAudioNext);
			}
			changeVolumen();
			//al presionar si el audio estaba detenido se iniciara nuevamente
			_buttonPlay.gotoAndStop("pause");
		}
		
		private static function changeAudioPrev (event:Event):void 
		{
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
				Events.listener(_controlBar,Event.ENTER_FRAME, soundScrub);
			}
			else 
			{
				_volumen = 1;
				Events.listener(_container,Event.ENTER_FRAME, soundProgress);
				Events.removeListener(_controlBar,Event.ENTER_FRAME, soundScrub);
			}
		}
		
		private static function soundScrub(event:Event):void {
			var soundDist:Number = (CodeCraft.getMainObject().mouseX - _container.x - _controlBar.x) / _controlBar.width;
			if(soundDist < 0){
				soundDist = 0;
			}
			if(soundDist > 1){
				soundDist = 1;
			}
			_channelSound.stop();
			_channelSound = _sound.play(Math.floor(_duration * soundDist));
			_progressBar.scaleX = soundDist;
			changeVolumen();
		}
		
		private static function soundProgress(event:Event):void 
		{    
			var loadTime:Number = _sound.bytesLoaded / _sound.bytesTotal;
			var loadPercent:uint = Math.round(100 * loadTime);
			var estimatedLength:int = Math.ceil(_sound.length / (loadTime));
			var playbackPercent:uint = Math.round(100 * (_channelSound.position / estimatedLength));
			_progressBar.scaleX = playbackPercent/100;
			_duration = estimatedLength;
		}
		
		private static function soundComplete (event:Event):void 
		{
			_buttonPlay.gotoAndStop("play");
		}
		
		private static function changeVolumen ():void 
		{
			_soundTransform.volume = _volumen;
			_channelSound.soundTransform = _soundTransform;
		}
		
	}
}