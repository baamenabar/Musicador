package com.datos{
	import fl.controls.listClasses.CellRenderer;
	import com.datos.CRFonco_up;
	import com.datos.CRFonco_over;
	import com.datos.CRFonco_selOver;
	import flash.text.TextFormat;

	public class CRFondoColor extends CellRenderer {
		//public var customProperty:String = "foo";
		protected var tofo:TextFormat;

		public function CRFondoColor() {
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
			if(this.selected){
				tofo.color = 0xFFFFFF;
			}else{
				tofo.color = 0;
			}
			super.drawBackground ();
		}
	}
}