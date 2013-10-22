package com.utils{
	import flash.events.EventDispatcher;
	import flash.events.NativeDragEvent;
	import flash.events.Event;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragActions;
	import flash.filesystem.File;
	
	import fl.controls.DataGrid;
	import agustin.utils.Debug;
	
	public class DragDrop extends EventDispatcher{
		public var eldg:DataGrid;
		
		public function DragDrop(objetivo:DataGrid){
			eldg = objetivo;
			init();
		}
		
		public function onDragIn(event:NativeDragEvent):void{ 
		    NativeDragManager.dropAction = NativeDragActions.MOVE; 
		    if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){ 
		        NativeDragManager.acceptDragDrop(eldg); //'this' is the receiving component 
		    } 
		}
		
		public function onDrop(event:NativeDragEvent):void { 
		    if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) { 
			    var arli:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_ONLY) as Array; 
				var archi:File;
				var unosi:Boolean = false;
				for(var i:int=0; i<arli.length; i++){
					archi = arli[i];
					if(archi.type.toLowerCase()==".mp3"){
						eldg.addItem({nombre:archi.name, dire:archi.nativePath.split('\\').join('/'), nuevo:true});//unescape(archi.url).substr(8)
						unosi = true;
					}
				}
				if(unosi){
					eldg.validateNow();
					dispatchEvent(new Event(Event.ADDED));
				}
			}
		}
		private function iniciaEscuchadores():void{
			eldg.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,onDragIn);
			eldg.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);
		}
		
		private function init():void{
			iniciaEscuchadores();
		}
	}
}