// -*- mode:objc -*-
// $Id: PTYTextView.m,v 1.41 2003-03-25 17:33:27 yfabian Exp $
/*
 **  PTYTextView.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Sathyam
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSTextView subclass. The view object for the VT100 screen.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#define DEBUG_ALLOC           0
#define DEBUG_METHOD_TRACE    0
#define GREED_KEYDOWN         1

#import "iTerm.h"
#import "PTYTextView.h"
#import "PTYSession.h"

#if USE_CUSTOM_DRAWING
@implementation PTYTextView

- (id)init
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -init");
#endif
    NSDictionary *dic;

    self = [super init];
//    [[NSCursor IBeamCursor] setOnMouseEntered: NO];
    dataSource=_delegate=markedTextAttributes=NULL;
    dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSColor yellowColor],
        NSBackgroundColorAttributeName,
        [NSColor blackColor],NSForegroundColorAttributeName,
        [NSNumber numberWithInt:2],NSUnderlineStyleAttributeName,NULL];
    [self setMarkedTextAttributes:dic];
    
    deadkey = NO;

    return (self);
}

- (id)initWithFrame: (NSRect) aRect
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -init");
#endif
    NSDictionary *dic;
    self = [super initWithFrame: aRect];
//    [[NSCursor IBeamCursor] setOnMouseEntered: NO];
    dataSource=_delegate=markedTextAttributes=NULL;

    dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSColor yellowColor],
        NSBackgroundColorAttributeName,
        [NSColor blackColor],NSForegroundColorAttributeName,
        [NSNumber numberWithInt:2],NSUnderlineStyleAttributeName,NULL];
    [self setMarkedTextAttributes:dic];
    deadkey = NO;

    return (self);

}

- (BOOL)isFlipped
{
    return YES;
}

- (void) dealloc
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -dealloc");
#endif

    [dataSource release];
    [_delegate release];
    [font release];
    [selectionColor release];
    [markedTextAttributes release];
    
    dataSource = nil;

    [super dealloc];
}

- (BOOL)shouldDrawInsertionPoint
{
#if 0 // DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView shouldDrawInsertionPoint]",
          __FILE__, __LINE__);
#endif
    return NO;
}

- (NSColor *) backgroundColor
{
    return bgColor;
}

- (void) setBackgroundColor: (NSColor *)color
{
    [bgColor release];
    bgColor=[color retain];
}

- (BOOL) antiAlias
{
    return (antiAlias);
}

- (void) setAntiAlias: (BOOL) antiAliasFlag
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setAntiAlias: %d]",
          __FILE__, __LINE__, antiAliasFlag);
#endif
    antiAlias = antiAliasFlag;
}

- (NSDictionary*) markedTextAttributes
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView selectedTextAttributes]",
          __FILE__, __LINE__);
#endif
    return markedTextAttributes;
}

- (void) setMarkedTextAttributes: (NSDictionary *) attr
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setSelectedTextAttributes:%@]",
          __FILE__, __LINE__,attr);
#endif
    [markedTextAttributes release];
    markedTextAttributes=[attr copy];
}

- (NSColor *) selectionColor
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView selectionColor]",
          __FILE__, __LINE__);
#endif
    
    return selectionColor;

}

- (void) setSelectionColor: (NSColor *) aColor
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setSelectionColor:%@]",
          __FILE__, __LINE__,aColor);
#endif

    [selectionColor release];
    selectionColor=[aColor copy];
}

- (NSFont *)font
{
    return font;
}

- (NSFont *)nafont
{
    return nafont;
}

- (void) setFont:(NSFont*)aFont nafont:(NSFont *)naFont;
{
    NSDictionary *dic=markedTextAttributes;

    dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSColor yellowColor],
        NSBackgroundColorAttributeName,
        [NSColor blackColor],NSForegroundColorAttributeName,
        [NSNumber numberWithInt:2],NSUnderlineStyleAttributeName,NULL];
    [self setMarkedTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [dic objectForKey: NSBackgroundColorAttributeName], NSBackgroundColorAttributeName,
            [dic objectForKey: NSForegroundColorAttributeName], NSForegroundColorAttributeName,
            naFont, NSFontAttributeName,
            [NSNumber numberWithInt:2],NSUnderlineStyleAttributeName,
            NULL]];
    
    
    [font release];
    font=[aFont copy];
    [nafont release];
    nafont=[naFont copy];
}


- (id) dataSource
{
    return (dataSource);
}

- (void) setDataSource: (id) aDataSource
{
   [dataSource release];
   [aDataSource retain];
   dataSource = aDataSource;
}

- (id) delegate
{
    return _delegate;
}

- (void) setDelegate: (id) aDelegate
{
    [_delegate release];
    [_delegate retain];
    _delegate = aDelegate;
}    

- (float) lineHeight
{
    return (lineHeight);
}

- (void) setLineHeight: (float) aLineHeight
{
    lineHeight = aLineHeight;
}

- (float) lineWidth
{
    return (lineWidth);
}

- (void) setLineWidth: (float) aLineWidth
{
    lineWidth = aLineWidth;
}

- (void) refresh
{
    NSSize aSize;

    if([self dataSource] != nil)
    {
        numberOfLines = [dataSource numberOfLines];
        aSize = [self frame].size;
        aSize.height = numberOfLines * lineHeight;
        if(aSize.height > [[self enclosingScrollView] documentVisibleRect].size.height)
        {
            NSRect aFrame;

            aFrame = [self frame];
            aFrame.size.height = aSize.height;
            [self setFrame: aFrame];
        }
        [self setNeedsDisplay: YES];
    }


}

-(void) scrollLineUp:(id) receiver
{
    NSRect scrollRect = [self frame];

    scrollRect.origin.y+=lineHeight;
    scrollRect.size.height=lineHeight;
    [self scrollRectToVisible: scrollRect];
}

-(void) scrollLineDown:(id) receiver
{
    NSRect scrollRect = [self frame];

    scrollRect.origin.y-=lineHeight;
    scrollRect.size.height=lineHeight;
    [self scrollRectToVisible: scrollRect];
}

-(void) scrollPageUp:(id) receiver
{
}

-(void) scrollPageDown:(id) receiver;
{
}


- (void)moveLastLine
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView moveLastLine]", __FILE__, __LINE__ );
#endif

    if (numberOfLines > 0)
    {
        NSRect aFrame;

        aFrame.origin.x = 0;
        aFrame.origin.y = (numberOfLines - 1) * lineHeight;
        aFrame.size.width = [self frame].size.width;
        aFrame.size.height = lineHeight;

        [self scrollRectToVisible: aFrame];
    }
}


- (void)drawRect:(NSRect)rect
{

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView drawRect:(%f,%f,%f,%f)]",
          __FILE__, __LINE__,
          rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif

    // set the antialias flag
    [[NSGraphicsContext currentContext] setShouldAntialias: antiAlias];

    [super drawRect: rect];

    int numLines, i, lineOffset;
    int y=[dataSource cursorY]-1+[dataSource topLines];
    NSAttributedString *aLine;
    NSRect aRect;
    float halfLine;

    if(lineHeight <= 0 || lineWidth <= 0)
        return;


    lineOffset = rect.origin.y/lineHeight;
    halfLine=rect.origin.y-lineOffset*lineHeight;
    numLines=(rect.size.height+halfLine+lineHeight-1)/lineHeight;
    aRect.origin.x=rect.origin.x;
    aRect.origin.y=lineOffset*lineHeight;
    aRect.size.width = lineWidth;
    aRect.size.height = lineHeight;
    //NSLog(@"%f+%f->%d+%d", rect.origin.y,rect.size.height,lineOffset,numLines);

    for(i = 0; i <numLines/*&&aRect.origin.y<rect.orgin.y+rect.size.height*/; i++)
    {
        aLine = [[self dataSource] stringAtLine: i + lineOffset];
        if(aLine == nil)
        {
            //NSLog(@"Got a nil line...");
            ;
        }else {
            if (i+lineOffset==y&&![self hasMarkedText]) {
                // show the cursor in the line array
                NSMutableAttributedString *s=[[NSMutableAttributedString alloc] initWithAttributedString:aLine];
                NSMutableDictionary *dic;
                NSColor *fg, *bg;
                int idx;

                idx=[dataSource getIndexAtX:[dataSource cursorX]-1 Y:[dataSource cursorY]-1 withPadding:YES];
                if(idx >= [aLine length])
                    [s appendAttributedString:[dataSource defaultAttrString:@" "]];
                // reverse the video on the position where the cursor is supposed to be shown.
                dic=[NSMutableDictionary dictionaryWithDictionary: [s attributesAtIndex:idx effectiveRange:nil]];
                fg=[dic objectForKey:NSBackgroundColorAttributeName];
                bg=[dic objectForKey:NSForegroundColorAttributeName];
                [dic setObject:bg forKey:NSBackgroundColorAttributeName];
                [dic setObject:fg forKey:NSForegroundColorAttributeName];
                [s setAttributes:dic range:NSMakeRange(idx,1)];
                [s drawInRect: aRect];
                [s release];
            }
            else [aLine drawInRect: aRect];
        }
        //NSLog(@"line %d[%@]: %f",i + lineOffset, [aLine string], aRect.origin.y);
        aRect.origin.y += lineHeight;
    }
}


