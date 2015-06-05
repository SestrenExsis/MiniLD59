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
		public var isEnemy:Boolean = false;
		public var angularVelocity:Number = 0.0;
		
		public function MovingSprite(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0, IsEnemy:Boolean = false)
		{
			super(TextureIndex, X, Y, Z);
			
			_animationTimer += Math.random() * 500;
			isEnemy = IsEnemy;
		}
		
		override public function update(Map:LevelMap = null):void
		{
			_animationTimer += GameTimer.elapsedInMilliseconds;
			
			if (_animationTimer >= 500)
			{
				_animationTimer -= 500;
				_curFrame = (_curFrame + 1) % TEX_PLAYER_WALK.length;
			}
			
			if (isEnemy && Map)
			{
				var _angularAcceleration:Number = Math.random() - 0.5;
				_angularAcceleration *= (angularVelocity > 5 || angularVelocity < -5) ? 0.0 : 1.0;
				angularVelocity += _angularAcceleration;
				angle += angularVelocity;
				move(Map, 0, 0.05);
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
			
			var _facing:uint = ((_viewAngle - angle + 225) / 90 + 4) % 4;
			var _facingFrame:uint = (_facing >= 3) ? 1 : _facing;
			setTextureIndexTo(3 * _facingFrame + TEX_PLAYER_WALK[_curFrame]);
			
			if (_facing < 3)
				_context.drawTriangles(indexBuffer, 0, 2);
			else
				_context.drawTriangles(indexBuffer, 6, 2);
		}
		
		
	}
}