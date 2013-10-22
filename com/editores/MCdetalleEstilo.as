package com.editores{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import fl.controls.Button;
	import fl.controls.ColorPicker;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	import fl.events.ColorPickerEvent;
	
	import com.net.ConectaLocalSync;
	import com.net.Direcciones;
	import agustin.utils.Debug;
	import agustin.calculos.Calcula;
	import flash.geom.ColorTransform;
	
	public class MCdetalleEstilo extends MovieClip{
		private var odats:Object;
		private var cdp:DataProvider;
		private var conCambios:Boolean = false;
		private var laDB:String;
		public var colo:ConectaLocalSync;
		
		public function MCdetalleEstilo(rDB:String,rDatos:Object=null){
			odats = rDatos;
			laDB = rDB;
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function posiciona():void{
			var pos:Point = this.parent.globalToLocal(new Point(-this.x,-this.y));
			fon_mc.x = pos.x;
			fon_mc.y = pos.y;
			fon_mc.width = stage.stageWidth;
			fon_mc.height = stage.stageHeight;
		}
		
		private function enPress(eve:MouseEvent):void{
			this.startDrag();
		}
		private function enSuelta(eve:MouseEvent):void{
			this.stopDrag();
			posiciona();
		}
		private function enCancela(eve:MouseEvent):void{
			if(conCambios){
				dispatchEvent(new Event(Event.CLOSE));
			}
			if(parent!=null)if(parent.removeChild!=null)parent.removeChild(this);
		}
		
		private function enCBcambia(eve:Event):void{
			var selo:Object = estilo_cb.selectedItem;
			if(selo.data=="nuevo"){
				e_cp.selectedColor = 0xFFFFFF;
				t_txt.text = "";
				c_txt.text = "#FFFFFF";
				e_btn.enabled = false;
			}else{
				e_cp.selectedColor = selo.elcolor;
				t_txt.text = selo.label;
				c_txt.text = "#"+e_cp.hexValue.toUpperCase();
				e_btn.enabled = true;
			}
		}
		
		private function enSelecCP(eve:ColorPickerEvent):void{
			c_txt.text = "#"+e_cp.hexValue.toUpperCase();
		}
		
		private function enGuardar(eve:MouseEvent):void{
			//Debug.traza(estilo_cb.selectedItem);//nombre AS label, idt AS data, elcolor AS elcolor
			var sql:String;
			if(estilo_cb.selectedItem.data == "nuevo"){
				sql = "INSERT INTO 'temas' ('nombre','elcolor') VALUES ('"+t_txt.text+"', '"+e_cp.selectedColor+"')";
			}else{
				sql = "UPDATE 'temas' SET nombre = '"+t_txt.text+"', elcolor = '"+e_cp.selectedColor+"' WHERE idt = '"+estilo_cb.selectedItem.data+"'";
			}
			colo.open();
			colo.query(sql);
			colo.close();
			enGuardaMood();
		}
		
		private function enGuardaMood():void{
			conCambios = true;
			update();
		}
		
		private function enBorrar(eve:MouseEvent):void{
			//Debug.traza(estilo_cb.selectedItem);
		}
		
		private function update():void{
			var sql:String = "SELECT nombre AS label, idt AS data, elcolor AS elcolor FROM 'temas'";//update [table_name] set [field_name] = replace([field_name],'[string_to_find]','[string_to_replace]');
			colo.open();
			var respu:Array = colo.query(sql);
			colo.close();
			enCargaTemas(respu);
		}
		
		private function enCargaTemas(respu:Array):void{
			cdp.removeAll();
			cdp.addItem({label:"nuevo", data:"nuevo"});
			cdp.addItems(respu);
			e_cp.selectedColor = 0xFFFFFF;
			t_txt.text = "";
			c_txt.text = "#FFFFFF";
			e_btn.enabled = false;
		}
		
		private function diagrama():void{
			var mpos:Point = this.parent.globalToLocal(new Point(stage.stageWidth*.5-vfon_mc.width*.5,stage.stageHeight*.5-vfon_mc.height*.5));
			this.x = mpos.x;
			this.y = mpos.y;
			posiciona();
		}
		
		private function iniciaDatos():void{
			cdp = new DataProvider();
			cdp.addItem({label:"nuevo", data:"nuevo"});
			if(odats!=null){
				cdp.addItems(odats);
			}
			estilo_cb.dataProvider = cdp;
			estilo_cb.addEventListener(Event.CHANGE,enCBcambia);
			estilo_cb.rowCount=10;
			var klores:Array = e_cp.colors;
			var colol:ColorTransform;
			for(var i:int=0; i<216; i++){
				if((i%18)<9){
					colol = new ColorTransform(1,1,1,1,Calcula.randRange(100,254-int(i/4)),Calcula.randRange(100,200+int(i/4)),Calcula.randRange(100,254-int(i/4)));
					klores[i] = colol.color;
				}
			}
			//klores.sort();
			e_cp.colors=klores;
			colo = new ConectaLocalSync(laDB);
		}
		private function iniciaEscuchadores():void{
			vfon_mc.addEventListener(MouseEvent.MOUSE_DOWN,enPress);
			vfon_mc.addEventListener(MouseEvent.MOUSE_UP,enSuelta);
			c_btn.addEventListener(MouseEvent.CLICK,enCancela);
			e_cp.addEventListener(ColorPickerEvent.ENTER,enSelecCP);
			e_cp.addEventListener(ColorPickerEvent.CHANGE,enSelecCP);
			g_btn.addEventListener(MouseEvent.CLICK,enGuardar);
			e_btn.addEventListener(MouseEvent.CLICK,enBorrar);
		}
		
		private function init(eve:Event):void{
			diagrama();
			iniciaEscuchadores();
			iniciaDatos();
		}
	}
}