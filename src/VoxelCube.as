package
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class VoxelCube
	{
		protected static var _textureAtlas:TextureAtlas;
		protected static var _context:Context3D;
		protected static var _program:VoxelProgram;
		protected static var _m1:Matrix3D;
		protected static const CUBE_INDICES:Vector.<uint> = Vector.<uint>([ //
			 0,  1,  2,  2,  1,  3, // Top
			 4,  5,  6,  6,  5,  7, // Front
			 8,  9, 10, 10,  9, 11, // Bottom
			12, 13, 14, 14, 13, 15, // Right
			16, 17, 18, 18, 17, 19, // Back
			20, 21, 22, 22, 21, 23  // Left
		]);
		protected static const CUBE_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.5,-0.5,-0.5,   0.5,-0.5,-0.5,  -0.5,-0.5, 0.5,   0.5,-0.5, 0.5, // Top Face: 0, 1, 2, 3
			-0.5,-0.5, 0.5,   0.5,-0.5, 0.5,  -0.5, 0.5, 0.5,   0.5, 0.5, 0.5, // South Face: 4, 5, 6, 7
			-0.5, 0.5, 0.5,   0.5, 0.5, 0.5,  -0.5, 0.5,-0.5,   0.5, 0.5,-0.5, // Bottom Face: 8, 9, 10, 11
			-0.5,-0.5,-0.5,  -0.5,-0.5, 0.5,  -0.5, 0.5,-0.5,  -0.5, 0.5, 0.5, // West Face: 12, 13, 14, 15
			 0.5,-0.5,-0.5,  -0.5,-0.5,-0.5,   0.5, 0.5,-0.5,  -0.5, 0.5,-0.5, // North Face: 16, 17, 18, 19
			 0.5,-0.5, 0.5,   0.5,-0.5,-0.5,   0.5, 0.5, 0.5,   0.5, 0.5,-0.5  // East Face: 20, 21, 22, 23
		]);
		
		public static const TEX_BLUE_WALL:uint = 48;
		public static const TEX_GREEN_WALL:uint = 52;
		public static const TEX_CEILING:uint = 47;
		public static const TEX_FLOOR:uint = 39;
		
		protected var _position:Vector3D;
		protected var _textureIndex:int = -2;
		
		protected var _textureVertices:Vector.<Number>;
		protected var _textureVertBuf:VertexBuffer3D;
		protected var _positionVertBuf:VertexBuffer3D;
		protected var _indexBuf:IndexBuffer3D;
		
		public function VoxelCube(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			_position = new Vector3D(X, Y, Z);
			textureIndex = TextureIndex;
			
			_positionVertBuf = _context.createVertexBuffer(24, 3);
			_positionVertBuf.uploadFromVector(CUBE_VERTICES, 0, 24);
			
			_indexBuf = _context.createIndexBuffer(36);
			_indexBuf.uploadFromVector(CUBE_INDICES, 0, 36);
		}
		
		public static function init(Context:Context3D, Program:VoxelProgram, TextureAtlasA:TextureAtlas):void
		{
			_context = Context;
			_program = Program;
			_m1 = new Matrix3D();
			_textureAtlas = TextureAtlasA;
		}
		
		public static function preRender():void
		{
			_program.program = VoxelProgram.PROGRAM_SIMPLE;
			_context.setTextureAt(0, _textureAtlas.texture);
			_context.setRenderToBackBuffer();
			_context.clear(0.4, 0.0, 0.0, 1.0);
		}
		
		public static function postRender():void
		{
			_context.setTextureAt(0, null);
			_context.setVertexBufferAt(0, null);
			_context.setVertexBufferAt(1, null);
		}
		
		public function renderScene(Camera:ViewpointCamera):void
		{
			if (_textureIndex < 0)
				return;
			
			_context.setVertexBufferAt(0, _positionVertBuf, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _textureVertBuf, 0, Context3DVertexBufferFormat.FLOAT_2);
			
			// From worldSpace to cameraSpace
			_m1.identity();
			_m1.appendTranslation(_position.x, _position.y, _position.z);
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			_context.drawTriangles(_indexBuf);
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
		
		public function set textureIndex(Value:int):void
		{
			if (Value == _textureIndex)
				return;
			
			_textureIndex = Value;
			_textureVertices = new Vector.<Number>();
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureAtlas.pushUVCoordinatesToVector(_textureVertices, _textureIndex);
			_textureVertBuf = _context.createVertexBuffer(24, 2);
			_textureVertBuf.uploadFromVector(_textureVertices, 0, 24);
		}
	}
}