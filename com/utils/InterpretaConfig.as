package com.utils{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import gs.StringUtils;
	public class InterpretaConfig{
		
		public function InterpretaConfig(){
			
		}
		
		public static function convierteAObjeto(reci:String):Object{
			var oret:Object = new Object();
			//trace("reci ="+escape(reci));
			var prc:Array = escape(reci).split("%0A");
			var apa:Array;
			for(var i:int=0; i<prc.length; i++){
				if(prc[i].substr(0,2)!= "//"){
					apa = unescape(prc[i]).split(":");
					oret[StringUtils.trim(apa[0])] = StringUtils.trim(apa[1]);
				}
			}
			return oret;
		}
		
		public static function guardaNoNuevo(reci:String,rArchivo:String="configs.sti"):void{
			var ars:Array = new Array();
			//trace("reci ="+escape(reci));
			var prc:Array = escape(reci).split("%0A");
			for(var i:int=0; i<prc.length; i++){
				if(prc[i].substr(0,5)!= "nuevo"){
					ars.push(prc[i]);
				}
			}
			var stg:String = unescape(ars.join("%0A"));
			var applicationDirectoryPath:File = File.applicationDirectory;
			var nativePathToApplicationDirectory:String = applicationDirectoryPath.nativePath.toString();
			nativePathToApplicationDirectory+= "/"+rArchivo;
			var file:File = new File(nativePathToApplicationDirectory);
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(stg);
			fileStream.close();
		}
		
		public static function guardaDatos(datos:Object,rArchivo:String="configs.sti"):void{
			var ars:Array = new Array();
			//trace("reci ="+escape(reci));
			for(var i:String in datos){
				ars.push(i+":"+datos[i]);
			}
			var stg:String = unescape(ars.join("%0A"));
			var applicationDirectoryPath:File = File.applicationDirectory;
			var nativePathToApplicationDirectory:String = applicationDirectoryPath.nativePath.toString();
			nativePathToApplicationDirectory+= "/"+rArchivo;
			var file:File = new File(nativePathToApplicationDirectory);
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(stg);
			fileStream.close();
			trace("guardado: "+"stg"+"\n------\nfin guardado");
		}
	}
}