package com.utils{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Point;
	import fl.controls.Button;
	import flash.events.MouseEvent;
	
	public class Alerta extends MovieClip{
		public var mensaje:String = "Alerta";
		public var YES:String = "OK";
		public var NO:String = "";
		public var manejaYES:Function = null;
		public var manejaNO:Function = null;
		
		public function Alerta(){
			this.visible = false;
			t_txt.autoSize = TextFieldAutoSize.CENTER;
			t_txt.text = mensaje;
			fon_mc.width = 5;
			fon_mc.height = 5;
			vfon_mc.x = 5;
			vfon_mc.y = 5;
			aplicaSoloOK();
			uno_btn.addEventListener(MouseEvent.MOUSE_UP,sueltaYES);
			dos_btn.addEventListener(MouseEvent.MOUSE_UP,sueltaNO);
		}
		
		public function alerte(mens:String=null,manejadorYES:Function=null,manejadorNO:Function=null):void{
			if(mens!=null)mensaje = mens;
			t_txt.text = mensaje;
			var pos:Point = this.parent.globalToLocal(new Point(stage.stageWidth*.5-vfon_mc.width*.5,stage.stageHeight*.5-vfon_mc.height*.5));
			this.x = pos.x;
			this.y = pos.y;
			alineaFondo();
			aplicaSoloOK();
			manejaYES = manejadorYES;
			manejaNO = manejadorNO;
			this.visible=true;
		}
		
		private function aplicaSoloOK():void{
			if(NO){//12
				uno_btn.move(vfon_mc.x+12, vfon_mc.y+vfon_mc.height-uno_btn.height-8);
				dos_btn.move(vfon_mc.x+vfon_mc.width-12-dos_btn.width, vfon_mc.y+vfon_mc.height-dos_btn.height-8);
				dos_btn.visible = true;
			}else{
				dos_btn.visible = false;
				uno_btn.move(vfon_mc.x+(vfon_mc.width/2)-(uno_btn.width/2) , vfon_mc.y+vfon_mc.height-uno_btn.height-8);
				dos_btn.move(vfon_mc.x+(vfon_mc.width/2)-(dos_btn.width/2) , vfon_mc.y+vfon_mc.height-dos_btn.height-8);
			}
			uno_btn.label = YES;
			dos_btn.label = NO;
			t_txt.x = vfon_mc.x+(vfon_mc.width/2)-(t_txt.width/2);
			t_txt.y = vfon_mc.y+15;
		}
		
		private function alineaFondo():void{
			var pos:Point = this.parent.globalToLocal(new Point(-this.x,-this.y));
			fon_mc.x = pos.x;
			fon_mc.y = pos.y;
			fon_mc.width = stage.stageWidth;
			fon_mc.height = stage.stageHeight;
		}
		
		private function sueltaYES(eve:MouseEvent):void{
			if(manejaYES!=null)manejaYES();
			this.visible=false;
		}
		
		private function sueltaNO(eve:MouseEvent):void{
			if(manejaNO!=null)manejaNO();
			this.visible=false;
		}
	}
}