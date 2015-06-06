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
		
		protected var _textureVertices:Vector.<Number>;
		protected var _textureVertBuf:VertexBuffer3D;
		
		protected var _size:Number = 1.0;
		protected var _position:Vector3D; // The w value is used to store facing angle in the XZ plane.
		protected var _targetPosition:Vector3D;
		protected var _moveSpeed:Number;
		protected var _rotationSpeed:Number;
		
		protected var _textureIndex:int = -2;
		protected var _frameIndex:int = 0;
		protected var _frameTimer:Number = 0;
		
		public var visible:Boolean = true;
		public var _cameraDistance:Number = 0.0;
		
		public function Entity(X:Number = 0.0, Y:Number = 0.0, Z:Number = 0.0, Angle:Number = 0.0)
		{
			_position = new Vector3D(X, Y, Z, Angle);
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
			if (!visible)
				return;
		}
		
		public function update(Map:LevelMap = null):void
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
		
		public function get size():Number
		{
			return _size;
		}
		
		public function set size(Value:Number):void
		{
			_size = Value;
		}
		
		public function get angle():Number
		{
			return _position.w;
		}
		
		public function set angle(Value:Number):void
		{
			position.w = Value;
			
			if (Value > 180)
				position.w -= 360;
			else if (Value < -180)
				position.w += 360;
		}
		
		public function move(Map:LevelMap, RelativeAngle:Number = 0.0, Velocity:Number = 0.0, IgnoreSliding:Boolean = false):Boolean
		{
			if (Velocity == 0.0)
				return false;
			
			var _trueAngle:Number = (RelativeAngle - angle + 90) * (Math.PI / 180);
			var _xComponent:Number = Velocity * Math.cos(_trueAngle);
			var _zComponent:Number = Velocity * Math.sin(_trueAngle);
			var _dirX:int = (_xComponent < 0) ? -1 : 1;
			var _dirZ:int = (_zComponent < 0) ? -1 : 1;
			var _width:Number = 0.5 * _dirX * _size;
			var _height:Number = 0.5 * _dirZ * _size;
			_xComponent += _width;
			_zComponent += _height;
			
			var _xMax:Number = _xComponent;
			var _zMax:Number = _zComponent;
			
			var _tile:VoxelCube;
			var _x1:Number = Math.round(_position.x);
			var _x2:Number = Math.round(_position.x + _xComponent);
			var _z1:Number = Math.round(_position.z);
			var _z2:Number = Math.round(_position.z + _zComponent);
			var _completion:Number = 1.0;
			
			if (_x1 != _x2)
			{
				_tile = Map.getTileAt(_x2, _z1);
				if (!_tile || _tile.solid) // Player hits the x-boundary of a new tile
				{
					_xMax = (_x1 + 0.5 * _dirX) - _position.x;
					_completion = _xMax / _xComponent;
				}
			}
			
			if (_z1 != _z2)
			{
				_tile = Map.getTileAt(_x1, _z2);
				if (!_tile || _tile.solid) // Player hits the z-boundary of a new tile
				{
					_zMax = (_z1 + 0.5 * _dirZ) - _position.z;
					_completion = Math.min(_completion, _zMax / _zComponent);
				}
			}
			
			if (_x1 != _x2 && _z1 != _z2)
			{
				_tile = Map.getTileAt(_x2, _z2);
				if (!_tile || _tile.solid) // Player hits the tile diagonally across
				{
					// TODO: Change this to favor whichever one involves the smallest change in velocity
					if (_xComponent < _zComponent)
					{
						_xMax = Math.min(_xMax,(_x1 + 0.5 * _dirX) - _position.x);
						_completion = Math.min(_completion, _xMax / _xComponent);
					}
					else
					{
						_zMax = Math.min(_zMax,(_z1 + 0.5 * _dirZ) - _position.z);
						_completion = Math.min(_completion, _zMax / _zComponent);
					}
				}
			}
			
			if (IgnoreSliding && _completion < 1.0)
			{
				_xMax = _completion * _xComponent;
				_zMax = _completion * _zComponent;
			}
			_position.x += _xMax - _width;
			_position.z += _zMax - _height;
			
			return _completion < 1.0;
		}
	}
}