- (void)keyDown:(NSEvent *)event
{
    NSInputManager *imana = [NSInputManager currentInputManager];
    BOOL IMEnable = [imana wantsToInterpretAllKeystrokes];
    BOOL put;
    id delegate = [self delegate];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView keyDown:%@]",
          __FILE__, __LINE__, event );
#endif

    // Check for dead keys
    if (deadkey) {
        [self interpretKeyEvents:[NSArray arrayWithObject:event]];
        deadkey=[self hasMarkedText];
        return;
    }
    else if ([[event characters] length]<1) {
        deadkey=YES;
        [self interpretKeyEvents:[NSArray arrayWithObject:event]];
        return;
    }

    if (IMEnable) {
        BOOL prev = [self hasMarkedText];
        IM_INPUT_INSERT = NO;
        [self interpretKeyEvents:[NSArray arrayWithObject:event]];

#if GREED_KEYDOWN
        if (prev == NO &&
            IM_INPUT_INSERT == NO &&
            [self hasMarkedText] == NO)
        {
            put = YES;
        }
        else
            put = NO;
#else
        put = NO;
#endif
    }
    else
        put = YES;

    if (put == YES) {
        if ([delegate respondsToSelector:@selector(keyDown:)])
            [delegate keyDown:event];
        else
            [super keyDown:event];
    }
}

- (void)mouseDown:(NSEvent *)event
{
//#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView mouseDown:%@]",
          __FILE__, __LINE__, event );
//#endif
}

- (void)mouseUp:(NSEvent *)event
{
//#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView mouseUp:%@]",
          __FILE__, __LINE__, event );
//#endif
}

- (void)mouseDragged:(NSEvent *)event
{
    //#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView mouseDragged:%@]",
          __FILE__, __LINE__, event );
    //#endif
}


// Override copy and paste to do our stuff
- (void) copy: (id) sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *aString;
//    NSMutableAttributedString *aMutableAttributedString;
//    int i = 0;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView copy:%@]", __FILE__, __LINE__, sender );
#endif


    // Put the trimmed string on the pasteboard
    [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: self];
    [pboard setString: aString forType: NSStringPboardType];

}

