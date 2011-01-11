

#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"
#import "IconDownloader.h"

@interface TableViewCommand : PhoneGapCommand <UITableViewDelegate, UITableViewDataSource, IconDownloaderDelegate> 
{
	UITableView* tblView;
	NSMutableArray *entries;   // imagePaths per index + icons
	NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
}

@property (nonatomic, retain) UITableView* tblView;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableArray *entries;

- (void)showView:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)hideView:(NSArray*)arguments withDict:(NSDictionary*)options;

- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath;

@end
