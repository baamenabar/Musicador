package com.utils{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import agustin.utils.Debug;
	
	public class Importador extends EventDispatcher{
		public var total:int = 0;
		public var curind:int = 0;
		private var lista:Array;
		private var carpetaDestino:File;
		private var conteo:int = 0;
		private var orig:File;
		private var respaldoCan:Array;
		private var respaldoMoo:Array;
		
		public function Importador():void{
			init();
		}
		
		public function nuevaDB():void{
			var arcanc:Array = new Array();
			var testri:String;
			for(var i:int=0; i<respaldoCan.length; i++){
				testri = "";
				for each(var valo:* in respaldoCan[i]){
					testri += String(escape(valo))+";;";
				}
				arcanc.push(testri.substring(0,testri.length-2));
			}
			var filcan:File = new File(carpetaDestino.nativePath+"/canciones.sti");
			var filmoo:File = new File(carpetaDestino.nativePath+"/moods.sti");
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(filcan, FileMode.WRITE);
			fileStream.writeUTFBytes(arcanc.join(unescape("%0A")));//%0A = salto de línea Linux
			fileStream.close();
			
			arcanc = new Array();
			for(i=0; i<respaldoMoo.length; i++){
				testri = "";
				for each(valo in respaldoMoo[i]){
					testri += String(escape(valo))+";;";
				}
				arcanc.push(testri.substring(0,testri.length-2));
			}
			fileStream = new FileStream(); 
			fileStream.open(filmoo, FileMode.WRITE);
			fileStream.writeUTFBytes(arcanc.join(unescape("%0A")));
			fileStream.close();
		}
		
		private function soloArchivo(dre:String):String{
			var arles:Array = dre.split("/");
			return arles.pop();
		}
		
		private function fileCopyCompleteHandler(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
			eve.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler);
			//trace("archivo "+conteo+" copiado");
			conteo++;
			curind = conteo;
			if(conteo==lista.length){
				dispatchEvent(new Event(Event.COMPLETE));
			}else{
				dispatchEvent(new Event(Event.CHANGE));
				copiaArchivo(lista[conteo]);
			}
		}
		
		private function fileCopyIOErrorEventHandler(eve:IOErrorEvent):void{
			eve.currentTarget.removeEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
			eve.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler);
			trace("IO error");
			conteo++;
			curind = conteo;
			if(conteo==lista.length){
				dispatchEvent(new Event(Event.COMPLETE));
			}else{
				dispatchEvent(new Event(Event.CHANGE));
				copiaArchivo(lista[conteo]);
			}
		}
		
		private function copiaArchivo(cual:Object):void{
			var dir:File = new File(carpetaDestino.nativePath+"/"+cual.estilo); 
			Debug.print_r(cual);
			trace("------------------\n");
			sumaMoo(cual);
			respaldoCan.push({idc:cual.idc, idt:cual.idt, nombre:cual.nombre, dire:cual.estilo+"/"+soloArchivo(cual.dire), coment:cual.coment});
			dir.createDirectory(); 
			orig = new File(cual.dire);
			var destin:File = new File(dir.nativePath+"/"+soloArchivo(cual.dire));
			orig.addEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
			orig.addEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler); 
			orig.copyToAsync(destin,true);
		}
		
		private function sumaMoo(odat:Object):void{
			var took:Boolean=true;
			for(var i:int=0; i<respaldoMoo.length; i++){
				if(respaldoMoo[i].idt == odat.idt){
					took = false;
					break;
				}
			}
			if(took)respaldoMoo.push({idt:odat.idt, nombre:odat.estilo, elcolor:odat.elcolor});
		}
		
		private function enCarpetaSeleccionada(eve:Event):void{
			//trace(carpetaDestino.nativePath);
			respaldoCan = new Array();
			respaldoMoo = new Array();
			copiaArchivo(lista[conteo]);
		}
		
		private function enCancela(eve:Event):void{
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		private function pideCarpeta():void{
			carpetaDestino.browseForDirectory("Destination Folder");
		}
		
		private function iniciaEscuchadores():void{
			carpetaDestino.addEventListener(Event.SELECT,enCarpetaSeleccionada);
			carpetaDestino.addEventListener(Event.CANCEL,enCancela);
		}
		
		
		private function iniciaDatos():void{
			carpetaDestino = new File();
			total = lista.length;
			respaldoCan = new Array();
			respaldoMoo = new Array();
		}
		
		private function init():void{
			iniciaDatos();
			iniciaEscuchadores();
			pideCarpeta();
		}
	}
}