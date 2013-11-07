package codeCraft.media 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import codeCraft.debug.Debug;
	import codeCraft.display.Button;
	
	public class Audio 
	{
		
		/* Cambian el valor del volumen tanto de fondo como de la presentacion */
		private static var _volumenPresentation:int = 1;
		private static var _volumenBackground:int = 1;
		private static var _channelPresentation:SoundChannel = new SoundChannel();
		private static var _channelBackground:SoundChannel = new SoundChannel();
		/* Es una variable creada para suplantar un audio vacio, o un valor sin sonido */
		private static var _audio:Sound = new Sound();
		private static var _soundTransformPresentation:SoundTransform = new SoundTransform();
		private static var _soundTransformBackground:SoundTransform = new SoundTransform();
		/* Almacenan el sonido que se reproduce actualmente para cada uno de los caneles */
		private static var _soundPresentation:* = null;
		private static var _soundBackground:* = null;
		private static var _url:URLRequest;
		private static var _arraySoundChannel:Array = new Array();
		/* Almacena la funcion que retorna cada vez que termina de reproducir un audio */
		private static var _functionReturnComplete:Function = null;
		/* Posicion actual del sonido para realizar una pausa */
		private static var _positionSoundPresentation:Number = 0;
		private static var _positionSoundBackground:Number = 0;
		/* Indicaran si los canales del audio estan activos o no lo estan */
		private static var _channelPresentationActive:Boolean = false;
		private static var _channelBackgroundActive:Boolean = false;
		
		/**
		 * Detiene el sonido de la presentación, la funcion esta como publica para permitir que
		 * se asigne a objeto, por defecto la función ya esta asignada a el boton de sonido
		 * del menu de opciones que se carga con CodeCraft.addMenu();
		 * 
		 * Su funcionamiento se basa en subir o bajar el volumen que tiene el channel del audio 
		 * de la presentacion, cuando es 1 suena y cuando es 0 no suena, se encarga tambien de
		 * detener la animacion del boton para indicar que se silencio el audio, si se usa un
		 * objeto diferente para llamar a esta funcion se debera tener en cuenta que la animacion
		 * del boton sea igual a la animacion de los botones cargados por la libreria
		 * 
		 * @param event
		 */
		public static function stopPresetation(event:MouseEvent):void
		{
			//se verifica si tiene un listener activo para no tener el audio
			if(_functionReturnComplete == null)
			{
				_channelPresentation.stop();
				_channelPresentationActive = false;
			}
			if (_volumenPresentation == 1) 
			{
				//Silencia
				_positionSoundPresentation = _channelPresentation.position;
				event.currentTarget.gotoAndStop('silencio');
				Button.removeOver(event.currentTarget,1);
				_volumenPresentation = 0;
			} 
			else
			{
				//reproduce de  nuevo
				event.currentTarget.gotoAndStop('normal');
				_volumenPresentation = 1;
				Button.over(event.currentTarget,1,null,true);
				//se verifica si se pauso el audio para que no se reproduzca
				if(_positionSoundPresentation == 0)
				{
					playAudio (_soundPresentation,0);
					playComplete(0,_functionReturnComplete);
				}
			}
			_soundTransformPresentation = _channelPresentation.soundTransform;
			_soundTransformPresentation.volume = _volumenPresentation;
			_channelPresentation.soundTransform = _soundTransformPresentation;
		}
		
		/**
		 * Cambia el volumen del canal de audio de la presentacion
		 * @param value Numero int entre 1 y 0 para la asignacion del volumen del canal de presentacion
		 */
		public static function setVolumenPresentation (value:int = 0):void 
		{
			_volumenPresentation = value;
			_soundTransformPresentation = _channelPresentation.soundTransform;
			_soundTransformPresentation.volume = _volumenPresentation;
			_channelPresentation.soundTransform = _soundTransformPresentation;
		}
		
		
		/**
		 * 
		 * @param event
		 */
		public static function stopBackground(event:MouseEvent):void
		{
			//se verifica si tiene un listener activo para no tener el audio
			if(_functionReturnComplete == null)
			{
				_channelBackground.stop();
				_channelBackgroundActive = false;
			}
			if (_volumenBackground == 1) 
			{
				//Silencia
				event.currentTarget.gotoAndStop('silencio');
				Button.removeOver(event.currentTarget,1);
				_volumenBackground = 0;
			} 
			else 
			{
				//reproduce de  nuevo
				event.currentTarget.gotoAndStop('normal');
				_volumenBackground = 1;
				Button.over(event.currentTarget,1,2,true);
				playAudio (_soundBackground,1);
			}
			_soundTransformBackground = _channelBackground.soundTransform;
			_soundTransformBackground.volume = _volumenBackground;
			_channelBackground.soundTransform = _soundTransformBackground;
		}
		
		/**
		 * Cambia el volumen del canal de audio del fondo
		 * @param value Numero int entre 1 y 0 para la asignacion del volumen del canal del fondo
		 */
		public static function setVolumenBackground (value:int = 0):void 
		{
			_volumenBackground = value;
			if(_channelBackgroundActive)
			{
			 	playAudio (_soundBackground,1);
			}
			_soundTransformBackground = _channelBackground.soundTransform;
			_soundTransformBackground.volume = _volumenBackground;
			_channelBackground.soundTransform = _soundTransformBackground;
		}
		
		public static function puaseSoundPresentation (event:MouseEvent):void 
		{
			//se verifica si se detiene o si se reproduce
			if(event.currentTarget.currentLabel == "pause")
			{
				//almacena la posicion actual del audio
				_positionSoundPresentation = _channelPresentation.position;
				stopSoundPresentation();
				//se cambia la posicion del boton que se presion
				event.currentTarget.gotoAndStop("play");
				_channelPresentationActive = false;
			}
			else
			{
				playAudio(_soundPresentation,0,false,_positionSoundPresentation);
				playComplete(0,_functionReturnComplete);
				event.currentTarget.gotoAndStop("pause");
				_channelPresentationActive = true;
			}
		}
		
		/**
		 * 
		 */
		public static function stopSoundPresentation(clearChannel:Boolean = true):void
		{
			_channelPresentation.stop();
			if(clearChannel)
			{
				playAudio(null,0);
			}
			_channelPresentationActive = false;
			//se verifica si tiene un listener el canal
			if(_channelPresentation.hasEventListener(Event.SOUND_COMPLETE))
			{
				_channelPresentation.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
			}
		}
		
		/**
		 *  
		 * @param clearChannel	
		 */
		public static function stopSoundBackground (clearChannel:Boolean = false):void 
		{
			
			_channelBackground.stop();
			if(clearChannel)
			{
				playAudio(null,0);
			}
			_channelBackgroundActive = false;
			//se verifica si tiene un listener el canal
			if(_channelBackground.hasEventListener(Event.SOUND_COMPLETE))
			{
				_channelBackground.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
			}
		}
		
		
		/**
		 * 
		 * @param stopAllSound	
		 */
		public static function stopAllSound(clearChannel:Boolean = false):void
		{
			_channelBackground.stop();
			_channelPresentation.stop();
			//soundMixer detiene todos los demas sonidos que no hayan sido agregados a los dos caneles
			SoundMixer.stopAll();
			//limpiamos el canal para agregar otro _audio o evitar que el _audio se reprodusca nuevamente
			if(clearChannel)
			{
				playAudio(null,0);
				playAudio(null,1);
			}
			//se verifica si tiene un listener el canal
			if(_channelPresentation.hasEventListener(Event.SOUND_COMPLETE))
			{
				_channelPresentation.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
			}
			if(_channelBackground.hasEventListener(Event.SOUND_COMPLETE))
			{
				_channelBackground.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
			}
			//el canad de fondo no se desabilita, se silencia para poder dar la opcion de restaurar nuevamente si este
			//se encontraba sonando antes, esto se hace por medio de la funcion setVolumenBackgroun
			setVolumenBackground();
			//_channelBackgroundActive = false;
			_channelPresentationActive = false;
		}
		
		
		/**
		 * 
		 * @param ruta
		 * @param numberChannel
		 * @param loopSound
		 */
		public static function playAudio (ruta:* = null, numberChannel:int = 1, loopSound:Boolean = false,position:Number = 0):void 
		{
			var numberLoop:int = 0;
			if(loopSound)
			{
				numberLoop = 100;
			}
			try
			{
				if (ruta != null) 
				{
					if(ruta is Array)
					{
						ruta  = ruta[0];
					}
					if (ruta is String) 
					{
						_url = new URLRequest(ruta);
						_audio = new Sound(_url);
						_audio.addEventListener(IOErrorEvent.IO_ERROR, errorLoadSound);
					}
					else 
					{
						if(ruta is Sound)
						{
							_audio = ruta;								
						}
						else 
						{
							_audio = new ruta();
						}
					}
					if(numberChannel == 1)
					{
						_channelBackground.stop();
						_soundBackground = ruta;
						_channelBackground = _audio.play(position,numberLoop);
						_channelBackground.soundTransform = _soundTransformBackground;
						_channelBackgroundActive = true;
						//_channelBackground.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
					}
					else 
					{
						_channelPresentation.stop();
						_soundPresentation = ruta;
						_channelPresentation = _audio.play(position,numberLoop);
						_channelPresentation.soundTransform = _soundTransformPresentation;
						_channelPresentationActive = true;
						//_channelPresentation.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
					}
				}
				else 
				{
					if(numberChannel == 1)
					{
						_channelBackground.stop();
						_soundBackground = ruta;
						_channelBackgroundActive = false;
					}
					else 
					{
						_channelPresentation.stop();
						_soundPresentation = ruta;
						_channelPresentationActive = false;
					}					
				}
			}
			catch(error:Error)
			{
				Debug.print("url has not sound","Audio.playAudio","Falla CodeCraft ");
			}
		}
		
		
		/**
		 * 
		 * @param numberChannel
		 * @param functionReturn
		 */
		public static function playComplete(numberChannel:int = 1, functionReturn:Function = null):void
		{
			if(functionReturn != null)
			{
				_functionReturnComplete = functionReturn;
				//se verifica el canal y se agregan los listener que retornan la funcion
				if(numberChannel == 1)
				{
					_channelBackground.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
				}
				else 
				{
					_channelPresentation.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
				}	
			}
			else 
			{
				if(_functionReturnComplete != null)
				{
					if(numberChannel == 1)
					{
						_channelBackground.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
						_channelBackground.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
					}
					else 
					{
						_channelPresentation.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
						_channelPresentation.addEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
					}	
				}
				else 
				{
					//Debug.print("La funcion a retornar presenta errores, verifique que no sea null","Audio.playComplete","Falla CodeCraft");
				}			
			}
		}
		
		
		public static function getStatusSound (numberChannel:int = 0):Boolean
		{
			if(numberChannel == 0)
			{
				return _channelPresentationActive;
			}
			else
			{
				return _channelBackgroundActive;
			}
		}
		
		public static function getPositionSound (numberChannel:int = 0):Number
		{
			if(numberChannel == 0)
			{
				return  _channelPresentation.position;
			}
			else
			{
				return  _channelBackground.position;
			}
		}
		
		public static function playCurrentSoundPosition (numberChannel:int = 0, position:Number = 0):void 
		{
			if(numberChannel == 0)
			{
				playAudio(_soundPresentation,0,false,position);
			}
			else
			{
				playAudio(_soundBackground,1,false,position);
			}
		}
		
		/**
		 * 
		 * @param event	
		 */
		private static function soundChannelComplete (event:Event):void 
		{
			//se elimina listener, devuelve la funcion y se limpia de la memoria
			event.currentTarget.removeEventListener(Event.SOUND_COMPLETE,soundChannelComplete);
			if (event.currentTarget == _channelPresentation)
			{
				_channelPresentationActive = false;
			}
			if(event.currentTarget == _channelBackground)
			{
				_channelBackgroundActive = false;
			}
			//se verifica si anteriormente se asigno una funcion a retornar por medio de la funcion playComplete
			if(_functionReturnComplete != null)
			{
				_functionReturnComplete();
				//_functionReturnComplete = null;
			}
		}
		
		
		private static function errorLoadSound(event:IOErrorEvent):void 
		{
			//Debug.print("Verifique la url del audio, al parecer no existe tal ruta.","Audio.playAudio","Falla CodeCraft ");
		}
		
		
	}
}