- (void)paste:(id)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView paste:%@]", __FILE__, __LINE__, sender );
#endif

}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView validateMenuItem:%@; supermenu = %@]", __FILE__, __LINE__, item, [[item menu] supermenu] );
#endif

    if ([item action] == @selector(paste:))
    {
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];

        // Check if there is a string type on the pasteboard
        return ([pboard stringForType:NSStringPboardType] != nil);
    }
    else if ([item action ] == @selector(cut:))
        return NO;
    else if ([item action]==@selector(saveDocumentAs:))
    {
        // We always validate the "Save" command
        return (YES);
    }
    else if ([item action]==@selector(mail:) ||
             [item action]==@selector(browse:))
    {
        //        NSLog(@"selected range:%d",[self selectedRange].length);
        return ([self selectedRange].length>0);
    }
    else
        return NO;
}

- (void)changeFont:(id)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView changeFont:%@]", __FILE__, __LINE__, sender );
#endif

        [super changeFont:sender];

}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    NSMenu *cMenu;

    // Allocate a menu
    cMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];

    // Menu items for acting on text selections
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"-> Browser",@"iTerm",@"Context menu")
                                          action:@selector(browse:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"-> Mail",@"iTerm",@"Context menu")
                                          action:@selector(mail:) keyEquivalent:@""];

    // Separator
    [cMenu addItem:[NSMenuItem separatorItem]];

    // Copy,  paste, and save
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Copy",@"iTerm",@"Context menu")
                                          action:@selector(copy:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Paste",@"iTerm",@"Context menu")
                                          action:@selector(paste:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Save",@"iTerm",@"Context menu")
                                          action:@selector(saveDocumentAs:) keyEquivalent:@""];

    // Separator
    [cMenu addItem:[NSMenuItem separatorItem]];

    // Select all
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Select All",@"iTerm",@"Context menu")
                                          action:@selector(selectAll:) keyEquivalent:@""];


    return [cMenu autorelease];
}

- (void) mail:(id)sender
{
    NSString *s = [[self attributedSubstringFromRange:[self selectedRange]] string];
    NSURL *url;

    if (![s hasPrefix:@"mailto:"])
        url = [NSURL URLWithString:[@"mailto:" stringByAppendingString:s]];
    else
        url = [NSURL URLWithString:s];

    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) browse:(id)sender
{
    NSString *s = [[self attributedSubstringFromRange:[self selectedRange]] string];
    NSURL *url;

    if (![s hasPrefix:@"http://"])
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:s]];
    else
        url = [NSURL URLWithString:s];

    [[NSWorkspace sharedWorkspace] openURL:url];
}


//
// Drag and Drop methods for our text view
//

//
// Called when our drop area is entered
//
- (unsigned int) draggingEntered:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingEntered:%@]", __FILE__, __LINE__, sender );
#endif

    // Always say YES; handle failure later.
    bExtendedDragNDrop = YES;


    return bExtendedDragNDrop;
}


//
// Called when the dragged object is moved within our drop area
//
- (unsigned int) draggingUpdated:(id <NSDraggingInfo>)sender
{
    unsigned int iResult;
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingUpdated:%@]", __FILE__, __LINE__, sender );
#endif

    // Let's see if our parent NSTextView knows what to do
    iResult = [super draggingUpdated: sender];

    // If parent class does not know how to deal with this drag type, check if we do.
    if (iResult == NSDragOperationNone) // Parent NSTextView does not support this drag type.
    {
        return [self _checkForSupportedDragTypes: sender];
    }

    return iResult;
}


//
// Called when the dragged object leaves our drop area
//
- (void) draggingExited:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingExited:%@]", __FILE__, __LINE__, sender );
#endif

    // We don't do anything special, so let the parent NSTextView handle this.
    [super draggingExited: sender];

    // Reset our handler flag
    bExtendedDragNDrop = NO;
}


//
// Called when the dragged item is about to be released in our drop area.
//
- (BOOL) prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    BOOL bResult;
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView prepareForDragOperation:%@]", __FILE__, __LINE__, sender );
#endif

    // Check if parent NSTextView knows how to handle this.
    bResult = [super prepareForDragOperation: sender];

    // If parent class does not know how to deal with this drag type, check if we do.
    if ( bResult != YES &&
         [self _checkForSupportedDragTypes: sender] != NSDragOperationNone )
    {
        bResult = YES;
    }

    return bResult;
}


//
// Called when the dragged item is released in our drop area.
//
- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{
    unsigned int dragOperation;
    BOOL bResult = NO;
    PTYSession *delegate = [self delegate];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView performDragOperation:%@]", __FILE__, __LINE__, sender );
#endif


    // If parent class does not know how to deal with this drag type, check if we do.
    if (bExtendedDragNDrop)
    {
        NSPasteboard *pb = [sender draggingPasteboard];
        NSArray *propertyList;
        NSString *aString;
        int i;

        dragOperation = [self _checkForSupportedDragTypes: sender];

        switch (dragOperation)
        {
            case NSDragOperationCopy:
                // Check for simple strings first
                aString = [pb stringForType:NSStringPboardType];
                if (aString != nil)
                {
                    if ([delegate respondsToSelector:@selector(pasteString:)])
                        [delegate pasteString: aString];
                }
                    // Check for file names
                    propertyList = [pb propertyListForType: NSFilenamesPboardType];
                for(i = 0; i < [propertyList count]; i++)
                {
                    // Just paste the file names into the shell after escaping special characters.
                    if ([delegate respondsToSelector:@selector(pasteString:)])
                    {
                        NSMutableString *aMutableString;

                        aMutableString = [[NSMutableString alloc] initWithString: (NSString*)[propertyList objectAtIndex: i]];
                        // get rid of special characters
                        [aMutableString replaceOccurrencesOfString: @"\\" withString: @"\\\\" options: 0 range: NSMakeRange(0, [aMutableString length])];
                        [aMutableString replaceOccurrencesOfString: @" " withString: @"\\ " options: 0 range: NSMakeRange(0, [aMutableString length])];
                        [aMutableString replaceOccurrencesOfString: @"(" withString: @"\\(" options: 0 range: NSMakeRange(0, [aMutableString length])];
                        [aMutableString replaceOccurrencesOfString: @")" withString: @"\\)" options: 0 range: NSMakeRange(0, [aMutableString length])];
                        [aMutableString replaceOccurrencesOfString: @"\"" withString: @"\\\"" options: 0 range: NSMakeRange(0, [aMutableString length])];
    [aMutableString replaceOccurrencesOfString: @"&" withString: @"\\&" options: 0 range: NSMakeRange(0, [aMutableString length])];
    [aMutableString replaceOccurrencesOfString: @"'" withString: @"\\'" options: 0 range: NSMakeRange(0, [aMutableString length])];



    [delegate pasteString: aMutableString];
    [delegate pasteString: @" "];
    [aMutableString release];
                    }

                }
    bResult = YES;
    break;				
        }

    }

    return bResult;
}


