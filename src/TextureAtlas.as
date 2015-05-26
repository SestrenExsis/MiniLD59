package
{
	import com.adobe.utils.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class TextureAtlas
	{
		[Embed(source = "../assets/images/Default.png" )] protected static var textureClass:Class;
		
		private static const ATLAS_WIDTH_IN_TEXTURES:uint = 8;
		private static const ATLAS_HEIGHT_IN_TEXTURES:uint = 8;
		
		public static const PLAYER:Array = [0, 1, 2, 3, 4, 5, 6, 7, 8];
		public static const ENEMY_A:Array = [9, 10, 11, 12, 13, 14, 15, 16, 17];
		public static const ENEMY_B:Array = [18, 19, 20, 21, 22, 23, 24, 25, 26];
		public static const ITEMS:Array = [27, 28, 29, 30, 31];
		public static const BLOCKS_A:Array = [32, 33, 34, 35, 36, 37, 38];
		public static const BLOCKS_B:Array = [40, 41, 42, 43, 44, 45, 46];
		public static const WALLS_A:Array = [48, 49, 50, 51];
		public static const WALLS_B:Array = [52, 53, 54, 55];
		public static const FLOORS:Array = [39, 58, 59, 60, 61, 62];
		public static const CEILINGS:Array = [47, 58, 59, 60, 61, 62];
		
		protected static var _wallVertexBuffers:Vector.<VertexBuffer3D>;
		protected static var _floorVertexBuffers:Vector.<VertexBuffer3D>;
		protected static var _context:Context3D;
		protected var _bitmap:Bitmap;
		protected var _texture:Texture;
		
		public function TextureAtlas(Context:Context3D)
		{
			_context = Context;
			_bitmap = new textureClass() as Bitmap;
			
			var _bitmapData:BitmapData = _bitmap.bitmapData;
			_texture = _context.createTexture(_bitmapData.width, _bitmapData.height, Context3DTextureFormat.BGRA, false);
			_texture.uploadFromBitmapData(_bitmapData);
			
			_wallVertexBuffers = new Vector.<VertexBuffer3D>();
			
			var _textureCount:int = ATLAS_WIDTH_IN_TEXTURES * ATLAS_HEIGHT_IN_TEXTURES;
			var _spriteCount:int = 0.5 * _textureCount;
			var _textureVertices:Vector.<Number>;
			var _textureVertBuf:VertexBuffer3D;
			for (var i:int = 0; i < _textureCount; i++)
			{
				_textureVertices = new Vector.<Number>();
				if (i < _spriteCount)
				{
					pushUVCoordinatesToVector(_textureVertices, i);
					_textureVertBuf = _context.createVertexBuffer(4, 2);
					_textureVertBuf.uploadFromVector(_textureVertices, 0, 4);
				}
				else
				{
					pushUVCoordinatesToVector(_textureVertices, i);
					pushUVCoordinatesToVector(_textureVertices, i);
					pushUVCoordinatesToVector(_textureVertices, i);
					pushUVCoordinatesToVector(_textureVertices, i);
					pushUVCoordinatesToVector(_textureVertices, i);
					pushUVCoordinatesToVector(_textureVertices, i);
					
					_textureVertBuf = _context.createVertexBuffer(24, 2);
					_textureVertBuf.uploadFromVector(_textureVertices, 0, 24);
				}
				
				_wallVertexBuffers.push(_textureVertBuf);
			}
			
			_floorVertexBuffers = new Vector.<VertexBuffer3D>();
			
			var _floorVertexBuffer:VertexBuffer3D;
			for (i = 0; i < Math.min(FLOORS.length, CEILINGS.length); i++)
			{
				_textureVertices = new Vector.<Number>();
				pushUVCoordinatesToVector(_textureVertices, FLOORS[i]);
				pushUVCoordinatesToVector(_textureVertices, CEILINGS[i]);
				_floorVertexBuffer = _context.createVertexBuffer(8, 2);
				_floorVertexBuffer.uploadFromVector(_textureVertices, 0, 8);
				_floorVertexBuffers.push(_floorVertexBuffer);
			}
		}
		
		public static function getVertexBuffer(TextureIndex:int):VertexBuffer3D
		{
			if (TextureIndex >= 0)
				return _wallVertexBuffers[TextureIndex];
			return _floorVertexBuffers[(-1 * TextureIndex) - 1];
		}
		
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}
		
		public function get texture():Texture
		{
			return _texture;
		}
		
		public function pushUVCoordinatesToVector(Textures:Vector.<Number>, TextureIndex:uint, FlipHorizontal:Boolean = false):void
		{
			var _xComponent:uint = TextureIndex % ATLAS_WIDTH_IN_TEXTURES;
			var _yComponent:uint = TextureIndex / ATLAS_WIDTH_IN_TEXTURES;
			var _w:Number = 1 / ATLAS_WIDTH_IN_TEXTURES;
			var _h:Number = 1 / ATLAS_HEIGHT_IN_TEXTURES;
			
			var _x0:Number = _w * _xComponent;
			var _x1:Number = _x0 + _w;
			var _y0:Number = _h * _yComponent;
			var _y1:Number = _y0 + _h;
			
			if (FlipHorizontal)
				Textures.push(_x1, _y0, _x0, _y0, _x1, _y1, _x0, _y1);
			else
				Textures.push(_x0, _y0, _x1, _y0, _x0, _y1, _x1, _y1);
		}
	}
}