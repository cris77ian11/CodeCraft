package codeCraft.utils {
	
	import codeCraft.debug.Debug;
	import codeCraft.text.Texts;
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Timers extends MovieClip{
		
		//variables para el cronometro
		private static var minute:String;
		private static var seconds:String;
		private static var textField:*;
		private static var functionChronometer:Function;
		private static var timerChronometer:Timer = new Timer(1000);
		
		//variables para los timer
		private static var arrayTimer:Array = new Array();
		
		//funciones para el manejo de los timer y retornar una funcion cuando este finalice

		public static function timer (time:Number, onComplete:Function, repeat:int = 1):void{
			try{
				var timerNew:Timer = new Timer(time*1000,repeat);
				timerNew.addEventListener(TimerEvent.TIMER,timerComplete);
				timerNew.start();
				var arrayTemp:Array = new Array(timerNew,onComplete,repeat);
				arrayTimer.push(arrayTemp);
			}catch(error:Error){
				Debug.print('El timer no tiene los parametros correctos, falta insertar una funcion de retorno o ocurrio un error interno','SISTEMA','ERROR');
			}
		}
		
		public static function stopAllTimer ():void{
			if(arrayTimer.length > 0){
				for (var i:uint = 0; i < arrayTimer.length; i++){
					arrayTimer[i][0].stop();
					arrayTimer[i][0].removeEventListener(TimerEvent.TIMER,timerComplete);
					arrayTimer[i] = null;
				}
			}
			arrayTimer = new Array();
		}
		
		private static function timerComplete (event:TimerEvent):void {
			var position:int = Arrays.indexOf(arrayTimer,event.currentTarget,'todo');
			if(position != -1){
				arrayTimer[position][1]();
				if(arrayTimer[position][2] == 1){
					arrayTimer[position][2]--;
					event.currentTarget.stop();
					event.currentTarget.removeEventListener(TimerEvent.TIMER,timerComplete);
				}
			}else {
				Debug.print('Error en la funcion timerComplete de CodeCraft, no se encontro el elemento timer en arrayTimer','SISTEMA','ERROR');
			}
		}
		
		//funciones para el cronometro
		
		public static function chronometer (container:*, valueMinute:* = "10", valueSeconds:* = "00", onComplete:Function = null):void {
			try{
				functionChronometer = onComplete;
				textField = container;
				//se convierten los valores a textos para poder ser manipulados t hacer comprobaciones
				minute = String(valueMinute);
				seconds = String(valueSeconds);
				//cada segundo ocurre el cambio de valor por lo que timerchronometer vale 1 segundo
				timerChronometer.addEventListener(TimerEvent.TIMER, timerChange);
				timerChronometer.start();
				printTime();
			}catch(error:Error) {
				Debug.print('chronometer no tiene los parametros correctos, falta insertar un contenedor o ocurrio un error interno','SISTEMA','ERROR');
			}
		}
		//la funcion cada vez que pasa 1 segundo se encarga de reducir los numeros
		private static function timerChange (event:TimerEvent):void {
			var number:int;
			number = int(seconds);
			//el if detecta cuando los segundos llegaron a 0 para hacer el cambio o retroceso del minuto
			if(number == 0){
				seconds = "59";
				number = int(minute);
				if(number == 0){
					finishChronometer();
				}else {
					number--;
					minute = String(number);
				}
			}else {
				number--;
				seconds = String(number);
			}
			printTime();
		}
		
		//las dos funcion se encerga de saber cuando esta en un valor menor de 10 para agregar un cero al cronometro para u vizualizacion
		private static function verifyNumbers ():void {
			if (minute.length == 1) {
				minute = "0" + minute;
			}
			if (seconds.length == 1) {
				seconds = "0" + seconds;
			}
		}
		
		private static function printTime ():void {
			verifyNumbers();
			Texts.load(textField,minute + ":" + seconds);
		}
		
		//se ejecuta despues de que el cronometro llega a cero
		private static function finishChronometer ():void{
			timerChronometer.stop();
			timerChronometer.removeEventListener(TimerEvent.TIMER, timerChange);
			minute = "00";
			seconds = "00";
			printTime();
			if(functionChronometer != null) {
				functionChronometer();
			}
		}

	}
}