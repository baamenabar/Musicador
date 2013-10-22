package com.editores{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.media.Sound;

	import fl.controls.ComboBox;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import fl.controls.Slider;
	import fl.data.DataProvider;

	import com.net.ConectaLocalSync;
	import com.net.Direcciones;
	import com.utils.Alerta;
	import agustin.utils.Debug;
	import agustin.utils.Fecha;
	import flash.net.URLRequest;
	import com.greensock.plugins.VolumePlugin;
	import flash.events.IOErrorEvent;

	public class MCdetalleCancion extends MovieClip {
		public var odats:Object;
		private var mdp:DataProvider;
		public var colo:ConectaLocalSync;
		private var ale:Alerta;
		private var largoTotal:int;
		private var cancion:Sound;

		public function MCdetalleCancion(rcolo:ConectaLocalSync,rDatos:Object=null,rmoods:DataProvider=null) {
			odats = rDatos;
			mdp = rmoods;
			colo = rcolo;
			init();
		}
		private function posiciona():void {
			var pos:Point = this.parent.globalToLocal(new Point(-this.x,-this.y));
			fon_mc.x = pos.x;
			fon_mc.y = pos.y;
			fon_mc.width = stage.stageWidth;
			fon_mc.height = stage.stageHeight;
		}
		private function diagrama(eve:Event):void {
			var mpos:Point = this.parent.globalToLocal(new Point(stage.stageWidth*.5-vfon_mc.width*.5,stage.stageHeight*.5-vfon_mc.height*.5));
			this.x = mpos.x;
			this.y = mpos.y;
			posiciona();
		}
		private function enPideGuardar(eve:MouseEvent):void {
			var sql:String;//datos[i].nombre, idc:datos[i].idc, idt:datos[i].idt, dire:datos[i].dire, coment:datos[i].coment, elcolor:mood.colorID(datos[i].idt)});
			if (estilo_cb.selectedIndex>0) {
				var sliders:String='';
				var slidersVal:String='';
				var slidersUP:String='';
				if(slider_inicio.value || slider_fin.value){
					sliders=", 'inicio', 'fin'";
					slidersVal=", '"+slider_inicio.value+"', '"+slider_fin.value+"'";
				}
				if(odats.inicio!=slider_inicio.value || odats.fin!=slider_fin.value)slidersUP=", inicio = '"+slider_inicio.value+"', fin = '"+slider_fin.value+"'";
				if (odats==null) {
					sql = "INSERT INTO 'canciones' ('nombre','dire', 'coment', 'idt'"+sliders+") VALUES ('"+escape(t_txt.text)+"', '"+escape(p_txt.text)+"', '"+escape(c_txt.text)+"', '"+estilo_cb.selectedItem.data.data+"'"+slidersVal+")";
				} else {
					sql = "UPDATE 'canciones' SET nombre = '"+escape(t_txt.text)+"', dire = '"+escape(p_txt.text)+"', coment = '"+escape(c_txt.text)+"', idt = '"+estilo_cb.selectedItem.data.data+"'"+slidersUP+" WHERE idc = '"+odats.idc+"'";
				}
				colo.open();
				colo.query(sql);
				colo.close();
				enGuardaCancion();
			}else{
				ale.alerte("debe seleccionar un estilo");
			}
		}
		private function enGuardaCancion():void {
			var exv:Event;
			if (odats!=null) {
				odats.nombre = t_txt.text;
				odats.dire = p_txt.text;
				odats.coment = c_txt.text;
				odats.idt = estilo_cb.selectedItem.data.data;
				odats.elcolor = estilo_cb.selectedItem.data.elcolor;
				odats.estilo = estilo_cb.selectedItem.label;
				odats.inicio = slider_inicio.value;
				odats.fin = slider_fin.value;
				exv = new Event(Event.CLOSE);
			} else {
				exv = new Event(Event.COMPLETE);
			}
			dispatchEvent(exv);
			//enCancela(null);
		}
		private function enPress(eve:MouseEvent):void {
			this.startDrag();
		}
		private function enSuelta(eve:MouseEvent):void {
			this.stopDrag();
			posiciona();
		}
		public function enCancela(eve:MouseEvent):void {
			//colo.closeDB();
			if (parent!=null) {
				if (parent.removeChild!=null) {
					parent.removeChild(this);
				}
			}
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
		private function enNoEncuentra(eve:IOErrorEvent):void{
			cancion.removeEventListener(Event.COMPLETE,loadHandler);
			cancion.removeEventListener(IOErrorEvent.IO_ERROR,enNoEncuentra);
			startEnd_txt.text="URL no encontrada";
		}
		private function loadHandler(eve:Event):void{
			cancion.removeEventListener(Event.COMPLETE,loadHandler);
			cancion.removeEventListener(IOErrorEvent.IO_ERROR,enNoEncuentra);
			largoTotal = slider_inicio.maximum = slider_fin.maximum = int(cancion.bytesTotal / (cancion.bytesLoaded / cancion.length));
			trace("largoTotal: "+largoTotal+" odats.inicio && odats.fin: "+odats.inicio +" && "+ odats.fin);
			if(!odats.inicio && !odats.fin){
				startEnd_txt.text="00:00:000 / "+Fecha.milisegundosAminutos(largoTotal,3);
			}else{
				startEnd_txt.text=Fecha.milisegundosAminutos(odats.inicio,3)+" / "+Fecha.milisegundosAminutos(odats.fin,3);
				slider_inicio.value=odats.inicio;
				slider_fin.value=odats.fin;
			}
		}
		
		private function enSlidersCambia(eve:Event):void{
			if(slider_inicio.value>slider_fin.value){
				if(eve.target==slider_inicio){
					slider_fin.value=slider_inicio.value;
				}else{
					slider_inicio.value=slider_fin.value;
				}
			}
			startEnd_txt.text=Fecha.milisegundosAminutos(slider_inicio.value,3)+" / "+Fecha.milisegundosAminutos(slider_fin.value,3);
		}
		
		private function fileSelected(event:Event):void {
			var archivo:File = event.target as File;
			p_txt.text = archivo.nativePath.split('\\').join('/');//unescape(archivo.url).substr(8);//file///
			/*var stream:FileStream = new FileStream();
			stream.open(event.target, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
			trace(fileData);*/
		}
		
		private function encuentraEnDP(dato:int):int {
			var dade:Object;
			for (var i:int=0; i<mdp.length; i++) {
				dade = mdp.getItemAt(i);
				try{
					if (dade.data.data == dato) {
						return i;
					}
				}catch(err:*){
					
				}
			}
			return 0;
		}
		private function iniciaDatos():void {
			estilo_cb.dataProvider = mdp.clone();
			estilo_cb.dataProvider.removeItemAt(1);
			estilo_cb.selectedIndex = 0;
			if (odats!=null) {
				//Debug.traza(odats);
				t_txt.text = odats.nombre;
				p_txt.text = odats.dire;
				c_txt.text = odats.coment;
				estilo_cb.selectedIndex = encuentraEnDP(Number(odats.idt))-1;
				cancion = new Sound(new URLRequest("file:///"+odats.dire));
				cancion.addEventListener(Event.COMPLETE,loadHandler);
				cancion.addEventListener(IOErrorEvent.IO_ERROR,enNoEncuentra);
			}
			slider_inicio.liveDragging=slider_fin.liveDragging=true;
			estilo_cb.rowCount=10;
			ale = new Alerta();
			addChild(ale);
			//colo = new ConectaLocal(Direcciones.DB_DIR);
		}
		private function iniciaEscuchadores():void {
			addEventListener(Event.ADDED_TO_STAGE,diagrama);
			vfon_mc.addEventListener(MouseEvent.MOUSE_DOWN,enPress);
			vfon_mc.addEventListener(MouseEvent.MOUSE_UP,enSuelta);
			c_btn.addEventListener(MouseEvent.CLICK,enCancela);
			g_btn.addEventListener(MouseEvent.CLICK,enPideGuardar);
			e_btn.addEventListener(MouseEvent.CLICK,enPideExaminar);
			slider_fin.addEventListener(Event.CHANGE,enSlidersCambia);
			slider_inicio.addEventListener(Event.CHANGE,enSlidersCambia);
			//trace("escuchadores asignados");
		}
		private function init():void {
			iniciaEscuchadores();
			iniciaDatos();
		}
	}
}