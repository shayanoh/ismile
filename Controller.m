//
//  Controller.m
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import <Carbon/Carbon.h>

/*
OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData)
{
	//Do something once the key is pressed
	Controller* C = (Controller*)userData;
	[C showSmileys:nil];
	return noErr;
}
*/

@implementation Controller

-(void)awakeFromNib
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
	theItem = [bar statusItemWithLength:NSSquareStatusItemLength];
	
	[theItem setHighlightMode:YES];
	[theItem setImage:[NSImage imageNamed:@"MenuIcon"]];
	[theItem setMenu:StatusItemMenu];

	[smileyCacheView setController:self];
	[smileyCacheBox setHidden:YES];
	NSRect fr = [tabView frame];
	NSRect fr2 = [smileyCacheBox frame];
	fr.size.height += fr2.size.height;
	fr.origin.y -= fr2.size.height;
	[tabView setFrame:fr];
	
	[self loadSmileys];
	[self fillTabs];
	/*
	[smileyPanel setFloatingPanel:YES];
	[smileyPanel setBecomesKeyOnlyIfNeeded:YES];
	tabs = [[NSMutableArray alloc] initWithCapacity:10];
	
	IdxToUrl = [[NSMutableArray arrayWithCapacity:100] retain];
	IdxToImg = [[NSMutableArray arrayWithCapacity:100] retain];
	[self FillTabView];

	//Register the Hotkeys
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,self,NULL);
	
	EventHotKeyID MyHotKeyID;
	MyHotKeyID.signature='htk1';
	MyHotKeyID.id=1;
	RegisterEventHotKey(12, controlKey, MyHotKeyID, GetApplicationEventTarget(), 0, &MyHotKeyRef);
	
	// Set Timer to Hide Splash Screen
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideSplashScreen:) userInfo:nil repeats:NO];
	 */
}

-(void)showSmileys:(id)sender
{
	if ([smileyPanel isVisible])
		[smileyPanel orderOut:nil];
	else
	{
		NSPoint P2 = [NSEvent mouseLocation];
		P2.x-=30;
		P2.y+=65;
		[smileyPanel setFrameTopLeftPoint:P2];
		[smileyPanel makeKeyAndOrderFront:nil];
	}
}
-(void)quit:(id)sender
{	
	[self saveSmileys];
	[[NSApplication sharedApplication] terminate:self];
}

