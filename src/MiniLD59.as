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
		
		private var _basics:Vector.<VoxelCube>;
		private var _sprites:Vector.<SpriteBillboard>;
		
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
			context.setCulling(Context3DTriangleFace.BACK);
			
			program = new VoxelProgram(context);
			camera = new ViewpointCamera(1, 1, 1, stage.width, stage.height);
			textureAtlas = new TextureAtlas(context);
			Entity.init(context, program, textureAtlas);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_basics = new Vector.<VoxelCube>();
			_sprites = new Vector.<SpriteBillboard>();
			
			_sprites.push(new SpriteBillboard(Entity.TEX_PLAYER_WALK[0], 3, 1, 3));
			_sprites.push(new SpriteBillboard(Entity.TEX_PLAYER_WALK[0], 3, 1, 6));
			_sprites.push(new SpriteBillboard(Entity.TEX_PLAYER_WALK[0], 6, 1, 3));
			_sprites.push(new SpriteBillboard(Entity.TEX_PLAYER_WALK[0], 6, 1, 6));
			
			var _textureIndex:int;
			var _voxelChunk:VoxelCube;
			for (var x:int = 0; x < 16; x++)
			{
				for (var y:int = 0; y < 3; y++)
				{
					for (var z:int = 0; z < 16; z++)
					{
						if (y == 0)
							_textureIndex = Entity.TEX_BLUE_WALL;
						else if (y == 2)
							_textureIndex = Entity.TEX_GREEN_WALL;
						else
						{
							if (x == 0 || x == 15 || z == 0 || z == 15)
								_textureIndex = Entity.TEX_FLOOR;
							else
								_textureIndex = -1;
						}
						if (_textureIndex >= 0)
						{
							_voxelChunk = new VoxelCube(_textureIndex, x, y, z);
							_basics.push(_voxelChunk);
						}
					}
				}
			}
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
			camera.mouseMove(e.stageX, e.stageY);
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			camera.mouseDown();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			camera.mouseUp();
		}
		
		private function onMousePressed(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			camera.mouseMove(stage.mouseX, stage.mouseY);
		}
		
		private function sortingFunction(ChunkA:VoxelCube, ChunkB:VoxelCube):Number
		{
			var chunkADistance:Number = ChunkA.getCameraDistance(camera);
			var chunkBDistance:Number = ChunkB.getCameraDistance(camera);
			if (chunkADistance < chunkBDistance) return -1;
			else if (chunkADistance > chunkBDistance) return 1;
			else return 0;
		}
		
		private function onEnterFrame(e:Event):void
		{
			GameTimer.update();
			
			var i:int;
			Entity.preRender();
			var _voxelCube:VoxelCube;
			for (i = 0; i < _basics.length; i++)
			{
				_voxelCube = _basics[i];
				_voxelCube.renderScene(camera);
			}
			
			var _sprite:SpriteBillboard;
			for (i = 0; i < _sprites.length; i++)
			{
				_sprite = _sprites[i];
				_sprite.update();
				_sprite.renderScene(camera);
			}
			Entity.postRender();
			
			context.present();
			
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
				_velocity = 0.125;
			}
			camera.update(false, _angle, _velocity);
		}
	}
}