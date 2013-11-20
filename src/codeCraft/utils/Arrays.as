package codeCraft.utils {
	import codeCraft.debug.Debug;
	import codeCraft.error.Validation;

	/**
	 * 
	 * @author luisfelipe
	 */
	public class Arrays
	{


		/**
		 * 
		 * @param array
		 */
		public static function stop(array:Array):void
		{
			try
			{
				for(var i:int = 0; i < array.length; i++)
				{
					array[i].stop();
				}
			}
			catch(error:Error)
			{
				Debug.print("No se puede detener los movieclips en el fotograma especificado.","Arrays.stop","Falla CodeCraft ");
			}
		}

		/**
		 * 
		 * @param array
		 */
		public static function play(array:Array):void
		{
			try
			{
				for(var i:int = 0; i < array.length; i++)
				{
					var nameObject:String = "";
					//se verifica si si el elemento tiene un label asignado
					if(array[i].currentLabel != null)
					{
						nameObject = array[i].currentLabel;
					}
					if(nameObject.substr(0,2) != 'no')
					{
						array[i].play();
					}
				}
			}
			catch(error:Error)
			{
				Debug.print("No se puede aplicar play a los movieclips.","Arrays.play","Falla CodeCraft ");
			}
		}

		/**
		 * 
		 * @param array
		 * @param valor
		 * @param type
		 * @return 
		 */
		public static function indexOf(array:*, valor:* = null, type:String = "normal"):* {
			var _posicionArray:Array = new Array();
			if (array is Array) {
				switch (type) {
					case 'normal':
						_posicionArray[0] = array.indexOf(valor);
						break;
					case 'multi':
						for (var i:int = 0; i < array.length; i++) {
							if (array[i] is Array) {
								if (array[i].indexOf(valor) != -1) {
									_posicionArray.push(i);
								}
							}
						}
						break;
					default:
						_posicionArray[0] = array.indexOf(valor);
						if (_posicionArray[0] == -1) {
							_posicionArray = new Array();
							for (i = 0; i < array.length; i++) {
								if (array[i] is Array) {
									for (var j:int = 0; j < array[i].length; j++) {
										if (array[i][j] is Array) {
											if (array[i][j].indexOf(valor) != -1) {
												_posicionArray.push(i);
											}
										}
									}
									if (array[i].indexOf(valor) != -1) {
										_posicionArray.push(i);
									}
								}else {
									if (array.indexOf(valor) != -1) {
										_posicionArray.push(i);
									}
								}
							}
						}
						break;
				}
			}
			if(_posicionArray.length > 1){
				return _posicionArray;
			}else {
				if(_posicionArray.length == 0){
					return -1;
				}else {
					return _posicionArray[0];
				}
			}
		}

		//elimina un elemento del array y lo devuelve
		/**
		 * 
		 * @param array
		 * @param object
		 * @return 
		 */
		public static function remove (array:Array, object:*):* {
			var _posicion:Number = indexOf(array,object,'todo');
			if(_posicion != -1){
				array.splice(_posicion,1);
			}else {
				Validation.error('El object a eliminar del array no se encuentra');
			}
			return object;
		}

		//reordena un array poniendo ubicando los elementos de adelante a atras
		/**
		 * 
		 * @param array
		 * @return 
		 */
		public static function reverse (array:Array):Array{
			var arrayTemp:Array = new Array();
			for (var i:int = array.length; i > 0; i--){
				arrayTemp.push(array[i - 1]);
			}
			return arrayTemp;
		}

		//desordena un array
		/**
		 * 
		 * @param array
		 * @return 
		 */
		public static function random(array:Array):Array
		{
			if(array != null)
			{
				var arrayTemp:Array = new Array();
				var arrayCopia:Array = clone(array);
				while (arrayCopia.length > 0)
				{
					var _numero:Number = 0;
					if(arrayCopia[_numero] is Array)
					{
						arrayCopia[_numero] = random(arrayCopia[_numero]);
					}
					else
					{
						_numero = Math.floor(Math.random() * arrayCopia.length);
					}
					arrayTemp.push(arrayCopia[_numero]);
					arrayCopia.splice(_numero, 1);
				}
				return arrayTemp;
			}
			else
			{
				return null;
			}
		}

		/**
		 * LLena un array con los valores indicados, se puede asignar un espacio total del arreglo, tambien se  peude indicar
		 * desde que espacio del array quiere iniciar la carga de elementos y hasta que espacio, por defecto se llenara
		 * todo si no se modifican los valores
		 * @param value Valor de cualquier tipo con el que se quiera llenar el array
		 * @param sizeArray Tamano maximo de elemento que tiene o va a tener el array
		 * @param positionInitial Valor numerico que indica desde que posicion del array se va a iniciar el llenado
		 * @param positionFinal Valor numerico que indica hasta donde se va a llenar el arreglo
		 * @param valueNull Valor que se almacena en los campos del array que no se llenaran con el valor value
		 */
		public static function fill (value:*, sizeArray:int = 1, positionInitial:int = 0, positionFinal:int = 0, valueNull:* = null):Array
		{
			if (positionFinal == 0 || positionFinal < positionInitial)
			{
				positionFinal = sizeArray;
			}
			var arrayTemp:Array = new Array();
			for (var i:int = 0; i < sizeArray; i++)
			{
				if(i >= positionInitial && i < positionFinal)
				{
					arrayTemp.push(value);
				}
				else
				{
					arrayTemp.push(valueNull);
				}
			}
			return arrayTemp;
		}

		/**
		 * Se encarga de recorrer el array y verificar si el elemento que se pasa como value se encuentra en
		 * el array por completo, es decir si se quiere saber si un array esta lleno todos sus campos de true
		 * se utiliza la funcion, de estar lleno devolvera true, de tener aunque sea un campo con otro valor
		 * devolvera false.
		 * @param array Array al que se desea comprobar
		 * @param value Valor de cualquier tipo el que se desea verificar si esta cargado el array
		 */
		public static function verifyFill(array:Array, value:*):Boolean
		{
			for (var i:uint = 0; i < array.length; i++)
			{
				if(array[i] != value)
				{
					return false;
				}
			}
			return true;
		}
		
		
		/**
		 * Retorna Boolea true si llega el caso de que el tipo de valores almacenados en el array son los ingresados, si llega a haber 
		 * un solo elemento que no sea del tipo se devuelve false
		 * @param array
		 * @param type
		 * @return 
		 */
		public static function verifyType (array:Array, type:*):Boolean
		{
			for (var i:uint = 0; i < array.length; i++)
			{
				if(!(array[i] is type))
				{
					return false;
				}
			}
			return true;
		}


		/**
		 * Clona un array y devuelve la copia exacta del mismo, con la diferencia de que este se puede modificar
		 * y las acciones aplicadas a este no alteran al array de origen.
		 * @param array
		 * @return
		 *
		 */
		public static function clone(array:Array):Array
		{
			if(array != null)
			{
				var arrayCopia:Array = new Array();
				for(var i:uint = 0; i < array.length; i++)
				{
					arrayCopia.push(array[i]);
				}
				return arrayCopia;
			}
			else
			{
				return null;
			}
		}
		
		public static function reload(array:Array):Array 
		{
			var arrayTemporal:Array = new Array();
			for(var i:int = 0; i < array.length; i++)
			{
				if(array[i] != undefined || array[i] != null)
				{
					arrayTemporal.push(array[i]);
				}
			}
			return arrayTemporal;
		}

	}
}