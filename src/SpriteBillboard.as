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
		private static var _initialized:Boolean = false;
		
		protected static const SPRITE_INDICES:Vector.<uint> = Vector.<uint>([0,  1,  2,  2,  1,  3]);
		protected static const SPRITE_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0
		]);
		
		protected static var positionVertexBuffer:VertexBuffer3D;
		protected static var indexBuffer:IndexBuffer3D;
		
		protected var _animationTimer:int = 0;
		protected var _curFrame:int = 0;
		
		public function SpriteBillboard(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(X, Y, Z);
			
			setTextureIndexTo(TextureIndex);
			
			if (!_initialized)
				initBuffers();
		}
		
		public static function initBuffers():void
		{
			positionVertexBuffer = _context.createVertexBuffer(4, 3);
			positionVertexBuffer.uploadFromVector(SPRITE_VERTICES, 0, 4);
			
			indexBuffer = _context.createIndexBuffer(6);
			indexBuffer.uploadFromVector(SPRITE_INDICES, 0, 6);
			
			_initialized = true;
		}
		
		override public function renderScene(Camera:ViewpointCamera):void
		{
			if (_textureIndex < 0)
				return;
			
			_context.setVertexBufferAt(0, positionVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, TextureAtlas.getVertexBuffer(_textureIndex), 0, Context3DVertexBufferFormat.FLOAT_2);
			
			// From worldSpace to cameraSpace
			_m1.identity();
			_m1.appendTranslation(_position.x, _position.y, _position.z);
			
			// Use billboarding to force the Entity to face the camera
			var dX:Number = _position.x - Camera._position.x;
			var dZ:Number = _position.z - Camera._position.z;
			var _angle:Number = Math.atan2(dX, dZ) * (180 / Math.PI);
			_m1.appendRotation(_angle, Vector3D.Y_AXIS, _position);
			
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			_context.drawTriangles(indexBuffer);
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
	}
}