//
//
//
- (void) concludeDragOperation:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView concludeDragOperation:%@]", __FILE__, __LINE__, sender );
#endif

    // If we did no handle the drag'n'drop, ask our parent to clean up
    // I really wish the concludeDragOperation would have a useful exit value.
    if (!bExtendedDragNDrop)
    {
        [super concludeDragOperation: sender];
    }

    bExtendedDragNDrop = NO;
}

// Save method
- (void) saveDocumentAs: (id) sender
{

    NSString *aString;
    NSData *aData;
    NSSavePanel *aSavePanel;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView saveDocumentAs:%@]", __FILE__, __LINE__, sender );
#endif

    // We get our content of the textview or selection, if any
    if([self selectedRange].length > 0)
        aString = [[self attributedSubstringFromRange:[self selectedRange]] string];
    else
        aString = [[dataSource stringAtLine:[dataSource cursorY]-1+[dataSource topLines]] string];
    aData = [aString
            dataUsingEncoding: NSASCIIStringEncoding
         allowLossyConversion: YES];
    // retain here so that is does not go away...
    [aData retain];

    // initialize a save panel
    aSavePanel = [NSSavePanel savePanel];
    [aSavePanel setAccessoryView: nil];
    [aSavePanel setRequiredFileType: @""];

    // Run the save panel as a sheet
    [aSavePanel beginSheetForDirectory: @""
                                  file: @"Unknown"
                        modalForWindow: [self window]
                         modalDelegate: self
                        didEndSelector: @selector(_savePanelDidEnd: returnCode: contextInfo:)
                           contextInfo: aData];


}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    NSLog(@"otherMouseDown");
    //[self paste];
}

- (void)resetCursorRects
{
    static NSCursor *cursor=nil;

    //    NSLog(@"Setting mouse here");
    if (!cursor) cursor=[[[NSCursor alloc] initWithImage:[[NSCursor arrowCursor] image] hotSpot:NSMakePoint(0,0)] retain];
    [self addCursorRect:[self bounds] cursor:cursor];
    [cursor setOnMouseEntered:YES];
}

- (void) setCursorIndex:(int) idx
{
    cursorIndex=idx;
}



/// NSTextInput stuff
- (void)doCommandBySelector:(SEL)aSelector
{

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView doCommandBySelector:...]",
          __FILE__, __LINE__);
#endif

#if GREED_KEYDOWN == 0
    id delegate = [self delegate];

    if ([delegate respondsToSelector:aSelector]) {
        [delegate performSelector:aSelector withObject:nil];
    }
#endif
}

- (void)insertText:(id)aString
{
    int y=[dataSource cursorY]-1+[dataSource topLines];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView insertText:%@]",
          __FILE__, __LINE__, aString);
#endif
    IM_INPUT_INSERT = YES;

    [[dataSource stringAtLine: y] deleteCharactersInRange:[self markedRange]];
    IM_INPUT_MARKEDRANGE = NSMakeRange(0, 0);

    if ([_delegate respondsToSelector:@selector(insertText:)])
        [_delegate insertText:aString];
    else
        [super insertText:aString];
}

- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange
{
    NSRange repRange;
    int y=[dataSource cursorY]-1;
    int x=[dataSource cursorX]-1;
    NSAttributedString *as=[[NSAttributedString alloc] initWithString:[aString string] attributes:[self markedTextAttributes]];
    NSMutableAttributedString *aLine=[dataSource stringAtLine:y+[dataSource topLines]];
    
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setMarkedText:%@ selectedRange:(%d,%d)]",
          __FILE__, __LINE__, aString, selRange.location, selRange.length);
#endif

    if ([self hasMarkedText]) {
        repRange = [self markedRange];
    }
    else {
        repRange = NSMakeRange([dataSource getIndexAtX:x Y:y withPadding:NO], 0);
    }
    [aLine replaceCharactersInRange:repRange
               withAttributedString:as];
    IM_INPUT_MARKEDRANGE = NSMakeRange(0,
                                       [(NSAttributedString *)aString length]);
    IM_INPUT_SELRANGE = selRange;

    [self setNeedsDisplay:YES];
}

- (void)unmarkText
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView unmarkText]", __FILE__, __LINE__ );
#endif
    IM_INPUT_MARKEDRANGE = NSMakeRange(0, 0);
}

- (BOOL)hasMarkedText
{
    BOOL result;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView hasMarkedText]", __FILE__, __LINE__ );
#endif
    if (IM_INPUT_MARKEDRANGE.length > 0)
        result = YES;
    else
        result = NO;

    return result;
}

