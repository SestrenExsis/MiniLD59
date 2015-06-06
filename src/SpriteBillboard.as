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
	
	public class SpriteBillboard extends Entity
	{
		private static var _initialized:Boolean = false;
		
		protected static const SPRITE_INDICES:Vector.<uint> = Vector.<uint>([0, 1, 2, 2, 1, 3,   4, 5, 6, 6, 5, 7]);
		protected static const SPRITE_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0,
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0
		]);
		protected static var positionVertexBuffer:VertexBuffer3D;
		protected static var indexBuffer:IndexBuffer3D;
		
		public static const TYPE_PLAYER:int = 0;
		public static const TYPE_ENEMY:int = 1;
		public static const TYPE_BULLET:int = 2;
		
		protected var _spriteType:int = -1;
		
		public function SpriteBillboard(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0, SpriteType:int = -1)
		{
			super(X, Y, Z);

			setTextureIndexTo(TextureIndex);
			size = 0.75;
			_spriteType = SpriteType;
			
			if (!_initialized)
				initBuffers();
		}
		
		public function get spriteType():int
		{
			return _spriteType;
		}
		
		public function set spriteType(Value:int):void
		{
			_spriteType = Value;
		}
		
		public static function initBuffers():void
		{
			positionVertexBuffer = _context.createVertexBuffer(8, 3);
			positionVertexBuffer.uploadFromVector(SPRITE_VERTICES, 0, 8);
			
			indexBuffer = _context.createIndexBuffer(12);
			indexBuffer.uploadFromVector(SPRITE_INDICES, 0, 12);
			
			_initialized = true;
		}
		
		override public function renderScene(Camera:ViewpointCamera):void
		{
			if (_textureIndex < 0 || !visible)
				return;
			
			_context.setVertexBufferAt(0, positionVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, TextureAtlas.getVertexBuffer(_textureIndex), 0, Context3DVertexBufferFormat.FLOAT_2);
			
			// From worldSpace to cameraSpace
			_m1.identity();
			_m1.appendTranslation(_position.x, _position.y, _position.z);
			
			// Use billboarding to force the Entity to face the camera
			var dX:Number = _position.x - Camera._position.x;
			var dZ:Number = _position.z - Camera._position.z;
			var _viewAngle:Number = Math.atan2(dX, dZ) * (180 / Math.PI);
			_m1.appendRotation(_viewAngle, Vector3D.Y_AXIS, _position);
			
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			_context.drawTriangles(indexBuffer, 0, 2);
		}
		
		override public function update(Map:LevelMap = null):void
		{
			
		}
		
		public function overlaps(OtherSprite:SpriteBillboard):Boolean
		{
			var _distance:Number = Vector3D.distance(position, OtherSprite.position);
			if (_distance < (0.5 * size + 0.5 * OtherSprite.size))
			{
				if ((spriteType == TYPE_BULLET) && (OtherSprite.spriteType == TYPE_ENEMY))
					OtherSprite.visible = false;
				else if ((spriteType == TYPE_ENEMY) && (OtherSprite.spriteType == TYPE_BULLET))
					visible = false;
				return true;
			}
			else
				return false;
		}
	}
}