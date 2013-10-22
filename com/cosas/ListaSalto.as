package com.cosas{
	import flash.events.EventDispatcher;
	
	import agustin.datos.BuscaEnDataGrid;
	
	public class ListaSalto extends EventDispatcher{
		private var filtro:BuscaEnDataGrid;
		
		public function ListaSalto(rfil:BuscaEnDataGrid):void{
			filtro = rfil;
		}
	}
}