package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class ListaConnect extends MovieClip {
		private var conn:SQLConnection;
		private var createStmt:SQLStatement;
		private var conteo:int = 0;
		public var mdo:DataProvider;
		public var arrTemas:Array;
		
		public function ListaConnect() {
			init();
		}
		private function iniciaConecciones():void {
			conn = new SQLConnection();
			conn.addEventListener(SQLEvent.OPEN, openHandler);
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			var dbFile:File = File.applicationDirectory.resolvePath("DBSample.db");//File.applicationStorageDirectory.resolvePath("DBSample.db");//desktopDirectory
			conn.openAsync(dbFile);
		}
		
		function preInserta(eve:MouseEvent):void{
			createStmt = new SQLStatement();
			createStmt.sqlConnection = conn;
			createStmt.addEventListener(SQLEvent.RESULT, insertResult);
			createStmt.addEventListener(SQLErrorEvent.ERROR, createError);
			inserta();
			/*var sql:String =  
			    "CREATE TABLE IF NOT EXISTS temas (" +  
			    "    idt INTEGER PRIMARY KEY AUTOINCREMENT, " +  
			    "    nombre TEXT " +
			    ")";*/
		}
		
		private function inserta():void{
			var sql:String;
			var ojet:Object;
			var coment:String;
			sql = "INSERT INTO temas (nombre) VALUES ";
			//sql += "("+escape(ojet.label)+", "+escape(ojet.data.path)+", "+escape(coment)+", 0)";
			sql += "(\""+arrTemas[conteo]+"\")";
			createStmt.text = sql;
			trace(sql);
			createStmt.execute();
		}
		
		private function insertResult(eve:SQLEvent):void{
			trace("insertado exitoso");
			trace(eve);
			conteo++;
			if(conteo<arrTemas.length)inserta();
		}
		
		private function insertaOLD1():void{
			var sql:String;
			var ojet:Object;
			var coment:String;
			sql = "INSERT INTO canciones (nombre, dire, coment, idt) VALUES ";
			ojet = mdo.getItemAt(conteo);
			coment = "-";
			if(ojet.data.comentario.length>3)coment = ojet.data.comentario;
			//sql += "("+escape(ojet.label)+", "+escape(ojet.data.path)+", "+escape(coment)+", 0)";
			sql += "(\""+ojet.label+"\", \""+ojet.data.path+"\", \""+coment+"\", 0)";
			createStmt.text = sql;
			trace(sql);
			createStmt.execute();
		}
		
		private function insertResultOLD1(eve:SQLEvent):void{
			trace("insertado exitoso");
			trace(eve);
			conteo++;
			if(conteo<mdo.length)inserta();
		}
		
		function openHandler(event:SQLEvent):void {
			trace("the database was abierta successfully");
		}
		
		function creaDB(eve:MouseEvent):void{
			createStmt = new SQLStatement();
			createStmt.sqlConnection = conn;
			var sql:String =  
			    "CREATE TABLE IF NOT EXISTS temas (" +  
			    "    idt INTEGER PRIMARY KEY AUTOINCREMENT, " +  
			    "    nombre TEXT " +
			    ")";
			createStmt.text = sql;
			createStmt.addEventListener(SQLEvent.RESULT, createResult);
			createStmt.addEventListener(SQLErrorEvent.ERROR, createError);
			createStmt.execute();
		}
		
		function createResult(event:SQLEvent):void {
			trace("datos insertados");
			var sql:String =  
			    "CREATE TABLE IF NOT EXISTS canciones (" +  
			    "    idc INTEGER PRIMARY KEY AUTOINCREMENT, " +  
			    "    nombre TEXT, " +
				"    dire TEXT, " +
				"    coment TEXT, " +
				"    idt INTEGER " +
			    ")";
			createStmt.text = sql;
			createStmt.removeEventListener(SQLEvent.RESULT, createResult);
			createStmt.addEventListener(SQLEvent.RESULT, createResult2);
			createStmt.execute();
		}
		
		function createResult2(event:SQLEvent):void {
			trace("Tabla creada");
		}
		
		function createError(event:SQLErrorEvent):void {
			trace("Error message:", event.error.message);
			trace("Details:", event.error.details);
		}

		function errorHandler(event:SQLErrorEvent):void {
			trace("Error message:", event.error.message);
			trace("Details:", event.error.details);
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