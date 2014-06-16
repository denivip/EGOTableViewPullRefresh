//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"


@interface EGORefreshTableHeaderView ()
@property (nonatomic) EGOPullState state;
@property (nonatomic, weak) UILabel *lastUpdatedLabel;
@property (nonatomic, weak) UILabel *statusLabel;
@property (nonatomic, weak) CALayer *arrowImage;
@property (nonatomic, weak) DVActivityIndicator *activityView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) UIEdgeInsets originalContentInset;
@property (nonatomic) BOOL restoreOriginalContentInset;
@end

@implementation EGORefreshTableHeaderView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        _isLoading = NO;
        
        CGFloat midY = frame.size.height - PULL_AREA_HEIGHT/2;
        
        /* Config Last Updated Label */
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		
        /* Config Status Updated Label */
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
        /* Config Arrow Image */
		CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f,midY - 27, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityCenter;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
        /* Config activity indicator */
        DVActivityIndicator *view = [[DVActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        view.image = [UIImage imageNamed:@"loading_view"];
        view.hidesWhenStopped = YES;
		view.frame = CGRectMake(25.0f,midY - 8, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;		
		
		[self setState:EGOOPullNormal];
        
        /* Configure the default colors and arrow image */
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

#define aMinute 60
#define anHour 3600
#define aDay 86400

- (void)refreshLastUpdatedDate {
    NSDate * date = nil;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
	}
    if(date) {
        NSTimeInterval timeSinceLastUpdate = [date timeIntervalSinceNow];
        NSInteger timeToDisplay = 0;
        timeSinceLastUpdate *= -1;
        
        if(timeSinceLastUpdate < anHour) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            
            if(timeToDisplay == /* Singular*/ 1) {
            _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minute ago",@"PullTableViewLan",@"Last uppdate in minutes singular"),(long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld minutes ago",@"PullTableViewLan",@"Last uppdate in minutes plural"), (long)timeToDisplay];

            }
            
        } else if (timeSinceLastUpdate < aDay) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hour ago",@"PullTableViewLan",@"Last uppdate in hours singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld hours ago",@"PullTableViewLan",@"Last uppdate in hours plural"), (long)timeToDisplay];
                
            }
            
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld day ago",@"PullTableViewLan",@"Last uppdate in days singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Updated %ld days ago",@"PullTableViewLan",@"Last uppdate in days plural"), (long)timeToDisplay];
            }
            
        }
        
    } else {
        _lastUpdatedLabel.text = nil;
    }
    
    // Center the status label if the lastupdate is not available
    CGFloat midY = self.frame.size.height - PULL_AREA_HEIGHT/2;
    if(!_lastUpdatedLabel.text) {
        _statusLabel.frame = CGRectMake(0.0f, midY - 8, self.frame.size.width, 20.0f);
    } else {
        _statusLabel.frame = CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f);
    }
    
}

- (void)setState:(EGOPullState)aState{
	
	switch (aState) {
		case EGOOPullPulling:
			
			_statusLabel.text = NSLocalizedStringFromTable(@"Release to refresh...",@"PullTableViewLan", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullNormal:
			
			if (_state == EGOOPullPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedStringFromTable(@"Pull down to refresh...",@"PullTableViewLan", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullLoading:
			
			_statusLabel.text = NSLocalizedStringFromTable(@"Loading...",@"PullTableViewLan", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage
{
    self.backgroundColor = backgroundColor? backgroundColor : DEFAULT_BACKGROUND_COLOR;
    
    if(textColor) {
        _lastUpdatedLabel.textColor = textColor;
        _statusLabel.textColor = textColor;
    } else {
        _lastUpdatedLabel.textColor = DEFAULT_TEXT_COLOR;
        _statusLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    
    _arrowImage.contents = (id)(arrowImage? arrowImage.CGImage : DEFAULT_ARROW_IMAGE.CGImage);
}

- (CGFloat)pullTriggerHeightWithContentInset:(UIEdgeInsets)contentInset
{
    return PULL_TRIGGER_HEIGHT + contentInset.top;
}

#pragma mark -
#pragma mark ScrollView Methods


- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
    
	if (_state == EGOOPullLoading) {
        if (! self.restoreOriginalContentInset) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, PULL_AREA_HEIGHT);
            UIEdgeInsets currentInsets = scrollView.contentInset;
            self.originalContentInset = currentInsets;
            self.restoreOriginalContentInset = YES;
            currentInsets.top += offset;
            scrollView.contentInset = currentInsets;
        }

	} else if (scrollView.isDragging) {
        if (! _isLoading) {
            switch (_state) {
                case EGOOPullPulling:
                    if (scrollView.contentOffset.y > - [self pullTriggerHeightWithContentInset:scrollView.contentInset] &&
                        scrollView.contentOffset.y < 0.0f) {
                        [self setState:EGOOPullNormal];
                    }
                    break;
                    
                case EGOOPullNormal:
                    if (scrollView.contentOffset.y < - [self pullTriggerHeightWithContentInset:scrollView.contentInset]) {
                        [self setState:EGOOPullPulling];
                    }
                    break;

                default:
                    break;
            }
        }

		if (self.restoreOriginalContentInset && scrollView.contentInset.top != self.originalContentInset.top) {
            scrollView.contentInset = self.originalContentInset;
            self.restoreOriginalContentInset = NO;
		}
		
	}
	
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView {
    _isLoading = YES;
    
    [self setState:EGOOPullLoading];

    if (! self.restoreOriginalContentInset) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        UIEdgeInsets currentInsets = scrollView.contentInset;
        self.originalContentInset = currentInsets;
        self.restoreOriginalContentInset = YES;
        currentInsets.top += PULL_AREA_HEIGHT;
        scrollView.contentInset = currentInsets;
        [UIView commitAnimations];
    }
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {

	if (scrollView.contentOffset.y <= - [self pullTriggerHeightWithContentInset:scrollView.contentInset] && !_isLoading) {
        [self startAnimatingWithScrollView:scrollView];
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
    _isLoading = NO;

    // Give start animation some time to finish.

    @weakify(self);
    @weakify(scrollView);

    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        @strongify(self);
        @strongify(scrollView);

        [UIView animateWithDuration:.3 animations:^{
            if (self.restoreOriginalContentInset) {
                scrollView.contentInset = self.originalContentInset;
                self.restoreOriginalContentInset = NO;
            }

            CGFloat yOffset = scrollView.contentOffset.y;
            if (self.searchBarHeight > 0 && yOffset < (self.searchBarHeight - scrollView.contentInset.top)) {
                [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, (self.searchBarHeight - scrollView.contentInset.top)) animated:YES];
            }
        }];
        
        [self setState:EGOOPullNormal];
    });
}

- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self refreshLastUpdatedDate];
}


@end