- (NSRange)markedRange
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView markedRange]", __FILE__, __LINE__);
#endif

    //return IM_INPUT_MARKEDRANGE;
    if (IM_INPUT_MARKEDRANGE.length > 0) {
        return NSMakeRange([dataSource getIndexAtX:[dataSource cursorX]-1 Y:[dataSource cursorY]-1 withPadding:NO], IM_INPUT_MARKEDRANGE.length);
    }
    else
        return NSMakeRange([dataSource getIndexAtX:[dataSource cursorX]-1 Y:[dataSource cursorY]-1 withPadding:NO], 0);
}

- (NSRange)selectedRange
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView selectedRange]", __FILE__, __LINE__);
#endif
    return NSMakeRange(NSNotFound, 0);
}

- (NSArray *)validAttributesForMarkedText
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView validAttributesForMarkedText]", __FILE__, __LINE__);
#endif
    return [NSArray arrayWithObjects:NSForegroundColorAttributeName,
        NSBackgroundColorAttributeName,
        NSUnderlineStyleAttributeName,
        nil];
}

- (NSAttributedString *)attributedSubstringFromRange:(NSRange)theRange
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView attributedSubstringFromRange:(%d,%d)]", __FILE__, __LINE__, theRange.location, theRange.length);
#endif
    int y=[dataSource cursorY]-1;
    NSAttributedString *aLine=[dataSource stringAtLine:y+[dataSource topLines]];

    return [aLine attributedSubstringFromRange:theRange];
}

- (unsigned int)characterIndexForPoint:(NSPoint)thePoint
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView characterIndexForPoint:(%f,%f)]", __FILE__, __LINE__, thePoint.x, thePoint.y);
#endif
    NSSize s=[VT100Screen fontSize: [dataSource font]];

    return [dataSource getIndexAtX:thePoint.x/s.width Y:thePoint.y/s.height withPadding:NO ];
}

- (long)conversationIdentifier
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView conversationIdentifier]", __FILE__, __LINE__);
#endif
    return [self hash]; //not sure about this
}

- (NSRect)firstRectForCharacterRange:(NSRange)theRange
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView firstRectForCharacterRange:(%d,%d)]", __FILE__, __LINE__, theRange.location, theRange.length);
#endif
    int y=[dataSource cursorY]-1;
    int x=[dataSource cursorX]-1;
    NSAttributedString *aLine=[dataSource stringAtLine:y+[dataSource topLines]];
    NSSize s=[[aLine attributedSubstringFromRange:theRange] size];

    return NSMakeRect(x*[VT100Screen fontSize: [dataSource font]].width+[self frame].origin.x,y*lineHeight+[self frame].origin.y,s.width,s.height);
}


@end


//
// private methods
//
@implementation PTYTextView (Private)

- (unsigned int) _checkForSupportedDragTypes:(id <NSDraggingInfo>) sender
{
    NSString *sourceType;
    BOOL iResult;

    iResult = NSDragOperationNone;

    // We support the FileName drag type for attching files
    sourceType = [[sender draggingPasteboard] availableTypeFromArray: [NSArray arrayWithObjects:
        NSFilenamesPboardType,
        NSStringPboardType,
        nil]];

    if (sourceType)
    {
        iResult = NSDragOperationCopy;
    }

    return iResult;
}

- (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel
                      returnCode: (int) theReturnCode
                     contextInfo: (void *) theContextInfo
{
    // If successful, save file under designated name
    if (theReturnCode == NSOKButton)
    {
        if ( ![(NSData *)theContextInfo writeToFile: [theSavePanel filename]
                                         atomically: YES] )
        {
            NSBeep();
        }
    }
    // release our hold on the data
    [(NSData *)theContextInfo release];

}

@end

#else
@implementation PTYTextView

- (id)init
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -init");
#endif

    self = [super init];
    deadkey = NO;

    return (self);
}

- (id)initWithFrame: (NSRect) aRect
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -init");
#endif

    self = [super initWithFrame: aRect];
    [[NSCursor IBeamCursor] setOnMouseEntered: NO];

    deadkey = NO;

    return (self);
    
}

- (void) dealloc
{
#if DEBUG_ALLOC
    NSLog(@"PTYTextView: -dealloc");
#endif

    if(dataSource != nil)
    {
	[dataSource release];
	dataSource = nil;
    }    
        
    [super dealloc];
}

- (BOOL)shouldDrawInsertionPoint
{
#if 0 // DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView shouldDrawInsertionPoint]",
	  __FILE__, __LINE__);
#endif
    return NO;
}

- (BOOL) antiAlias
{
    return (antiAlias);
}

- (void) setAntiAlias: (BOOL) antiAliasFlag
{
#if 0 // DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setAntiAlias: %d]",
	  __FILE__, __LINE__, antiAliasFlag);
#endif
    antiAlias = antiAliasFlag;
}

- (NSColor *) selectionColor
{
    NSDictionary *dic;
    
    dic = [self selectedTextAttributes];
    
    return ([dic objectForKey: NSBackgroundColorAttributeName]);

}

- (void) setSelectionColor: (NSColor *) aColor
{
    NSDictionary *dic;
    
    if(aColor != nil)
    {
        dic = [NSDictionary dictionaryWithObjectsAndKeys: aColor, NSBackgroundColorAttributeName, nil];
        [self setSelectedTextAttributes: dic];
    }

}


- (id) dataSource
{
    return (dataSource);
}

- (void) setDataSource: (id) aDataSource
{
    if(dataSource != nil)
    {
	[dataSource release];
	dataSource = nil;
    }
    if(aDataSource != nil)
    {
	[aDataSource retain];
	dataSource = aDataSource;
    }
}



- (float) lineHeight
{
    return (lineHeight);
}

- (void) setLineHeight: (float) aLineHeight
{
    lineHeight = aLineHeight;
}

- (float) lineWidth
{
    return (lineWidth);
}

- (void) setLineWidth: (float) aLineWidth
{
    lineWidth = aLineWidth;
}

