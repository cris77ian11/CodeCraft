package codeCraft.utils {
	import codeCraft.error.Validation;
	
	public class Arrays	{
		
		
		public static function stop(array:Array):void{
			try {
				for(var i:int = 0; i < array.length; i++){
					array[i].stop();
				}
			}catch(error:Error){
				Validation.error('El parametro a pasar debe ser un array que contenga movieClips');
			}
		}
		
		public static function play(array:Array):void{
			try {
				for(var i:int = 0; i < array.length; i++){
					if(array[i].currentLabel != 'noAnimation'){
						array[i].play();
					}
				}
			}catch(error:Error){
				Validation.error('El parametro a pasar debe ser un array que contenga movieClips');
			}
		}
		
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
		public static function reverse (array:Array):Array{
			var arrayTemp:Array = new Array();
			for (var i:int = array.length; i > 0; i--){
				arrayTemp.push(array[i - 1]);
			}
			return arrayTemp;
		}
		
		//desordena un array
		public static function random(array:Array):Array {
			var arrayTemp:Array = new Array(); 
			while (array.length > 0) {
				var _numero:Number = Math.floor(Math.random() * array.length);
				arrayTemp.push(array[_numero]); 
				array.splice(_numero, 1);
			}
			return arrayTemp;
		}
		
		//fill retorna un array con una cantidad de campos indicada y con
		public static function fill (value:*, sizeArray:* = 1):Array {
			if(sizeArray == undefined || sizeArray == null){
				sizeArray = 1;
			}
			var arrayTemp:Array = new Array();
			for (var i:uint = 0; i < sizeArray; i++){
				arrayTemp.push(value);	
			}
			return arrayTemp;
		}
		
	}
}