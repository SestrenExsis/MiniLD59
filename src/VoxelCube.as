package
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class VoxelCube extends Entity
	{
		private static var _initialized:Boolean = false;
		
		protected static const CUBE_FILL_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.5,-0.5,-0.5,   0.5,-0.5,-0.5,  -0.5,-0.5, 0.5,   0.5,-0.5, 0.5, // Top Face: 0, 1, 2, 3
			-0.5,-0.5, 0.5,   0.5,-0.5, 0.5,  -0.5, 0.5, 0.5,   0.5, 0.5, 0.5, // South Face: 4, 5, 6, 7
			-0.5, 0.5, 0.5,   0.5, 0.5, 0.5,  -0.5, 0.5,-0.5,   0.5, 0.5,-0.5, // Bottom Face: 8, 9, 10, 11
			-0.5,-0.5,-0.5,  -0.5,-0.5, 0.5,  -0.5, 0.5,-0.5,  -0.5, 0.5, 0.5, // West Face: 12, 13, 14, 15
			 0.5,-0.5,-0.5,  -0.5,-0.5,-0.5,   0.5, 0.5,-0.5,  -0.5, 0.5,-0.5, // North Face: 16, 17, 18, 19
			 0.5,-0.5, 0.5,   0.5,-0.5,-0.5,   0.5, 0.5, 0.5,   0.5, 0.5,-0.5  // East Face: 20, 21, 22, 23
		]);
		protected static const CUBE_EMPTY_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.5,-0.5, 0.5,   0.5,-0.5, 0.5,  -0.5,-0.5,-0.5,   0.5,-0.5,-0.5, // Top Face: 0, 1, 2, 3
			-0.5, 0.5,-0.5,   0.5, 0.5,-0.5,  -0.5, 0.5, 0.5,   0.5, 0.5, 0.5  // Bottom Face: 4, 5, 6, 7
		]);
		protected static const CUBE_FILL_INDICES:Vector.<uint> = Vector.<uint>([ //
			 0,  1,  2,  2,  1,  3, // Top
			 4,  5,  6,  6,  5,  7, // Front
			 8,  9, 10, 10,  9, 11, // Bottom
			12, 13, 14, 14, 13, 15, // Right
			16, 17, 18, 18, 17, 19, // Back
			20, 21, 22, 22, 21, 23  // Left
		]);
		protected static const CUBE_EMPTY_INDICES:Vector.<uint> = Vector.<uint>([ //
			0,  1,  2,  2,  1,  3, // Top
			4,  5,  6,  6,  5,  7  // Bottom
		]);
		
		protected static var fillPositionVertexBuffer:VertexBuffer3D;
		protected static var emptyPositionVertexBuffer:VertexBuffer3D;
		protected static var fillIndexBuffer:IndexBuffer3D;
		protected static var emptyIndexBuffer:IndexBuffer3D;
		
		public function VoxelCube(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(X, Y, Z);
			
			setTextureIndexTo(TextureIndex);
			
			if (!_initialized)
				initBuffers();
		}
		
		public function get solid():Boolean
		{
			return _textureIndex >= 0;
		}
		
		public static function initBuffers():void
		{
			fillPositionVertexBuffer = _context.createVertexBuffer(24, 3);
			fillPositionVertexBuffer.uploadFromVector(CUBE_FILL_VERTICES, 0, 24);
			
			emptyPositionVertexBuffer = _context.createVertexBuffer(8, 3);
			emptyPositionVertexBuffer.uploadFromVector(CUBE_EMPTY_VERTICES, 0, 8);
			
			fillIndexBuffer = _context.createIndexBuffer(36);
			fillIndexBuffer.uploadFromVector(CUBE_FILL_INDICES, 0, 36);
			
			emptyIndexBuffer = _context.createIndexBuffer(12);
			emptyIndexBuffer.uploadFromVector(CUBE_EMPTY_INDICES, 0, 12);
			
			_initialized = true;
		}
		
		override public function renderScene(Camera:ViewpointCamera):void
		{
			var _positionVertexBuffer:VertexBuffer3D;
			var _indexBuffer:IndexBuffer3D;
			if (_textureIndex >= 0)
			{
				_positionVertexBuffer = fillPositionVertexBuffer;
				_indexBuffer = fillIndexBuffer;
			}
			else
			{
				_positionVertexBuffer = emptyPositionVertexBuffer;
				_indexBuffer = emptyIndexBuffer;
			}
			
			_context.setVertexBufferAt(0, _positionVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, TextureAtlas.getVertexBuffer(_textureIndex), 0, Context3DVertexBufferFormat.FLOAT_2);
			
			// From worldSpace to cameraSpace
			_m1.identity();
			_m1.appendTranslation(_position.x, _position.y, _position.z);
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			_context.drawTriangles(_indexBuffer);
		}
	}
}