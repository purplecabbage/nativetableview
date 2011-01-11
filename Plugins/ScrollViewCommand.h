//  Created by Jesse MacFadyen on 10-10-31.
//  Copyright Nitobi 2010. All rights reserved.

#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"

@interface ScrollViewCommand : PhoneGapCommand <UIScrollViewDelegate> 
{
	UIScrollView* scrollView;
}

@property (nonatomic, retain) UIScrollView* scrollView;


- (void)showView:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)hideView:(NSArray*)arguments withDict:(NSDictionary*)options;


@end
