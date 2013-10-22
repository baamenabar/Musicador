package com.net{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class ConectaLocal extends MovieClip{
		private var conn:SQLConnection;
		private var stmt:SQLStatement;
		private var conteo:int = 0;
		public var arrTemas:Array;
		public var direDB:String;
		public var resulta:Array;
		
		public function ConectaLocal(rdireDB:String) {
			direDB = rdireDB;
			init();
		}
		private function iniciaConecciones():void {
			conn = new SQLConnection();
			conn.addEventListener(SQLEvent.OPEN, openHandler);
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			var dbFile:File = File.applicationDirectory.resolvePath(direDB);//File.applicationStorageDirectory.resolvePath("DBSample.db");//desktopDirectory
			conn.openAsync(dbFile);
		}
		
		public function query(sql:String,rRespuesta:Function=null,rError:Function=null):void{
			stmt = new SQLStatement();
			stmt.sqlConnection = conn;
			if(rRespuesta!=null){
				stmt.addEventListener(SQLEvent.RESULT, rRespuesta);
			}else{
				stmt.addEventListener(SQLEvent.RESULT, queryResult);
			}
			if(rError!=null){
				stmt.addEventListener(SQLErrorEvent.ERROR, rError);
			}else{
				stmt.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			}
			var ojet:Object;
			var coment:String;
			stmt.text = sql;
			//trace(sql);
			stmt.execute();
		}
		
		public function get resultado():Array{
			//trace("pidiendo resultado");
			var wel:Array = new Array();
			for(var i:String in resulta){
				wel[i] = resulta[i];
				for(var e:String in wel[i]){
					wel[i][e] = unescape(wel[i][e]);
				}
			}
			return wel;
		}
		
		public function closeDB():void{
			conn.close();
		}
		
		private function queryResult(eve:SQLEvent):void{
			//trace("query exitoso");
			trace(eve);
			resulta = stmt.getResult().data;
			//trace("resulta = "+resulta);
			var tev:Event = new Event(Event.COMPLETE);
			dispatchEvent(tev);
		}
		
		protected function openHandler(event:SQLEvent):void {
			trace("the database was abierta successfully");
			var tev:Event = new Event(Event.OPEN);
			dispatchEvent(tev);
		}

		private function errorHandler(event:SQLErrorEvent):void {
			trace("Error message:", event.error.message);
			trace("Details:", event.error.details);
			var tev:Event = new Event(Event.CANCEL);
			dispatchEvent(tev);
		}
		
		private function iniciaEscuchadores():void{
			//set_btn.addEventListener(MouseEvent.CLICK,preInserta);
			//nudb_btn.addEventListener(MouseEvent.CLICK,creaDB);
		}
		
		private function init():void {
			iniciaConecciones();
			iniciaEscuchadores();
		}
	}
}