- (void) refresh
{
    NSSize aSize;

    if([self dataSource] != nil)
    {
	numberOfLines = [dataSource numberOfLines];
	aSize = [self frame].size;
	aSize.height = numberOfLines * lineHeight;
	if(aSize.height > [[self enclosingScrollView] documentVisibleRect].size.height)
	{
	    NSRect aFrame;

	    aFrame = [self frame];
	    aFrame.size.height = aSize.height;
	    [self setFrame: aFrame];
	}
	[self setNeedsDisplay: YES];
    }

    
}

- (void)moveLastLine
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView moveLastLine]", __FILE__, __LINE__ );
#endif

    if (numberOfLines > 0)
    {
	NSRect aFrame;

	aFrame.origin.x = 0;
	aFrame.origin.y = (numberOfLines - 1) * lineHeight;
	aFrame.size.width = [self frame].size.width;
	aFrame.size.height = lineHeight;

	[self scrollRectToVisible: aFrame];
    }
    else
	[self scrollRangeToVisible:NSMakeRange([[self textStorage] length],0)];
    
}


- (void)drawRect:(NSRect)rect
{

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView drawRect:(%f,%f,%f,%f)]",
	  __FILE__, __LINE__,
	  rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif

    // set the antialias flag
    [[NSGraphicsContext currentContext] setShouldAntialias: antiAlias];
    [super drawRect: rect];

}


- (void)keyDown:(NSEvent *)event
{
    NSInputManager *imana = [NSInputManager currentInputManager];
    BOOL IMEnable = [imana wantsToInterpretAllKeystrokes];
    id delegate = [self delegate];
    BOOL put;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView keyDown:%@]",
	  __FILE__, __LINE__, event );
#endif

    // Check for dead keys
    if (deadkey) {
        [self interpretKeyEvents:[NSArray arrayWithObject:event]];
        deadkey=[self hasMarkedText];
	return;
    }
    else if ([[event characters] length]<1) {
        deadkey=YES;
	[self interpretKeyEvents:[NSArray arrayWithObject:event]];
	return;
    }    
    
    if (IMEnable) {
	BOOL prev = [self hasMarkedText];
	IM_INPUT_INSERT = NO;
	[self interpretKeyEvents:[NSArray arrayWithObject:event]];

#if GREED_KEYDOWN
	if (prev == NO && 
	    IM_INPUT_INSERT == NO && 
	    [self hasMarkedText] == NO) 
	{
	    put = YES;
	}
	else
	    put = NO;
#else
	put = NO;
#endif
    }
    else
	put = YES;

    if (put == YES) {
	if ([delegate respondsToSelector:@selector(keyDown:)])
	    [delegate keyDown:event];
	else
	    [super keyDown:event];
    }
}

- (void)doCommandBySelector:(SEL)aSelector
{

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView doCommandBySelector:...]",
	  __FILE__, __LINE__);
#endif

#if GREED_KEYDOWN == 0
    id delegate = [self delegate];

    if ([delegate respondsToSelector:aSelector]) {
	[delegate performSelector:aSelector withObject:nil];
    }
#endif
}

- (void)insertText:(id)aString
{
    id delegate = [self delegate];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView insertText:%@]",
	  __FILE__, __LINE__, aString);
#endif
    NSTextStorage *storage = [self textStorage];

    IM_INPUT_INSERT = YES;

    [storage beginEditing];
    [storage deleteCharactersInRange:[self markedRange]];
    [storage endEditing];
    IM_INPUT_MARKEDRANGE = NSMakeRange(0, 0);

    if ([delegate respondsToSelector:@selector(insertText:)])
	[delegate insertText:aString];
    else
	[super insertText:aString];
}

- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange
{
    NSRange repRange;
    NSTextStorage *storage = [self textStorage];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView setMarkedText:%@ selectedRange:(%d,%d)]",
	  __FILE__, __LINE__, aString, selRange.location, selRange.length);
#endif
    
    if ([self hasMarkedText]) {
	repRange = [self markedRange];
    }
    else {
	repRange = NSMakeRange(cursorIndex, 0);
    }
    [storage beginEditing];
    if ([aString isKindOfClass:[NSAttributedString class]]) {
	[storage replaceCharactersInRange:repRange 
		     withAttributedString:aString];
	IM_INPUT_MARKEDRANGE = NSMakeRange(0, 
					   [(NSAttributedString *)aString length]);
    }
    else {
	[storage replaceCharactersInRange:repRange
			       withString:aString];
	IM_INPUT_MARKEDRANGE = NSMakeRange(0,
					   [(NSString *)aString length]);
    }
    IM_INPUT_SELRANGE = selRange;
    [storage endEditing];

    [self setNeedsDisplay:YES];
}

- (void)unmarkText
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView unmarkText]", __FILE__, __LINE__ );
#endif
    IM_INPUT_MARKEDRANGE = NSMakeRange(0, 0);
}

- (BOOL)hasMarkedText
{
    BOOL result;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView hasMarkedText]", __FILE__, __LINE__ );
#endif
    if (IM_INPUT_MARKEDRANGE.length > 0)
	result = YES;
    else
	result = NO;

    return result;
}

- (NSRange)markedRange 
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView markedRange]", __FILE__, __LINE__);
#endif

    //return IM_INPUT_MARKEDRANGE;
    if (IM_INPUT_MARKEDRANGE.length > 0) {
	NSTextStorage *storage = [self textStorage];
	int len = [storage length];
	int toploc;

	toploc = len - IM_INPUT_MARKEDRANGE.length;
	return NSMakeRange(cursorIndex, IM_INPUT_MARKEDRANGE.length);
    }
    else
	return NSMakeRange(cursorIndex, 0);
}


