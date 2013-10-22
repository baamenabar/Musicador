package com.datos {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class CRFonco_up extends MovieClip{
		
		public function CRFonco_up(){
			addEventListener(Event.ADDED_TO_STAGE,leeme);
		}
		
		private function leeme(eve:Event):void{
			//trace("data: "+this.parent["data"]["elcolor"]);
			var ecol:ColorTransform = new ColorTransform();
			ecol.color = Number(this.parent["data"]["elcolor"]);
			fon_mc.transform.colorTransform = ecol;
			//trace(this.parent.parent);
		}
	}
}