package com.tests{
	import flash.display.MovieClip;
	import flash.events.Event;
	import fl.controls.DataGrid;
	
	import com.cosas.DragDrop;
	
	public class TestDragDrop extends MovieClip{
		public var drad:DragDrop;
		
		public function TestDragDrop(){
			drad = new DragDrop(tdg);
			drad.addEventListener(Event.ADDED,enAgregado);
		}
		
		private function enAgregado(eve:Event):void{
			trace("agregado");
		}
	}
}