// Override copy and paste to do our stuff
- (void) copy: (id) sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSString *aString;
    NSMutableAttributedString *aMutableAttributedString;
    int i = 0;

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView copy:%@]", __FILE__, __LINE__, sender );
#endif

    aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString: [[self textStorage] attributedSubstringFromRange: [self selectedRange]]];
    [aMutableAttributedString autorelease];

    if((aMutableAttributedString == nil) || ([aMutableAttributedString length] == 0))
	return;

    // remove linewraps
    while (i < [aMutableAttributedString length])
    {
	if([aMutableAttributedString attribute: @"VT100LineWrap" atIndex: i effectiveRange: nil])
	    [aMutableAttributedString deleteCharactersInRange: NSMakeRange(i, 1)];
	i++;
    }

    // Further process the string
    aString = [aMutableAttributedString string];
    if((aString == nil) || ([aString length] == 0))
	return;
    if([aString length] > 1) // Cocoa bug?
	aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Put the trimmed string on the pasteboard
    [pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: self];
    [pboard setString: aString forType: NSStringPboardType];
    
}

- (void)paste:(id)sender
{
    id delegate = [self delegate];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView paste:%@]", __FILE__, __LINE__, sender );
#endif

    if ([delegate respondsToSelector:@selector(paste:)])
	[delegate paste:sender];
    else
	[super paste:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView validateMenuItem:%@; supermenu = %@]", __FILE__, __LINE__, item, [[item menu] supermenu] );
#endif

    if ([item action] == @selector(paste:))
    {
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];
        
        // Check if there is a string type on the pasteboard
        return ([pboard stringForType:NSStringPboardType] != nil);
    }
    else if ([item action ] == @selector(cut:))
        return NO;
    else if ([item action]==@selector(saveDocumentAs:))
    {
	// We always validate the "Save" command
	return (YES);
    }
    else if ([item action]==@selector(mail:) || 
             [item action]==@selector(browse:)) 
    {
//        NSLog(@"selected range:%d",[self selectedRange].length);
	return ([self selectedRange].length>0);
    }
    else
        return [super validateMenuItem:item];
}

- (void)changeFont:(id)sender
{
    id delegate = [self delegate];

#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView changeFont:%@]", __FILE__, __LINE__, sender );
#endif

    if ([delegate respondsToSelector:@selector(changeFont:)])
	[delegate changeFont:sender];
    else
	[super changeFont:sender];

}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    NSMenu *cMenu;
    
    // Allocate a menu
    cMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];

    // Menu items for acting on text selections
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"-> Browser",@"iTerm",@"Context menu")
			action:@selector(browse:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"-> Mail",@"iTerm",@"Context menu")
			action:@selector(mail:) keyEquivalent:@""];

    // Separator
    [cMenu addItem:[NSMenuItem separatorItem]];

    // Copy,  paste, and save
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Copy",@"iTerm",@"Context menu")
			action:@selector(copy:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Paste",@"iTerm",@"Context menu")
			action:@selector(paste:) keyEquivalent:@""];
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Save",@"iTerm",@"Context menu")
			action:@selector(saveDocumentAs:) keyEquivalent:@""];

    // Separator
    [cMenu addItem:[NSMenuItem separatorItem]];

    // Select all
    [cMenu addItemWithTitle:NSLocalizedStringFromTable(@"Select All",@"iTerm",@"Context menu")
			action:@selector(selectAll:) keyEquivalent:@""];

    
    // Ask the delegae if there is anything to be added
    if ([[self delegate] respondsToSelector:@selector(menuForEvent: menu:)])
	[[self delegate] menuForEvent:theEvent menu: cMenu];

    
    return [cMenu autorelease];
}

- (void) mail:(id)sender
{
    NSString *s = [[self string] substringWithRange:[self selectedRange]];
    NSURL *url;
    
    if (![s hasPrefix:@"mailto:"])
    	url = [NSURL URLWithString:[@"mailto:" stringByAppendingString:s]];
    else
    	url = [NSURL URLWithString:s];

    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) browse:(id)sender
{
    NSString *s = [[self string] substringWithRange:[self selectedRange]];
    NSURL *url;
    
    if (![s hasPrefix:@"http://"])
    	url = [NSURL URLWithString:[@"http://" stringByAppendingString:s]];
    else
    	url = [NSURL URLWithString:s];

    [[NSWorkspace sharedWorkspace] openURL:url];
}


//
// Drag and Drop methods for our text view
//

//
// Called when our drop area is entered
//
- (unsigned int) draggingEntered:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingEntered:%@]", __FILE__, __LINE__, sender );
#endif
    
    // Always say YES; handle failure later.
    bExtendedDragNDrop = YES;
    
    
    return bExtendedDragNDrop;
}


//
// Called when the dragged object is moved within our drop area
//
- (unsigned int) draggingUpdated:(id <NSDraggingInfo>)sender
{
    unsigned int iResult;
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingUpdated:%@]", __FILE__, __LINE__, sender );
#endif
    
    // Let's see if our parent NSTextView knows what to do
    iResult = [super draggingUpdated: sender];
    
    // If parent class does not know how to deal with this drag type, check if we do.
    if (iResult == NSDragOperationNone) // Parent NSTextView does not support this drag type.
    {
        return [self _checkForSupportedDragTypes: sender];
    }
    
    return iResult;
}


//
// Called when the dragged object leaves our drop area
//
- (void) draggingExited:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView draggingExited:%@]", __FILE__, __LINE__, sender );
#endif
    
    // We don't do anything special, so let the parent NSTextView handle this.
    [super draggingExited: sender];
    
    // Reset our handler flag
    bExtendedDragNDrop = NO;
}


//
// Called when the dragged item is about to be released in our drop area.
//
- (BOOL) prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    BOOL bResult;
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView prepareForDragOperation:%@]", __FILE__, __LINE__, sender );
#endif
    
    // Check if parent NSTextView knows how to handle this.
    bResult = [super prepareForDragOperation: sender];
    
    // If parent class does not know how to deal with this drag type, check if we do.
    if ( bResult != YES && 
        [self _checkForSupportedDragTypes: sender] != NSDragOperationNone )
    {
        bResult = YES;
    }
    
    return bResult;
}


