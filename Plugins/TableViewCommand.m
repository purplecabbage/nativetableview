

#import "TableViewCommand.h"
#import "AppRecord.h"

@implementation TableViewCommand

@synthesize tblView;
@synthesize entries;
@synthesize imageDownloadsInProgress;

- (void)showView:(NSArray*)arguments withDict:(NSDictionary*)options
{
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	self.entries = [NSMutableArray arrayWithCapacity:100];
	
	int x = [[arguments objectAtIndex:0] intValue];
	int y = [[arguments objectAtIndex:1] intValue];
	int w = [[arguments objectAtIndex:2] intValue];
	int h = [[arguments objectAtIndex:3] intValue];
	
	
	for (id aView in webView.subviews) 
	{
		UIView* sub = (UIView*)aView;
		if([sub isKindOfClass:[UIScrollView class]])
		{
			tblView = [UITableView alloc];
			CGRect rect = CGRectZero;
			rect.size.width = w;
			rect.size.height = h;
			rect.origin.y = y;
			rect.origin.x = x;
			[tblView initWithFrame:rect style:UITableViewStylePlain]; // UITableViewStyleGrouped
			tblView.delegate = self;
			tblView.dataSource = self;
			tblView.sectionHeaderHeight = 120;
			
			[sub addSubview:tblView];
			break;
		}
	}

}

- (void)hideView:(NSArray*)arguments withDict:(NSDictionary*)options
{
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* jsString = [[NSString alloc] initWithFormat:@"selectedItemAtIndex(%d);", [indexPath indexAtPosition: 1 ]];
	[ webView stringByEvaluatingJavaScriptFromString:jsString];
	
	[ jsString release ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSString* jsString = [[NSString alloc] initWithFormat:@"getItemCount(%d);",section];
	NSString* strValue = [ webView stringByEvaluatingJavaScriptFromString:jsString];
	
	int retValue = [strValue intValue];
	
	[jsString release];
	
	return retValue;
}

	



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		 
//		 UITableViewCellStyleDefault,	// Simple cell with text label and optional image view (behavior of UITableViewCell in iPhoneOS 2.x)
//		 UITableViewCellStyleValue1,		// Left aligned label on left and right aligned label on right with blue text (Used in Settings)
//		 UITableViewCellStyleValue2,		// Right aligned label on left with blue text and left aligned label on right (Used in Phone/Contacts)
//		 UITableViewCellStyleSubtitle	// Left aligned label on top and left aligned label on bottom with gray text (Used in iPod).
		 
		
		cell = [[[ UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
		[ [ cell textLabel ] setTextColor:[ UIColor colorWithRed:0.3 green:0.4 blue:0.4 alpha:1.0]];
		
		
//		 UITableViewCellAccessoryNone,                   // don't show any accessory view
//		 UITableViewCellAccessoryDisclosureIndicator,    // regular chevron. doesn't track
//		 UITableViewCellAccessoryDetailDisclosureButton, // blue button w/ chevron. tracks
//		 UITableViewCellAccessoryCheckmark               // checkmark. doesn't track
		 
		
		cell.backgroundColor = [ UIColor greenColor]; // this only works for tables with type grouped
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		
//		 UITableViewCellSelectionStyleNone,
//		 UITableViewCellSelectionStyleBlue,
//		 UITableViewCellSelectionStyleGray
		 
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
	int indexPosition = [indexPath indexAtPosition:1];

	NSString* jsString = [[NSString alloc] initWithFormat:@"getItemAtIndex(%d);", indexPosition];

	NSString* cellText = [ webView stringByEvaluatingJavaScriptFromString:jsString];
	
	
	NSDictionary* obj = (NSDictionary*)[cellText JSONFragmentValue];
	
	// This was to test the time it took to receive a call, at startup
	// it takes 10-30 ms per call to js
	//NSLog(@"HTML returned :: %@",[obj objectForKey:@"timeDiff"]);
	
    cell.textLabel.text = [obj objectForKey:@"text"];
	cell.detailTextLabel.text = [obj objectForKey:@"detailText"];
	
	NSString* imgSrc = [obj objectForKey:@"image"];
	
	AppRecord *appRecord = NULL;
	
	if([entries count] > indexPosition)
	{
		appRecord = (AppRecord*)[entries objectAtIndex:indexPosition];
		
	}
	
	if (!appRecord || !appRecord.appIcon)
	{
		if(!appRecord)
		{	
			appRecord = [[[AppRecord alloc] init] autorelease];
			appRecord.imageURLString = imgSrc;
			[ entries setObject:appRecord atIndex:indexPosition];
		}
		
		if (self.tblView.dragging == NO && self.tblView.decelerating == NO)
		{
			[self startIconDownload:appRecord forIndexPath:indexPath];
		}
		// if a download is deferred or in progress, return a placeholder image
		cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
	}
	else
	{
		cell.imageView.image = appRecord.appIcon;
	}
	
	[jsString release];
	
    return cell;
	
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.appRecord.appIcon;
    }
}


// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tblView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.appIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end