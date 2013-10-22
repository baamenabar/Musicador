package{
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.media.ID3Info;
	import flash.filesystem.File;
	import flash.utils.Timer;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;
	import flash.system.System;
	import fl.controls.DataGrid;
	
	import agustin.utils.Debug;
	import agustin.datos.BuscaEnDataGrid;
	import com.net.ConectaLocal;
	import com.net.ConectaLocalSync;
	import com.net.Direcciones;
	import com.net.Configuraciones;
	import com.cosas.MMoods;
	import com.cosas.LicanDG;
	//import com.cosas.ListaSalto;
	import com.utils.DragDrop;
	import com.utils.Alerta;
	import com.utils.EspereMC;
	import com.utils.Migrador;
	import com.utils.DGdragDrop;
	import com.editores.MCdetalleCancion;
	import flash.display.NativeWindow;
	import flash.geom.Rectangle;
	import flash.display.NativeWindowInitOptions;
	import com.greensock.plugins.VolumePlugin;
	import com.greensock.TweenLite;
	
	public class Musicador extends MovieClip{
		public var cosyn:ConectaLocalSync;
		public var mos:MMoods;
		public var lica:LicanDG;
		public var filtro:BuscaEnDataGrid;
		public var drad:DragDrop;
		public var ale:Alerta;
		public var conf:Configuraciones;
		public var espera:EspereMC;
		public var timin:Timer;
		public var nuna:NativeWindow;
		public var uddd:DGdragDrop;
		
		public function Musicador(){
			init();
		}
		
		private function inicio():void{
			var ultimaCancion:String=conf.getProp("ultimaCancion");
			if(ultimaCancion){
				mplayer.curSong = int(ultimaCancion);
				mplayer.cambiaTocando();
			}
			var anchoSta:String=conf.getProp("width");
			if(anchoSta){
				nuna.width = Number(anchoSta);
				nuna.height = Number(conf.getProp("height"));
				enResizeStage(null);
			}
			uddd = new DGdragDrop(candg);
			var columnas:String=conf.getProp("columnas");
			if(columnas)lica.columnas=columnas.split(',');
			lica.addEventListener(Event.ID3,enResizeColumnas);
			uddd.addEventListener(Event.COMPLETE,guardaOrden);
		}
		
		private function endobleClick(eve:MouseEvent):void{
			//trace("doble Click: "+candg.selectedItem.dire);
			mplayer.loadSound(candg.selectedItem.dire,true,true,true);
		}
		
		private function enENTER(cual:Object):void{
			mplayer.loadSound(cual.dire,true,true,true);
		}
		
		private function dbAbierta(eve:TimerEvent):void{
			timin.removeEventListener(TimerEvent.TIMER,dbAbierta);
			var sql:String = "SELECT nombre AS label, idt AS data, elcolor AS elcolor FROM 'temas' ORDER BY nombre COLLATE NOCASE";//update [table_name] set [field_name] = replace([field_name],'[string_to_find]','[string_to_replace]');
			//trace("cargando temas");
			cosyn.open();
			var respu:Array = cosyn.query(sql);
			cosyn.close();
			enCargaTemas(respu);
			inicio();
		}
		
		private function enCargaTemas(respu:Array):void{
			//trace("enCargaTemas disparado");
			mos = new MMoods(tem_cb,respu,conf.laDB);
			mos.addEventListener(Event.SELECT,asignaMood);
			mos.addEventListener(Event.CHANGE,pideUpdateMood);
			
			lica = new LicanDG(candg,mos);
			lica.orden = conf.getProp('orden');
			var sql:String = "SELECT * FROM 'canciones' ORDER BY idt DESC";
			cosyn.open();
			var respu:Array = cosyn.query(sql);
			cosyn.close();
			mplayer.asignaDG(candg);
			enCargaCanciones(respu);
		}
		
		private function enCargaCanciones(respu:Array):void{
			lica.carga(respu);
			filtro = new BuscaEnDataGrid(candg,b_txt,clin_btn);
			filtro.registraColumnas(new Array("nombre","estilo","coment","dire"));
			filtro.registraDatos();
			drad = new DragDrop(candg);
			drad.addEventListener(Event.ADDED,enAgregadoPorDrag);
			confMenu();
		}
		
		private function asignaMood(eve:Event):void{
			cosyn.open();
			for each(var valor:* in candg.selectedItems){
				Debug.print_r(tem_cb.selectedItem);
				valor.idt = tem_cb.selectedItem.data.data;
				valor.estilo = tem_cb.selectedItem.label;
				valor.elcolor = tem_cb.selectedItem.data.elcolor;//estilo el color
				cosyn.query("UPDATE 'canciones' SET idt = '"+tem_cb.selectedItem.data.data+"' WHERE idc = '"+valor.idc+"'");
			}
			cosyn.close();
			candg.validateNow();
		}
		
		private function pideUpdateMood(eve:Event):void{
			//trace("pidiendo update mood");
			var sql:String = "SELECT nombre AS label, idt AS data, elcolor AS elcolor FROM 'temas' ORDER BY nombre COLLATE NOCASE";//update [table_name] set [field_name] = replace([field_name],'[string_to_find]','[string_to_replace]');
			cosyn.open();
			var respu:Array = cosyn.query(sql);
			cosyn.close();
			enActualizaMoods(respu);
		}
		
		private function enActualizaMoods(respu:Array):void{
			mos.updateMoods(respu);
			trace("moods actualizados");
			//dispatchEvent(new Event("MOODS_ACTUALIZADOS"));
			enMoodsActualizados(null);
		}
		
		private function actualizaCanciones():void{
			var sql:String = "SELECT * FROM 'canciones' ORDER BY idt DESC";
			cosyn.open();
			var respu:Array = cosyn.query(sql);
			cosyn.close();
			enReCargaCanciones(respu);
		}
		
		private function enReCargaCanciones(respu:Array):void{
			lica.carga(respu,true);
			filtro.registraDatos();
			dispatchEvent(new Event("CANCIONES_ACTUALIZADAS"));
		}
		
		private function enEditFila(eve:MouseEvent):void{
			if(candg.selectedItems.length==1){
				var cade:MCdetalleCancion = new MCdetalleCancion(cosyn,candg.selectedItem,tem_cb.dataProvider);
				addChild(cade);
				cade.addEventListener(Event.CLOSE,enCancionCambiada);
				cade.addEventListener(Event.COMPLETE,enCancionNueva);
			}
		}
		
		private function enCancionNueva(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.CLOSE,enCancionCambiada);
			eve.currentTarget.removeEventListener(Event.COMPLETE,enCancionNueva);
			actualizaCanciones();
			eve.currentTarget.enCancela(null);
		}
		
		private function enCancionCambiada(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.CLOSE,enCancionCambiada);
			eve.currentTarget.removeEventListener(Event.COMPLETE,enCancionNueva);
			//candg.selectedItem = eve.currentTarget.odats;
			actualizaCanciones();
			eve.currentTarget.enCancela(null);
		}
		
		private function enAgregadoPorDrag(eve:Event):void{
			cosyn.open();
			for(var i:int=0; i<candg.dataProvider.length; i++){
				if(candg.getItemAt(i).nuevo){
					trace("nombre del nuevo = "+candg.getItemAt(i).nombre);
					candg.getItemAt(i).estilo='';
					candg.getItemAt(i).idt=0;
					candg.getItemAt(i).elcolor=0xFFFFFF;
					candg.getItemAt(i).coment = '-';
					trace("afectadas = "+cosyn.query("INSERT INTO 'canciones' (nombre, dire, idt, coment) VALUES ('"+escape(candg.getItemAt(i).nombre)+"', '"+escape(candg.getItemAt(i).dire)+"', '0', '')"));
					//candg.getItemAt(i).idc = cosyn.query("SELECT idc FROM 'canciones' WHERE dire = '"+escape(candg.getItemAt(i).dire)+"' ORDER BY idc DESC LIMIT 1")[0].idc;
				}
			}
			cosyn.close();
			guardaOrden();
			actualizaTodo();
		}
		
		private function agregaFile(eve:MouseEvent):void{
			var cade:MCdetalleCancion = new MCdetalleCancion(cosyn,null,tem_cb.dataProvider);
			addChild(cade);
			cade.addEventListener(Event.CLOSE,enCancionCambiada);
			cade.addEventListener(Event.COMPLETE,enCancionNueva);
		}
		
		private function enPideExaminar(eve:MouseEvent):void {
			var fileToOpen:File = new File();
			var mp3Filter:FileFilter = new FileFilter("MP3", "*.mp3","mp3");

			try {
				fileToOpen.browseForOpen("Open", [mp3Filter]);
				fileToOpen.addEventListener(Event.SELECT, fileSelected);
			} catch (error:Error) {
				trace("Failed:", error.message);
			}
		}
		
		private function fileSelected(event:Event):void {
			var archivo:File = event.target as File;
			//trace("archivo.url:"+'file:///'+archivo.nativePath.split('\\').join('/')+" ----- "+unescape(archivo.url));
			var nodat:Object = {nombre:archivo.name, dire:archivo.nativePath.split('\\').join('/'), estilo:'', idt:0, elcolor:0xFFFFFF, coment:'-'};
			cosyn.open();
			cosyn.query("INSERT INTO 'canciones' (nombre, dire, idt, coment) VALUES ('"+escape(nodat.nombre)+"', '"+escape(nodat.dire)+"', '0', '')");
			//nodat.idc = cosyn.query("SELECT idc FROM 'canciones' WHERE dire = '"+escape(nodat.dire)+"' ORDER BY idc DESC LIMIT 1")[0].idc;
			//candg.addItem(nodat);
			cosyn.close();
			guardaOrden();
			actualizaTodo();
		}
		
		private function enInicioCancion(eve:Event):void{
			var poscancion:Number=mplayer.curSong*candg.rowHeight;
			if(candg.verticalScrollPosition-poscancion < -(candg.height-30) || candg.verticalScrollPosition > poscancion-30)candg.verticalScrollPosition = poscancion;
			conf.setProp("ultimaCancion",String(candg.getItemAt(mplayer.curSong).idc));
		}
		
		private function enID3Disponible(eve:Event):void{
			var cid:ID3Info = mplayer.mp3Player.id3;
			id3_txt.text = cid.artist+" - "+cid.songName;
		}
		
		private function enClickFlechitaID(eve:MouseEvent):void{
			candg.getItemAt(mplayer.curSong).nombre = id3_txt.text;
			cosyn.open();
			var declar:String = 'UPDATE "canciones" SET nombre = "'+id3_txt.text+'" WHERE idc = '+int(candg.getItemAt(mplayer.curSong).idc);
			trace("SQL:"+declar);
			cosyn.query(declar);
			cosyn.close();
		}
		
		private function enResizeStage(eve:Event){
			candg.width = mplayer.transbackground.width = nuna.width-18;
			candg.height = nuna.height-candg.y-38;
			TweenLite.killDelayedCallsTo(guardaCoordenadas);
			TweenLite.delayedCall(2,guardaCoordenadas);
		}
		
		private function guardaCoordenadas():void{
			conf.setProp("width",String(nuna.width));
			conf.setProp("height",String(nuna.height));
		}
		
		private function enResizeColumnas(eve:Event){
			conf.setProp("columnas",lica.columnas.join(','));
		}
		
		private function enKeyUp(eve:KeyboardEvent):void{
			switch( eve.keyCode )
			{
				case Keyboard.DELETE:
					if(candg.selectedItems.length){
						if(candg.selectedItems.length>1){
							ale.NO = "NO";
							ale.YES = "YES"
							ale.alerte("Do you confirm deleting the selected items from the list?",borraSeleccionado);
							ale.NO = "";
							ale.YES="OK"
						}else{
							borraSeleccionado();
						}
					}
				break;
				
				case Keyboard.ENTER:
					if(candg.selectedItems.length){
						enENTER(candg.selectedItems[0]);
					}
				break;
				
				case 74:
					//var lisa:ListaSalto = new ListaSalto(filtro);
				break;
				
			}
		}
		
		private function borraSeleccionado():void{
			cosyn.open();
			var libor:Array = new Array();
			var respu:*;
			for(var i:int=0; i<candg.selectedItems.length; i++){
				respu = cosyn.query("DELETE FROM canciones WHERE idc = "+candg.selectedItems[i].idc+"");
				trace("respueste del = "+respu);
				if(respu){
					//libor.push(candg.selectedItems[i]);
					trace("candg.selectedItems[0].idc ="+candg.selectedItems[i].idc);
				}else{
					ale.alerte("error when deleting: "+candg.selectedItems[i].nombre);
					break;
				}
			}
			//for each(var valor:* in libor)candg.removeItem(valor);
			//filtro.registraDatos();
			cosyn.close();
			guardaOrden();
			actualizaTodo();
		}
		
		private function enSobreMenuPress(eve:MouseEvent):void{
			menu_cb.open();
		}
		
		private function enMoodsActualizados(eve:Event):void{
			//removeEventListener("MOODS_ACTUALIZADOS",enMoodsActualizados);
			espera.finEspere();
		}
		
		private function enCancionesActualizadas(eve:Event):void{
			removeEventListener("CANCIONES_ACTUALIZADAS",enCancionesActualizadas);
			pideUpdateMood(null);
			//addEventListener("MOODS_ACTUALIZADOS",enMoodsActualizados);
		}
		
		private function guardaOrden(eve:Event=null):void{
			if(filtro.filtrando)return;
			conf.setProp("orden",lica.orden);
			//trace('orden guardado: '+conf.getProp('orden'));
		}
		
		private function actualizaTodo():void{
			espera.espere("Updating Data");
			addEventListener("CANCIONES_ACTUALIZADAS",enCancionesActualizadas);
			actualizaCanciones();
		}
		
		private function sacaEscuchadoresImport(quien:Migrador):void{
			quien.removeEventListener(Event.CANCEL,enCancelaImportacion);
			quien.removeEventListener(Event.COMPLETE,enImportacionCompleta);
		}
		
		private function enImportacionCompleta(eve:Event):void{
			sacaEscuchadoresImport(eve.currentTarget as Migrador);
			actualizaTodo();
			espera.finEspere();
			ale.alerte("Import Complete");
		}
		
		private function enCancelaImportacion(eve:Event):void{
			sacaEscuchadoresImport(eve.currentTarget as Migrador);
			espera.finEspere();
		}
		
		private function importaFolder():void{
			var migr:Migrador = new Migrador(null,true);
			migr.cosync = cosyn;
			espera.espere("Please wait, Importing folder");
			migr.addEventListener(Event.CANCEL,enCancelaImportacion);
			migr.addEventListener(Event.COMPLETE,enImportacionCompleta);
		}
		
		private function abrePlayList():void{
			var migr:Migrador = new Migrador(null);
			migr.cosync = cosyn;
			espera.espere("Please wait, opening playlist");
			migr.addEventListener(Event.CANCEL,enCancelaImportacion);
			migr.addEventListener(Event.COMPLETE,enImportacionCompleta);
		}
		
		private function enCompletaGuardado(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.OPEN,enCompletaGuardado);
			eve.currentTarget.removeEventListener(Event.COMPLETE,enCompletaMigracion);
			eve.currentTarget.removeEventListener(Event.CANCEL,enCancelaMigracion);
			eve.currentTarget.removeEventListener(Event.CHANGE,enCambio);
			espera.finEspere();
			ale.alerte("Playlist has been successfully saved.");
		}
		
		private function enCompletaMigracion(eve:Event):void{
			eve.currentTarget.removeEventListener(Event.OPEN,enCompletaGuardado);
			eve.currentTarget.removeEventListener(Event.COMPLETE,enCompletaMigracion);
			eve.currentTarget.removeEventListener(Event.CANCEL,enCancelaMigracion);
			eve.currentTarget.removeEventListener(Event.CHANGE,enCambio);
			espera.espere("Making a copy of the exported music Data Base");
			eve.currentTarget.nuevaDB();
			espera.finEspere();
			ale.alerte("Files have been successfully copyed.");
		}
		
		private function enCancelaMigracion(eve:Event):void{
			trace("migración cancelada");
			eve.currentTarget.removeEventListener(Event.OPEN,enCompletaGuardado);
			eve.currentTarget.removeEventListener(Event.COMPLETE,enCompletaMigracion);
			eve.currentTarget.removeEventListener(Event.CANCEL,enCancelaMigracion);
			eve.currentTarget.removeEventListener(Event.CHANGE,enCambio);
			espera.finEspere();
		}
		
		private function enCambio(eve:Event):void{
			espera.espere("Please wait, copying files. "+eve.currentTarget.curind+" of "+eve.currentTarget.total);
		}
		
		private function enCambiaMenu(eve:Event):void{
			//trace(eve.target.selectedItem.data);
			var aCopiar:Array;
			var pidiendoGuardarPL:Boolean = false;
			if(eve.target.selectedItem.data=="ma_todos"){
				aCopiar = filtro.respaldoDP.toArray();
			}else if(eve.target.selectedItem.data=="ma_vis"){
				aCopiar = candg.dataProvider.toArray();
			}else if(eve.target.selectedItem.data=="ma_sel"){
				aCopiar = candg.selectedItems;
			}else if(eve.target.selectedItem.data=="ma_import"){
				importaFolder();
				return;
			}else if(eve.target.selectedItem.data=="pl_open"){
				abrePlayList();
				return;
			}else if(eve.target.selectedItem.data=="pl_save"){
				aCopiar = filtro.respaldoDP.toArray();
				pidiendoGuardarPL = true;
			}
			if(aCopiar.length<1){
				ale.alerte("no files selected for export");
				return;
			}
			var migr:Migrador = new Migrador(aCopiar,pidiendoGuardarPL);
			espera.espere("Please wait, copying files. 0 of "+migr.total);
			if(pidiendoGuardarPL)espera.espere("Please wait, saving playlist");
			addChild(espera);
			migr.addEventListener(Event.COMPLETE,enCompletaMigracion);
			migr.addEventListener(Event.CANCEL,enCancelaMigracion);
			migr.addEventListener(Event.CHANGE,enCambio);
			migr.addEventListener(Event.OPEN,enCompletaGuardado);
			eve.target.selectedIndex = -1;
			//sobre_menu_mc.t_txt.text = eve.target.selectedItem.label;
		}
		
		private function confMenu():void{
			//var medo:DataProvider = new DataProvider();
			menu_cb.addItem({label:"Open PlayList", data:"pl_open"});
			menu_cb.addItem({label:"Save PlayList", data:"pl_save"});
			menu_cb.addItem({label:"Import migrated folder", data:"ma_import"});
			menu_cb.addItem({label:"Migrate selected files", data:"ma_sel"});
			menu_cb.addItem({label:"Migrate visible files", data:"ma_vis"});
			menu_cb.addItem({label:"Migrate all files", data:"ma_todos"});
			//menu_cb.dataProvider = medo;
			menu_cb.addEventListener(Event.CHANGE,enCambiaMenu);
			trace("confMenu llamado");
		}
		
		private function iniciaDiagram():void{
			espera = new EspereMC();
			addChild(espera);
			ale = new Alerta();
			addChild(ale);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			nuna = stage.nativeWindow;
		}
		
		private function iniciaDatos():void{
			conf = new Configuraciones();
			cosyn = new ConectaLocalSync(conf.laDB);
			timin = new Timer(500,1);
		}
		
		private function iniciaExcuchadores():void{
			candg.addEventListener(MouseEvent.DOUBLE_CLICK,endobleClick);
			candg.addEventListener(KeyboardEvent.KEY_UP,enKeyUp);
			eso_btn.addEventListener(MouseEvent.CLICK,enEditFila);
			mplayer.eje_btn.addEventListener(MouseEvent.CLICK,enPideExaminar);
			mplayer.addEventListener(Event.ID3,enID3Disponible);
			mplayer.addEventListener(Event.INIT,enInicioCancion);
			mplayer.aid_btn.addEventListener(MouseEvent.CLICK,enClickFlechitaID);
			sobre_menu_mc.addEventListener(MouseEvent.MOUSE_DOWN,enSobreMenuPress);
			timin.addEventListener(TimerEvent.TIMER,dbAbierta);
			stage.addEventListener(Event.RESIZE,enResizeStage);
		}
		
		private function init():void{
			iniciaDiagram();
			iniciaDatos();
			iniciaExcuchadores();
			timin.start();
		}
	}
}