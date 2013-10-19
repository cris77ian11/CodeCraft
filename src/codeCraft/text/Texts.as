package codeCraft.text{

	import flash.display.MovieClip;
	import flash.text.StaticText;
	import flash.text.TextField;
	
	import codeCraft.debug.Debug;
	
	public class Texts {
		
		private static var numberText:int = 0;

		public static function load (object:*, textValue:*, nivel:int = 1):void 
		{
			var textTemp:*;
			numberText = 0;
			if (object is Array) 
			{
				for (var i:uint = 0; i < object.length; i++) 
				{ 
					if (object[i] is TextField || object[i] is StaticText) 
					{
						textTemp = object[i];
					}
					else 
					{
						for (var n:uint = 0; n < object[i].numChildren; n++) 
						{
							//Verify children is TextField
							if (nivel == 1)
							{
								Debug.print(object[i].getChildAt(n));
								if (object[i].getChildAt(n) is TextField || object[i].getChildAt(n) is StaticText) 
								{
									textTemp = object[i].getChildAt(n);
								}
							}
							else 
							{
								var objectTemp:* = object[i].getChildAt(n);
								if(objectTemp is MovieClip)
								{
									for (var l:uint = 0; l < objectTemp.numChildren; l++) 
									{
										if (objectTemp.getChildAt(l) is TextField || objectTemp.getChildAt(l) is StaticText) 
										{
											textTemp = objectTemp.getChildAt(l);
										}
									}
								}
							}
						}
					}
					loadText(textTemp,textValue);
					numberText++;
				}
			}
			else 
			{
				if (object is TextField || object is StaticText) {
					textTemp = object;
				}else {
					for (var j:uint = 0; j < object.numChildren; j++) {
						if (object.getChildAt(j) is TextField || object.getChildAt(j) is StaticText) {
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
			if(objectText is TextField || objectText is StaticText){
				objectText.text = textLoad;
			}
		}
		
	}
}