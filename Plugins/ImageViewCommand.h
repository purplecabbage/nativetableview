

#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"
@interface ImageViewCommand : PhoneGapCommand <UITableViewDelegate, UITableViewDataSource> 
{
	UIImageView* imgView;
}

@property (nonatomic, retain) UIImageView* imgView;

- (void)showView:(NSArray*)arguments withDict:(NSDictionary*)options;

@end
