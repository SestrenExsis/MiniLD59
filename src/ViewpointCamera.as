package
{
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class ViewpointCamera
	{
		protected var _projectionTransform:PerspectiveMatrix3D;
		protected var _viewTransform:Matrix3D;
		protected var _lookAtTransform:Matrix3D;
		public var _mouseX:Number = 0;
		public var _mouseY:Number = 0;
		protected var _mouseIsDown:Boolean;
		protected var _savePos:Point;
		protected var _center:Point;
		
		public var _position:Vector3D;
		public var _velocity:Number = 0;
		public var _pitch:Number = 0;
		public var _yaw:Number = 0;
		
		private var _rightAxis:Vector3D;
		private var _backAxis:Vector3D;
		private var _upAxis:Vector3D;
		
		public function ViewpointCamera(PosX:Number = 0, PosY:Number = 0, PosZ:Number = 0, CenterX:Number = 0, CenterY:Number = 0):void
		{
			_viewTransform = new Matrix3D();
			_lookAtTransform = new Matrix3D();
			_center = new Point(CenterX, CenterY);
			_savePos = new Point(CenterX, CenterY);
			_position = new Vector3D(PosX, PosY, PosZ);
			_rightAxis = new Vector3D();
			_backAxis = new Vector3D();
			_upAxis = new Vector3D();
			
			_projectionTransform = new PerspectiveMatrix3D();
			var aspect:Number = 4 / 3;
			var zNear:Number = 0.1;
			var zFar:Number = 1000;
			var fov:Number = 45 * Math.PI / 180;
			_projectionTransform.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
			
			update(true);
		}
		
		public function mouseDown():void
		{
			_mouseIsDown = true;
		}
		
		public function update(ForceTransformation:Boolean = false):void
		{
			var x:Number = _center.x - _mouseX;  
			var y:Number  = _center.y - _mouseY;
			var deltaX:Number = _savePos.x - x;
			var deltaY:Number = _savePos.y - y;
			_savePos.setTo(x, y);
			
			if (_mouseIsDown || _velocity != 0 || ForceTransformation)
			{
				_viewTransform.identity();
				_viewTransform.appendTranslation(_position.x, _position.y, _position.z);
				
				if (_mouseIsDown)
				{
					_yaw = _yaw + deltaX;
					if (_yaw > 180)
						_yaw -= 360;
					else if (_yaw < -180)
						_yaw += 360;
					
					_pitch = _pitch + deltaY;
					if (_pitch <= -80)
						_pitch = -80;
					else if (_pitch >= 80)
						_pitch = 80;
				}
				
				_viewTransform.appendRotation(_yaw, Vector3D.Y_AXIS, _position);
				var _viewRight:Vector3D = rightAxisOf(_viewTransform);
				_viewTransform.appendRotation(_pitch, _viewRight, _position); //Needs to take the previous rotation into account
				
				if (_velocity != 0)
				{
					var _viewDir:Vector3D = backAxisOf(_viewTransform);
					_viewTransform.appendTranslation(_velocity * _viewDir.x, _velocity * _viewDir.y, _velocity * _viewDir.z);
					
					_position.x += _velocity * _viewDir.x;
					_position.y += _velocity * _viewDir.y;
					_position.z += _velocity * _viewDir.z;
					_velocity = 0;
				}
				
				_viewTransform.invert();
			}
		}
		
		public function mouseUp():void
		{
			_mouseIsDown = false;
		}
		
		public function mouseMove(mouseX:Number, mouseY:Number):void
		{
			_mouseX = mouseX;
			_mouseY = mouseY;
		}
		
		public function mouseWheel(WheelDelta:int):void
		{
			_velocity = WheelDelta / 10;
		}
		
		public function destroy():void
		{
			_projectionTransform = null;
			_viewTransform = null;
			_center = null;
			_savePos = null;
		}
		
		public function set center(value:Point):void
		{
			_center = value;
		}
		
		private function rightAxisOf(MatrixA:Matrix3D):Vector3D
		{
			var _raw:Vector.<Number> = MatrixA.rawData;
			_rightAxis.setTo(_raw[0], _raw[1], _raw[2]);
			return _rightAxis;
		}
		
		private function upAxisOf(MatrixA:Matrix3D):Vector3D
		{
			var _raw:Vector.<Number> = MatrixA.rawData;
			_upAxis.setTo(_raw[4], _raw[5], _raw[6]);
			return _upAxis;
		}
		
		private function backAxisOf(MatrixA:Matrix3D):Vector3D
		{
			var _raw:Vector.<Number> = MatrixA.rawData;
			_backAxis.setTo(_raw[8], _raw[9], _raw[10]);
			return _backAxis;
		}
		
		public function get projectionTransform():Matrix3D
		{
			return _projectionTransform;
		}
		
		public function get viewTransform():Matrix3D
		{
			return _viewTransform;
		}
	}
}