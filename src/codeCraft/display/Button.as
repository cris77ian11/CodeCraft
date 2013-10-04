package codeCraft.display { 
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.error.Validation;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	public class Button {
		
		//variables de animacion
		private static var arrayAnimacion:Array = new Array ();
		// se utilizara para almacenar el objeto en el que el mouse esta encima en la funcion sobre
		private static var elementoSobreActual:* = null; 
		
		public static function button (object:*, enabled:Boolean = true, clicActive:Boolean = true):void {
			try {
				if(object is Array){
					for (var i:uint = 0; i < object.length; i++) {
						object[i].buttonMode = enabled;
						object[i].mouseChildren = !enabled;
					}
				}else {
					object.buttonMode = enabled;
					object.mouseChildren = !enabled;
				}
				if(clicActive) {
					if(enabled){
						Events.listener(object,MouseEvent.CLICK, Button.clickACtive,false,false);
					}else{
						Events.removeListener(object,MouseEvent.CLICK, Button.clickACtive, false);
					}
				}
			}catch(error:Error){
				Validation.error('El elemento object no es un elemento permitido o ya es un simbolo de tipo boton');
			}
		}
		
		
		public static function over(object:*, initialFrame:* = null, finalFrame:* = null, returnOver:Boolean = false):void {
			try {
				var positionArray:*;
				var arrayTemp:Array = new Array (object, initialFrame, finalFrame, returnOver);
				if (object is Array) {
					positionArray = Arrays.indexOf (arrayAnimacion,object[0], 'todo');
				}else {
					positionArray = Arrays.indexOf (arrayAnimacion,object, 'todo');
				}
				if(positionArray == -1){
					Events.listener (object, MouseEvent.MOUSE_OVER, animationOver);
					Events.listener (object, MouseEvent.MOUSE_OUT, animationOut);
				}
				arrayAnimacion.push (arrayTemp);
				if (initialFrame != null) {
					CodeCraft.stopFrame(object, initialFrame);
				}
			}catch(error:Error){
				Validation.error('El elemento object no es un elemento permitido o ya es un simbolo de tipo boton');
			}
		}
		
		public static function removeOver (object:*, initialFrame:* = null):void {
			var positionArray:*;
			var uniqueObject:Boolean = true;
			if (object is Array) {
				positionArray = Arrays.indexOf (arrayAnimacion,object[0], 'todo');
			}else {
				positionArray = Arrays.indexOf (arrayAnimacion,object, 'todo');
			}
			if(positionArray is Array){
				uniqueObject = false;
				var valueTemp:int = -1;
				for (var i:int = 0; i < positionArray.length; i++){
					if(arrayAnimacion[positionArray[i]][1] == initialFrame){
						valueTemp = i;
					}
				}
				positionArray = positionArray[valueTemp];
			}
			try {
				if(positionArray != -1) {
					if(arrayAnimacion[positionArray][1] == null) {
						CodeCraft.scaleMode(object);
					}
					if(uniqueObject){
						Events.removeListener (object, MouseEvent.MOUSE_OVER, animationOver, false);
						Events.removeListener (object, MouseEvent.MOUSE_OUT, animationOut, false);
					}
					arrayAnimacion.splice (positionArray, 1);
				}
			}catch (error:Error){
				Debug.print('El elemento de la función over se encuentra repedito, no se pudo eliminar el over','SISTEMA','ERROR');
			}
		}
		
		//animacion de cuando el boton es presionado, hace el efecto de presionado 
		private static function clickACtive (event:MouseEvent):void{
			var animationTween:TimelineMax = new TimelineMax();
			animationTween.append(TweenMax.to(event.currentTarget,0.1,{scaleX:0.8,scaleY:0.8}));
			animationTween.append(TweenMax.to(event.currentTarget,0.1,{scaleX:1,scaleY:1}));
			animationTween.play();
		}
		
		private static function animationOver (e:MouseEvent):void {
			var positionArray:* = Arrays.indexOf (arrayAnimacion, e.currentTarget, 'todo');
			if (positionArray is Array){
				for (var i:int = 0; i < positionArray.length; i++){
					if (arrayAnimacion[positionArray[i]][1] == null) {
						TweenMax.to(e.currentTarget,0.5,{scaleX:1.1,scaleY:1.1,ease:Cubic.easeOut});
					}else {
						if (arrayAnimacion[positionArray[i]][2] != null && arrayAnimacion[positionArray[i]][2] != 0) {
							e.currentTarget.gotoAndStop (arrayAnimacion[positionArray[i]][2]);
						}else {
							e.currentTarget.gotoAndPlay (arrayAnimacion[positionArray[i]][1]);
						}
					}
				}
			}else {
				if (arrayAnimacion[positionArray][1] == null) {
					TweenMax.to(e.currentTarget,0.5,{scaleX:1.1,scaleY:1.1,ease:Cubic.easeOut});
				}else {
					if (arrayAnimacion[positionArray][2] != null && arrayAnimacion[positionArray][2] != 0) {
						e.currentTarget.gotoAndStop (arrayAnimacion[positionArray][2]);
					}else {
						e.currentTarget.gotoAndPlay (arrayAnimacion[positionArray][1]);
					}
				}
			}
		}
		
		private static function animationOut(e:MouseEvent):void {
			var positionArray:* = Arrays.indexOf (arrayAnimacion, e.currentTarget, 'todo');
			if(positionArray is Array){
				for(var i:int = 0; i < positionArray.length; i++){
					if (arrayAnimacion[positionArray[i]][1] == null){
						TweenMax.to(e.currentTarget,0.2,{scaleX:1,scaleY:1});
					}else if (arrayAnimacion[positionArray[i]][2] != null && arrayAnimacion[positionArray[i]][2] != 0) {
						e.currentTarget.gotoAndStop (arrayAnimacion[positionArray[i]][1]);
					}else if(arrayAnimacion[positionArray[i]][1] is Number) {
						if(arrayAnimacion[positionArray[i]][2] == 0){
							e.currentTarget.play();
							e.currentTarget.addEventListener (Event.ENTER_FRAME, verifyStopElemento);
						}else {
							e.currentTarget.stop ();
							if (arrayAnimacion[positionArray[i]][3]) {
								e.currentTarget.gotoAndStop (arrayAnimacion[positionArray[i]][1]);
							}
						}
					}
				}
			}else {
				if (arrayAnimacion[positionArray][1] == null){
					TweenMax.to(e.currentTarget,0.2,{scaleX:1,scaleY:1});
				}else if (arrayAnimacion[positionArray][2] != null && arrayAnimacion[positionArray][2] != 0) {
					e.currentTarget.gotoAndStop (arrayAnimacion[positionArray][1]);
				}else if(arrayAnimacion[positionArray][1] is Number) {
					if(arrayAnimacion[positionArray][2] == 0){
						e.currentTarget.play();
						e.currentTarget.addEventListener (Event.ENTER_FRAME, verifyStopElemento);
					}else {
						e.currentTarget.stop ();
						if (arrayAnimacion[positionArray][3]) {
							e.currentTarget.gotoAndStop (arrayAnimacion[positionArray][1]);
						}
					}
				}
			}
		}
		
		private static function verifyStopElemento(e:Event):void{
			if(e.currentTarget.currentFrame == 1) {
				e.currentTarget.removeEventListener (Event.ENTER_FRAME, verifyStopElemento);
				e.currentTarget.gotoAndStop(1);
			}
		}
		
		
	}
}