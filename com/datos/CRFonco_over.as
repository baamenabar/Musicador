package com.datos {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import com.datos.CRFonco_up;
	
	public class CRFonco_over extends CRFonco_up{
		
		public function CRFonco_over(){
			addEventListener(Event.ADDED_TO_STAGE,leeme);
		}
		
		private function leeme(eve:Event):void{
			//trace("data: "+this.parent["data"]["elcolor"]);
			var ecol:ColorTransform = new ColorTransform();
			ecol.color = Number(this.parent["data"]["elcolor"]);
			fon_mc.transform.colorTransform = ecol;
			fon_mc.alpha = .7;
			//trace(this.parent.parent);
		}
	}
}