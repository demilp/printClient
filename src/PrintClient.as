package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.printing.PaperSize;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.text.TextField;
	
	import fl.motion.AdjustColor;
	
	public class PrintClient extends Sprite
	{
		public var tf : TextField;
		public var socket : SimpleSocket;
		public function PrintClient()
		{
			//clients = new Vector.<Socket>();
			tf = new TextField();
			tf.width = 2048;
			tf.text = "Url imagenes"
			addChild(tf);
			printers = new Vector.<PrinterButton>();
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest("config.xml"));
			
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
		}
		private function xmlLoaded(event:Event):void
		{
			Globals.InicialiazarDatos(new XML(event.target.data));
			socket = new SimpleSocket(Globals.Ip, Globals.Port);
			socket.onData = onData;
			socket.onConnect = onConnect;
			socket.init();
			
			for(var i : int = 0; i < Globals.Printers.length; i++)
			{
				var s : PrinterButton = new PrinterButton(Globals.Printers[i]);
				addChild(s);
				s.y = i * 30 + 20;
				s.x = 5;
				printers.push(s);
			}
		}
		private var printers : Vector.<PrinterButton>;
		private var currentPrinter : int = 0;
		private var buffer:String = "";
		private function onConnect() : void
		{
			socket.sendString("{\"type\":\"register\", \"data\":\"printer"+Globals.id+"\", \"tag\":\"tool\"};");
		}
		private var clients : Vector.<Socket>;
		public function onData(command : String) : void
		{
			tf.text = command;
			trace("Server: " + command);		
			command += buffer;
			var commands : Array = command.split(";");
			buffer = commands[length-1];
			for(var i : int; i < commands.length-1; i++)
			{
				if(commands[i] == "")
				{
					continue;
				}
				var parts : Array = (commands[i] as String).split("@");
				if((parts[0] as String).indexOf("file://") == -1)
				{
					continue;
				}
				try{
					var l : MyLoader = new MyLoader(imageLoaded);
					
					if(parts[1] != "")
					{
						l.copies = parseInt(parts[1]);
					}else
					{
						l.copies = 1;
					}
					l.url = parts[0];
				}catch(e:Error)
				{
					tf.text = "No se pudo encontrar la imagen";
				}				
			}
		}
		
		private function imageLoaded(obj : Object, copies : int) : void
		{
			var s : Sprite = new Sprite();
			s.addChild(Bitmap(obj.content));
			var whole : int = (int)(copies / Globals.CopiasSeguidas);
			var rest : int = copies % Globals.CopiasSeguidas;
			if(whole > 0)
			{
				for (var i:int = 0; i < whole; i++) 
				{
					print(s, Globals.CopiasSeguidas);
				}
			}
			if(rest > 0)
			{
				print(s, rest);
			}
		}
		public function print(sheet1 : Sprite, copies : int) : void
		{
			var cont : Sprite = new Sprite();
			sheet1.rotation = Globals.Rotation;
			
			var color:AdjustColor = new AdjustColor();
			color.brightness = Globals.Brightness;
			color.contrast = Globals.Contrast;
			color.hue = Globals.Hue;  
			color.saturation = Globals.Saturation;
			sheet1.filters = [new ColorMatrixFilter(color.CalculateFinalFlatArray())];
			
			var pj : PrintJob = new PrintJob();
			//pj.copies = copies;
			
			//Si por config no pasan nada, dejo que use la config de impresora default
			//if(Globals.NombreImpresora != "") pj.printer = Globals.NombreImpresora;
			
			cont.graphics.beginFill(0xffffff);
			cont.graphics.drawRect(0,0,pj.pageWidth,pj.pageHeight);
			cont.graphics.endFill();
			
			if(printers.length > 0)
			{
				if(printers[currentPrinter].isOn)
				{
					pj.printer = printers[currentPrinter].printerName;
				}
				else
				{
					var p : String = getNextWorkingPrinter();
					if(p == "")
					{
						return;
					}
					pj.printer = p;
				}
				
			}
			if(Globals.TamanioHoja != "") pj.selectPaperSize(PaperSize[Globals.TamanioHoja]);
			
			//Globals.Loguear("Dimensiones impresora: " + pj.pageWidth + "x" + pj.pageHeight);
			sheet1.width = pj.pageWidth * Globals.ScaleX/100;
			sheet1.height = pj.pageHeight * Globals.ScaleY/100;
			cont.addChild(sheet1);
			sheet1.x += (pj.pageWidth - (pj.pageWidth * Globals.ScaleX/100))/2;
			sheet1.y += (pj.pageHeight - (pj.pageHeight * Globals.ScaleY/100))/2;
			
			var options : PrintJobOptions = new PrintJobOptions();
			options.pixelsPerInch = Globals.PPI;
			options.printAsBitmap = true;
			
			var pagesToPrint:uint = 0;
			if(pj.start2(null, Globals.ShowPrintDialog))
			{
				try 
				{
					for (var i:int = 0; i < copies; i++) 
					{
						pj.addPage(cont, null, options, 1);
						pagesToPrint++;	
					}					
				}
				catch(e:Error)
				{}
				
				if(pagesToPrint > 0)
				{
					pj.send();
					if(printers.length > 0)
					{
						currentPrinter++;
						currentPrinter %= printers.length;
					}
				}
				else
				{
					trace("Printer.printMovieClip - no imprime (no pudo agregar paginas)");
				}
			}
			else
			{
				trace("Printer.printMovieClip - no imprime (no pudo activar impresora)");
			}
			
			
		}
		private function getNextWorkingPrinter() : String
		{
			for(var i : int; i < printers.length; i++)
			{
				if(printers[currentPrinter].isOn)
				{
					return printers[currentPrinter].printerName;
				}
				currentPrinter++
				currentPrinter %= printers.length;
			}
			return "";
		}
		
	}
}