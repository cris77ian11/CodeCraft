package codeCraft.text
{
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 *
	 * @author luisfelipe
	 */
	public class CheckInput
	{
		
		/* Indica al final si todas las cajas estan buenas */
		private static var _buenos:int = 0;
		/* Almacena las palabras que son correctas para cada input */
		private static var _textosCorrectos:Array;
		/* Almance las instancias de los input */
		private static var _cajasInputTexto:Array;
		/* Instancia del boton que se encarga de comprobar */
		private static var _botonComprobar:MovieClip;
		/* cantidad de caracteres a limitar por caja de texto */
		private static var _limiteCaracteres:int;
		
		/**
		 *
		 * @param casjasInputsTexto
		 * @param textosCorrectos
		 * @param limiteCaracteres
		 * @param botonComprobar
		 */
		public static function load(casjasInputsTexto:Array, textosCorrectos:Array, limiteCaracteres:int = 5, botonComprobar:MovieClip = null):void
		{
			_cajasInputTexto = casjasInputsTexto;
			_textosCorrectos = textosCorrectos;
			Debug.print(_textosCorrectos);
			_limiteCaracteres = limiteCaracteres;
			_botonComprobar = botonComprobar;
			configurar();
		}
		
		/**
		 *
		 */
		public static function remove():void
		{
			eliminarListener();
			_cajasInputTexto = null;
			_textosCorrectos = null;
			_limiteCaracteres = 5;
			_botonComprobar = null;
		}
		
		private static function configurar():void
		{
			Events.listener(_botonComprobar, MouseEvent.CLICK, comprobarInputs)
			//Configuramos las restricciones de las cajas.
			for (var i:int = 0; i < _cajasInputTexto.length; i++)
			{
				//indica la cantidad de caracteres maximos que puede tener
				_cajasInputTexto[i].maxChars = _limiteCaracteres;
				//indica las palabras qeu solo se permiten ingresar
				_cajasInputTexto[i].restrict = "A-z";
				//indica el orden del tabulador 
				_cajasInputTexto[i].tabIndex = i;
				_cajasInputTexto[i].addEventListener(FocusEvent.FOCUS_OUT, activar);
				_cajasInputTexto[i].addEventListener(FocusEvent.FOCUS_IN, capturaFoco);
			}
			CodeCraft.focoActive(_cajasInputTexto[0]);
		}
		
		private static function listener():void
		{
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_OUT, activar);
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_IN, capturaFoco);
			Events.listener(_cajasInputTexto, MouseEvent.CLICK, cambiarFoco, false, false);
		}
		
		private static function eliminarListener():void
		{
			Events.removeListener(_cajasInputTexto, FocusEvent.FOCUS_OUT, activar);
			Events.removeListener(_cajasInputTexto, FocusEvent.FOCUS_IN, capturaFoco);
			Events.removeListener(_cajasInputTexto, MouseEvent.CLICK, cambiarFoco, false);
		}
		
		private static function cambiarFoco(event:MouseEvent):void
		{
			CodeCraft.focoActive(event.currentTarget);
		}
		
		/**
		 * Verifica que ninguna de las cajas esten vacias y si se encuentra en la antepenultima
		 * caja para cambiar el foco del elemento al boton de comprobar.
		 */
		private static function activar(event:FocusEvent):void
		{
			//se iguala a cero par que no siga sumando
			_buenos = 0;
			for (var i:int = 0; i < _cajasInputTexto.length; i++)
			{
				if (_cajasInputTexto[i].text != "")
				{
					_buenos += 1;
					//si el contador buenos es igual a la cantidad de elementos -1 cambiamos el index 
					//para que al precionar la tecla tab se dirija a el boton de Comparar no a la primera caja		
					if (_buenos == _cajasInputTexto.length - 1)
					{
						_cajasInputTexto[0].tabIndex = 2;
						_botonComprobar.tabIndex = 1;
					}
				}
				
			}
			//Valida que todas las cajas de texto sean correctas
			if (_buenos == _cajasInputTexto.length)
			{
				CodeCraft.property(_botonComprobar, {alpha: 1});
				for (var j:int = 0; j < _textosCorrectos.length; j++)
				{
					_cajasInputTexto[j].selectable = false;
					_cajasInputTexto[j].tabIndex = null;
				}
			}
		}
		
		/**
		 * restaurar los bordes de las cajas y sus textos a su color original
		 * @param event
		 */
		private static function capturaFoco(event:FocusEvent):void
		{
			
			if (event.target)
			{
				var posicion:int = Arrays.indexOf(_cajasInputTexto, event.currentTarget);
				//Desactivamos el borde de la caja
				_cajasInputTexto[posicion].border = false;
				
				if (_cajasInputTexto[posicion].text.length <= 0)
				{
					//si la caja esta vacia restaura al color negro
					_cajasInputTexto[posicion].textColor = 0x000000;
				}
			}
		
		}
		
		private static function comprobarInputs(event:MouseEvent):void
		{
			for (var i:int = 0; i < _textosCorrectos.length; i++)
			{
				//si la caja de texto esta vacia me la marca  de color rojo y no valida
				if (_cajasInputTexto[i].text == "")
				{
					_cajasInputTexto[i].border = true;
					_cajasInputTexto[i].borderColor = 0xFF0000;
				}
				else
				{
					trace(String(_textosCorrectos[0]).toUpperCase());
					trace(String(_cajasInputTexto[i].text).toUpperCase());
					//valida todas las cajas de texto con el array que contiene las  respuestas correctas, _textosCorrectos
					if (String(_textosCorrectos[i]).toUpperCase() == String(_cajasInputTexto[i].text).toUpperCase())
					{
						//si la opcion es correcta
						_cajasInputTexto[i].textColor = 0x028901;
						_cajasInputTexto[i].mouseEnabled = false;
						_cajasInputTexto[i].selectable = false;
					}
					else
					{
						//Opciones malas
						//Restaura el contador a 0 para que no entre a la comprobacion final
						_buenos = 0;
						_cajasInputTexto[i].textColor = 0xC40000;
						_cajasInputTexto[i].selectable = true;
						_cajasInputTexto[i].tabIndex = i;
					}
				}
				Events.listener(CodeCraft.getMainObject().stage,FocusEvent.KEY_FOCUS_CHANGE,DeshabilitaTab,false,false);
			}
		}
		
		/**
		 * Evita que al final de la comprobacion y al precionar tab realice el cambio de caja.. asi el  usuario va diretamente a la caja mala en cuestion.
		 * @param	event
		 */
		private static function DeshabilitaTab(event:FocusEvent):void
		{
			if (Keyboard.TAB)
			{
				event.preventDefault();
			}
		}
	
	}
}