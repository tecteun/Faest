package 
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import tec.Faest.CModule;
	/**
	 * ...
	 * @author 
	 */
	public class StreamDecoder 
	{
		private const BUFFERSIZE:uint = 100 * 1024 * 1024;
		private var ctx:uint;
		private var pData:uint;
		private var pCipher:uint;
		private var pCipherOffset:uint;
		private var pDataReadOffset:uint;
		private var pDataWriteOffset:uint;
		private var _input:IDataInput;
		private var _bytesAvailable:uint;
		public function StreamDecoder(input:IDataInput, iv:uint, mkey:uint) 
		{
			_input = input;
			pData = pDataWriteOffset = pDataReadOffset = CModule.malloc(BUFFERSIZE);
			pCipher = pCipherOffset = CModule.malloc(BUFFERSIZE);
			ctx = 1;
			//init new Faest context
			if (Faest.AesCtxIni(ctx, iv, mkey, Faest.KEY128, String(Faest.CBC)) < 0) {
				trace("init error");
			}
		}
		
		public function readByte():uint {
			decode(multipleOf16(1));
			var retval:uint = CModule.read32(pDataReadOffset);
			pDataReadOffset += 1;
			return retval;
		}
		
		public function readBytes(output:ByteArray, length:uint):void {
			decode(multipleOf16(length));
			CModule.readBytes(pDataReadOffset, length, output);
			pDataReadOffset += length;
		}
		
			private function decode(numBytes:uint):void {
			if (_input.bytesAvailable >= numBytes) {
				//load new bytes in ciphered_space pCipher
				CModule.writeBytes(pCipherOffset, numBytes, _input);
				//decrypt into decrypted_space pData
				if (Faest.AesDecrypt(ctx, pCipherOffset, pDataWriteOffset, numBytes ) < 0) {
					trace("[" + StreamDecoder + "] error in decryption\n");
				}else {
					pDataWriteOffset += numBytes;
					pCipherOffset += numBytes;
				}
				
				/*
				var buffer:ByteArray = new ByteArray();
				CModule.readBytes(pCipherOffset - numBytes, numBytes , buffer);
				trace(Hex.fromArray(buffer));
				var buffer:ByteArray = new ByteArray();
				CModule.readBytes(pDataWriteOffset - (numBytes * 16), numBytes , buffer);
				trace(Hex.fromArray(buffer));
				trace("=====");
				*/
			}
		}
		
		private function roundUp(numToRound:int, multiple:int):int
		{ 
			if(multiple == 0) 
			{ 
				return numToRound; 
			} 

			var remainder:int = numToRound % multiple;
			if (remainder == 0){
				return numToRound;
			}
			return numToRound + multiple - remainder;
		} 
		
		private function multipleOf16(i:uint):uint {
			//return i % 16 < 16 ?  i - i % 16: i + (i - i % 16);
			return roundUp(i, 16);
		}
		
		public function get bytesAvailable():uint 
		{
			return _input.bytesAvailable;
		}
	}

}