//
// Called when the dragged item is released in our drop area.
//
- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{
    unsigned int dragOperation;
    BOOL bResult = NO;
    PTYSession *delegate = [self delegate];
    
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView performDragOperation:%@]", __FILE__, __LINE__, sender );
#endif
    
    
    // If parent class does not know how to deal with this drag type, check if we do.
    if (bExtendedDragNDrop)
    {
        NSPasteboard *pb = [sender draggingPasteboard];
        NSArray *propertyList;
        NSString *aString;
        int i;
        
        dragOperation = [self _checkForSupportedDragTypes: sender];
        
        switch (dragOperation)
        {
            case NSDragOperationCopy:
                // Check for simple strings first
                aString = [pb stringForType:NSStringPboardType];
                if (aString != nil)
                {
                    if ([delegate respondsToSelector:@selector(pasteString:)])
                        [delegate pasteString: aString];
                    else
                        [super paste:sender];
                }
                // Check for file names
                propertyList = [pb propertyListForType: NSFilenamesPboardType];
                for(i = 0; i < [propertyList count]; i++)
                {
                    // Just paste the file names into the shell after escaping special characters.
                    if ([delegate respondsToSelector:@selector(pasteString:)])
                    {
			NSMutableString *aMutableString;

			aMutableString = [[NSMutableString alloc] initWithString: (NSString*)[propertyList objectAtIndex: i]];
			// get rid of special characters
			[aMutableString replaceOccurrencesOfString: @"\\" withString: @"\\\\" options: 0 range: NSMakeRange(0, [aMutableString length])];
			[aMutableString replaceOccurrencesOfString: @" " withString: @"\\ " options: 0 range: NSMakeRange(0, [aMutableString length])];
			[aMutableString replaceOccurrencesOfString: @"(" withString: @"\\(" options: 0 range: NSMakeRange(0, [aMutableString length])];
			[aMutableString replaceOccurrencesOfString: @")" withString: @"\\)" options: 0 range: NSMakeRange(0, [aMutableString length])];
			[aMutableString replaceOccurrencesOfString: @"\"" withString: @"\\\"" options: 0 range: NSMakeRange(0, [aMutableString length])];
    [aMutableString replaceOccurrencesOfString: @"&" withString: @"\\&" options: 0 range: NSMakeRange(0, [aMutableString length])];
    [aMutableString replaceOccurrencesOfString: @"'" withString: @"\\'" options: 0 range: NSMakeRange(0, [aMutableString length])];


			
                        [delegate pasteString: aMutableString];
                        [delegate pasteString: @" "];
			[aMutableString release];
                    }

                }
                bResult = YES;
                break;				
        }
        
    }
    
    return bResult;
}


//
//
//
- (void) concludeDragOperation:(id <NSDraggingInfo>)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView concludeDragOperation:%@]", __FILE__, __LINE__, sender );
#endif
    
    // If we did no handle the drag'n'drop, ask our parent to clean up
    // I really wish the concludeDragOperation would have a useful exit value.
    if (!bExtendedDragNDrop)
    {
        [super concludeDragOperation: sender];
    }
    
    bExtendedDragNDrop = NO;
}

// Save method
- (void) saveDocumentAs: (id) sender
{
    
    NSString *aString;
    NSData *aData;
    NSSavePanel *aSavePanel;
    
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYTextView saveDocumentAs:%@]", __FILE__, __LINE__, sender );
#endif

    // We get our content of the textview or selection, if any
    if([self selectedRange].length > 0)
        aString = [[self string] substringWithRange: [self selectedRange]];
    else
        aString = [self string];
    aData = [aString 
            dataUsingEncoding: NSASCIIStringEncoding
            allowLossyConversion: YES];
    // retain here so that is does not go away...        
    [aData retain];
    
    // initialize a save panel
    aSavePanel = [NSSavePanel savePanel];
    [aSavePanel setAccessoryView: nil];
    [aSavePanel setRequiredFileType: @""];
    
    // Run the save panel as a sheet
    [aSavePanel beginSheetForDirectory: @"" 
                file: @"Unknown" 
                modalForWindow: [self window]
                modalDelegate: self 
                didEndSelector: @selector(_savePanelDidEnd: returnCode: contextInfo:) 
                contextInfo: aData];

    
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // Check if the delegate will handle the event
    id delegate = [self delegate];
    if([delegate respondsToSelector: @selector(willHandleEvent:)] &&
       [delegate willHandleEvent: theEvent])
	[delegate handleEvent: theEvent];
    else
	[super mouseDown: theEvent];
}

- (void) setCursorIndex:(int) idx
{
    cursorIndex=idx;
}

@end

//
// private methods
//
@implementation PTYTextView (Private)

- (unsigned int) _checkForSupportedDragTypes:(id <NSDraggingInfo>) sender
{
  NSString *sourceType;
  BOOL iResult;
  
  iResult = NSDragOperationNone;
  
  // We support the FileName drag type for attching files
  sourceType = [[sender draggingPasteboard] availableTypeFromArray: [NSArray arrayWithObjects: 
									       NSFilenamesPboardType, 
									     NSStringPboardType, 
									     nil]];
  
  if (sourceType)
    {
      iResult = NSDragOperationCopy;
    }
  
  return iResult;
}

- (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel
	       returnCode: (int) theReturnCode
	      contextInfo: (void *) theContextInfo
{
  // If successful, save file under designated name
  if (theReturnCode == NSOKButton)
    {
      if ( ![(NSData *)theContextInfo writeToFile: [theSavePanel filename]
                    atomically: YES] )
	{
	  NSBeep();
	}
    }
    // release our hold on the data
    [(NSData *)theContextInfo release];
    
}

@end

#endif