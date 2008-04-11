//
//  smileyListView.m
//  QSmile2
//
//  Created by Shayan Ostad Hassan on 11/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "smileyListView.h"


@implementation smileyListView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
		NSTrackingArea* t = [[NSTrackingArea alloc] initWithRect:frame 
														 options:NSTrackingInVisibleRect | 
							 NSTrackingActiveAlways |
							 NSTrackingMouseEnteredAndExited |
							 NSTrackingMouseMoved
														   owner:self 
														userInfo:nil];
		[self addTrackingArea:t];
		[self registerForDraggedTypes:[NSArray arrayWithObjects: 
									   @"iSmile_Smiley", NSURLPboardType, nil]]; 
		drawfocusrect = NO;
		smileyViews = [[NSMutableArray alloc] init];
		smileys = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSArray*)smileyList
{
	return (NSArray*) smileys;
}

- (void)setController:(Controller*)cont
{
	controller = cont;
}
-(void)setTabName:(NSString*)s
{
	tabName = s;
}
-(NSString*)tabName
{
	return tabName;
}
- (void)drawRect:(NSRect)aRect
{
//	NSGraphicsContext* aContext = [NSGraphicsContext currentContext];
	if (drawfocusrect)
	{
		[[NSColor colorWithDeviceRed:.1 green:.1 blue:.5 alpha:.5] setFill];
		NSRectFill([self bounds]);
	}
}
- (void)mouseMoved:(NSEvent*)e
{
	NSPoint P = [e locationInWindow];
	P = [self convertPoint:P fromView:nil];
	int nmi = (P.y-25) / 30;
	int nmj = (P.x-25) / 30;
	if (nmi!=mi || nmj!=mj)
	{
		mi=nmi;
		mj=nmj;
		if (mi<0 || mj<0 || mi>=Rows || mj>=Cols) m_in=false; else m_in=true;
		[self realignSmileys];
	}
}
- (void)mouseExited:(NSEvent*)e
{
	mi=mj=-1;
	m_in = false;
	[self realignSmileys];
	[[NSGarbageCollector defaultCollector] collectExhaustively];
	
}
- (void)mouseDown:(NSEvent*)e
{
	dragged = NO;
	draggedout = NO;
	if (m_in)
	{
		clickvalid = YES;
		mdi=mi;
		mdj=mj;
	}
	else
	{
		clickvalid = NO;
	}
}
- (void)mouseDragged:(NSEvent*)e
{
	if (!clickvalid) return;
	if (draggedout) return;
	if (!dragged)
	{
		draggingSmileyView = [smileyViews objectAtIndex:mdi*Cols+mdj];
		draggingSmiley = [smileys objectAtIndex:mdi*Cols+mdj];
		[smileyViews removeObjectAtIndex:mdi*Cols+mdj];
		dragged = YES;
		[self realignSmileys];
	}
	else
	{
		[self mouseMoved:e];
		if (!m_in)
		{
			
			NSMutableData *data = [[NSMutableData alloc] init];
			NSKeyedArchiver *arc = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[arc setOutputFormat:NSPropertyListBinaryFormat_v1_0];
			[arc encodeObject:draggingSmiley forKey:@"smiley"];
			[arc finishEncoding];
			
			draggedout = true;
			NSPasteboard *pboard;
			
			pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
			[pboard declareTypes:[NSArray arrayWithObject:@"iSmile_Smiley"]  owner:self];
			[pboard setData:data forType:@"iSmile_Smiley"];
			[draggingSmileyView setHidden:YES];

			[self dragImage:[draggingSmileyView image] 
						 at:[self convertPoint:[e locationInWindow] fromView:nil]
					 offset:NSMakeSize(0, 0) 
					  event:e 
				 pasteboard:pboard 
					 source:self
				  slideBack:YES];
		}
	}
}
- (void)mouseUp:(NSEvent*)e
{
	if (clickvalid && !dragged)
	{
		NSLog(@"Click at %d %d",mdi,mdj);
		int idx = mdi*Cols+mdj;
		if (idx>=[smileys count])
		{
			NSLog(@"Invalid click!");
		}
		else
		{
			smiley *s = [smileys objectAtIndex:mdi*Cols+mdj];
			NSLog(@"URL is %@", s.url);
		}
		return;
	}
	if (dragged)
	{
		if (m_in)
		{
			if (mi*Cols+mj>[smileyViews count])
			{
				[smileyViews addObject:draggingSmileyView];
				[smileys removeObject:draggingSmiley];
				[smileys addObject:draggingSmiley];
				[self setSubviews:smileyViews];			
			}
			else
			{
				[smileyViews insertObject:draggingSmileyView atIndex:mi*Cols+mj];
				[smileys removeObject:draggingSmiley];
				[smileys insertObject:draggingSmiley atIndex: mi*Cols+mj];
				[self setSubviews:smileyViews];
			}
		}
		else
		{
			[smileyViews insertObject:draggingSmileyView atIndex:mdi*Cols+mdj];
		}
		dragged = NO;
		[self realignSmileys];
	}
}

