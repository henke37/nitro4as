package Nitro.SDAT.SequenceEvents {
	
	public class VarVarEvent extends SequenceEvent {

		public var operation:uint;
		
		public static const assign:uint=0;
		public static const addition:uint=1;
		public static const subtract:uint=2;
		public static const multiply:uint=3;
		public static const divide:uint=4;
		public static const shift:uint=5;
		public static const random:uint=6;
		public static const unknownOp:uint=7;
		public static const equals:uint=8;
		public static const greaterThanEq:uint=9;
		public static const greaterThan:uint=10;
		public static const lessThanEq:uint=11;
		public static const lessThan:uint=12;
		public static const notEqual:uint=13;
		
		public var variable1:uint;
		public var variable2:uint;
		public var operand:uint;

		public function VarVarEvent(op:uint,v:uint,v2:uint) {
			operation=op;
			variable1=v;
			variable2=v2;
		}

	}
	
}
