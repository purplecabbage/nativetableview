//  Created by Jesse MacFadyen on 10-10-31.
//  Copyright Nitobi 2010. All rights reserved.

#import "ScrollViewCommand.h"


@implementation ScrollViewCommand

@synthesize scrollView;

- (void)showView:(NSArray*)arguments withDict:(NSDictionary*)options
{
	
	int x = [[arguments objectAtIndex:0] intValue];
	int y = [[arguments objectAtIndex:1] intValue];
	int w = [[arguments objectAtIndex:2] intValue];
	int h = [[arguments objectAtIndex:3] intValue];
	
	
	for (id aView in webView.subviews) 
	{
		UIView* sub = (UIView*)aView;
		if([sub isKindOfClass:[UIScrollView class]])
		{
			
			CGRect rect = CGRectZero;
			rect.size.width = w;
			rect.size.height = h;
			rect.origin.y = y;
			rect.origin.x = x;
			scrollView = [[UIScrollView alloc] initWithFrame:rect];
			scrollView.delegate = self;
			scrollView.contentSize = CGSizeMake(720, 469);
			scrollView.maximumZoomScale = 2.0;
			scrollView.minimumZoomScale = 0.5;
			UIImage *image = [UIImage imageNamed:@"glovebox-ops.jpg"];
			UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
			[image release];
			[scrollView addSubview:imageView];
			[imageView release];
			scrollView.bouncesZoom = YES;
			
			[sub addSubview:scrollView];
			break;
		}
	}

}

- (void)hideView:(NSArray*)arguments withDict:(NSDictionary*)options
{
	
}







// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}


@end