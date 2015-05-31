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
		
		public static const TEX_EMPTY_FLOOR:int = -1;
		public static const TEX_LIT_FLOOR:int = -2;
		public static const TEX_BROWN_WALL:int = 40;
		public static const TEX_WOOD:int = 41;
		public static const TEX_GRAY_STONE:int = 48;
		public static const TEX_BROWN_STONE:int = 49;
		public static const TEX_MOSSY_STONE:int = 50;
		public static const TEX_BLUE_STONE:int = 51;
		public static const TEX_PILLAR:int = 56;
		//public static const TEX_CEILING_LAMP:int = 47;
		//public static const TEX_FLOOR:int = 39;
		public static const TEX_PLAYER_WALK:Vector.<int> = Vector.<int>([1, 2]);
		
		protected var _position:Vector3D;
		protected var _textureIndex:int = -2;
		protected var _textureVertices:Vector.<Number>;
		protected var _textureVertBuf:VertexBuffer3D;
		protected var _size:Vector3D;
		
		public var _cameraDistance:Number = 0.0;
		
		public function Entity(X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			_position = new Vector3D(X, Y, Z);
			_size = new Vector3D(1.0, 1.0, 1.0);
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
		
		public function renderScene(Camera:ViewpointCamera):void
		{
			
		}
		
		public function update():void
		{
			
		}
		
		public function getCameraDistance(Camera:ViewpointCamera):Number
		{
			var cameraPosition:Vector3D = Camera.position;
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
		
		public function get position():Vector3D
		{
			return _position;
		}
		
		public function get size():Vector3D
		{
			return _size;
		}
		
		public function setSizeTo(X:Number = 1.0, Y:Number = 1.0, Z:Number = 1.0):void
		{
			_size.setTo(X, Y, Z);
		}
	}
}