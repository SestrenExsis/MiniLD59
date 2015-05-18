package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#ff0000")]
	
	public class MiniLD59 extends Sprite
	{
		private var context:Context3D;
		private var program:VoxelProgram;
		private var textureAtlas:TextureAtlas;
		private var camera:ViewpointCamera;
		
		private var _basics:Vector.<VoxelCube>;
		
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
			//context.setCulling(Context3DTriangleFace.BACK);
			
			program = new VoxelProgram(context);
			camera = new ViewpointCamera(0, 0, 0, stage.width, stage.height);
			textureAtlas = new TextureAtlas(context);
			VoxelCube.init(context, program, textureAtlas);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveCamera);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelCamera);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownCamera);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			textureAtlas = new TextureAtlas(context);
			textureAtlas.bitmap.y = 32;
			addChild(textureAtlas.bitmap);
			
			_basics = new Vector.<VoxelCube>();
			
			VoxelCube.init(context, program, textureAtlas);
			var _textureIndex:int;
			var _voxelChunk:VoxelCube;
			for (var x:int = 0; x < 16; x++)
			{
				for (var y:int = 0; y < 3; y++)
				{
					for (var z:int = 0; z < 16; z++)
					{
						if (y == 0)
							_textureIndex = VoxelCube.TEX_BLUE_WALL;
						else if (y == 2)
							_textureIndex = VoxelCube.TEX_GREEN_WALL;
						else
						{
							if (x == 0 || x == 15 || z == 0 || z == 15)
								_textureIndex = VoxelCube.TEX_FLOOR;
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
		
		
		
		private function onMouseMoveCamera(e:MouseEvent):void
		{
			camera.mouseMove(e.stageX, e.stageY);
		}
		
		private function onMouseDownCamera(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpCamera);
			camera.mouseDown();
		}
		
		private function onMouseUpCamera(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressedCamera);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpCamera);
			camera.mouseUp();
		}
		
		private function onMousePressedCamera(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, onMousePressedCamera);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpCamera);
			camera.mouseMove(stage.mouseX, stage.mouseY);
		}
		
		private function onMouseWheelCamera(e:MouseEvent):void
		{
			camera.mouseWheel(e.delta);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
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
			VoxelCube.preRender();
			
			var _voxelChunk:VoxelCube;
			for (var i:int = 0; i < _basics.length; i++)
			{
				_voxelChunk = _basics[i];
				_voxelChunk.renderScene(camera);
			}
			VoxelCube.postRender();
			
			context.present();
			camera.update();
		}
	}
}