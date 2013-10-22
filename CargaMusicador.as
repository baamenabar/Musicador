package {
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import flash.filesystem.File; 
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.data.SQLStatement;
	import flash.utils.Timer;

	import com.utils.InterpretaConfig;
	import com.net.ConectaLocalSync;
	import com.net.Configuraciones;
	import agustin.utils.Debug;
	
	public class CargaMusicador extends MovieClip{
		var datos:Array;
		var conf:Configuraciones;
		var cosyn:ConectaLocalSync;
		var confData:String;
		
		public function CargaMusicador(){
			init();
		}
		
		private function soloArchivo(dre:String):String{
			var arles:Array = dre.split("\\");
			return arles.pop();
		}
		
		private function convierteAObjeto(rst:String):Array{
			var unoa:Array = rst.split("|!|!|");
			var unos:String;
			var unoo:Object;
			var dosa:Array = new Array();
			var doss:String;
			var tresa:Array;
			var cuatroa:Array;
			var cincoa:Array;
			var doso:Object;
			var seisa:Array;
			var unof:File;
			for each(unos in unoa){
				unoo = new Object();
				unoo.elcolor = 0xFFFFFF;
				tresa = unos.split("|||");
				unoo.nombre = tresa[0].split(";;")[1];
				cuatroa = tresa[1].split("|;|;|");//dividido en las canciones
				seisa = new Array();
				for each(doss in cuatroa){
					doso = new Object();
					cincoa = doss.split(";:;:;");
					unof = new File(cincoa[0]);
					doso.dire = unof.url.substr(8);//cincoa[0];
					doso.nombre = soloArchivo(cincoa[0]);
					doso.coment = cincoa[1];
					if(doso.coment==undefined)doso.coment='';
					seisa.push(doso);
				}
				unoo.canciones = seisa;
				dosa.push(unoo);
			}
			return dosa;
		}
		
		private function iniciaDatos():void{
			conf = new Configuraciones();
			cosyn = new ConectaLocalSync(conf.laDB);
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
			datos = convierteAObjeto(confData);
			Debug.print_r(datos);
			//revisaDatos();
			var tim:Timer = new Timer(1000,1);
			tim.addEventListener(TimerEvent.TIMER,cargaenDB);
			tim.start();
		}
		
		private function cargaenDB(eve:TimerEvent):void{
			eve.currentTarget.removeEventListener(TimerEvent.TIMER,cargaenDB);
			var i:int;
			var e:int;
			var idt:int;
			var odat:Object;
			var sql:String;
			var arca:Array;
			cosyn.open();
			for(i=0; i<datos.length; i++){
				odat = datos[i];
				odat.idt = i;
				sql = "INSERT INTO 'temas' ('idt','nombre','elcolor') VALUES ('"+odat.idt+"', '"+odat.nombre+"', '"+odat.elcolor+"')";
				cosyn.query(sql);
			}
			for(i=0; i<datos.length; i++){
				arca = datos[i].canciones;
				idt = datos[i].idt;
				for(e=0; e<arca.length; e++){
					odat = arca[e];
					sql = "INSERT INTO 'canciones' ('nombre','dire', 'coment', 'idt') VALUES ('"+escape(odat.nombre)+"', '"+escape(odat.dire)+"', '"+escape(odat.coment)+"', '"+idt+"')";
					cosyn.query(sql);
				}
			}
			cosyn.close();
			trace("listo");
		}
		
		private function iniciaExcuchadores():void{
			
			enRecibe("m_adyd.txt");
		}
		
		private function init():void{
			iniciaDatos();
			iniciaExcuchadores();
		}
	}
}