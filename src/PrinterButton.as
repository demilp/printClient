package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class PrinterButton extends Sprite
	{
		private var _isOn : Boolean = true;
		public function get isOn() : Boolean
		{
			return _isOn;
		}
		private var _name : String;
		private var textField : TextField;
		public function get printerName() : String
		{
			return _name;
		}
		public function PrinterButton(name : String)
		{
			_name = name;
			addEventListener(MouseEvent.CLICK, onClick);
			graphics.beginFill(0x00ff00);
			graphics.drawRect(0,0,500, 25);
			graphics.endFill();
			textField = new TextField();
			addChild(textField);
			textField.width = 500;
			textField.text = _name;
			textField.selectable = false;
		}
		private function toggle() : void
		{
			_isOn = !_isOn;
			if(_isOn)
			{
				graphics.beginFill(0x00ff00);
			}
			else
			{
				graphics.beginFill(0xff0000);
			}
			
			graphics.drawRect(0,0,500, 25);
			graphics.endFill();
		}
		private function onClick(e : MouseEvent) : void
		{
			toggle();
		}
	}
}