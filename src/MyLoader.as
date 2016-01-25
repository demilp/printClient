package
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class MyLoader extends Loader
	{
		
		public function MyLoader($callBack:Function = null)
		{
			super();
			
			callBack = $callBack; 
			
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, Complete);
		}
		
		private var callBack:Function;
		
		private var _url:String;
		public var copies : int = 1;
		public function set url(value:String):void {
			
			if (_url != value) {
				_url = value;
				var request:URLRequest = new URLRequest(_url);
				this.load(request); 
			}
		}
		
		protected function Complete(event:Event):void {
			var target:Object = event.target;
			
			if (callBack) {
				callBack.apply(null, [target, copies]);
			}
		}
	}
}