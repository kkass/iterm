// -*- mode:objc -*-
// $Id: PTYTextView.h,v 1.2 2003-08-09 07:41:19 ujwal Exp $
//
/*
 **  PTYTextView.h
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

#import <Cocoa/Cocoa.h>
#import <iTerm/iTerm.h>

#if USE_CUSTOM_DRAWING
@interface PTYTextView : NSView <NSTextInput>
{
    BOOL IM_INPUT_INSERT;
    NSRange IM_INPUT_SELRANGE;
    NSRange IM_INPUT_MARKEDRANGE;

    // This is a flag to let us know whether we are handling this
    // particular drag and drop operation. We are using it because
    // the prepareDragOperation and performDragOperation of the
    // parent NSTextView class return "YES" even if the parent
    // cannot handle the drag type. To make matters worse, the
    // concludeDragOperation does not have any return value.
    // This all results in the inability to test whether the
    // parent could handle the drag type properly. Is this a Cocoa
    // implementation bug?
    // Fortunately, the draggingEntered and draggingUpdated methods
    // seem to return a real status, based on which we can set this flag.
    BOOL bExtendedDragNDrop;

    // anti-alias flag
    BOOL antiAlias;

    // dead key support
    BOOL deadkey;

    BOOL resized;
    BOOL CURSOR;
    int	cursorIndex;

    float lineHeight;
    float lineWidth;

    NSDictionary *markedTextAttributes;
    NSDictionary *selectionTextAttributes;
    NSAttributedString *markedText;
    NSColor *bgColor;
    NSFont *font;
    NSFont *nafont;
    
    // data source
    id dataSource;
    int numberOfLines;
    id _delegate;

    //selection
    int startIndex, startY, endIndex, endY;
}

- (id)init;
- (void)dealloc;
- (BOOL)isFlipped;
- (BOOL)shouldDrawInsertionPoint;
- (void)drawRect:(NSRect)rect;
- (void)keyDown:(NSEvent *)event;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (NSString *) selectedText;
- (void)copy: (id) sender;
- (void)paste:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (void)changeFont:(id)sender;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void) browse:(id)sender;
- (void) mail:(id)sender;
- (void) setCursorIndex:(int)idx;

    // get/set methods
- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *)color;
- (NSFont *)font;
- (NSFont *)nafont;
- (void) setFont:(NSFont*)aFont nafont:(NSFont*)naFont;
- (BOOL) antiAlias;
- (void) setAntiAlias: (BOOL) antiAliasFlag;
- (NSColor *) selectionColor;
- (void) setSelectionColor: (NSColor *) aColor;
- (NSDictionary*) markedTextAttributes;
- (void) setMarkedTextAttributes: (NSDictionary *) attr;
- (id) dataSource;
- (void) setDataSource: (id) aDataSource;
- (id) delegate;
- (void) setDelegate: (id) delegate;
- (float) lineHeight;
- (void) setLineHeight: (float) aLineHeight;
- (float) lineWidth;
- (void) setLineWidth: (float) aLineWidth;

- (void) refresh;
- (void) setDirtyLine: (int) y;
- (BOOL) resized;
- (void) showCursor;
- (void) hideCursor;

    //
    // Drag and Drop methods for our text view
    //
- (unsigned int) draggingEntered: (id<NSDraggingInfo>) sender;
- (unsigned int) draggingUpdated: (id<NSDraggingInfo>) sender;
- (void) draggingExited: (id<NSDraggingInfo>) sender;
- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>) sender;
- (BOOL) performDragOperation: (id<NSDraggingInfo>) sender;
- (void) concludeDragOperation: (id<NSDraggingInfo>) sender;

    // Cursor control
- (void)resetCursorRects;

// Scrolling control
- (void) scrollLineUp: (id) sender;
- (void) scrollLineDown: (id) sender;
- (void) scrollPageUp: (id) sender;
- (void) scrollPageDown: (id) sender;
- (void) scrollHome;
- (void) scrollEnd;

    // Save method
- (void) saveDocumentAs: (id) sender;
- (void) print:(id)sender;

    // NSTextInput
- (void)insertText:(id)aString;
- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange;
- (void)unmarkText;
- (BOOL)hasMarkedText;
- (NSRange)markedRange;
- (NSRange)selectedRange;
- (NSArray *)validAttributesForMarkedText;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)theRange;
- (void)doCommandBySelector:(SEL)aSelector;
- (unsigned int)characterIndexForPoint:(NSPoint)thePoint;
- (long)conversationIdentifier;
- (NSRect)firstRectForCharacterRange:(NSRange)theRange;

@end

//
// private methods
//
@interface PTYTextView (Private)

- (unsigned int) _checkForSupportedDragTypes:(id <NSDraggingInfo>) sender;
- (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel returnCode: (int) theReturnCode contextInfo: (void *) theContextInfo;

@end

#else
@interface PTYTextView : NSTextView
{
    
    BOOL IM_INPUT_INSERT;
    NSRange IM_INPUT_SELRANGE;
    NSRange IM_INPUT_MARKEDRANGE;
    
    // This is a flag to let us know whether we are handling this
    // particular drag and drop operation. We are using it because
    // the prepareDragOperation and performDragOperation of the
    // parent NSTextView class return "YES" even if the parent
    // cannot handle the drag type. To make matters worse, the
    // concludeDragOperation does not have any return value.
    // This all results in the inability to test whether the
    // parent could handle the drag type properly. Is this a Cocoa
    // implementation bug?
    // Fortunately, the draggingEntered and draggingUpdated methods
    // seem to return a real status, based on which we can set this flag.
    BOOL bExtendedDragNDrop;
    
    // anti-alias flag
    BOOL antiAlias;

    // dead key support
    BOOL deadkey;
    int	cursorIndex;

    float lineHeight;
    float lineWidth;

    // data source
    id dataSource;
    int numberOfLines;

    // last search location
    unsigned int lastSearchLocation;

    // print selection
    BOOL printingSelection;

    // for the typesetter
    NSFont *font;
}

- (id)init;
- (id)initWithFrame: (NSRect) aRect;
- (id)initWithFrame: (NSRect) aRect textContainer: (NSTextContainer *) textContainer;
- (void)dealloc;
- (BOOL)shouldDrawInsertionPoint;
- (void)drawRect:(NSRect)rect;
- (void)keyDown:(NSEvent *)event;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)doCommandBySelector:(SEL)aSelector;
- (void)insertText:(id)aString;
- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange;
- (void)unmarkText;
- (BOOL)hasMarkedText;
- (NSRange)markedRange;
- (NSString *)copyAsString;
- (void)copy: (id) sender;
- (void)paste:(id)sender;
- (void)pasteSelection:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (void)changeFont:(id)sender;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void) browse:(id)sender;
- (void) mail:(id)sender;
- (void) setCursorIndex:(int)idx;

// get/set methods
- (BOOL) antiAlias;
- (void) setAntiAlias: (BOOL) antiAliasFlag;
- (NSColor *) selectionColor;
- (void) setSelectionColor: (NSColor *) aColor;

- (id) dataSource;
- (void) setDataSource: (id) aDataSource;

- (float) lineHeight;
- (void) setLineHeight: (float) aLineHeight;
- (float) lineWidth;
- (void) setLineWidth: (float) aLineWidth;

- (NSFont *) font;
- (void) setFont: (NSFont *)aFont;

- (void) refresh;
- (void) scrollHome;
- (void) scrollEnd;

//
// Drag and Drop methods for our text view
//
- (unsigned int) draggingEntered: (id<NSDraggingInfo>) sender;
- (unsigned int) draggingUpdated: (id<NSDraggingInfo>) sender;
- (void) draggingExited: (id<NSDraggingInfo>) sender;
- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>) sender;
- (BOOL) performDragOperation: (id<NSDraggingInfo>) sender;
- (void) concludeDragOperation: (id<NSDraggingInfo>) sender;

// Save method
- (void) saveDocumentAs: (id) sender;

// Print
- (void) print: (id) sender;
- (void) printSelection: (id) sender;

@end

//
// find functionality
//
@interface PTYTextView (Find)
- (IBAction) showFindPanel: (id) sender;
- (IBAction) findNext: (id) sender;
- (IBAction) findPrevious: (id) sender;
- (IBAction) findWithSelection: (id) sender;
- (IBAction) jumpToSelection: (id) sender;
- (void) findSubString: (NSString *) subString forwardDirection: (BOOL) direction ignoringCase: (BOOL) caseCheck;
- (void) setSearchString: (NSString *) aString;
- (void) setIgnoreCase: (BOOL) flag;
@end


//
// private methods
//
@interface PTYTextView (Private)

- (unsigned int) _checkForSupportedDragTypes:(id <NSDraggingInfo>) sender;
- (void) _savePanelDidEnd: (NSSavePanel *) theSavePanel returnCode: (int) theReturnCode contextInfo: (void *) theContextInfo;

@end

#endif