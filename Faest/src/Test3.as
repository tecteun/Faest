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
	public class Test3 extends Sprite 
	{//~33s
		[Embed(source = "../bin/test.txt", mimeType = "application/octet-stream")]
		private var rawdata:Class;
		[Embed(source="../bin/video.key", mimeType="application/octet-stream")]
		private var key:Class
		public function Test3():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var bytes:ByteArrayAsset = new rawdata();
			var data:int = CModule.malloc(bytes.length);
			var encrypted:int = CModule.malloc(bytes.length);
			
			CModule.writeBytes(data, bytes.length, bytes);
			
			///prepare key
			var _key:ByteArrayAsset = new key();
			var mkey = CModule.malloc(16);
			CModule.writeBytes(mkey, 16, _key);
			//trace("key: " + Hex.fromArray(_key)); //d68123b4a76b92b636b724333f901f9d
			
			///prepare iv
			var tArr:ByteArray = new ByteArray();
			tArr.writeUnsignedInt(1830);
			var ivptr:int = CModule.malloc(16);
			//trace(StringTools.lpad(Hex.fromArray(tArr), "0", 32));
			//var iv:ByteArray =  Hex.toArray(StringTools.lpad(Hex.fromArray(tArr), "0", 32));
			var iv:ByteArray =  Hex.toArray("00000000000000000000000000000726");
			CModule.writeBytes(ivptr, iv.length, iv);
			
			
			//ENCRYPT
			var ctx = 1;
			if (Faest.AesCtxIni(ctx, ivptr, mkey, Faest.KEY128, String(Faest.CBC)) < 0) {
				trace("init error");
			}
			
			if (Faest.AesEncrypt(ctx, data, encrypted, bytes.length) < 0) {
				trace("error in encryption\n");
			}
			
			var encbuffer:ByteArray = new ByteArray();
			
			trace("3:normal \t" + Hex.fromArray(bytes, true));
			trace("3:encrypted \t" + Hex.fromArray(encbuffer, true) + "\n");
			
			encbuffer.position = 0;
			var decoder:StreamDecoder = new StreamDecoder(encbuffer, ivptr, mkey);
			
			var decbuffer:ByteArray = new ByteArray();
			CModule.readBytes(encrypted, 8, encbuffer);
			encbuffer.position = 0;
			encrypted += 8;
			decoder.readBytes(decbuffer, 8);
			trace("restored \t" + Hex.fromArray(decbuffer, true));
			
			CModule.readBytes(encrypted, 8, encbuffer);
			encbuffer.position = 8;
			encrypted += 8;
			decoder.readBytes(decbuffer, 8);
			trace("restored \t" + Hex.fromArray(decbuffer, true));
			
			
			CModule.readBytes(encrypted, 16, encbuffer);
			encbuffer.position = 16;
			encrypted += 16;
			decoder.readBytes(decbuffer, 16);
			trace("restored \t" + Hex.fromArray(decbuffer, true));
			CModule.readBytes(encrypted, 16, encbuffer);
			encbuffer.position = 32;
			encrypted += 16;
			decoder.readBytes(decbuffer, 16);
			trace("restored \t" + Hex.fromArray(decbuffer, true)); 0
			CModule.readBytes(encrypted, 16, encbuffer);
			encbuffer.position = 48;
			encrypted += 16;
			decoder.readBytes(decbuffer, 16);
			trace("restored \t" + Hex.fromArray(decbuffer, true));
		}
		
	}
	
}