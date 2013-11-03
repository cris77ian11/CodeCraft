package codeCraft.utils
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import codeCraft.core.CodeCraft;
	import codeCraft.debug.Debug;
	import codeCraft.events.Events;
	import codeCraft.text.Texts;
	
	public class Magnet
	{
		
		/* Almacena los elementos en un multiarray, los elementos se ubican por arrays por frace para acomodar */
		private static var _elementosIman:Array = null;
		/* Representa el boton que permite relizar la comprobacion del orden de las palabras en el iman */
		private static var _botonComparacionIman:MovieClip;
		/* Almacena un multiarrray con las posiciones de cada palabra de las fraces */
		private static var _posicionIman:Array;
		/* Realiza referenia al elemento que se esta moviendo */
		private static var _elementoImanMoviendo:*;
		/* Almacena el elemento que se colisiono para no volver a colisionar de nuevo */
		private static var _elementoImanColisionado:* = null;
		/* Almacena los textos que van a contener los imanes */ 
		private static var _textosIman:Array;
		/* Se utilizara para indicar si se desea que se verifique el estado de las preguntas al momento que se mueva una pieza */
		private static var _verificarInstante:Boolean = false;
		/* Almacena un array con dos funciones, una a retornar cuando cargue el uman y otra a retornar cuando se elimine el iman */
		private static var _funcionesRetornar:Array;
		
		public static function load(elementosIman:Array,posicionIman:Array,textosIman:Array,botonComparacion:MovieClip = null,verificarInstante:Boolean = false, retornarFuncion:Array = null):void
		{
			_elementosIman = elementosIman;
			_posicionIman = posicionIman;
			_textosIman = textosIman;
			if(botonComparacion == null)
			{
				botonComparacion = new MovieClip();
			}
			_botonComparacionIman = botonComparacion;
			_verificarInstante = verificarInstante;
			_funcionesRetornar = retornarFuncion;
			
			cargarElementos();
			listenerIman();
		}
		
		public static function remove ():void 
		{
			if(_elementosIman != null)
			{
				eliminarListenerIman();
				eliminarElementos();
			}
		}
		
		private static function cargarElementos():void 
		{	
			CodeCraft.property(_botonComparacionIman,{alpha: 1});
			CodeCraft.stopFrame(_elementosIman,"normal");
			Texts.load(_elementosIman,_textosIman);
			_elementosIman = Arrays.random(_elementosIman);
			for (var i:int = 0; i < _elementosIman.length; i++)
			{
				CodeCraft.addChild(_elementosIman[i],null,_posicionIman[i][0],_posicionIman[i][1],"x");
				var distancia:Number = 0;
				for(var j:int = 0; j < _elementosIman[i].length; j++)
				{
					distancia += _elementosIman[i][j].width; 
				}
				Drags.load(_elementosIman[i],false,true,new Rectangle(_posicionIman[i][0],_posicionIman[i][1],distancia,0));
				TweenMax.allFrom(_elementosIman[i],1,{alpha: 0, scaleX: 0, scaleY: 0, ease:Back.easeOut});
			}
		}
		
		private static function eliminarElementos():void 
		{
			for (var i:int = 0; i < _elementosIman.length; i++)
			{
				TweenMax.allTo(_elementosIman[i],0.5,{alpha: 0, scaleX: 0, scaleY: 0, ease:Back.easeIn, onComplete: CodeCraft.removeChild, onCompleteParams: [_elementosIman[i]]});
				Drags.remove(_elementosIman[i]);
			}
			_elementosIman = null;
			_elementoImanMoviendo = null;
			_elementoImanColisionado = null;
			_posicionIman = null;
			_textosIman = null;
			_botonComparacionIman = null;
			_verificarInstante = false;
		}
		
		private static function listenerIman ():void 
		{
			capturarPosicionElementosIman();
			Events.listener(_elementosIman,MouseEvent.MOUSE_DOWN, detectarMovimientoElementoIman,false,false);
			Events.listener(_botonComparacionIman,MouseEvent.CLICK, comprobarIman,true,true);
		}
		
		private static function eliminarListenerIman ():void 
		{
			Events.removeListener(_elementosIman,MouseEvent.MOUSE_DOWN, detectarMovimientoElementoIman,false);
			Events.removeListener(_botonComparacionIman,MouseEvent.CLICK, comprobarIman,true);
		}
		
		private static function capturarPosicionElementosIman ():void 
		{
			_posicionIman = new Array();
			for(var i:int = 0; i < _elementosIman.length; i++)
			{
				_posicionIman.push(new Array());
				for (var j:int = 0; j < _elementosIman[i].length; j++)
				{
					_posicionIman[i][j] = new Array(_elementosIman[i][j].x, _elementosIman[i][j].y);
				}
			}
		}
		
		private static function posicionarElementosIman ():void 
		{
			for(var i:int = 0; i < _elementosIman.length; i++)
			{
				_posicionIman.push(new Array());
				for (var j:int = 0; j < _elementosIman[i].length; j++)
				{
					_posicionIman[i][j] = new Array(_elementosIman[i][j].x, _elementosIman[i][j].y);
				}
			}
		}
		
		private static function moverIman (event:MouseEvent):void 
		{
			//almacena la posicion del iman en array principal
			var posicion:int = Arrays.indexOf(_elementosIman, _elementoImanMoviendo,"all");
			//almaena la posicion del boton dentro del array del elemento del iman
			var posicionBoton:int = Arrays.indexOf(_elementosIman[posicion], _elementoImanMoviendo);
			for (var i:int = 0; i < _elementosIman[posicion].length; i++)
			{
				if((_elementosIman[posicion][i].x >= _elementosIman[posicion][posicionBoton].x - 10 
					&& _elementosIman[posicion][i].x <= _elementosIman[posicion][posicionBoton].x + 10)
					&& _elementosIman[posicion][i] != _elementosIman[posicion][posicionBoton])
				{
					//se invierte la posicion del elemento que se colision ubicandolo en otra posicion
					_elementosIman[posicion][i].x = _posicionIman[posicion][posicionBoton][0];
					_elementosIman[posicion][i].y = _posicionIman[posicion][posicionBoton][1];
					_elementosIman[posicion][posicionBoton] = _elementosIman[posicion][i];
					_elementosIman[posicion][i] = _elementoImanMoviendo;
					_elementoImanColisionado = _elementosIman[posicion][i];
					break;
				}
			}
		}
		
		private static function detectarMovimientoElementoIman(event:MouseEvent):void 
		{
			_elementoImanMoviendo = event.currentTarget;
			//almacena la posicion del elemento en en array principal
			var posicion:int = Arrays.indexOf(_elementosIman,event.currentTarget,"all");
			//almaena la posicion del boton dentro del array del elemento del iman
			var posicionBoton:int = Arrays.indexOf(_elementosIman[posicion], event.currentTarget);
			Events.listener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_MOVE, moverIman,false,false);
			Events.listener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, eliminarMovimientoElementoIman,false,false);
		}
		
		private static function eliminarMovimientoElementoIman (event:MouseEvent):void 
		{
			Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_UP, eliminarMovimientoElementoIman,false);
			Events.removeListener(CodeCraft.getMainObject().stage,MouseEvent.MOUSE_MOVE, moverIman,false);
			//almacena la posicion del elemento en en array principal
			var posicion:int = Arrays.indexOf(_elementosIman,_elementoImanMoviendo,"all");
			var posicionBoton:int = Arrays.indexOf(_elementosIman[posicion], _elementoImanMoviendo);
			//posiciona el elemento nuevamente
			_elementosIman[posicion][posicionBoton].x = _posicionIman[posicion][posicionBoton][0];
			_elementoImanMoviendo = null;
		}
		
		private static function comprobarIman (event:MouseEvent):void 
		{
			for(var i:int = 0; i < _elementosIman.length; i++)
			{
				for (var j:int = 0; j < _elementosIman[i].length; j++)
				{
					if(_elementosIman[i][j].texto.text == _textosIman[i][j])
					{
						_elementosIman[i][j].gotoAndStop("bien");
					}
					else
					{
						_elementosIman[i][j].gotoAndStop("mal");
					}
				}
			}
		}
		
	}
}