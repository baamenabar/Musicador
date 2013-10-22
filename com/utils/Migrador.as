package com.utils{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import agustin.utils.Debug;
	import com.net.ConectaLocalSync;
	
	public class Migrador extends EventDispatcher{
		public var total:int = 0;
		public var curind:int = 0;
		public var datos:Object;
		public var cosync:ConectaLocalSync;
		public var tooka:Boolean;
		private var lista:Array;
		private var orden:Array;
		private var carpetaDestino:File;
		private var archivoDestino:File;
		private var paraAbrir:File;
		private var archivoPL:File;
		private var conteo:int = 0;
		private var orig:File;
		private var respaldoCan:Array;
		private var respaldoMoo:Array;
		private var pideGuardarPL:Boolean;
		private var abriendoPL:Boolean = true;
		
		public function Migrador(rlista:Array=null,rpgpl:Boolean=false):void{
			lista = rlista;
			pideGuardarPL = rpgpl;
			if(lista==null){
				if(pideGuardarPL){
					abreFolder();
				}else{
					abrePL();
				}
			}else{
				init();
			}
		}
		
		public function nuevaDB(donde:File=null):void{
			trace("usando nuevaDB");
			var arcanc:Array = new Array();
			var artei:Array;
			for(var i:int=0; i<respaldoCan.length; i++){
				//Debug.print_r(respaldoCan[i]);
				artei = new Array();
				artei[0] = respaldoCan[i].idc;
				artei[1] = respaldoCan[i].idt;
				artei[2] = escape(respaldoCan[i].nombre);
				artei[3] = escape(respaldoCan[i].dire);
				artei[4] = escape(respaldoCan[i].coment);
				artei[5] = respaldoCan[i].inicio;
				artei[6] = respaldoCan[i].fin;
				for(var e:int=0; e<artei.length; e++){
					if(!artei[e] || artei[e]=="null"){
						trace(e+" -- "+artei[e]+"-- falso");
						artei[e]="";
					}
				}
				arcanc.push(artei.join(";;"));
			}
			var armood:Array = new Array();
			//trace("juntandoMoo");
			for(i=0; i<respaldoMoo.length; i++){
				artei = new Array();
				//trace("---mooo---");
				//Debug.print_r(respaldoMoo[i]);
				artei[0] = respaldoMoo[i].idt;
				artei[1] = respaldoMoo[i].nombre;
				artei[2] = respaldoMoo[i].elcolor;
				/*var testri:String = "";
				for each(var valo:* in respaldoMoo[i]){
					testri += String(escape(valo))+";;";
				}*/
				armood.push(artei.join(";;"));//testri.substring(0,testri.length-2));
			}
			var striExp:String = arcanc.join(unescape("%0A"))+unescape("%0A-%3B%7C%3B-%0A")+armood.join(unescape("%0A"))+unescape("%0A-%3B%7C%3B-%0A")+orden.join(',');
			var filcan:File;
			if(donde==null){
				filcan = new File(carpetaDestino.nativePath+"/playlist.sti");
			}else{
				filcan = donde;
			}
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(filcan, FileMode.WRITE);
			fileStream.writeUTFBytes(striExp);//%0A = salto de línea Linux
			fileStream.close();
			if(donde!=null)dispatchEvent(new Event(Event.OPEN));
		}
		
		private function soloArchivo(dre:String):String{
			var arles:Array = dre.split("/");
			return arles.pop();
		}
		private function arreglaSlashes(dre:String):String{
			var wel:String = dre.split("\\").join("/");
			return wel;
		}
		
		private function fileCopyCompleteHandler(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
			eve.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler);
			trace("archivo "+conteo+" copiado");
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
			if(eve){
				eve.currentTarget.removeEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
				eve.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler);
			}
			trace("IO error ");
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
			//Debug.print_r(cual);
			//trace("------------------\n");
			sumaMoo(cual);
			orden.push(cual.idc);
			//trace("post sumaMoo");
			respaldoCan.push({idc:cual.idc, idt:cual.idt, nombre:cual.nombre, dire:cual.estilo+"/"+soloArchivo(arreglaSlashes(cual.dire)), coment:cual.coment});
			try{
				dir.createDirectory(); 
				trace("directorio creado");
				orig = new File(unescape(cual.dire));
				var destin:File = new File(dir.nativePath+"/"+unescape(soloArchivo(arreglaSlashes(cual.dire))));
				orig.addEventListener(Event.COMPLETE, fileCopyCompleteHandler); 
				orig.addEventListener(IOErrorEvent.IO_ERROR, fileCopyIOErrorEventHandler); 
				orig.copyToAsync(destin,true);
				trace("copiando archivo");
			}catch(err:*){
				trace("error NN: "+err);
				Debug.print_r(err);
				fileCopyIOErrorEventHandler(null);
			}
		}
		
		private function sumaMoo(odat:Object):void{
			tooka = true;
			for(var i:int=0; i<respaldoMoo.length; i++){
				//trace("esloop");
				if(respaldoMoo[i].idt == odat.idt){
					tooka = false;
					break;
				}
			}
			//trace("tooka = "+tooka);
			//Debug.print_r(odat);
			if(!tooka){
				//trace("tooka falso");
			}else{
				//trace("tratando de hacer push");
				respaldoMoo.push({idt:odat.idt, nombre:odat.estilo, elcolor:odat.elcolor});
			}
			//trace("fin sumaMoo");
		}
		
		private function enCarpetaSeleccionada(eve:Event):void{
			//trace(carpetaDestino.nativePath);
			respaldoCan = new Array();
			respaldoMoo = new Array();
			orden = new Array();
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
			orden = new Array();
			respaldoCan = new Array();
			respaldoMoo = new Array();
		}
		
		private function respaldaPL():void{
			var hoy:Date = new Date();
			var archivoPL:File = new File(archivoDestino.nativePath+"/playlist"+String(hoy.fullYear)+"-"+String(hoy.month+1)+"-"+String(hoy.date)+".mpl"); 
			var cual:Object;
			for(var i:int=0; i<lista.length; i++){
				cual = lista[i];
				Debug.print_r(cual);
				//trace("------------------\n");
				sumaMoo(cual);
				respaldoCan.push({idc:cual.idc, idt:cual.idt, nombre:cual.nombre, dire:cual.dire, coment:cual.coment, inicio:cual.inicio, fin:cual.fin});
			}
			nuevaDB(archivoPL);
		}
		
		private function enArchivoSeleccionado(eve:Event):void{
			respaldoCan = new Array();
			respaldoMoo = new Array();
			respaldaPL();
		}
		
		private function pideArchivoRespaldo():void{
			archivoDestino.browseForDirectory("Select folder to save Playlist File");
		}
		
		private function iniciaEscuchadoresRespaldo():void{
			archivoDestino.addEventListener(Event.SELECT,enArchivoSeleccionado);
			archivoDestino.addEventListener(Event.CANCEL,enCancela);
		}
		
		private function iniciaDatosRespaldo():void{
			archivoDestino = new File();
		}
		
		private function init():void{
			iniciaDatos();
			if(pideGuardarPL){
				iniciaDatosRespaldo();
				iniciaEscuchadoresRespaldo();
				pideArchivoRespaldo();
			}else{
				iniciaEscuchadores();
				pideCarpeta();
			}
		}
		
		//***********----------------------------------
		
		private function reemplazaDB():void{
			if(cosync!=null){
				cosync.open();
				trace(cosync.query("DELETE FROM 'canciones' WHERE idc > 0"));
				trace(cosync.query("DELETE FROM 'temas' WHERE idt > 0"));
				
				var omoo:Object;
				var insemoo:String = "INSERT INTO 'temas' (idt, nombre, elcolor) VALUES ";
				var tins:String;
				for(var i:int=0; i<respaldoMoo.length; i++){
					omoo = respaldoMoo[i];
					tins = insemoo+"('"+omoo.idt+"', '"+omoo.nombre+"', '"+omoo.elcolor+"')";
					trace(tins);
					trace(cosync.query(tins));
				}
				
				insemoo = 'INSERT INTO "canciones" (idc, nombre, dire, idt, coment, inicio, fin) VALUES ';
				for(i=0; i<respaldoCan.length; i++){
					omoo = respaldoCan[i];
					if(!omoo.inicio)omoo.inicio='0';
					if(!omoo.fin)omoo.fin='0';
					tins = insemoo+'("'+omoo.idc+'", "'+omoo.nombre+'", "'+omoo.dire+'", "'+omoo.idt+'", "'+omoo.coment+'", "'+omoo.inicio+'", "'+omoo.fin+'")';
					trace(tins);
					trace(cosync.query(tins));
					//arvalos.push(tins);
				}
				cosync.close();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function cargaPL():void{
			archivoPL = paraAbrir;
			datos = ManejaPL.abreEinterpretaPL(archivoPL);
			//Debug.print_r(datos);
			respaldoCan = datos.canciones;
			respaldoMoo = datos.moods;
			reemplazaDB();
		}
		private function cargaMigrado():void{
			archivoPL = new File(paraAbrir.nativePath+"/playlist.sti");
			datos = ManejaPL.abreEinterpretaCarpeta(paraAbrir.nativePath);
			Debug.print_r(datos);
			respaldoCan = datos.canciones;
			respaldoMoo = datos.moods;
			reemplazaDB();
		}
		
		private function enParaSeleccionado(eve:Event):void{
			if(abriendoPL){
				cargaPL();
			}else{
				cargaMigrado();
			}
		}
		
		private function pideArbirArchivo():void{
			paraAbrir.browseForOpen("PlaylistFile",new Array(new FileFilter("Musicador Play List File","*.mpl","mpl")));
		}
		private function pideArbirCarpeta():void{
			paraAbrir.browseForDirectory("Select migrated folder");
		}
		
		private function iniciaEscuchadoresComunes():void{
			paraAbrir.addEventListener(Event.SELECT,enParaSeleccionado);
			paraAbrir.addEventListener(Event.CANCEL,enCancela);
		}
		
		private function iniciaDatosComunes():void{
			paraAbrir = new File();
			respaldoCan = new Array();
			respaldoMoo = new Array();
		}
		
		private function abrePL():void{
			trace("pidiendo abrir playlist");//
			iniciaDatosComunes();
			iniciaEscuchadoresComunes();
			pideArbirArchivo();
		}
		
		private function abreFolder():void{
			trace("pidiendo abrir carpeta de respaldo");
			abriendoPL = false;
			iniciaDatosComunes();
			iniciaEscuchadoresComunes();
			pideArbirCarpeta();
		}
	}
}