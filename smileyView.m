//
//  smileyView.m
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "smileyView.h"


@implementation smileyView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}
- (void)mouseDown:(NSEvent*)e
{
	[ [self superview] mouseDown:e ];
}
@end
