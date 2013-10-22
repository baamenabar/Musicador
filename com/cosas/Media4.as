package com.cosas
{
	/*****************************************
	 * Media4 :
	 * Demonstrates loading external sounds.
	 * -------------------
	 * See 4_soundloading.fla
	 ****************************************/
	 
	import flash.display.*;
	import flash.text.TextField;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle; 
	import flash.net.*;
	import flash.ui.Keyboard;
	import flash.filesystem.File;
	
	import fl.controls.DataGrid;
	import fl.data.DataProvider;
	
	import com.cosas.MCbtnTipo1;
	import com.cosas.MCvolumen;
	
	import agustin.utils.Debug;
	import agustin.utils.Fecha;
	
	public class Media4 extends MovieClip
	{
		//*************************
		// Sound properties
			
		public var mp3Players:Array = new Array();	
		public var mp3Player:Sound;
		public var mp3Channel:SoundChannel;	
		public var mp3Position:Number = 0;	
		public var deltaPos:int = 100;
		public var startEnd:Object;
		
		// Flags
		public var looping:Boolean = false;
		public var playing:Boolean = false;
		public var paused:Boolean = false;
		public var advance:Boolean = false;
		public var goback:Boolean = false;
		public var dragging:Boolean = false;
		public var primeraVez:Boolean = true;
		public var tiempoPositivo:Boolean = true;
		
		// Assets
		public var playhilite:MovieClip;
		public var loophilite:MovieClip;
		
		
		// EXTERNAL
		public var eldg:DataGrid=null;
		public var idc:int;
		public var curSong:int=0;
		public var intentosDeCarga:Object = new Object();
		private var mdp:DataProvider=null;
		
		//*************************
		// Constructor:
		
		public function Media4()
		{
			// Diagrama
			play_btn.icon = fPlay;
			stop_btn.icon = fStop;
			rewind_btn.icon = fRew;
			stepback_btn.icon = fStepB;
			fastforward_btn.icon = fFF;
			stepforward_btn.icon = fStepF;
			loop_btn.icon = fLoop;
			eje_btn.icon = fEject;
			
			//IniciaDatos
			startEnd = {inicio:0,fin:0};
			intentosDeCarga.numero = 0;
			
			// Respond to mouse events
			stop_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			play_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			rewind_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			stepback_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			stepback_btn.addEventListener(MouseEvent.MOUSE_DOWN,pressHandler);
			stepforward_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			stepforward_btn.addEventListener(MouseEvent.MOUSE_DOWN,pressHandler);
			fastforward_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			ti_txt.addEventListener(MouseEvent.CLICK,clickHandler);
			loop_btn.addEventListener(MouseEvent.CLICK,clickHandler);
			fader_btn.addEventListener(MouseEvent.MOUSE_DOWN,dragPressHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,enTeclasDOWN);
			stage.addEventListener(KeyboardEvent.KEY_UP,enTeclasUP);
			
			// Respond to change events
			//sound_stepper.addEventListener(Event.CHANGE,changeHandler);
			
			// The stage handles drag release and releaseOutside events
			stage.addEventListener(MouseEvent.MOUSE_UP,dragReleaseHandler);
			
			// Update every frame
			addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			
			//loadSound();
		}
		
		//************************* 
		// Event Handling:
		
		// Sound loaded
		protected function enNoEncuentra(eve:IOErrorEvent):void{
			trace("no encontrado (IO): "+eve);
			intentosDeCarga.numero++;
			if(intentosDeCarga.numero>1){
				intentosDeCarga.numero=0;
				tocaSiguiente();
			}else{
				loadSound(intentosDeCarga.dire,intentosDeCarga.nuevo,intentosDeCarga.coincide,intentosDeCarga.externo)
			}
		}
		
		protected function loadHandler(event:Event):void
		{
			if(startEnd.inicio){
				playSound(startEnd.inicio);
			}else{
				playSound(0);
			}
			fader_btn.visible=true;
			if(primeraVez){
				volumControl.activa(mp3Channel);
				primeraVez = false;
			}
			intentosDeCarga.numero=0;
			intentosDeCarga.dire='';
			intentosDeCarga.nuevo=false;
			intentosDeCarga.coincide=false;
			intentosDeCarga.externo=false;
			dispatchEvent(new Event(Event.INIT));
		}
		
		protected function enID3Disponible(eve:Event):void{
			mp3Player.removeEventListener(Event.ID3,enID3Disponible);
			dispatchEvent(eve);
		}
		
		// Sound playback completed
		protected function completeHandler(event:Event):void
		{
			/*if( looping ){
				playSound(0);
			}else */if(eldg!=null){
				tocaSiguiente();
			}else{
				playing = false;
				//playhilite.visible = false;
				play_btn.activo();
				mp3Channel.removeEventListener(Event.SOUND_COMPLETE,completeHandler);
			}
		}
		
		// Scrub drag
		protected function dragPressHandler(event:MouseEvent):void
		{
			// Create a rectangle to constrain the drag
			var rx:Number = track_mc.x + 1;
			var ry:Number = fader_btn.y;
			var rw:Number = track_mc.width - fader_btn.width - 1;
			var rh:Number = 0;
			var rect:Rectangle = new Rectangle(rx, ry, rw, rh);
			
			// Drag
			dragging = true;
			fader_btn.startDrag(false,rect);
		}
		
		// Scrub release
		protected function dragReleaseHandler(event:MouseEvent):void
		{
			if( dragging )
			{
				// Stop drag
				fader_btn.stopDrag();
				if(playing){
					// Seek
					mp3Position = ((fader_btn.x-track_mc.x)/(track_mc.width-fader_btn.width))*mp3Player.length;
					stopSound();
					playSound(mp3Position);
				}else{
					fader_btn.x = track_mc.x + 1;
				}
				dragging = false;
			}
		}
		
		// Seek press
		protected function pressHandler(event:MouseEvent):void
		{	
			switch( event.target )
			{
				case stepback_btn:
					
					goback = true;
					break;
					
				case stepforward_btn:
					
					advance = true;
					break;
			}
		}
		
		// Button release
		protected function clickHandler(event:MouseEvent):void
		{
			switch( event.target )
			{
				case stop_btn:
					
					if( playing ){
						mp3Position = mp3Channel.position;
						paused = true;
					}
					if(mp3Channel!=null)stopSound();
					break;
					
				case play_btn:
				
					if(!playing){
						if(eldg.selectedIndex==-1){
							eldg.selectedIndex=0;
							tocaAnterior();
						}else if(paused){
							playSound(mp3Position);	
							paused = false;
						}
					}else{
						stopSound();
						playSound(0);
					}
					break;
					
				case rewind_btn:
					
					mp3Position = 0;
					if( playing ){
						stopSound();
					}
					fader_btn.x = track_mc.x + 1;
					tocaAnterior();
					break;
					
				case stepback_btn:
					
					goback = false;
					break;
					
				case stepforward_btn:
					
					advance = false;
					break;
					
				case fastforward_btn:
					
					mp3Position = mp3Player.length;
					if( playing ){
						stopSound();
					}
					fader_btn.x = track_mc.x + (track_mc.width - fader_btn.width);
					tocaSiguiente();
					break;
					
				case loop_btn:
					
					looping = !looping;
					
					if( looping ){
						if( loophilite == null )
						{
							loophilite = new LoopHiliteSymbol();
							loophilite.x = loop_btn.x;
							loophilite.y = loop_btn.y + 1;
							loophilite.mouseEnabled = false;
							addChild(loophilite);
						}else{
							loophilite.visible = true;
						}
					}else{
						loophilite.visible = false;
					}
					break;
				
				case ti_txt:
					tiempoPositivo = !tiempoPositivo;
				break
			}
		}
		
		protected function enTeclasDOWN(eve:KeyboardEvent):void{
			
		}
		
		protected function enTeclasUP(eve:KeyboardEvent):void{
			switch( eve.keyCode )
			{
				case Keyboard.LEFT:
					deltaPos = 5000;
					goback = true;
					break;
				
				case Keyboard.RIGHT:
					deltaPos = 5000;
					advance = true;
					break;
			}
		}
		
		// Update every frame
		protected function enterFrameHandler(event:Event):void
		{
			if( mp3Channel == null ){
				return;
			}
			// Seek forward and back
			if( advance )
			{
				var fwdPos:Number = mp3Channel.position+deltaPos;
				if(	fwdPos < mp3Player.length ) {
					if( playing ) {
						mp3Position = fwdPos;
						stopSound();
						playSound(mp3Position);
					}
					else if( fader_btn.x <= (track_mc.x + (track_mc.width-fader_btn.width))){
						fader_btn.x += 1;
						mp3Position = ((fader_btn.x/(track_mc.width-fader_btn.width))*mp3Player.length);
					}
				}
				
			}
			else if( goback ) 
			{
				if( playing ) {
					mp3Position = mp3Channel.position-deltaPos;
					stopSound();
					playSound(mp3Position);
				} 
				else if( fader_btn.x > track_mc.x ) {
					fader_btn.x -= 1;
					mp3Position = ((fader_btn.x/track_mc.width)*mp3Player.length);
				}
			}
			if(deltaPos>100){
				deltaPos=100;
				goback = advance = false;
			}
			// Move fader when playing
			if(!dragging && playing){
				if(tiempoPositivo){
					ti_txt.text = Fecha.milisegundosAminutos(mp3Channel.position)+" / "+Fecha.milisegundosAminutos(mp3Player.length);
				}else{
					ti_txt.text = "-"+Fecha.milisegundosAminutos(mp3Player.length-mp3Channel.position)+" / "+Fecha.milisegundosAminutos(mp3Player.length);
				}
				fader_btn.x = track_mc.x+((mp3Channel.position/mp3Player.length)*(track_mc.width-fader_btn.width));
				if(startEnd.fin && startEnd.fin<mp3Channel.position){//si está definido un fin para la canción y si se ha superado el final definido en milisegundos, saltar ala siguiente canción.
					startEnd.fin=0;
					tocaSiguiente();
				}
			}
		}
		
		/*protected function changeHandler(event:Event):void
		{
			//mp3Index = sound_stepper.value;
			mp3Position = 0;
			
			// Load/play new sound...
			stopSound();
			loadSound();
		}*/
		
		protected function tocaSiguiente():void{
			//var suma:int = eldg.selectedIndex+1;
			curSong=encuentraTocando();
			var suma:int = curSong+1;
			if(suma==mdp.length)suma=0;
			var nuevaCancion:Object = eldg.getItemAt(suma);
			if(looping){//hace loop en grupo de canciones por estilo
				var curCan:Object = eldg.getItemAt(curSong);
				var curIdt:int = curCan.idt;
				if(curIdt!=nuevaCancion.idt){
					var i:int=0;
					var encontrado:Boolean = false
					while(!encontrado){
						if(eldg.getItemAt(i).idt==curIdt){
							encontrado=true;
							suma = i;
							break;
						}
						i++;
						if(i==eldg.dataProvider.length)i=0;
					}
				}
			}
			//eldg.selectedIndex = suma;
			//loadSound(eldg.selectedItem.dire,true);
			curSong = suma;
			startEnd.inicio = nuevaCancion.inicio;
			startEnd.fin = nuevaCancion.fin;
			loadSound(nuevaCancion.dire,true);
		}
		
		protected function tocaAnterior():void{
			//var suma:int = eldg.selectedIndex-1;
			var suma:int = curSong-1;
			if(suma==-1)suma=0;
			var nuevaCancion:Object = eldg.getItemAt(suma);
			//eldg.selectedIndex = suma;
			//loadSound(eldg.selectedItem.dire,true);
			curSong = suma;
			startEnd.inicio = nuevaCancion.inicio;
			startEnd.fin = nuevaCancion.fin;
			loadSound(nuevaCancion.dire,true);
		}
		
		//*************************
		// Public methods:
		public function encuentraTocando():int{
			var i:int;
			var largom:int = mdp.length;
			for(i=0; i<largom; i++){
				if(mdp.getItemAt(i).tocando)return i;
			}
			return 0;
		}
		
		public function rebusca():void{
			trace("pidiendo rebusca");
			var took:Boolean = false;
			for(var i:int=0; i<mdp.length; i++){
				if(mdp.getItemAt(i).idc==idc){
					curSong = i;
					took=true;
					break;
				}
			}
			if(!took)curSong=mdp.length-1;
		}
		
		public function cambiaTocando():void{
			var ocan:Object;
			var unoTocando:Boolean=false;
			for (var i:int=0; i<mdp.length; i++){
				ocan = mdp.getItemAt(i);
				ocan.tocando=false;
				if(ocan.idc==idc){
					ocan.tocando=true;
					unoTocando=true;
				}
			}
			if(!unoTocando){
				eldg.getItemAt(0).tocando=0;
			}
			eldg.validateNow();
		}
		
		public function loadSound(dire:String="",nuevo:Boolean=false,coincide:Boolean=false,externo:Boolean=false):void
		{
			if(nuevo){
				if(mp3Channel!=null)mp3Channel.stop();
				//mp3Player = null;
			}
			
			var ure:URLRequest = new URLRequest();
			intentosDeCarga.dire=dire;
			intentosDeCarga.nuevo=nuevo;
			intentosDeCarga.coincide=coincide;
			intentosDeCarga.externo=externo;
			var ufil:File ;
			if(!intentosDeCarga.numero){
				ure.url = "file:///"+dire;
			}else if(intentosDeCarga.numero==1){
				trace("tratando: "+unescape(dire));
				ufil = new File(unescape(dire));
				ure.url = '';
				if(ufil.exists)ure.url=ufil.url;
			}else if(intentosDeCarga.numero==2){
				trace("tratando: "+unescape(dire));
				ufil = new File(unescape(dire));
				ure.url = '';
				if(ufil.exists)ure.url=ufil.url;
			}else{
				ure.url = "";
			}
			
			mp3Player = new Sound(ure);
			if(!mp3Player.hasEventListener(Event.COMPLETE))mp3Player.addEventListener(Event.COMPLETE,loadHandler);
			if(!mp3Player.hasEventListener(IOErrorEvent.IO_ERROR))mp3Player.addEventListener(IOErrorEvent.IO_ERROR,enNoEncuentra);
			if(!mp3Player.hasEventListener(Event.ID3))mp3Player.addEventListener(Event.ID3,enID3Disponible);
			
			fader_btn.visible=false;
			if(coincide){
				curSong = eldg.selectedIndex;
			}
			var nuevaCancion:Object=eldg.getItemAt(curSong);
			if(externo){
				startEnd.inicio=nuevaCancion.inicio;
				startEnd.fin=nuevaCancion.fin;
			}
			idc = nuevaCancion.idc;
			cambiaTocando();
		}
		
		public function asignaDG(edg:DataGrid):void{
			eldg = edg;
			mdp = eldg.dataProvider;
		}
		
		public function playSound(startTime:Number=0):void
		{
			if( playhilite == null ){
				playhilite = new PlayHiliteSymbol();
				playhilite.x = play_btn.x + 1;
				playhilite.y = play_btn.y + 1;
				playhilite.mouseEnabled = false;
				addChild(playhilite);
				playhilite.visible=false;
			}/*else{
				playhilite.visible = true;
			}*/
			play_btn.activo();
			playing = true;
			mp3Channel = mp3Player.play(startTime);
			mp3Channel.addEventListener(Event.SOUND_COMPLETE,completeHandler);
		}
		
		public function stopSound():void
		{
			playing = false;
			//playhilite.visible = false;
			play_btn.activo(false);
			mp3Channel.stop();
			mp3Channel.removeEventListener(Event.SOUND_COMPLETE,completeHandler);
		}
	}
}