package tec.Faest
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import com.adobe.flascc.CModule;
	/**
	 * ...
	 * @author 
	 */
	public class HTTPStreamingDecoder 
	{
		private static const BUFFERSIZE:uint = 100 * 1024 * 1024; //10mb
		private static var ctx:uint;
		private static var pData:uint;
		private var pCipherOffset:uint;
		private var pDataReadOffset:uint;
		private var pDataWriteOffset:uint;
		private var _input:IDataInput;
		private var _bytesAvailable:uint;
		private var iv:uint;
		private var mkey:uint;
		public function HTTPStreamingDecoder(iv:uint, mkey:uint) 
		{
			pDataWriteOffset = pDataReadOffset = pData;
			this.mkey = mkey;
			this.iv = iv;
			
			
			//init new Faest context
			if (Faest.AesCtxIni(ctx, iv, mkey, Faest.KEY128, String(Faest.CBC)) < 0) {
				;
				//fail
			}else {
				;
				
			}
		}
		
		public function dispose():void {
			CModule.free(this.mkey);
			CModule.free(this.iv);
		}
		
		public function readByte():uint {
			decode(1);
			var retval:uint = CModule.read8(pDataReadOffset);
			pDataReadOffset += 1;
			return retval;
		}
		
		public function readBytes(output:ByteArray, length:uint):void {
			var decoded:uint = decode(length);
			CModule.readBytes(pDataReadOffset, length, output);
			pDataReadOffset += length;
			output.position = 0;
		}
		
		private function decode(numBytes:uint):uint {
			var decryptedBytes:int = 0;
			if (bufferBytesAvailable < numBytes) { //without this check video goes skipping
				//need to decode more bytes, buffer is quite empty
				if (_input.bytesAvailable <= numBytes - bufferBytesAvailable) {
					numBytes = _input.bytesAvailable; //get last bytes of the stack
				}else {
					numBytes = numBytes - bufferBytesAvailable;
				}
				var num16:uint = multipleOf16(numBytes);
				var toWriteInCipher:uint = _input.bytesAvailable < num16 ? _input.bytesAvailable : num16;
				//load new bytes in ciphered_space pCipher
				//always write and decrypt in blocks of 16
				CModule.writeBytes(pDataWriteOffset, toWriteInCipher, _input);
				//decrypt into decrypted_space pData
				decryptedBytes = Faest.AesDecrypt(ctx, pDataWriteOffset, pDataWriteOffset, num16);
				if (decryptedBytes < 0) {
					;
					
						throw(HTTPStreamingDecoder + " error in decryption\n");
					
				}else {
					decryptedBytes = pDataWriteOffset += toWriteInCipher;
				}
			}
			return decryptedBytes; //actually decrypted bytes.
			
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
		
		private function get bufferBytesAvailable():uint 
		{
			return pDataWriteOffset - pDataReadOffset;
		}
		
		public function get bytesAvailable():uint 
		{
			return _input.bytesAvailable + bufferBytesAvailable;
		}
		
		public function set input(value:IDataInput):void 
		{
			_input = value;
		}
		
		public static function allocateMem():void {
			
			pData =  CModule.malloc(BUFFERSIZE);
			ctx = CModule.malloc(500);
		}
	}

}