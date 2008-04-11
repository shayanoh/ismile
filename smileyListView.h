//
//  smileyListView.h
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <smiley.h>
#import <smileyView.h>
#import <Controller.h>
@class Controller;

@interface smileyListView : NSView {
	NSMutableArray* smileys;
	NSMutableArray* smileyViews;
	
	int Cols,Rows;
	int mi,mj;
	bool m_in;
	int mdi,mdj;
	bool clickvalid;
	bool dragged;
	bool draggedout;
	
	bool drawfocusrect;
	
	smileyView* draggingSmileyView;
	smiley* draggingSmiley;
	
	Controller* controller;
	
	NSString* tabName;

}
-(void)setSmileyList:(NSMutableArray*)sl;
-(NSArray*)smileyList;
-(void)setFrame:(NSRect)rect;
-(void)setController:(Controller*)cont;
-(void)setTabName:(NSString*)s;
-(NSString*)tabName;
-(void)realignSmileys;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
@end
