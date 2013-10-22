package com.net{
	import fl.controls.DataGrid;
	import fl.data.DataProvider;
	import fl.controls.dataGridClasses.DataGridColumn;
	
	public class ArmaLista{
		private var edg:DataGrid;
		
		public function ArmaLista(elDG:DataGrid){
			edg = elDG;
			mdo = edg.dataProvider;
			var c1:DataGridColumn = new DataGridColumn("label");
			var c2:DataGridColumn = new DataGridColumn("grupo");
			c1.headerText = "nombre";
			c2.headerText = "estilo";
			edg.addColumn(c1);
			edg.addColumn(c2);
		}
		
		private function function recibe(datos:Array):void{
			
		}
	}
}