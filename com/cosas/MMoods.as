package com.cosas{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import com.editores.MCdetalleEstilo;
	import agustin.utils.Debug;
	
	public class MMoods extends EventDispatcher{
		public var elcb:ComboBox;
		public var lista:Array;
		public var edp:DataProvider;
		private var laDB:String;
		
		public function MMoods(rcb:ComboBox,rdata:Array,rDB:String){
			elcb = rcb;
			lista = rdata;
			laDB = rDB;
			init();
		}
		
		public function update(rdata:Array):void{
			lista = rdata;
		}
		
		public function updateMoods(redat:Array):void{
			lista = redat;
			edp.removeAll();
			edp.addItem({label:"mood", data:null});
			edp.addItem({label:"edit moods", data:"edita"});
			if(lista==null)return;
			for(var i:int=0; i<lista.length; i++){
				edp.addItem({label:lista[i].label, data:lista[i]});
			}
			//edp.addItems(lista);
		}
		
		public function nombreID(sid:int):String{
			var wel:String = "";
			if(sid!=0){
				for (var i:String in lista){
					if(lista[i].data==sid){
						wel = lista[i].label;
						break;
					}
				}
			}
			return wel;
		}
		
		public function colorID(sid:int):int{
			var wel:int = 0xFFFFFF;
			if(sid!=0){
				for (var i:String in lista){
					if(lista[i].data==sid){
						wel = lista[i].elcolor;
						if(wel==0)wel = 0xFFFFFF;
						break;
					}
				}
			}
			return wel;
		}
		
		public function elige(idt:int):void{
			elcb.selectedIndex = 0;
			if(idt==0)return;
			for(var i:int=0; i<edp.length; i++){
				//Debug.print_r(edp.getItemAt(i));
				if(edp.getItemAt(i).data!="edita" && edp.getItemAt(i).data!=null){
					if(edp.getItemAt(i).data.data == idt){
						elcb.selectedIndex = i;
						break;
					}
				}
			}
		}
		
		private function enCambiaCB(eve:Event):void{
			if(elcb.selectedItem.data == "edita"){
				var edimo:MCdetalleEstilo = new MCdetalleEstilo(laDB,lista);
				if(elcb.parent)if(elcb.parent.addChild!=null)elcb.parent.addChild(edimo);
				elcb.selectedIndex=0;
				edimo.addEventListener(Event.CLOSE,actualiza);
			}else if(elcb.selectedItem.data != null){
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		
		private function actualiza(eve:Event):void{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function iniciaDatos():void{
			edp = elcb.dataProvider;//new DataProvider();
			edp.addItem({label:"moods", data:null});
			edp.addItem({label:"edit moods", data:"edita"});
			//edp.addItems(lista);
			if(lista!=null){
				for(var i:int=0; i<lista.length; i++){
					edp.addItem({label:lista[i].label,data:lista[i]});
				}
			}
			//elcb.dataProvider = edp;
		}
		
		private function iniciaEscuchadores():void{
			elcb.addEventListener(Event.CHANGE,enCambiaCB);
		}
		
		private function init():void{
			iniciaDatos();
			iniciaEscuchadores()
		}
	}
}