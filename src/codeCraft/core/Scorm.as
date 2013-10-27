package codeCraft.core {
	import codeCraft.debug.Debug;
	import codeCraft.error.Validation;
	import codeCraft.events.Events;
	import codeCraft.media.Audio;
	
	import com.pipwerks.SCORM;
	
	import flash.events.MouseEvent;
	
	public class Scorm {
		
		private static var scorm:SCORM;
		
		public static function initialize():void {
			//ejecuta conexion al scorm
			scorm = new SCORM();
			try {
				scorm.connect();
				Debug.print("SCORM INICIADO", "SCORM");
			} catch (error:Error) {
				Debug.print("SCORM no conectado", "SCORM");
			}
		}
		
		private static function closeScormButton(e:MouseEvent):void {
			close();
		}
		
		public static function close():void {
			CodeCraft.removeAll();
			//se modifica estos valores para detener los audios mientras se elimina esta pantalla
			Audio.playAudio(null,0);
			Audio.playAudio(null,1);
			Debug.print("SCORM CERRADO", "SCORM");
			scorm.set("cmi.core.lesson_status", "completed");
			scorm.disconnect();
		}
		
		public static function qualify (valor:* = "0"):void {
			if (valor is String || valor is Number) {
				Debug.print("SCORM CALIFICADO con " + valor, "SCORM");
				if (valor is String) {
					scorm.set("cmi.core.score.raw", valor); //asigna el valor por medio de un porcentaje dado
				} else {
					scorm.set("cmi.core.score.raw", valor.toString());
				}
			} else {
				Validation.error('Se a pasado un valor no valido al parametro valor de la funcion scormCalificar');
			}
		}
		
		public static function closeButton(object:*,over:Boolean = false):void {
			Events.listener(object, MouseEvent.CLICK, closeScormButton,true,over);
		}
		
	}
}