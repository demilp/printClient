package
{
	import flash.printing.PrintJob;
	import flash.utils.Dictionary;

	// ========================================================================

	public class Globals
	{
		// ====================================================================	
		public static var TamanioHoja : String;
		public static var NombreImpresora : String;
		public static var PPI : Number;
		public static var ShowPrintDialog : Boolean;
		public static var Brightness : Number;
		public static var Contrast : Number;
		public static var Saturation : Number;
		public static var Hue : Number;
		public static var Printers : Vector.<String>;
		public static var Rotation : Number;
		public static var ScaleX : Number;
		public static var ScaleY : Number;
	
		public static var CopiasSeguidas : int;
		public static var CalidadJPG : int;
		public static var Port : int;
		public static var Ip : String;
		public static var id : String;
		
		private static var filtros : Dictionary;
		private static var filtros_print : Dictionary;
		
		public static function InicialiazarDatos(XmlData : XML) : void
		{
			switch(String(XmlData.printer.@printerLoadType))
			{
				case "0":
				{
					Printers = PrintJob.printers;
					break;
				}
				case "1":
				{
					Printers = new Vector.<String>();
					for(var i : int = 0; i < XmlData.Names.Name.length(); i++)
					{
						if(XmlData.Names.Name[i] != "")
						{
							Printers.push(XmlData.Names.Name[i]);
						}
					}
					break;
				}
				case "2":
				{
					
					Printers = new Vector.<String>();
					for(var i : int = 0; i < PrintJob.printers.length; i++)
					{
						if(PrintJob.printers[i].indexOf(String(XmlData.Names.Filter)) != -1)
						{
							Printers.push(PrintJob.printers[i]);
						}
					}
					break;
				}					
				default:
				{
					Printers = PrintJob.printers;
					break;
				}
			}
			//Printers = PrintJob.printers;
			
			//trace(XmlData.Names.Name.length());
			CopiasSeguidas = parseInt(XmlData.general.@copias_seguidas);
			Port = parseInt(XmlData.general.@port);
			Ip = String(XmlData.general.@ip);
			id = String(XmlData.general.@bypassId);
			ScaleX = Number(XmlData.printer.@scaleX);
			ScaleY = Number(XmlData.printer.@scaleY);
			Rotation = Number(XmlData.printer.@rotation);
			TamanioHoja = String(XmlData.printer.@paper_size);
			NombreImpresora = String(XmlData.printer.@name);
			PPI = Number(XmlData.printer.@ppi);
			ShowPrintDialog = (String(XmlData.printer.@show_dialog) == "true");
			Brightness = Number(XmlData.printer.@brightness);
			Contrast = Number(XmlData.printer.@contrast);
			Saturation = Number(XmlData.printer.@saturation);
			Hue = Number(XmlData.printer.@hue);
			CalidadJPG = int(XmlData.general.@calidad_jpg);
			
		}
	}
}