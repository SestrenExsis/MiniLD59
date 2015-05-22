package
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class SpriteBillboard extends Entity
	{
		protected static const SPRITE_INDICES:Vector.<uint> = Vector.<uint>([0,  1,  2,  2,  1,  3]);
		protected static const SPRITE_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0
		]);
		
		protected var _animationTimer:int = 0;
		protected var _curFrame:int = 0;
		
		public function SpriteBillboard(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(X, Y, Z);
			
			setTextureIndexTo(TextureIndex);
			
			_positionVertBuf = _context.createVertexBuffer(4, 3);
			_positionVertBuf.uploadFromVector(SPRITE_VERTICES, 0, 4);
			
			_indexBuf = _context.createIndexBuffer(6);
			_indexBuf.uploadFromVector(SPRITE_INDICES, 0, 6);
		}
		
		override public function renderScene(Camera:ViewpointCamera, FaceCamera:Boolean = true):void
		{
			super.renderScene(Camera, true);
		}
		
		override public function update():void
		{
			_animationTimer += GameTimer.elapsedInMilliseconds;
			
			if (_animationTimer >= 500)
			{
				_animationTimer -= 500;
				_curFrame = (_curFrame + 1) % TEX_PLAYER_WALK.length
				setTextureIndexTo(TEX_PLAYER_WALK[_curFrame]);
			}
		}
		
		override public function setTextureIndexTo(TextureIndex:int):void
		{
			super.setTextureIndexTo(TextureIndex);
			
			_textureVertices = new Vector.<Number>();
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureVertBuf = _context.createVertexBuffer(4, 2);
			_textureVertBuf.uploadFromVector(_textureVertices, 0, 4);
		}
	}
}