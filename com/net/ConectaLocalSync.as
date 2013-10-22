package com.net{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class ConectaLocalSync extends MovieClip{
		private var conn:SQLConnection;
		private var stmt:SQLStatement;
		private var dbFile:File;
		public var direDB:String;
		
		public function ConectaLocalSync(rdireDB:String) {
			direDB = rdireDB;
			init();
		}
		private function iniciaConecciones():void {
			conn = new SQLConnection();
			dbFile = File.applicationDirectory.resolvePath(direDB);//File.applicationStorageDirectory.resolvePath("DBSample.db");//desktopDirectory
			//trace("conectando a: "+dbFile.nativePath);
		}
		
		public function query(sql:String):*{
			//conn.begin();
			stmt = new SQLStatement();
			stmt.sqlConnection = conn;
			stmt.text = sql;
			stmt.execute();
			var wel:*;
			if(sql.substr(0,7)=="SELECT "){
				wel = stmt.getResult().data;
			}else{
				wel = stmt.getResult().rowsAffected;
			}
			trace("SQL SYNC ejecutado = "+sql);
			return wel;
		}
		
		public function close():void{
			conn.close();
		}
		public function open():void{
			conn.open(dbFile);
		}
		
		private function init():void {
			iniciaConecciones();
		}
	}
}