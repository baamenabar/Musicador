package  com.utils{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.Sprite;
	import fl.controls.DataGrid;
	import fl.controls.listClasses.CellRenderer;
	
	import agustin.utils.Debug;
	import agustin.utils.BitmapDataDraw;
	import flash.events.EventDispatcher;
	
	public class DGdragDrop extends EventDispatcher{
		private var edg:DataGrid;
		private var pini:Point;
		private var curcer:CellRenderer;
		private var curpoi:Point;
		private var curobp:Array;
		private var inde:int;
		private var deltay:Number;
		private var contenedor:Sprite;
		private var curFilas:Array;
		
		public function DGdragDrop(redg:DataGrid) {
			edg=redg;
			init();
		}
		
		private function enSuelta(eve:MouseEvent):void{
			edg.removeEventListener(Event.ENTER_FRAME,enCC);
			if(deltay)dispatchEvent(new Event(Event.COMPLETE));
			deltay=0;
		}
		
		private function enPress(eve:MouseEvent):void{
			if(edg.mouseX>edg.width-15 || edg.mouseY<26)return;
			//trace(eve);
			//trace(eve.target);
			//trace(eve.target.areInaccessibleObjectsUnderPoint(new Point(eve.target.stage.mouseX,eve.target.stage.mouseY)))
			//trace(eve.target.data);
			//trace(eve.target.listData.index);
			inde = eve.target.listData.index;
			var corre:Boolean = revisaSeleccion(eve);
			
			contenedor = eve.target.parent;
			pini = new Point(contenedor.mouseX,contenedor.mouseY);
			curcer = eve.target as CellRenderer;
			curFilas = new Array();
			var selecciones:Array = edg.selectedItems;
			var i:Object;
			for each(i in selecciones){
				curFilas.push(i);
			}
			deltay=0;
			edg.stage.addEventListener(MouseEvent.MOUSE_UP,enSuelta);
			edg.addEventListener(Event.ENTER_FRAME,enCC);
			//trace("----------------");
		}
		private function revisaSeleccion(eve:MouseEvent): Boolean{
			var doit:Boolean = true;
			if(eve.shiftKey || eve.commandKey || eve.controlKey)return false;
			if(edg.selectedIndices.length<2){
				if(edg.selectedIndex!=inde){
					edg.selectedIndex=inde;
					return true;
				}
			}else{
				var encon:Boolean=false;
				for each(var i:int in edg.selectedIndices)if(i==inde){
					encon=true;
					break;
				}
				if(!encon){
					edg.selectedIndex=inde;
					return true;
				}
			}
			return false;
		}
		private function enCC(eve:Event):void{
			curpoi.x = contenedor.mouseX;//edg.stage.mouseX;
			curpoi.y = contenedor.mouseY;//edg.stage.mouseY;
			deltay=pini.y-curpoi.y;
			//trace(deltay);
			curobp = edg.stage.getObjectsUnderPoint(new Point(edg.stage.mouseX,edg.stage.mouseY));
			var ojs:*;
			var opadre:CellRenderer;
			for each(ojs in curobp){
				
			//trace('que es?'+ojs.parent.toString());
			if(ojs.parent.toString().substr(0,20)=='[object CellRenderer' || ojs.parent.toString()=='[object CRFondoColor]' || ojs.parent.toString()=='[object BoldCell]'){
				opadre = ojs.parent as CellRenderer;
			//trace("son? "+opadre.listData.index+"!="+curcer.listData.index);
			if(opadre.listData.index!=curcer.listData.index){
				//trace("no soy yo");
				var actcer:CellRenderer = opadre;
				var nuindex:int = opadre.listData.index;
				var removidos:Array=new Array();
				for each(var i:Object in curFilas){
					removidos.push(edg.removeItem(i));
				}
				//var removido:Object = edg.removeItemAt(curcer.listData.index);
				edg.dataProvider.addItemsAt(removidos,nuindex);
				curcer=actcer;
				//trace("typeof:"+typeof(ojs.parent)+" - toString: "+ojs.parent.toString()+" - normal: "+ojs.parent);//if(typeof(ojs)==)
				edg.selectedItems=removidos;
				//trace("ahora si? "+curcer.name+"="+actcer.name);
				break;
			}
			}
			}
		}
		
		private function iniciaEscuchadores():void{
			edg.addEventListener(MouseEvent.MOUSE_DOWN,enPress);
		}
		
		private function init():void{
			curpoi = new Point();
			iniciaEscuchadores();
		}
	}
	
}
