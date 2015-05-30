package
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class MovingSprite extends SpriteBillboard
	{
		protected var _animationTimer:int = 0;
		protected var _curFrame:int = 0;
		protected var _angle:Number = 0.0;
		
		public function MovingSprite(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(TextureIndex, X, Y, Z);
			
			_animationTimer += Math.random() * 500;
		}
		
		override public function update():void
		{
			_animationTimer += GameTimer.elapsedInMilliseconds;
			
			if (_animationTimer >= 500)
			{
				_animationTimer -= 500;
				_curFrame = (_curFrame + 1) % TEX_PLAYER_WALK.length;
			}
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
			
			var _facing:uint = ((_viewAngle - _angle + 225) / 90 + 4) % 4;
			var _facingFrame:uint = (_facing >= 3) ? 1 : _facing;
			setTextureIndexTo(3 * _facingFrame + TEX_PLAYER_WALK[_curFrame]);
			
			if (_facing < 3)
				_context.drawTriangles(indexBuffer, 0, 2);
			else
				_context.drawTriangles(indexBuffer, 6, 2);
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