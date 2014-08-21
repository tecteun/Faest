package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import mx.core.ByteArrayAsset;
	import tec.Faest.CModule;
	import tec.Faest.ram;
	import Faest;
	/**
	 * ...
	 * @author tec
	 *  openssl enc -d -aes-128-cbc -in ./rtl4-track_1\=128000-video\=4250000-1830.ts  -K d68123b4a76b92b636b724333f901f9d -iv 00000000000000000000000000000726 > decrypted.ts

	 */
	public class Test2 extends Sprite 
	{//~33s
		[Embed(source = "../bin/test.txt", mimeType = "application/octet-stream")]
		private var rawdata:Class;
		[Embed(source="../bin/video.key", mimeType="application/octet-stream")]
		private var key:Class
		public function Test2():void 
		{
			
			/*
			var bytes:ByteArrayAsset = new data();
			var data:int = CModule.malloc(bytes.length);
			CModule.writeBytes(data, bytes.length, bytes);
			
			for (var a = 0; a < 100; a ++){
				var ctx:int = 1;
				var b:ByteArray = new ByteArray();
				var ivptr:int = CModule.malloc(32);
				CModule.writeLatin1String(ivptr, "INI VECTINI VECT");
				var pkey:int = CModule.malloc(32);
				CModule.writeLatin1String(pkey, "This is a sample AESKey");
				
				
				trace(bytes.length);
				trace(CModule.read32(data));
				if (Faest.AesCtxIni(ctx, ivptr, pkey, Faest.KEY128, String(Faest.CBC)) < 0) {
					trace("init error");
				}
				
				if (Faest.AesEncrypt(ctx, data, data, bytes.length) < 0) {
					trace("error in encryption\n");
				}
				//CModule.readBytes(data, bytes.length, b);
				//b.position = 0;
				//trace(b.bytesAvailable + ":" + b.readUTFBytes(b.bytesAvailable));
				
				if (Faest.AesCtxIni(ctx, ivptr, pkey, Faest.KEY128, String(Faest.CBC)) < 0) {
					trace("init error");
				}
				
				if (Faest.AesDecrypt(ctx, data, data, bytes.length) < 0) {
					trace("error in encryption\n");
				}
				
				//CModule.readBytes(data, bytes.length, b);
				//b.position = 0;
				//trace(b.bytesAvailable + ":" + b.readUTFBytes(b.bytesAvailable));
			}
			*/
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			var _decoded:ByteArray = new ByteArray();
			var bytes:ByteArrayAsset = new rawdata();
			trace(Hex.fromArray(bytes, true));
			var multipleof16 = bytes.length % 16 < 16 ?  bytes.length - bytes.length % 16: bytes.length + (bytes.length - bytes.length % 16);
			//multipleof16 += 32;
			var data:int = CModule.malloc(bytes.length);
			var encrypted:int = CModule.malloc(bytes.length);
			CModule.writeBytes(data, bytes.length / 2 , bytes);
			CModule.writeBytes(data + bytes.length /2 , bytes.bytesAvailable, bytes);
			
			////
			//CModule.readBytes(data, bytes.length, _decoded);
			//_decoded.position = 0;
			//trace(Hex.fromArray(_decoded).substr(0, 32));
			/////
			
			var _key:ByteArrayAsset = new key();
			var mkey = CModule.malloc(16);
			CModule.writeBytes(mkey, 16, _key);
			//trace("key: " + Hex.fromArray(_key)); //d68123b4a76b92b636b724333f901f9d
			
			
			var tArr:ByteArray = new ByteArray();
			tArr.writeUnsignedInt(1830);
			var ivptr:int = CModule.malloc(16);
			//trace(StringTools.lpad(Hex.fromArray(tArr), "0", 32));
			//var iv:ByteArray =  Hex.toArray(StringTools.lpad(Hex.fromArray(tArr), "0", 32));
			var iv:ByteArray =  Hex.toArray("00000000000000000000000000000726");
			CModule.writeBytes(ivptr, iv.length, iv);
			
			
			
			var ctx = 1;
			//ENCRYPT
			if (Faest.AesCtxIni(ctx, ivptr, mkey, Faest.KEY128, String(Faest.CBC)) < 0) {
				trace("init error");
			}
			
			if (Faest.AesEncrypt(ctx, data, encrypted, multipleof16) < 0) {
				trace("error in encryption\n");
			}
			
			CModule.readBytes(encrypted, bytes.length, _decoded);
			_decoded.position = 0;
			trace("encrypted \n" + Hex.fromArray(_decoded, true) + "\n");
			
			//DECRYPT
			if (Faest.AesCtxIni(ctx, ivptr, mkey, Faest.KEY128, String(Faest.CBC)) < 0) {
				trace("init error");
			}
			
			data = CModule.malloc(bytes.length);
			if (Faest.AesDecrypt(ctx, encrypted, data, 16) < 0) {
				trace("error in decryption\n");
			}
			encrypted += 16;
			
			/////
			CModule.readBytes(data, bytes.length, _decoded);
			trace(Hex.fromArray(_decoded, true));
			_decoded.position = 16;
			
			trace(_decoded.toString() );
			
			//data = CModule.malloc(bytes.length);
			if (Faest.AesDecrypt(ctx, encrypted, data + 16, 16) < 0) {
				trace("error in decryption\n");
			}
			
			/////
			CModule.readBytes(data + 16, bytes.length, _decoded);
			trace(Hex.fromArray(_decoded, true));
			_decoded.position = 0;
			
			trace(_decoded.toString() );
			/////
		}
		
	}
	
}