-(void)loadSmileys
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSData *filedata = [ud dataForKey:@"smileys"];
//	NSData *filedata = [[NSData alloc] initWithContentsOfFile:@"/Users/ShayanOH/Desktop/data.dat"];
	if (!filedata)
	{
		tabs = [[NSMutableArray alloc] init];
		[tabs addObject:@"iSmile!"];
		smileys = [[NSMutableArray alloc] init];
	}
	else
	{
		NSKeyedUnarchiver *unarc = [[NSKeyedUnarchiver alloc] initForReadingWithData:filedata];
		tabs = [unarc decodeObjectForKey:@"tabs"];
		smileys = [unarc decodeObjectForKey:@"smileys"];
		[unarc finishDecoding];	
	}
}
-(void)collectSmileys
{
	[smileys removeAllObjects];
	int i;
	for (i=0;i<[tabView numberOfTabViewItems];i++)
	{
		smileyListView* slv = [[tabView tabViewItemAtIndex:i] view];
		[smileys addObjectsFromArray:[slv smileyList]];
	}	
}
-(void)saveSmileys
{
	[self collectSmileys];
	NSMutableData *filedata = [[NSMutableData alloc] init];
	NSKeyedArchiver *arc = [[NSKeyedArchiver alloc] initForWritingWithMutableData:filedata];
//	[arc setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[arc setOutputFormat:NSPropertyListBinaryFormat_v1_0];
	[arc encodeObject:tabs forKey:@"tabs"];
	[arc encodeObject:smileys forKey:@"smileys"];
	[arc finishEncoding];
	
//	[filedata writeToFile:@"/Users/ShayanOH/Desktop/data.dat" atomically:NO];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:filedata forKey:@"smileys"];
	
	[arc release];
	[filedata release];
	
}
-(void)fillTabs
{
	while ([tabView numberOfTabViewItems]>1) [tabView removeTabViewItem:[tabView tabViewItemAtIndex:0]];
	for (NSString* tabName in tabs)
	{
		NSMutableArray* tabSmileys = [[NSMutableArray alloc] init];
		for (smiley* sm in smileys)
		{
			if (sm.tabname == tabName) [tabSmileys addObject:sm];
		}
		smileyListView* slv = [[smileyListView alloc] init];
		[slv setController: self];
		[slv setSmileyList: tabSmileys];
		[slv setTabName:tabName];
		NSTabViewItem* tvi = [[NSTabViewItem alloc] init];
		[tvi setLabel:tabName];
		[tvi setView:slv];
		[tabView addTabViewItem:tvi];
	}
	[tabView  removeTabViewItem:[tabView tabViewItemAtIndex:0]];
}
-(void)dragStarted
{
	if ([smileyCacheBox isHidden]==NO) return;
	NSRect fr = [tabView frame];
	NSRect fr2 = [smileyCacheBox frame];
	fr.size.height -= fr2.size.height;
	fr.origin.y += fr2.size.height;
	[[tabView animator] setFrame: fr];
	[smileyCacheBox setHidden:NO];
}
-(void)dragFinished
{
	NSLog(@"cache count: %d",(int)[[smileyCacheView smileyList] count]);
	if ([[smileyCacheView smileyList] count]>0) return;
	NSRect fr = [tabView frame];
	NSRect fr2 = [smileyCacheBox frame];
	fr.size.height += fr2.size.height;
	fr.origin.y -= fr2.size.height;
	[[tabView animator] setFrame: fr];
	[smileyCacheBox setHidden:YES];
}
-(NSMenu*)tabContextMenu
{
	return TabContextMenu;
}
-(IBAction)addNewTab:(id)sender
{
	[self collectSmileys];
	curAction = 1;
	[tabNameError setStringValue:@""];
	[tabNameText setStringValue:@""];
	[NSApp beginSheet:tabNameSheet modalForWindow:smileyPanel modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:self];
}
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[tabNameSheet orderOut:self];
}
- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertAlternateReturn)
	{
		NSString *name = [[[tabView selectedTabViewItem] view] tabName];
		NSMutableArray *newsmileys = [[NSMutableArray alloc] init];
		int i;
		for (i=0;i<[smileys count]; i++)
		{
			smiley* s = [smileys objectAtIndex:i];
			if (![[s tabname] isEqualTo:name])
				[newsmileys addObject:s];
		}
		smileys = newsmileys;
		[tabs removeObject:name];
		[self fillTabs];
	}
}
-(IBAction)deleteThisTab:(id)sender
{
	[self collectSmileys];
	NSAlert* al = [NSAlert alertWithMessageText:@"Are you sure you want to delete this tab?" defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"By deleting this tab, all smileys within it will be deleted. This action is not undoable!"];
	[al beginSheetModalForWindow:smileyPanel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:self];
}
-(IBAction)cancelSheet:(id)sender
{
	[NSApp endSheet:tabNameSheet];
}
-(IBAction)okSheet:(id)sender
{
	if (curAction==1)
	{
		NSString* newname = [tabNameText stringValue];
		if ([newname length]==0)
		{
			[tabNameError setStringValue:@"No name entered!"];
			return;
		}
		if ([tabs containsObject:newname])
		{
			[tabNameError setStringValue:@"Duplicate name!"];
			return;
		}
		[NSApp endSheet:tabNameSheet];
		[tabs addObject:newname];
		[self fillTabs];
	}
}
@end
