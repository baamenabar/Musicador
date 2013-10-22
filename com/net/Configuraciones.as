package com.net{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import flash.data.SQLConnection; 
	import flash.errors.SQLError; 
	import flash.filesystem.File; 
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.data.SQLStatement;

	import com.utils.InterpretaConfig;
	import com.net.ConectaLocalSync;
	import agustin.utils.Debug;

	public class Configuraciones extends EventDispatcher {
		private var carg:URLLoader;
		private var datos:Object;
		private var confData:String;
		public var ultimaCancion:int=0;
		public var laDB:String = "";

		public function Configuraciones() {
			init();
		}
		public function setProp(name:String,value:String):void{
			datos[name]=value;
			InterpretaConfig.guardaDatos(datos);
		}
		public function getProp(name:String):String{
			if(datos[name]!=null)return datos[name];
			return '';
		}
		
		private function revisaDatos():void {
			//Debug.print_r(datos);
			if (datos.ultimaCancion) {
				ultimaCancion = datos.ultimaCancion;
			}
			if (datos.nuevo && datos.laBaseDeDatos) {
				creaEinstala();
				InterpretaConfig.guardaNoNuevo(confData);
			}
			if(datos.laBaseDeDatos)laDB = datos.laBaseDeDatos;
			/*dispatchEvent(new Event(Event.CHANGE));
			trace("evento disparado");*/
		}
		private function noEncuentra(eve:IOErrorEvent):void {
			dispatchEvent(new Event(Event.CANCEL));
		}
		private function enRecibe(rArchivo:String):void {
			//confData=carg.data;
			var applicationDirectoryPath:File = File.applicationDirectory;
			var nativePathToApplicationDirectory:String = applicationDirectoryPath.nativePath.toString();
			nativePathToApplicationDirectory+= "/"+rArchivo;
			var file:File = new File(nativePathToApplicationDirectory);
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.READ);
			confData = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			datos = InterpretaConfig.convierteAObjeto(confData);
			revisaDatos();
		}
		private function init():void {
			/*carg = new URLLoader();
			carg.addEventListener(Event.COMPLETE,enRecibe);
			carg.addEventListener(IOErrorEvent.IO_ERROR,noEncuentra);
			carg.load(new URLRequest("configs.sti"));*/
			enRecibe("configs.sti");
			//
		}
		private function creaEinstala():void {
			var conn:SQLConnection = new SQLConnection();
			var dbFile:File;
			if (datos.laBaseDeDatos.length<25) {
				dbFile = File.applicationDirectory.resolvePath(datos.laBaseDeDatos);
			} else {
				dbFile = File(datos.laBaseDeDatos);
			}
			//trace("conectando a: "+dbFile.nativePath);
			try {
				conn.open(dbFile);
				trace("the database was created successfully");
			} catch (error:SQLError) {
				trace("Error message:", error.message);
				trace("Details:", error.details);
			}
			var createStmt:SQLStatement = new SQLStatement();
			createStmt.sqlConnection = conn;
			var sql1:String =  
			    "CREATE TABLE IF NOT EXISTS temas (" +  
			    "    idt INTEGER PRIMARY KEY AUTOINCREMENT, " +  
			    "    nombre TEXT, " +
			"    elcolor INTEGER " +
			    ")";
			createStmt.text = sql1;
			try {
				createStmt.execute();
				trace("Table 1 created");
			} catch (error:SQLError) {
				trace("Error message 1:", error.message);
				trace("Details 1:", error.details);
			}

			var sql2:String =  
			    "CREATE TABLE IF NOT EXISTS canciones (" +  
			    "    idc INTEGER PRIMARY KEY AUTOINCREMENT, "+  
			    "    nombre TEXT, " +
			"    dire TEXT, " +
			"    idt INTEGER, " +
			"    coment TEXT, " +
			"    inicio INTEGER DEFAULT 0, " +
			"    fin INTEGER DEFAULT 0" +
			    ")";//nombre, dire, idt, coment
				
				//"CREATE TABLE IF NOT EXISTS canciones ( idc INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, dire TEXT, idt INTEGER, coment TEXT, inicio INTEGER DEFAULT 0, fin INTEGER DEFAULT 0)"
				

			createStmt.text = sql2;
			try {
				createStmt.execute();
				trace("Table 2 created");
			} catch (error:SQLError) {
				trace("Error message 2:", error.message);
				trace("Details 2:", error.details);
			}
			//cosyn.query(sql);
			conn.close();
		}
		
	}
}