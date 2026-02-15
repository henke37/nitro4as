package  {
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.ui.*;
	
	import Nitro.SDAT.*;
	import Nitro.SDAT.InfoRecords.*;
	
	public class FSTestCellRenderer extends ColoredCellRenderer {
		
		private var saveItem:ContextMenuItem;
		
		private var fr:FileReference;

		public function FSTestCellRenderer() {
			contextMenu=new ContextMenu();
			contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, buildMenu);
			contextMenu.hideBuiltInItems();
			saveItem=new ContextMenuItem("Save Subfile");
			saveItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveSelected);
			contextMenu.customItems=[saveItem];
		}
	
		private function buildMenu(evt:ContextMenuEvent):void {
			saveItem.visible = "info" in data;
		}
	
		private function get fsTest():FSTest { return FSTest(root); }
	
		private function saveSelected(evt:ContextMenuEvent):void {
			var info:BaseInfoRecord = data["info"];
			var sdat:SDAT = SDAT(data["sdat"]);
			var blob:ByteArray = sdat.openFileById(info.fatId);
			
			fr=new FileReference();
			fr.save(blob);
		}

	}
	
}
