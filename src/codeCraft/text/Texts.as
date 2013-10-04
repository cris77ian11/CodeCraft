package codeCraft.text{
	
	import fl.text.TLFTextField;
	
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	public class Texts {
		
		private static var numberText:int = 0;

		public static function load (object:*, textValue:*):void {
			var textTemp:*;
			numberText = 0;
			if (object is Array) {
				for (var i:uint = 0; i < object.length; i++) { 
					if (object[i] is TextField || object[i] is TLFTextField) {
						textTemp = object[i];
					}else {
						for (var n:uint = 0; n < object[i].numChildren; n++) {
							//Verify children is TextField
							if (object[i].getChildAt(n) is TextField || object[i].getChildAt(n) is TLFTextField) {
								textTemp = object[i].getChildAt(n);
							}
						}
					}
					loadText(textTemp,textValue);
					numberText++;
				}
			} else {
				if (object is TextField || object is TLFTextField) {
					textTemp = object;
				}else {
					for (var j:uint = 0; j < object.numChildren; j++) {
						if (object.getChildAt(j) is TextField || object.getChildAt(j) is TLFTextField) {
							textTemp = object.getChildAt(j);
						}
					}
				}
				loadText(textTemp,textValue);
			}
		}
		
		private static function loadText (objectText:*, valueText:*):void {
			objectText.wordWrap = true;
			objectText.selectable = false; 
			var textLoad:String;
			if(valueText is Array){
				textLoad = valueText[numberText];	
			}else {
				textLoad = valueText;
			}
			if(objectText is TextField || objectText is TLFTextField){
				objectText.text = textLoad;
			}
		}
		
	}
}