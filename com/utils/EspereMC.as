package com.utils{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.geom.Point;
	
	public class EspereMC extends MovieClip{
		private var este:MovieClip;
		
		public function EspereMC(){
			inicia();
		}
		
		public function espere(mensaje:String):void{
			este.conte.msg_txt.text = mensaje;
			este.visible=true;
			var pos:Point = this.parent.globalToLocal(new Point(stage.stageWidth*.5,stage.stageHeight*.5));
			this.x = pos.x;
			this.y = pos.y;
			alineaFondo();
			if(parent!=null)if(parent.addChild!=null)parent.addChild(this);
		}
		
		public function finEspere():void{
			este.visible=false;
		}
		
		private function alineaFondo():void{
			var pos:Point = this.parent.globalToLocal(new Point(-this.x,-this.y));
			sob.x = pos.x;
			sob.y = pos.y;
			sob.width = stage.stageWidth;
			sob.height = stage.stageHeight;
		}
		
		private function inicia():void{
			este = this;
			este.sob.y = este.sob.x = 0;
			este.visible=false;
		}
		
	}
}