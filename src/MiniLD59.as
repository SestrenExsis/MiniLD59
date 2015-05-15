package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.events.Event;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#ff0000")]
	
	public class MiniLD59 extends Sprite
	{
		private var context:Context3D;
		private var textureAtlas:TextureAtlas;
		
		public function MiniLD59()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			if(e)
				removeEventListener(e.type, arguments.callee);
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, contextGained);
			stage.stage3Ds[0].requestContext3D("auto");
		}
		
		private function contextGained(e:Event):void
		{
			context = e.target.context3D;
			context.enableErrorChecking = true;
			context.configureBackBuffer(640, 480, 0, true);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			textureAtlas = new TextureAtlas(context);
			textureAtlas.bitmap.y = 32;
			addChild(textureAtlas.bitmap);
		}
		
		private function onEnterFrame(e:Event):void
		{
			context.clear(0.9, 0.9, 0.9);
			context.present();
		}
	}
}