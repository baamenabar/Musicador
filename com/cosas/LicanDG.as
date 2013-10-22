package com.cosas{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import fl.data.DataProvider;
	import fl.events.DataGridEvent;
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.DataGridColumn;
	
	import com.cosas.MMoods;
	import com.datos.CRFondoColor;
	import com.datos.MultiLineCell;
	import com.datos.BoldCell;
	
	public class LicanDG extends EventDispatcher{
		public var edg:DataGrid;
		public var datos:Array;
		private var dapro:DataProvider;
		private var mood:MMoods;
		private var poss:Object;
		private var c1:DataGridColumn;
		private var c2:DataGridColumn;
		private var c3:DataGridColumn;
		private var _orden:Vector.<int>;
		
		public function LicanDG(elDG:DataGrid,restil:MMoods){
			edg = elDG;
			mood = restil;
			init();
		}
		
		public function carga(rdats:Array,actualiza:Boolean=false):void{
			datos = rdats;
			if(actualiza)edg.removeAll();
			if(datos==null)return;
			var e:int;
			var largoOrden:int;
			var cuentaNo:int=0;
			var tidc:int;
			var i:int;
			for each(e in _orden){
				for(i=0; i<datos.length; i++){
					if(e==datos[i].idc){
						dapro.addItem({nombre:unescape(datos[i].nombre), estilo:mood.nombreID(datos[i].idt), idc:datos[i].idc, idt:datos[i].idt, dire:unescape(datos[i].dire), coment:unescape(datos[i].coment), elcolor:mood.colorID(datos[i].idt), tocando:false, inicio:datos[i].inicio, fin:datos[i].fin});
						datos.splice(i,1);
						break;
					}
				}
			}
			if(datos.length){
				for(i=0; i<datos.length; i++)dapro.addItem({nombre:unescape(datos[i].nombre), estilo:mood.nombreID(datos[i].idt), idc:datos[i].idc, idt:datos[i].idt, dire:unescape(datos[i].dire), coment:unescape(datos[i].coment), elcolor:mood.colorID(datos[i].idt), tocando:false, inicio:datos[i].inicio, fin:datos[i].fin});
			}
			leeOrden();
		}
		
		public function get columnas():Array{
			return new Array(int(c1.width),int(c2.width),int(c3.width));
		}
		public function set columnas(cols:Array):void{
			if(cols.length!=3)return;
			//c1.width = int(cols[0]);
			c2.width = Number(cols[1]);
			c3.width = Number(cols[2]);
		}
		
		public function get orden():String{
			leeOrden();
			return _orden.join(',');
		}
		public function set orden(eord:String):void{
			var tarro:Array = eord.split(',');
			_orden = new Vector.<int>();
			for each(var i:String in tarro)_orden.push(int(i));
		}
		
		private function init():void{
			dapro = edg.dataProvider;
			_orden = new Vector.<int>();
			//var cte:DataGridColumn = new DataGridColumn("idc");
			c1 = new DataGridColumn("nombre");
			c2 = new DataGridColumn("estilo");
			c3 = new DataGridColumn("coment");
			c1.headerText = "Song";
			c2.headerText = "Mood";
			c3.headerText = "Comments";
			c1.cellRenderer = BoldCell;
			c2.cellRenderer = CRFondoColor;
			c3.cellRenderer = MultiLineCell;
			c1.minWidth=c2.minWidth=c3.minWidth=130;
			edg.rowHeight = 30
			//edg.addColumn(cte);
			edg.addColumn(c1);
			edg.addColumn(c2);
			edg.addColumn(c3);
			edg.addEventListener(Event.CHANGE,eligeEstilo);
			edg.addEventListener(DataGridEvent.COLUMN_STRETCH,enAjustaColumna);
			poss = new Object()
		}
		
		private function leeOrden():void{
			_orden = new Vector.<int>();
			var largo:int = dapro.length;
			var i:int;
			for(i=0; i<largo; i++)_orden.push(int(edg.getItemAt(i).idc));
		}
		
		private function eligeEstilo(eve:Event):void{
			var arsel:Array = edg.selectedItems;
			var idti:int = arsel[0].idt;
			//trace("idti = "+idti);
			for(var i:int=0; i<arsel.length; i++){
				if(arsel[i].idt != idti){
					mood.elige(0);
					return;
				}
			}
			mood.elige(idti);
		}
		
		private function enAjustaColumna(eve:DataGridEvent):void{
			dispatchEvent(new Event(Event.ID3));
		}
	}
}