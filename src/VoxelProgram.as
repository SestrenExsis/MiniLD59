package
{
	import com.adobe.utils.*;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	
	public class VoxelProgram
	{
		[Embed(source="../assets/data/SIMPLE.VERTEX.asm", mimeType="application/octet-stream")]
		private static var SIMPLE_VERTEX_ASM:Class;
		[Embed(source="../assets/data/SIMPLE.FRAGMENT.asm", mimeType="application/octet-stream")]
		private static var SIMPLE_FRAGMENT_ASM:Class;
		
		public static const PROGRAM_SIMPLE:uint = 0;
		
		protected var _context:Context3D;
		protected var _program:int = -1;
		protected var _programs:Vector.<Program3D>;
		
		public function VoxelProgram(Context:Context3D)
		{
			_context = Context;
			_programs = new Vector.<Program3D>();
			
			// *** Begin PROGRAM_SIMPLE ***
			var _program3D:Program3D;
			var _vertexShader:AGALMiniAssembler = new AGALMiniAssembler(true);
			_vertexShader.assemble(Context3DProgramType.VERTEX, convertASMFileToAGALSource(SIMPLE_VERTEX_ASM));
			var _fragmentShader:AGALMiniAssembler = new AGALMiniAssembler(true);
			_fragmentShader.assemble(Context3DProgramType.FRAGMENT, convertASMFileToAGALSource(SIMPLE_FRAGMENT_ASM));
			_program3D = _context.createProgram();
			_program3D.upload(_vertexShader.agalcode, _fragmentShader.agalcode);
			_programs.push(_program3D);
		}
		
		private function convertASMFileToAGALSource(ASMFile:Class):String
		{
			var _bytes:ByteArray = new ASMFile() as ByteArray;
			var _string:String = _bytes.toString();
			var _array:Array = _string.split("\r\n");
			var _index:int = 0;
			for (var i:int = 0; i < _array.length; i++)
			{
				_string = StringUtil.trim(_array[i]); //trim whitespace
				_index = _string.indexOf(";");
				if (_index >= 0)
					_string = _string.substr(0, _index + 1); // cutoff ASM comments
				if (_string.length == 0) //ignore the line altogether if it is empty
				{
					_array.splice(i, 1);
					i--;
				}
				else
					_array[i] = _string;
			}
			
			return _array.join("\n");
		}
		
		public function get program():uint
		{
			return _program;
		}
		
		public function set program(Value:uint):void
		{
			if (Value == _program || Value >= _programs.length)
				return;
			
			_program = Value;
			_context.setProgram(_programs[_program]);
		}
	}
}