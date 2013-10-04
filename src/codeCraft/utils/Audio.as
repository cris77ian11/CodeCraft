package codeCraft.utils {
	import codeCraft.display.Button;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	public class Audio {
		
		public static var volumenPresentation:int = 1;
		public static var volumenBackground:int = 1;
		
		private static var channelPresentation:SoundChannel = new SoundChannel();
		private static var channelBackground:SoundChannel = new SoundChannel();
		private static var audio:Sound = new Sound();
		private static var soundTransformPresentation:SoundTransform = new SoundTransform();
		private static var soundTransformBackground:SoundTransform = new SoundTransform();
		private static var soundPresentation:* = null;
		private static var soundBackground:* = null;
		private static var url:URLRequest;
		private static var arraySoundChannel:Array = new Array();
		private static var positionSoundPresentation:Number;
		
		public static function stopPresetation(event:MouseEvent):void{
			channelPresentation.stop();
			if (volumenPresentation == 1) {
				//Silencia
				event.currentTarget.gotoAndStop('silencio');
				Button.removeOver(event.currentTarget,1);
				volumenPresentation = 0;
				positionSoundPresentation = channelPresentation.position;
				channelPresentation.stop();
			} else {
				//reproduce de  nuevo
				event.currentTarget.gotoAndStop('normal');
				volumenPresentation = 1;
				Button.over(event.currentTarget,1,null,true);
				playAudio (soundPresentation,0);
			}
			soundTransformPresentation = channelPresentation.soundTransform;
			soundTransformPresentation.volume = volumenPresentation;
			channelPresentation.soundTransform = soundTransformPresentation;
		}
		
		public static function stopBackground(event:MouseEvent):void{
			channelBackground.stop();
			if (volumenBackground == 1) {
				//Silencia
				event.currentTarget.gotoAndStop('silencio');
				Button.removeOver(event.currentTarget,1);
				volumenBackground = 0;
				channelBackground.stop();
			} else {
				//reproduce de  nuevo
				event.currentTarget.gotoAndStop('normal');
				volumenBackground = 1;
				Button.over(event.currentTarget,1,2,true);
				playAudio (soundBackground,1);
			}
			soundTransformBackground = channelBackground.soundTransform;
			soundTransformBackground.volume = volumenBackground;
			channelBackground.soundTransform = soundTransformBackground;
		}
		
		public static function stopSoundPresentation():void{
			channelPresentation.stop();
			soundPresentation = null;
		}
		
		public static function stopAllSound():void{
			channelBackground.stop();
			channelPresentation.stop();
			SoundMixer.stopAll();
		}
		
		public static function stopSound(ruta:* = null, numberChannel:int = 1):void {
			
		}
		
		
		public static function playAudio (ruta:* = null, numberChannel:int = 1, loopSound:Boolean = false):void {
			var numberLoop:int = 0;
			if(loopSound){
				numberLoop = 100;
			}
			try{
				if (ruta != null) {
					if(ruta is Array){
						ruta  = ruta[0];
					}
					if (ruta is String) {
						url = new URLRequest(ruta);
						audio = new Sound(url);
					} else {
						if(ruta is Sound){
							audio = ruta;								
						}else {
							audio = new ruta();
						}
					}
					if(numberChannel == 1){
						channelBackground.stop();
						soundBackground = ruta;
						if(volumenBackground == 1){
							channelBackground = audio.play(0,numberLoop);
						}
					}else {
						if(soundPresentation != ruta){
							positionSoundPresentation = 0;
						}
						channelPresentation.stop();
						soundPresentation = ruta;
						if(volumenPresentation == 1){
							channelPresentation = audio.play(positionSoundPresentation,numberLoop);
						}
					}
				}else {
					if(numberChannel == 1){
						channelBackground.stop();
						soundBackground = ruta;
					}else {
						channelPresentation.stop();
						soundPresentation = ruta;
					}					
				}
			}catch(error:Error){
				trace('url has not sound');
			}
		}
	}
}