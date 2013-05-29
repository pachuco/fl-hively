package replay_hively {
	public class hvl_instrument{
		public var ins_Name:String;								//TEXT[128]
		public var ins_Volume:uint;								//uint8
		public var ins_WaveLength:uint;							//uint8
		public var ins_FilterLowerLimit:uint;					//uint8
		public var ins_FilterUpperLimit:uint;					//uint8
		public var ins_FilterSpeed:uint;						//uint8
		public var ins_SquareLowerLimit:uint;					//uint8
		public var ins_SquareUpperLimit:uint;					//uint8
		public var ins_SquareSpeed:uint;						//uint8
		public var ins_VibratoDelay:uint;						//uint8
		public var ins_VibratoSpeed:uint;						//uint8
		public var ins_VibratoDepth:uint;						//uint8
		public var ins_HardCutRelease:uint;						//uint8
		public var ins_HardCutReleaseFrames:uint;				//uint8
		public var ins_Envelope:hvl_envelope;					//
		public var ins_PList:hvl_plist;							//
		
		public function hvl_instrument():void{
			ins_Envelope = new hvl_envelope();
			ins_PList = new hvl_plist();
		}
	}
}