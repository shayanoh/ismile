//
//  Controller.h
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import <smiley.h>
#import <smileyListView.h>
@class smileyListView;
@interface Controller : NSObject {
	IBOutlet NSPanel* smileyPanel;
	IBOutlet NSTabView* tabView;
	IBOutlet NSBox* smileyCacheBox;
	IBOutlet smileyListView* smileyCacheView;
	NSStatusItem* theItem;
    IBOutlet NSMenu *StatusItemMenu;
	
	NSMutableArray* smileys;
	NSMutableArray* tabs;
	
	NSRect oldRect;
	
	IBOutlet NSMenu* TabContextMenu;
	
	IBOutlet NSWindow* tabNameSheet;
	IBOutlet NSTextField* tabNameText;
	IBOutlet NSTextField* tabNameError;
	int curAction;
}


-(void)awakeFromNib;
-(IBAction)showSmileys:(id)sender;
-(IBAction)quit:(id)sender;
-(IBAction)addNewTab:(id)sender;
-(IBAction)deleteThisTab:(id)sender;
-(IBAction)okSheet:(id)sender;
-(IBAction)cancelSheet:(id)sender;


-(void)loadSmileys;
-(void)collectSmileys;
-(void)saveSmileys;
-(void)fillTabs;

-(void)dragStarted;
-(void)dragFinished;

-(NSMenu*)tabContextMenu;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end
