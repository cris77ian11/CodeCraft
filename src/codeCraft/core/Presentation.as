package codeCraft.core {
	
	import codeCraft.debug.Debug;
	import codeCraft.display.Button;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	import codeCraft.utils.Audio;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class Presentation {
		
		//sound
		private static var frameActual:Number;
		private static var positionArray:Number;
		
		//variables para la navigation
		private static var moverPresentacion:Boolean = false;
		private static var arrayPresentation:Array = new Array();
		private static var arrayPresentationMovieClip:Array = new Array();
		private static var navigation:Dictionary = new Dictionary();
		private static var arraySounds:Array = new Array();
		private static var soundForAnimation:Boolean = false;
		
		/*
		█████████████████████████████████████████████████████████████████████████████████████████████
		FUNCIONES navigation
		█████████████████████████████████████████████████████████████████████████████████████████████
		*/
		
		
		/**
		 * 
		 * @param	buttonLeft		Representa el boton o la flecha que va a atras de la presentacion
		 * @param	buttonRight		Representa el boton o la flecha que va a adelante de la prensetacion
		 * @param	currentPage		El numero actual del fotograma donde se encuentra la presentacion
		 * @param	pages			Numero total de paginas de la presentacion
		 */
		public static function checkNavigation(buttonLeft:Object, buttonRight:Object, currentPage:Number = 1, pages:Number = 1):void {
			if (pages != 1) {
				if (currentPage >= pages) {
					buttonLeft.visible = true;
					buttonRight.visible = false;
				}else {
					if (currentPage <= 1) {
						buttonLeft.visible = false;
						buttonRight.visible = true;
					}else {
						buttonLeft.visible = true;
						buttonRight.visible = true;
					}
				}
			}else {
				buttonLeft.visible = false;
				buttonRight.visible = false;
			}
			if(navigation['paging'] != null){
				if (pages > 1){
					navigation['paging'].text = currentPage + "/" + pages;
				}else {
					navigation['paging'].text = "";
				}
			}
		}
		
		
		public static function load(buttonLeft:Object, buttonRight:Object, paging:* = null, container:* = null, noAnimation:Array = null):void {
			if (container == null) {
				container = CodeCraft.getMainObject();
			}else{
				container.visible = true;
			}
			container.gotoAndStop(1);
			navigation['buttonLeft'] = buttonLeft;
			navigation['buttonRight'] = buttonRight;
			navigation['paging'] = paging;
			navigation['container'] = container;
			navigation['noAnimation'] = noAnimation;
			
			//se activa el foco para que pueda navegar con el teclado
			CodeCraft.getMainObject().stage.stageFocusRect = false;
			CodeCraft.getMainObject().stage.focus = CodeCraft.getMainObject();
			
			checkNavigation(navigation['buttonLeft'], navigation['buttonRight'], 1, navigation['container'].totalFrames);
			storePresentation ();
			listenerPresentation();
		}
		
		public static function remove():void {
			removeListenerPresentation();
			if(navigation['paging'] != null){
				navigation['paging'].text = "";
			}
		}
		
		public static function reload():void{
			checkNavigation(navigation['buttonLeft'], navigation['buttonRight'], navigation['container'].currentFrame, navigation['container'].totalFrames);
		}
		
		//se utiliza para cargar los audios que van a funcionar con la opcion de la presentacion
		public static function loadSound(sounds:Array):void{
			if(CodeCraft.soundActive && navigation['container'] != undefined){
				arraySounds = sounds;
				frameActual = 0;
				Events.listener(CodeCraft.getMainObject(),Event.ENTER_FRAME, detectChangeFrame);
			}
		}
		
		private static function storePresentation():void {
			var storeObject:Boolean = true;
			arrayPresentation = new Array();
			arrayPresentationMovieClip = new Array();
			for(var i:uint = 0; i < navigation['container'].numChildren; i++){
				var object:* = navigation['container'].getChildAt(i);
				if (object != navigation['buttonLeft'] && object != navigation['buttonRight']){
					if(navigation['noAnimation'] != null && navigation['noAnimation'] is Array){
						for(var j:uint = 0; j < navigation['noAnimation'].length; j++){
							if(object.name == navigation['noAnimation'][j].name || object == navigation['noAnimation'][j]){
								storeObject = false;
							}
						}
					}
					if(storeObject){
						object.alpha = 0;
						if(object is MovieClip){
							object.gotoAndStop(1);
							arrayPresentationMovieClip.push(object);
						}
						arrayPresentation.push(object);
					}
					storeObject = true;
				}
			}
			arrayPresentation.sortOn("name",Array.CASEINSENSITIVE);
			entryAnimation();
		}
		
		private static function navigationButton(e:MouseEvent):void {
			if (e.currentTarget == navigation['buttonLeft']) { 
				//atras
				moverPresentacion = false;
			}else { 
				//adelante
				moverPresentacion = true;
			}
			outAnimation();
		}
		
		private static function navigationKeyBoard(e:KeyboardEvent):void {
			var teclaPresionada:Number = e.keyCode;
			if (teclaPresionada == 37 && navigation['container'].currentFrame > 1) {
				//flecha izquierda
				moverPresentacion = false;
				outAnimation();
			} 
			if (teclaPresionada == 39 && navigation['container'].currentFrame < navigation['container'].totalFrames) { 
				//flecha derecha
				moverPresentacion = true;
				outAnimation();
			}
		}
		
		private static function entryAnimation():void {
			TweenMax.allTo(arrayPresentation,0.5,{alpha:1,ease:Cubic.easeOut},0.5,entryAnimationComplete);
			Arrays.play(arrayPresentationMovieClip);
		}
		
		private static function entryAnimationComplete():void{
			soundForAnimation = false;
			if(CodeCraft.soundActive && arraySounds.length > 0){
				Audio.playAudio(arraySounds[frameActual - 1], 0);
			}
		}
		
		private static function outAnimation():void {
			soundForAnimation = true;
			TweenMax.allTo(arrayPresentation,0.2,{alpha:0},0,outAnimationComplete);
		}
		
		private static function outAnimationComplete():void{
			if (moverPresentacion) {
				navigation['container'].nextFrame();
			}else {
				navigation['container'].prevFrame();
			}
			checkNavigation (navigation['buttonLeft'], navigation['buttonRight'], navigation['container'].currentFrame, navigation['container'].totalFrames);
			storePresentation ();
		}
		
		//cargar y eliminar los listner que hacen que sirva la presentacion
		private static function listenerPresentation ():void {
			Events.listener(navigation['buttonLeft'], MouseEvent.CLICK, navigationButton,true,true);
			Events.listener(navigation['buttonRight'], MouseEvent.CLICK, navigationButton,true,true);
			Events.listener(CodeCraft.getMainObject(),KeyboardEvent.KEY_DOWN, navigationKeyBoard);
			Events.listener(navigation['container'], MouseEvent.CLICK, CodeCraft.focoNavigation,false);
		}
		private static function removeListenerPresentation ():void {
			Events.removeListener(navigation['buttonLeft'], MouseEvent.CLICK, navigationButton);
			Events.removeListener(navigation['buttonRight'], MouseEvent.CLICK, navigationButton);
			Events.removeListener(CodeCraft.getMainObject(),KeyboardEvent.KEY_DOWN, navigationKeyBoard);
			Events.removeListener(navigation['container'], MouseEvent.CLICK, CodeCraft.focoNavigation,false);
			if(CodeCraft.soundActive){
				Events.removeListener(CodeCraft.getMainObject(),Event.ENTER_FRAME, detectChangeFrame);
				Audio.stopSoundPresentation();
			}
		}
		
		private static function detectChangeFrame (event:Event):void {
			if(frameActual != navigation['container'].currentFrame){
				frameActual = navigation['container'].currentFrame;
				if(soundForAnimation){
					Audio.stopSoundPresentation();
				}else {
					Audio.playAudio(arraySounds[frameActual - 1], 0);
				}
			}
		}
	}
}