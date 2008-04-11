//
//  smiley.m
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "smiley.h"


@implementation smiley
@synthesize icondata,tabname,url;
-(void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:self.icondata forKey:@"icondata"];
	[coder encodeObject:self.tabname forKey:@"tabname"];
	[coder encodeObject:self.url forKey:@"url"];
}
-(id)initWithCoder:(NSCoder*)coder
{
	self.icondata = [coder decodeObjectForKey:@"icondata"];
	self.tabname = [coder decodeObjectForKey:@"tabname"];
	self.url = [coder decodeObjectForKey:@"url"];
	return self;
}
@end
