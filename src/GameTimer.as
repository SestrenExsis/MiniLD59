package
{
	import flash.utils.getTimer;
	
	public class GameTimer
	{
		protected static var _lastTime:int = 0;
		protected static var _currentTime:int = 0;
		protected static var _elapsedInMilliseconds:int = 0;
		protected static var _elapsedInSeconds:Number = 0.0;
		
		public function GameTimer()
		{
			
		}
		
		public static function update():void
		{
			_lastTime = _currentTime;
			_currentTime = getTimer();
			
			_elapsedInMilliseconds = _currentTime - _lastTime;
			_elapsedInSeconds = _elapsedInMilliseconds / 1000;
		}
		
		public static function get elapsedInMilliseconds():int
		{
			return _elapsedInMilliseconds;
		}
		
		public static function get elapsedInSeconds():int
		{
			return _elapsedInSeconds;
		}
	}
}