package com.cosas{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
	
	public class MCbtnTipo2 extends MovieClip{
		public var colorBase:uint = 0x234080;
		public var colorOver:uint = 0x1A50D9;
		public var colorPress:uint = 0x1061E3;
		protected var ecol:ColorTransform;
		
		public function MCbtnTipo2(){
			init();
		}
		
		private function pintame(ncol:uint):void{
			ecol.color = ncol;
			bc_mc.transform.colorTransform = ecol;
		}
		
		private function enSobre(eve:MouseEvent):void{
			pintame(colorOver);
		}
		private function enFuera(eve:MouseEvent):void{
			pintame(colorBase);
		}
		private function enAprieta(eve:MouseEvent):void{
			pintame(colorPress);
		}
		private function enSuelta(eve:MouseEvent):void{
			pintame(colorOver);
		}
		
		private function iniciaEscuchadores():void{
			addEventListener(MouseEvent.MOUSE_OVER,enSobre);
			addEventListener(MouseEvent.MOUSE_OUT,enFuera);
			addEventListener(MouseEvent.MOUSE_DOWN,enAprieta);
			addEventListener(MouseEvent.MOUSE_UP,enSuelta);
			this.mouseEnabled=true;
			this.mouseChildren = false;
		}
		
		private function init():void{
			ecol = new ColorTransform();
			iniciaEscuchadores();
		}
	}
}