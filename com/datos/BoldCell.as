package com.datos{
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import flash.text.TextFormat;
	import com.datos.CRFonco_up;
	import com.datos.CRFonco_over;
	import com.datos.CRFonco_selOver;

	public class BoldCell extends CellRenderer implements ICellRenderer{
		//private var _listData:ListData;
		protected var tofo:TextFormat;
		
		public function BoldCell() {
			var originalStyles:Object = CellRenderer.getStyleDefinition();
        	setStyle("upSkin",			CRFonco_up);
			setStyle("overSkin",		CRFonco_over);
			setStyle("selectedUpSkin",	CRFonco_selUp);
			setStyle("selectedOverSkin",CRFonco_selOver);
        	setStyle("downSkin",		CRFonco_over);
			setStyle("selectedDownSkin",CRFonco_selOver);
			tofo = new TextFormat("_sans");
			this.setStyle("textFormat", tofo);
		}
		override protected function drawBackground ():void {
			textField.width = this.width;
			textField.htmlText = textField.text;
			textField.backgroundColor=0xFFCB05;
			if(this.selected){
				tofo.color = 0xFFFFFF;
			}else{
				tofo.color = 0;
			}
			if(this.data["tocando"]){
				tofo.bold = true;
				textField.background=true;
				tofo.color = 0;
			}else{
				tofo.bold = false;
				textField.background=false;
			}
			super.drawBackground ();
		}
		/*public function set listData(newListData:ListData):void {
            _listData = newListData;
        }
		public function get listData():ListData {
            return _listData;
        }*/
	}
}/*
disabledTextFormat style on the specified component: 

componentInstance.setStyle("disabledTextFormat", new TextFormat());


Returns 
*/