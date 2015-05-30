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
		
		protected static const SPRITE_INDICES:Vector.<uint> = Vector.<uint>([0, 1, 2, 2, 1, 3,   4, 5, 6, 6, 5, 7]);
		protected static const SPRITE_VERTICES:Vector.<Number> = Vector.<Number>([
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0,
			-0.375, 0.25, 0.0,   0.375, 0.25, 0.0,  -0.375,-0.5, 0.0,   0.375,-0.5, 0.0
		]);
		
		protected static var positionVertexBuffer:VertexBuffer3D;
		protected static var indexBuffer:IndexBuffer3D;
		
		protected var _animationTimer:int = 0;
		protected var _curFrame:int = 0;
		protected var _angle:Number = 0.0;
		//protected var _facing:uint = 0;
		
		public function SpriteBillboard(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(X, Y, Z);

			setTextureIndexTo(TextureIndex);
			setSizeTo(0.75, 0.75, 0.75);
			
			if (!_initialized)
				initBuffers();
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
			var _viewAngle:Number = Math.atan2(dX, dZ) * (180 / Math.PI);
			_m1.appendRotation(_viewAngle, Vector3D.Y_AXIS, _position);
			
			_m1.append(Camera.viewTransform);
			_m1.append(Camera.projectionTransform);
			
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _m1, true);
			
			var _facing:uint = ((_viewAngle - _angle) / 90 + 4) % 4; // TODO: Double-check that this doesn't need an offset
			var _facingFrame:uint = (_facing >= 3) ? 1 : _facing;
			setTextureIndexTo(3 * _facingFrame + TEX_PLAYER_WALK[_curFrame]);
			
			if (_facing < 3)
				_context.drawTriangles(indexBuffer, 0, 2);
			else
				_context.drawTriangles(indexBuffer, 6, 2);
		}
		
		override public function update():void
		{
			_animationTimer += GameTimer.elapsedInMilliseconds;
			
			if (_animationTimer >= 500)
			{
				_animationTimer -= 500;
				_curFrame = (_curFrame + 1) % TEX_PLAYER_WALK.length
			}
		}
		
		public function move(Map:LevelMap, Angle:Number = 0.0, Velocity:Number = 0.0):void
		{
			if (Velocity != 0.0)
			{
				var _angle:Number = (Angle - angle + 90) * (Math.PI / 180);
				var _xComponent:Number = Velocity * Math.cos(_angle);
				var _zComponent:Number = Velocity * Math.sin(_angle);
				var _dirX:int = (_xComponent < 0) ? -1 : 1;
				var _dirZ:int = (_zComponent < 0) ? -1 : 1;
				var _width:Number = 0.5 * _dirX * _size.x;
				var _height:Number = 0.5 * _dirZ * _size.z;
				_xComponent += _width;
				_zComponent += _height;
				
				var _xMax:Number = _xComponent;
				var _zMax:Number = _zComponent;
				
				var _tile:VoxelCube;
				var _x1:Number = Math.round(_position.x);
				var _x2:Number = Math.round(_position.x + _xComponent);
				var _z1:Number = Math.round(_position.z);
				var _z2:Number = Math.round(_position.z + _zComponent);
				
				if (_x1 != _x2)
				{
					_tile = Map.getTileAt(_x2, _z1);
					if (!_tile || _tile.solid) // Player hits the x-boundary of a new tile
						_xMax = (_x1 + 0.5 * _dirX) - _position.x;
				}
				
				if (_z1 != _z2)
				{
					_tile = Map.getTileAt(_x1, _z2);
					if (!_tile || _tile.solid) // Player hits the z-boundary of a new tile
						_zMax = (_z1 + 0.5 * _dirZ) - _position.z;
				}
				
				if (_x1 != _x2 && _z1 != _z2)
				{
					_tile = Map.getTileAt(_x2, _z2);
					if (!_tile || _tile.solid) // Player hits the tile diagonally across
					{
						// TODO: Change this to favor whichever one involves the smallest change in velocity
						if (_xComponent < _zComponent)
							_xMax = (_x1 + 0.5 * _dirX) - _position.x;
						else
							_zMax = (_z1 + 0.5 * _dirZ) - _position.z;
					}
				}
				
				_position.x += _xMax - _width;
				_position.z += _zMax - _height;
			}
		}
		
		public function get angle():Number
		{
			return _angle;
		}
		
		public function set angle(Value:Number):void
		{
			_angle = Value;
			
			if (_angle > 180)
				_angle -= 360;
			else if (_angle < -180)
				_angle += 360;
		}
	}
}