package codeCraft.display { 
	
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.error.Validation;
	import codeCraft.events.Events;
	import codeCraft.utils.Arrays;
	
	public class Button {
		
		//variables de animacion
		private static var _arrayAnimacion:Array = new Array ();
		private static var _objectCurrentOver:Array = new Array();
		
		/**
		 * Agrega el modo boton a un movieClip o array con movieClips, tambien se encarga de agregar
		 * una animación de tipo zoom si se detecta el clicActive, la animación consta de hacer una scale
		 * reduciendo el tamaño del boton simulando el efecto de que fue presionado.
		 * 
		 * @param object MovieClip o array con Movieclips
		 * @param enabeld Estado de la accion, true activa y false desactiva
		 * @param clicActive Activa la animacion del boton al presionar, true activa y false desactiva	
		 */
		public static function button (object:*, enabled:Boolean = true, clicActive:Boolean = true):void 
		{
			try 
			{
				if(object is Array)
				{
					
					for (var i:uint = 0; i < object.length; i++) 
					{
						//activa el modo button del mouse a el elemento y los hijos de este
						//de esta forma se evita que si tiene textos no haga efecto modo boton
						object[i].buttonMode = enabled;
						object[i].mouseChildren = !enabled;
					}
				}
				else 
				{
					object.buttonMode = enabled;
					object.mouseChildren = !enabled;
				}
				//el clicActive es utilizado para realizar una animacion al presionar el boton
				if(clicActive) 
				{
					if(enabled)
					{
						Events.listener(object,MouseEvent.CLICK, Button.clickACtive,false,false);
					}
					else
					{
						Events.removeListener(object,MouseEvent.CLICK, Button.clickACtive, false);
					}
				}
			}
			catch(error:Error)
			{
				Debug.print("El elemento object no es un elemento permitido o es un simbolo de tipo boton","Button.button","Falla CodeCraft ");
			}
		}
		
		/**
		 * Realiza una animación de over a un MovieClip o array con MovieClips, el parametro initialFrame
		 * si se deja null se realizara una animación de scale al elemento, si se agrega un numero se tomara como el
		 * fotograma inicial y se ejecutara una animacion de tipo linea de tiempo, el finalFrame si se deja null
		 * la animación se realiza reproduciendo la linea de tiempo indefinidamente si se retira el mouse del objeto
		 * este se detiene donde este en la linea de tiempo, si se indica el returnOver como true, entonces al retirar
		 * el mouse del objeto se detiene en el initialFrame. 
		 * El parametro finalFrame si se llega a agregar un numero la animación sera un cambio de fotograma del 
		 * initialFrame al finalFrame como un estado de un boton.
		 * 
		 * Si se agrega un array en initialFrame se ejecutara una animacion de linea de tiempo con etiquetas
		 * el array debe tener tres campos que son string correspondientes a las etiquetas del elemento
		 * la primera etiqueta hace referencia al fotograma inicial, la segunda al punto en el que se va a detener
		 * y la ultima a la etiqueta final de la animación, en este tipo de over se activa automaticamente el modo boton.
		 * 
		 * @param object MovieClip o array con MovieClips para aplicar la animación
		 * @param initialFrame
		 * @param finalFrame
		 * @param returnOver Indica si se desea que al finalizar la animacion infinita del elemento,se retorne al fotograma inicial del elemento	
		 */
		public static function over(object:*, initialFrame:* = null, finalFrame:* = null, returnOver:Boolean = false):void 
		{
			try 
			{
				var positionArray:*;
				var arrayTemp:Array = new Array (object, initialFrame, finalFrame, returnOver);
				if (object is Array) 
				{
					//se recorre el array como todo por los tres nivles de array que lo conforman
					positionArray = Arrays.indexOf (_arrayAnimacion,object[0], 'todo');
				}
				else
				{
					positionArray = Arrays.indexOf (_arrayAnimacion,object, 'todo');
				}
				//se verifica si el elemento existe, de no existir sera igual a -1 en ese caso carga todo
				if(positionArray == -1)
				{
					Events.listener (object, MouseEvent.MOUSE_OVER, animationOver,false);
					Events.listener (object, MouseEvent.MOUSE_OUT, animationOut,false);
				}
				_arrayAnimacion.push (arrayTemp);
				if (initialFrame != null) 
				{
					//se verifica si un array y se le asigna el valor 1
					if(initialFrame is Array)
					{
						initialFrame = 1;
						//si es un array se activa el modo boton ya que es una animacion de linea de tiempo por etiqueta
						button(object,true,false);
					}
					CodeCraft.stopFrame(object, initialFrame);
				}
			}
			catch(error:Error)
			{
				Debug.print("El elemento object no es un elemento permitido o es un simbolo de tipo boton","Button.over","Error CodeCraft ");
			}
		}
		
		/**
		 * Elimina el over de un MovieClip o array con MovieClips
		 * 
		 * @param object MovieClip o arrays con MovieClips a eliminar el over
		 * @param initialFrame
		 */
		public static function removeOver (object:*, initialFrame:* = null):void 
		{
			var positionArray:*;
			var uniqueObject:Boolean = true;
			if (object is Array) 
			{
				positionArray = Arrays.indexOf (_arrayAnimacion,object[0], 'todo');
			}
			else 
			{
				positionArray = Arrays.indexOf (_arrayAnimacion,object, 'todo');
			}
			if(positionArray is Array)
			{
				uniqueObject = false;
				var valueTemp:int = -1;
				for (var i:int = 0; i < positionArray.length; i++)
				{
					if(_arrayAnimacion[positionArray[i]][1] == initialFrame)
					{
						valueTemp = i;
					}
				}
				positionArray = positionArray[valueTemp];
			}
			try 
			{
				if(positionArray != -1) 
				{
					if(_arrayAnimacion[positionArray][1] == null) 
					{
						CodeCraft.property(object,{scaleX: 1, scaleY: 1});
					}
					//si es el ultimo elemento que aparece en el array entonces se elimina el listener
					if(uniqueObject)
					{
						Events.removeListener (object, MouseEvent.MOUSE_OVER, animationOver, false);
						Events.removeListener (object, MouseEvent.MOUSE_OUT, animationOut, false);
					}
					_arrayAnimacion.splice (positionArray, 1);
				}
			}
			catch (error:Error)
			{
				Debug.print('El elemento de la función over no se enceuntra, no se pudo eliminar el over','Button.removeOver','Error CodeCraft ');
			}
		}
		
		/**
		 * Realiza la animación que tiene el efecto del presionado, esto se ejecuta cuando al button se le 
		 * pasa el parametro clicActive true
		 * 
		 * @param clicActive
		 */
		private static function clickACtive (event:MouseEvent):void
		{
			//ejecuta 2 animaciones una que escala asiendo menor y otro que lo devuelve al estado original
			var animationTween:TimelineMax = new TimelineMax();
			animationTween.append(TweenMax.to(event.currentTarget,0.1,{scaleX:0.8,scaleY:0.8}));
			animationTween.append(TweenMax.to(event.currentTarget,0.1,{scaleX:1,scaleY:1}));
			animationTween.play();
		}
		
		/**
		 * Realiza la animacion over del elemento
		 * 
		 * @param event
		 */
		private static function animationOver (event:MouseEvent):void 
		{
			var positionArray:* = Arrays.indexOf (_arrayAnimacion, event.currentTarget, 'todo');
			//si es un numero entoncese se convierte en un array para que pueda ejecutar el codigo
			if (positionArray is int)
			{
				positionArray = [positionArray];
			}		
			for (var i:int = 0; i < positionArray.length; i++)
			{
				var numberTemp:int = positionArray[i];
				//indica que se selecciono una animacion over, que consta de un scale del elemento
				if (_arrayAnimacion[numberTemp][1] == null) 
				{
					TweenMax.to(event.currentTarget,0.5,{scaleX:1.1,scaleY:1.1,ease:Cubic.easeOut});
				}
				else
				{
					//se verifica si el elemento 1 del array, es otro array indicado que la animacion
					//que se va a realizar es una animacion controlada por etiquetas de la linea de tiempo
					if(_arrayAnimacion[numberTemp][1] is Array)
					{
						var positionObjectCurrentOver:int = Arrays.indexOf(_objectCurrentOver,event.currentTarget,'multi');
						//se verifica si el elemento ya existe para no cargarlo hasta que la animacion termine
						if(positionObjectCurrentOver == -1)
						{
							_objectCurrentOver.push([event.currentTarget,_arrayAnimacion[numberTemp][1],false]);
							event.currentTarget.gotoAndPlay(_arrayAnimacion[numberTemp][1][0]);
							event.currentTarget.addEventListener(Event.ENTER_FRAME, verifyAnimationFrame);
						}
						else
						{
							//como se indico que ya existe entonces se reinicia la variable que indica que esta sobre el
							_objectCurrentOver[positionObjectCurrentOver][2] = false;
						}
					}
					else 
					{
						//se verifica si el elemento 2 del arreglo que hace referencia el fotograma final
						//es diferente de 0 y null, de serlo entonces se detiene el elemento en ese fotograma
						//de lo contrario se realiza una animacion sin fin
						if (_arrayAnimacion[numberTemp][2] != null && _arrayAnimacion[numberTemp][2] != 0) 
						{
							event.currentTarget.gotoAndStop (_arrayAnimacion[numberTemp][2]);
						}
						else 
						{
							event.currentTarget.gotoAndPlay (_arrayAnimacion[numberTemp][1]);
						}
					}
				}
			}
		}
		
		/**
		 * 
		 * @param event
		 */
		private static function animationOut(event:MouseEvent):void 
		{
			var positionArray:* = Arrays.indexOf (_arrayAnimacion, event.currentTarget, 'todo');
			//si es un numero entoncese se convierte en un array para que pueda ejecutar el codigo
			if (positionArray is Number)
			{
				positionArray = [positionArray];
			}
			for (var i:int = 0; i < positionArray.length; i++)
			{
				var numberTemp:int = positionArray[i];
				//se indica que la animacion es un scale, entonces se reinicia volviendolo a 1
				if (_arrayAnimacion[numberTemp][1] == null)
				{
					TweenMax.to(event.currentTarget,0.2,{scaleX:1,scaleY:1});
				}
				
				else
				{
					//se verifica si el elemento 2 del array es diferente de null y 0 indicando que si se cambio
					//de fotograma, por lo que entonces se retorna el objeto a la posicion inicial que es el
					//elemento 1 del array
					if (_arrayAnimacion[numberTemp][2] != null && _arrayAnimacion[numberTemp][2] != 0) 
					{
						event.currentTarget.gotoAndStop (_arrayAnimacion[numberTemp][1]);
					}
					else
					{
						if(_arrayAnimacion[numberTemp][1] is Array)
						{
							var positionObjectCurrentOver:int = Arrays.indexOf(_objectCurrentOver,event.currentTarget,'multi');
							//se verifica si el elemento existe para ser eliminado
							if(positionObjectCurrentOver != -1)
							{
								_objectCurrentOver[positionObjectCurrentOver][2] = true;
								event.currentTarget.play();
							}
						}
						else
						{
							if(_arrayAnimacion[numberTemp][2] == 0)
							{
								event.currentTarget.play();
								event.currentTarget.addEventListener (Event.ENTER_FRAME, verifyStopElemento);
							}
							else 
							{
								event.currentTarget.stop ();
								if (_arrayAnimacion[numberTemp][3]) 
								{
									event.currentTarget.gotoAndStop (_arrayAnimacion[numberTemp][1]);
								}
							}
						}
					}
				}	
			}
		}
		
		/**
		 * 
		 * @param event
		 */
		private static function verifyStopElemento(event:Event):void
		{
			if(event.currentTarget.currentFrame == 1) 
			{
				event.currentTarget.removeEventListener (Event.ENTER_FRAME, verifyStopElemento);
				event.currentTarget.gotoAndStop(1);
			}
		}
		
		
		/**
		 * Se encarga de verificar las animaciones de tipo linea de tiempo con etiquetas
		 * @param event
		 */
		private static function verifyAnimationFrame (event:Event):void 
		{
			var position:int = Arrays.indexOf(_objectCurrentOver,event.currentTarget,'multi');
			//se verifica si el objeto se encuentra en el fotograma con la etiqueta del medio
			if(event.currentTarget.currentLabel == _objectCurrentOver[position][1][1])
			{
				//se verifica si aun se encuentra sobre el elemento o si ya salio de el
				//de haber salido del elemento entonces se continua con la animacion hasta que
				//esta finalize y se elimna el elemento del array _objectCurrentOver
				if(_objectCurrentOver[position][2] == false)
				{
					event.currentTarget.stop();
				}
			}
			else
			{
				//se verifica si ya llego al final para eliminar el elemento del array
				if(event.currentTarget.currentLabel == _objectCurrentOver[position][1][2])
				{
					//se detiene en el fotograma con la primera etiqueta
					event.currentTarget.gotoAndStop(_objectCurrentOver[position][1][0]);
					//se elimina listener y se elemina el elemento del array
					event.currentTarget.removeEventListener (Event.ENTER_FRAME, verifyAnimationFrame);
					_objectCurrentOver.splice(position,1);
				}
			}
		}
		
		
	}
}