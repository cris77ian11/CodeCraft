package codeCraft.text
{
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;


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
		/* Se usa para indicar que palabras deben agregar pero no se toman en cuenta en la verificacion, son como la trampa */
		private static var _trampas:String;

		/**
		 *
		 * @param casjasInputsTexto
		 * @param textosCorrectos
		 * @param limiteCaracteres
		 * @param botonComprobar
		 * @param trampas
		 */
		public static function load(casjasInputsTexto:Array, textosCorrectos:Array, limiteCaracteres:int = 5, botonComprobar:MovieClip = null, trampas:String = ""):void
		{
			_cajasInputTexto = casjasInputsTexto;
			_textosCorrectos = textosCorrectos;
			_limiteCaracteres = limiteCaracteres;
			_botonComprobar = botonComprobar;
			_trampas = trampas;

		}

		/**
		 *
		 */
		public static function remove():void
		{
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_OUT, activar);
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_IN, capturaFoco);
			_cajasInputTexto = null;
			_textosCorrectos = null;
			_limiteCaracteres = 5;
			_botonComprobar = null;
			_trampas = "";
		}

		private static function ConfigurarCajas(CatidadCaracteres:int, restricPalabras:Array, BtnComprobar:*, escepcion:String):void
		{
			Events.listener(_botonComprobar, MouseEvent.CLICK, comprobarInputs)
			//Configuramos las restricciones de las cajas.
			for (var i:int = 0; i < _cajasInputTexto.length; i++)
			{
				//indica la cantidad de caracteres maximos que puede tener
				_cajasInputTexto[i].maxChars = _limiteCaracteres;
				//indica las palabras qeu solo se permiten ingresar
				_cajasInputTexto[i].restrict = _textosCorrectos + _trampas;
				//indica el orden del tabulador 
				_cajasInputTexto[i].tabIndex = i;
			}
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_OUT, activar);
			Events.listener(_cajasInputTexto, FocusEvent.FOCUS_IN, capturaFoco);

		}

		/**
		 * Verifica que ninguna de las cajas esten vacias y si se encuentra en la antepenultima
		 * caja para cambiar el foco del elemento al boton de comprobar.
		 */
		private static function activar(event:FocusEvent):void
		{
			for (var i:int = 0; i < _cajasInputTexto.length; i++)
			{
				if (_cajasInputTexto[i].text != "")
				{
					//si el contador buenos es igual a la cantidad de elementos -1 cambiamos el index 
					//para que al precionar la tecla tab se dirija a el boton de Comparar no a la primera caja		
					if (_buenos == _cajasInputTexto.length - 1)
					{
						_cajasInputTexto[0].tabIndex = 2;
						_botonComprobar.tabIndex = 1;
						CodeCraft.focoActive(_botonComprobar);
					}
				}

			}
			//Valida que todas las cajas de texto sean correctas
			if (_buenos == _cajasInputTexto.length)
			{
				for (var j:int = 0; j < _textosCorrectos.length; j++)
				{
					_cajasInputTexto[j].selectable = false;
					_cajasInputTexto[j].tabIndex = null;
				}
				CodeCraft.focoActive(_botonComprobar);
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
			CodeCraft.focoActive(event.currentTarget);
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
					//valida todas las cajas de texto con el array que contiene las  respuestas correctas, _textosCorrectos
					if (_textosCorrectos[i].toUpperCase() == _cajasInputTexto[i].text.toUpperCase())
					{
						//si la opcion es correcta
						_cajasInputTexto[i].textColor = 0x028901;
						_buenos += 1;
						_cajasInputTexto[i].mouseEnabled = false;
					}
					else
					{
						//Opciones malas
						//Restaura el contador a 0 para que no entre a la comprobacion final
						_buenos = 0;
						_cajasInputTexto[i].textColor = 0xC40000;
						_cajasInputTexto[i].selectable = true;

					}

				}

			}

		}
		
	}
}
