package codeCraft.media
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	
	public class Video
	{
		
		private static var reproductorYouTube:Object;
		private static var loaderYouTube:Loader;
		private static var loaderContextYouTube:LoaderContext = new LoaderContext();
		private static var _posicionYouTube:Array;
		private static var _tamanoYoutube:Array;
		
		/**
		 * 
		 * @param url
		 * @param playerSize
		 * @param positionPlayer
		 */
		public static function loadYouTube(video:String, playerSize:Array = null, positionPlayer:Array = null):void
		{
			loaderYouTube = new Loader();
			_posicionYouTube = positionPlayer;
			_tamanoYoutube = playerSize;
			if(positionPlayer == null)
			{
				_posicionYouTube = new Array(0,0);
			}
			if(playerSize == null)
			{
				_tamanoYoutube = new Array(640, 390);
			}
			loaderContextYouTube.checkPolicyFile = true;
			loaderContextYouTube.securityDomain = SecurityDomain.currentDomain;
			loaderContextYouTube.applicationDomain = ApplicationDomain.currentDomain;
			
			loaderYouTube.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			loaderYouTube.load(new URLRequest("http://www.youtube.com/v/" + video));
		}
		
		public static function removeYoutube():void
		{
			if(CodeCraft.getMainObject().contains(loaderYouTube))
			{
				CodeCraft.removeChild(loaderYouTube);	
			}
		}
		
		private static function onLoaderInit(event:Event):void {
			CodeCraft.addChild(loaderYouTube,null,_posicionYouTube[0],_posicionYouTube[1]);
			loaderYouTube.content.addEventListener("onReady", reproduccionYouTube);
			loaderYouTube.content.addEventListener("onError", errorYouTube);
		}
		
		private static function reproduccionYouTube(event:Event):void 
		{
			reproductorYouTube = loaderYouTube.content;
			reproductorYouTube.setSize(_tamanoYoutube[0],_tamanoYoutube[1]);
		}
		
		private static function errorYouTube(event:Event):void 
		{
			Debug.print("Error al reproducir el video de youtube. " + Object(event).data,"Video.errorYouTube", "Falla CodeCraft ");
		}
		
	}
}