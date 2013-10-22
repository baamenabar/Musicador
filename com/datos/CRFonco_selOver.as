package com.datos {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import com.datos.CRFonco_up;
	
	public class CRFonco_selOver extends CRFonco_up{
		
		public function CRFonco_selOver(){
			addEventListener(Event.ADDED_TO_STAGE,leeme);
		}
		
		private function leeme(eve:Event):void{
			var ecol:ColorTransform = new ColorTransform();
			ecol.color = Number(this.parent["data"]["elcolor"]);
			ecol.greenMultiplier=-0.5;
			ecol.redMultiplier=-0.5;
			ecol.blueMultiplier=-0.3;
			fon_mc.transform.colorTransform = ecol;
			fon_mc.alpha=0.7;
		}
	}
}