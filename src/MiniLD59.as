package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#ff0000")]
	
	public class MiniLD59 extends Sprite
	{
		private var context:Context3D;
		private var program:VoxelProgram;
		private var textureAtlas:TextureAtlas;
		private var camera:ViewpointCamera;
		
		private var moveForward:Boolean = false;
		private var moveBackward:Boolean = false;
		private var moveLeft:Boolean = false;
		private var moveRight:Boolean = false;
		
		private var _pitch:Number = 0.0;
		private var _mouseX:Number = 0.0;
		private var _mouseY:Number = 0.0;
		private var _mouseIsDown:Boolean;
		private var _savePos:Point;
		private var _center:Point;
		
		private var _levelMap:LevelMap;
		private var _player:SpriteBillboard;
		
		public function MiniLD59()
		{
			_center = new Point();
			_savePos = new Point();
			
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
			//context.setCulling(Context3DTriangleFace.BACK);
			
			program = new VoxelProgram(context);
			camera = new ViewpointCamera(1, 0, 1, stage.width, stage.height);
			textureAtlas = new TextureAtlas(context);
			Entity.init(context, program, textureAtlas);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_levelMap = new LevelMap(32, 32);
			_player = new SpriteBillboard(0, 1, 0, 1);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{ 
			if (e.keyCode == Keyboard.W)
				moveForward = true;
			if (e.keyCode == Keyboard.S)
				moveBackward = true;
			if (e.keyCode == Keyboard.A)
				moveLeft = true;
			if (e.keyCode == Keyboard.D)
				moveRight = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{ 
			if (e.keyCode == Keyboard.W)
				moveForward = false;
			if (e.keyCode == Keyboard.S)
				moveBackward = false;
			if (e.keyCode == Keyboard.A)
				moveLeft = false;
			if (e.keyCode == Keyboard.D)
				moveRight = false;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			_mouseX = e.stageX;
			_mouseY = e.stageY;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_mouseIsDown = true;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_mouseIsDown = false;
		}
		
		private function onMousePressed(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_mouseX = stage.mouseX;
			_mouseY = stage.mouseY;
		}
		
		public function set center(value:Point):void
		{
			_center = value;
		}
		
		public function update(ForceTransformation:Boolean = false, RelativeAngle:Number = 0.0, Velocity:Number = 0.0):void
		{
			var x:Number = _center.x - _mouseX;  
			var y:Number  = _center.y - _mouseY;
			var deltaX:Number = _savePos.x - x;
			var deltaY:Number = _savePos.y - y;
			_savePos.setTo(x, y);
			
			if (_mouseIsDown || Velocity != 0.0 || ForceTransformation)
			{
				if (_mouseIsDown)
				{
					_player.angle = _player.angle + deltaX;
					if (_player.angle > 180)
						_player.angle -= 360;
					else if (_player.angle < -180)
						_player.angle += 360;
					
					_pitch = _pitch + deltaY;
					if (_pitch <= -60)
						_pitch = -60;
					else if (_pitch >= 60)
						_pitch = 60;
				}
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			GameTimer.update();
			
			var _angle:Number = 0;
			var _velocity:Number = 0.0;
			if (moveForward != moveBackward || moveLeft != moveRight)
			{
				if (moveForward && !moveBackward)
				{
					_angle = 0;
					if (moveRight && !moveLeft)
						_angle -= 45;
					else if (moveLeft && !moveRight)
						_angle += 45;
				}
				else if (moveBackward && !moveForward)
				{
					_angle = 180;
					if (moveRight && !moveLeft)
						_angle += 45;
					else if (moveLeft && !moveRight)
						_angle -= 45;
				}
				else
				{
					if (moveRight && !moveLeft)
						_angle = -90;
					else if (moveLeft && !moveRight)
						_angle = 90;
				}
				_velocity = 0.075;
			}
			update(false, _angle, _velocity);
			
			_player.move(_levelMap, _angle, _velocity);
			camera.update(_player.angle, _pitch, _player.position);
			
			_levelMap.update();
			_levelMap.render(camera);
			context.present();
		}
	}
}