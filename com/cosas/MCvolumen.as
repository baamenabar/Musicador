package com.cosas{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import com.cosas.MCbtnTipo2;
	
	public class MCvolumen extends MovieClip{
		public var soc:SoundChannel;
		
		public function MCvolumen(){
			init();
		}
		
		public function activa(rsc:SoundChannel,curVol:Number=1):void{
			trace("volumen activado");
			soc=rsc;
			volf_btn.addEventListener(MouseEvent.MOUSE_DOWN,enPress);
			if(curVol==1){
				volf_btn.x = volt_mc.x+volt_mc.width-volf_btn.width;
			}
		}
		
		private function enAgregadoAlStage(eve:Event):void{
			
		}
		
		private function enPress(eve:Event):void{
			var rx:Number = volt_mc.x + 1;
			var ry:Number = volf_btn.y;
			var rw:Number = volt_mc.width - volf_btn.width - 1;
			var rh:Number = 0;
			var rect:Rectangle = new Rectangle(rx, ry, rw, rh);
			
			// Drag
			//dragging = true;
			volf_btn.startDrag(false,rect);
			stage.addEventListener(MouseEvent.MOUSE_UP,dragReleaseHandler);
			this.addEventListener(Event.ENTER_FRAME,enArrastrando);
		}
		
		protected function enArrastrando(eve:Event):void{
			var curvo:SoundTransform = soc.soundTransform;
			curvo.volume = ((volf_btn.x-volt_mc.x)/(volt_mc.width-volf_btn.width));
			soc.soundTransform = curvo;
		}
		
		protected function dragReleaseHandler(event:MouseEvent):void
		{
			this.removeEventListener(Event.ENTER_FRAME,enArrastrando);
			stage.removeEventListener(MouseEvent.MOUSE_UP,dragReleaseHandler);
			volf_btn.stopDrag();
/*			if( dragging )
			{
				// Stop drag
				
				if(playing){
					// Seek
					
					stopSound();
					playSound(mp3Position);
				}else{
					volf_btn.x = volt_mc.x + 1;
				}
				dragging = false;
			}
*/		}
		
		private function iniciaEscuchadores():void{
			this.addEventListener(Event.ADDED_TO_STAGE,enAgregadoAlStage);
		}
		
		private function init():void{
			iniciaEscuchadores();
		}
	}
}