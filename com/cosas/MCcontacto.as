package com.cosas{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class MCcontacto extends MovieClip{
		
		public function MCcontacto(){
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(eve:Event):void{
			trace("iniciado");
		}
	}
}