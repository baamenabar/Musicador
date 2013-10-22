package com.cosas{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
	
	public class MCbtnTipo1 extends MovieClip{
		public var colorBase:uint = 0x00ABEC;
		public var colorPrendido:uint = 0x00FFC9;
		public var colorActivo:uint = colorBase;
		public var colorOver:uint = 0x56CCFE;
		public var colorPress:uint = 0x57FBFF;
		protected var ecol:ColorTransform;
		protected var graph:DisplayObject;
		
		public function MCbtnTipo1(rIco:DisplayObject=null){
			graph = rIco;
			init();
		}
		
		public function set icon(rod:DisplayObject):void{
			pegaIcono(rod);
		}
		public function get icon():DisplayObject{
			return graph;
		}
		
		public function activo(prende:Boolean=true):void{
			prende ? colorActivo = colorPrendido : colorActivo = colorBase;
			pintame(colorActivo);
		}
		
		private function pintame(ncol:uint):void{
			ecol.color = ncol;
			bc_mc.transform.colorTransform = ecol;
		}
		
		private function pegaIcono(gr:DisplayObject):void{
			gr.x = -gr.width*.5;
			gr.y = -gr.height*.5;
			this.addChildAt(gr,getChildIndex(ph_mc));
			this.removeChild(ph_mc);
			iniciaEscuchadores();
		}
		
		private function enSobre(eve:MouseEvent):void{
			pintame(colorOver);
		}
		private function enFuera(eve:MouseEvent):void{
			pintame(colorActivo);
		}
		private function enAprieta(eve:MouseEvent):void{
			pintame(colorPress);
		}
		private function enSuelta(eve:MouseEvent):void{
			pintame(colorOver);
		}
		
		private function iniciaDiagramacion():void{
			if(graph!=null)pegaIcono(graph);
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
			iniciaDiagramacion();
			//iniciaEscuchadores();
		}
	}
}