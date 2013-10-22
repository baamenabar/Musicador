package com.utils{
	import flash.filesystem.*;
	//import gs.StringUtils;
	
	public class ManejaPL{
		public function ManejaPL(){
			
		}
		
		public static function abreEinterpretaPL(a_quien:File):Object{
			var arch:File = a_quien;
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(arch, FileMode.READ);
			var datos:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			var arr2partes:Array = datos.split(unescape("%0A-%3B%7C%3B-%0A"));
			var pre_lican:Array = arr2partes[0].split(unescape("%0A"));
			var pre_limoo:Array = arr2partes[1].split(unescape("%0A"));
			var lican:Array = new Array();
			var limoo:Array = new Array();
			var tarr:Array;
			for(var i:int=0; i<pre_lican.length; i++){
				tarr = pre_lican[i].split(";;");
				lican.push({idc:tarr[0], idt:tarr[1], nombre:tarr[2], dire:unescape(tarr[3]), coment:tarr[4], inicio:tarr[5], fin:tarr[6]});
			}
			for(i=0; i<pre_limoo.length; i++){
				tarr = pre_limoo[i].split(";;");
				limoo.push({idt:tarr[0], nombre:tarr[1], elcolor:tarr[2]});
			}
			var wel:Object = new Object();
			wel.canciones = lican;
			wel.moods = limoo;
			return wel;
		}
		/*
		artei = new Array();
				artei[0] = respaldoCan[i].idc;
				artei[1] = respaldoCan[i].idt;
				artei[2] = escape(respaldoCan[i].nombre);
				artei[3] = escape(respaldoCan[i].dire);
				artei[4] = escape(respaldoCan[i].coment);
				
				artei[0] = respaldoMoo[i].idt;
				artei[1] = respaldoMoo[i].nombre;
				artei[2] = respaldoMoo[i].elcolor;
		*/
		public static function abreEinterpretaCarpeta(d_quien:String):Object{
			var carp:File = new File(d_quien);
			var arch:File = new File(d_quien+"/playlist.sti");
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(arch, FileMode.READ);
			var datos:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			var arr2partes:Array = datos.split(unescape("%0A-%3B%7C%3B-%0A"));
			var pre_lican:Array = arr2partes[0].split(unescape("%0A"));
			var pre_limoo:Array = arr2partes[1].split(unescape("%0A"));
			var lican:Array = new Array();
			var limoo:Array = new Array();
			var tarr:Array;
			for(var i:int=0; i<pre_lican.length; i++){
				tarr = pre_lican[i].split(";;");
				lican.push({idc:tarr[0], idt:tarr[1], nombre:tarr[2], dire:escape(carp.url.substr(8))+"/"+unescape(tarr[3]), coment:tarr[4], inicio:tarr[5], fin:tarr[6]});
			}
			for(i=0; i<pre_limoo.length; i++){
				tarr = pre_limoo[i].split(";;");
				limoo.push({idt:tarr[0], nombre:tarr[1], elcolor:tarr[2]});
			}
			var wel:Object = new Object();
			wel.canciones = lican;
			wel.moods = limoo;
			return wel;
		}
	}
}