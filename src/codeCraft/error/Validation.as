package codeCraft.error {

	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	
	import flash.text.TextField;
	

	public class Validation{
		
		public static function error (error:String):void{
			Debug.print(error,'Sistema ERROR');
			
			var textMenssage:TextField = new TextField();
			textMenssage.text = "ERROR SISTEMA: "+ error;
			//CodeCraft.addChild(textMenssage,null,520,320); 
		}
	}
}