-(NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (!isLocal)
		return NSDragOperationDelete;
	return NSDragOperationMove;
}
- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
	NSLog(@"BeganAt %.2f %.2f",aPoint.x, aPoint.y);
	[controller dragStarted];
}
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	NSLog(@"EndedAt %.2f %.2f , %d",aPoint.x,aPoint.y,operation);
	dragged=NO;
	draggedout=NO;
	if (operation == NSDragOperationNone)
	{
		[smileyViews insertObject:draggingSmileyView atIndex:mdi*Cols+mdj];	
		[draggingSmileyView setHidden:NO];
		[self realignSmileys];
	}
	else if (operation == NSDragOperationDelete || operation == NSDragOperationMove)
	{
		if (operation == NSDragOperationDelete)
			NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, aPoint, NSZeroSize, nil, nil, nil);
		draggingSmileyView = nil;
		[smileys removeObject:draggingSmiley];
		draggingSmiley = nil;
		[self realignSmileys];
	}
	[controller dragFinished];
}
- (NSDragOperation)draggingEntered:(id)sender {
	NSLog(@"Enter!");
	[self setNeedsDisplay:YES];	
	drawfocusrect = YES;
	NSLog(@"%@", [[sender draggingPasteboard] types]);
	if ([[[sender draggingPasteboard] types] containsObject:@"iSmile_Smiley"]) return NSDragOperationMove;
	if ([[[sender draggingPasteboard] types] containsObject:NSURLPboardType]) return NSDragOperationCopy;
	drawfocusrect = NO;
	NSLog(@"Failed!");
	return NSDragOperationNone;
}
- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	drawfocusrect = NO;
	[self setNeedsDisplay:YES];
}
- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	drawfocusrect = NO;
	NSLog(@"Prepare!");
	[self setNeedsDisplay:YES];
	NSPasteboard *pb = [sender draggingPasteboard];
	if ([[pb types] containsObject:@"iSmile_Smiley"]) return YES;
	if ([[pb types] containsObject:NSURLPboardType]) return YES;
	return NO;
}
- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	NSLog(@"Perform!");
	NSPasteboard *pb = [sender draggingPasteboard];
	if ([[pb types] containsObject:@"iSmile_Smiley"])
	{
		NSData* data = [pb dataForType:@"iSmile_Smiley"];
		NSKeyedUnarchiver* unarc = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		smiley* s = [unarc decodeObjectForKey:@"smiley"];
		if (s==nil) return NO;
		[smileys addObject:s];
		NSRect r; r.size.width=25; r.size.height=25; r.origin = NSZeroPoint;
		smileyView* v = [[smileyView alloc] initWithFrame:r];
		[v setImage: [[NSImage alloc] initWithData:s.icondata]];
		[v setAnimates:NO];
		[v setImageScaling:NSScaleProportionally];
		[smileyViews addObject:v];
		[self setSubviews:smileyViews];
		[self realignSmileys];
		return YES;
	}
	if ([[pb types] containsObject:NSURLPboardType])
	{
		NSURL* url = [NSURL URLFromPasteboard:pb];
		if (url==nil) return NO;
		smiley* s = [[smiley alloc] init];
		s.url = [url absoluteString];
		s.icondata = [NSData dataWithContentsOfURL:url];
		if (s.icondata==nil) return NO;
		s.tabname = tabName;
		[smileys addObject:s];
		NSRect r; r.size.width=25; r.size.height=25; r.origin = NSZeroPoint;
		smileyView* v = [[smileyView alloc] initWithFrame:r];
		[v setImage: [[NSImage alloc] initWithData:s.icondata]];
		[v setAnimates:NO];
		[v setImageScaling:NSScaleProportionally];
		[smileyViews addObject:v];
		[self setSubviews:smileyViews];
		[self realignSmileys];
		return YES;
	}
	return NO;
}
-(void)setSmileyList:(NSMutableArray*)sl
{
	smileys = sl;
	smileyViews = [[NSMutableArray alloc] init];
	NSRect myFrame = [self frame];
	CGFloat x=0,y=0;
	for(smiley* s in sl)
	{
		if (x+25>myFrame.size.width)
		{
			x=0;
			y+=25;
		}
		NSRect r;
		r.size.width = 25;
		r.size.height= 25;
		r.origin.x = x;
		r.origin.y = y;
		smileyView* v = [[smileyView alloc] initWithFrame:r];
		[v setImage: [[NSImage alloc] initWithData:s.icondata]];
		[v setAnimates:NO];
		[v setImageScaling:NSScaleProportionally];
		[smileyViews addObject:v];
	}
	[self setSubviews:smileyViews];
}
-(bool)isFlipped
{
	return YES;
}
-(void)realignSmileys
{
	if (smileyViews==nil) return;
	NSRect myFrame = [self frame];
	CGFloat x=25,y=25;
	int i=0,j=0;
	if (dragged && m_in)
	{
		NSRect r;
		r.size.width = r.size.height = 75;
		r.origin.y = mi*30;
		r.origin.x = mj*30;
		[[draggingSmileyView animator] setFrame: r];
	}
	for(smileyView* v in smileyViews)
	{
	Again:
		if (x+55>myFrame.size.width)
		{
			x=25;
			y+=30;
			j=0;
			i++;
		}
		NSRect r;
		r.size.width = 30;
		r.size.height= 30;
		r.origin.x = x;
		r.origin.y = y;
		bool animate = false;
		if (m_in)
		{
			if (i<mi)
			{
				r.origin.y -= 25;
			}
			else if (i==mi)
			{
				if (j<mj)
				{
					r.origin.x -= 25;
				}
				else if (j==mj)
				{
					r.origin.x -= 25;
					r.origin.y -= 25;
					r.size.width += 50;
					r.size.height += 50;
					animate = true;
				}
				else
				{
					r.origin.x += 25;
				}
			}
			else
			{
				r.origin.y += 25;
			}
		}		
		if (dragged && m_in && i==mi && j==mj)
		{
			x+=30;
			j++;
			goto Again;
		}		

		[[v animator] setFrame: r];
		if (animate)
		{
			[v setAnimates: YES];
			[v setImageFrameStyle:NSImageFrameButton];
		}
		else
		{
			[v setAnimates:NO];
			[v setImageFrameStyle:NSImageFrameNone];
		}
		x+=30;
		j++;
	}
}
-(void)setFrame:(NSRect)rect
{
	Cols = (int)(rect.size.width-50)/30;
	Rows = (int)(rect.size.height-50)/30;
	[super setFrame:rect];
	[self realignSmileys];
}
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return [controller tabContextMenu];
}
@end
