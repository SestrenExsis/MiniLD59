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
	
	public class Entity
	{
		protected static var _textureAtlas:TextureAtlas;
		protected static var _context:Context3D;
		protected static var _program:VoxelProgram;
		protected static var _m1:Matrix3D;
		
		public static const TEX_BLUE_WALL:uint = 48;
		public static const TEX_GREEN_WALL:uint = 52;
		public static const TEX_CEILING:uint = 47;
		public static const TEX_FLOOR:uint = 39;
		public static const TEX_PLAYER_WALK:Vector.<uint> = Vector.<uint>([1, 2]);
		
		protected var _position:Vector3D;
		protected var _textureIndex:int = -2;
		
		protected var _textureVertices:Vector.<Number>;
		protected var _textureVertBuf:VertexBuffer3D;
		protected var _positionVertBuf:VertexBuffer3D;
		protected var _indexBuf:IndexBuffer3D;
		
		public function Entity(X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			_position = new Vector3D(X, Y, Z);
		}
		
		public static function init(Context:Context3D, Program:VoxelProgram, TextureAtlasA:TextureAtlas):void
		{
			_context = Context;
			_program = Program;
			_m1 = new Matrix3D();
			_textureAtlas = TextureAtlasA;
		}
		
		/**
		 * Call once each frame before rendering of any Entity instances.
		 */
		public static function preRender():void
		{
			_program.program = VoxelProgram.PROGRAM_SIMPLE;
			_context.setTextureAt(0, _textureAtlas.texture);
			_context.setRenderToBackBuffer();
			_context.clear(0.4, 0.0, 0.0, 1.0);
			_context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
		}
		
		/**
		 * Call once each frame after rendering of all Entity instances.
		 */
		public static function postRender():void
		{
			_context.setTextureAt(0, null);
			_context.setVertexBufferAt(0, null);
			_context.setVertexBufferAt(1, null);
		}
		
		public function renderScene(Camera:ViewpointCamera, FaceCamera:Boolean = false):void
		{
			if (_textureIndex < 0)
				return;
			
			_context.setVertexBufferAt(0, _positionVertBuf, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _textureVertBuf, 0, Context3DVertexBufferFormat.FLOAT_2);
			
			// From worldSpace to cameraSpace
			_m1.identity();
			_m1.appendTranslation(_position.x, _position.y, _position.z);
			
			// Use billboarding to force the Entity to face the camera
			if (FaceCamera)
			{
				var dX:Number = _position.x - Camera._position.x;
				var dZ:Number = _position.z - Camera._position.z;
				var _angle:Number = Math.atan2(dX, dZ) * (180 / Math.PI);
				_m1.appendRotation(_angle, Vector3D.Y_AXIS, _position);
			}
			
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			_context.drawTriangles(_indexBuf);
		}
		
		public function update():void
		{
			
		}
		
		public function getCameraDistance(Camera:ViewpointCamera):Number
		{
			var cameraPosition:Vector3D = Camera.viewTransform.position;
			return Vector3D.distance(cameraPosition, _position);
		}
		
		public function get textureIndex():int
		{
			return _textureIndex;
		}
		
		public function setTextureIndexTo(TextureIndex:int):void
		{
			if (TextureIndex == _textureIndex)
				return;
			
			_textureIndex = TextureIndex;
		}
	}
}