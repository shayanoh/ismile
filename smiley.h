//
//  smiley.h
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface smiley : NSObject<NSCoding> {
	NSData* icondata;
	NSString* tabname;
	NSString* url;
}
@property(readwrite,copy) NSString* tabname;
@property(readwrite,copy) NSString* url;
@property(readwrite,copy) NSData* icondata;

@end
