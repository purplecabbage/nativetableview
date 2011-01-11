//  Created by Jesse MacFadyen on 10-10-31.
//  Copyright Nitobi 2010. All rights reserved.



function NativeTableView()
{
	
}

NativeTableView.prototype.show = function(x,y,width,height)
{
	PhoneGap.exec("TableViewCommand.showTableView");
}

NativeTableView.prototype.hide = function()
{
	PhoneGap.exec("TableViewCommand.hideTableView");
}

NativeTableView.prototype.setData = function(data)
{

}



