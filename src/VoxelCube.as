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
		
		public function VoxelCube(TextureIndex:int, X:Number = 0, Y:Number = 0, Z:Number = 0)
		{
			super(X, Y, Z);
			
			setTextureIndexTo(TextureIndex);
			
			_positionVertBuf = _context.createVertexBuffer(24, 3);
			_positionVertBuf.uploadFromVector(CUBE_VERTICES, 0, 24);
			
			_indexBuf = _context.createIndexBuffer(36);
			_indexBuf.uploadFromVector(CUBE_INDICES, 0, 36);
		}
		
		override public function renderScene(Camera:ViewpointCamera, FaceCamera:Boolean = false):void
		{
			super.renderScene(Camera, false);
		}
		
		override public function setTextureIndexTo(TextureIndex:int):void
		{
			super.setTextureIndexTo(TextureIndex);
			
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