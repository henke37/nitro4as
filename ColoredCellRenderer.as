package  {
	
	import fl.controls.listClasses.*;
	import flash.geom.ColorTransform;

	
	public class ColoredCellRenderer extends CellRenderer {
		
		public function ColoredCellRenderer() {}

		//public override function set listData(value:ListData):void {
			//super.listData = value;
		protected override function drawBackground():void {
			super.drawBackground();
			
			background.transform.colorTransform=data.colorTransform;
		}
	}
	
}
