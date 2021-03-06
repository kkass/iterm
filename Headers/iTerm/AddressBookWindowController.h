/*
 **  AddressBookWindowController.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Ujwal S. Sathyam, Fabian
 **
 **  Project: iTerm
 **
 **  Description: Implements the addressbook functions.
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class PreferencePanel;
@class iTermController;

@interface AddressBookWindowController : NSWindowController {

    // bookmarks window
    IBOutlet NSTableView *adTable;

    // address entry window
    IBOutlet NSTabView *tabView;
    IBOutlet NSPopUpButton *tabSelection;
    IBOutlet id AE_PANEL;
    IBOutlet NSTextField *adCommand;
    IBOutlet NSPopUpButton *adEncoding;
    IBOutlet NSTextField *adName;
    IBOutlet NSTextField *adTextExample;
    IBOutlet id adRow;
    IBOutlet id adCol;
    IBOutlet id adTransparency;
    IBOutlet id adTransparency2;
    IBOutlet NSPopUpButton *adTermType;
    IBOutlet id adDir;
    IBOutlet id adAI;
    IBOutlet id adAICode;
    IBOutlet id adClose;
    IBOutlet NSButton *adRemapDeleteKey;
    IBOutlet id adDoubleWidth;
    IBOutlet id adShortcut;
    IBOutlet NSTextField *adNATextExample;
    IBOutlet id colorScheme;
    IBOutlet NSColorWell *adForeground;
    IBOutlet NSColorWell *adBackground;
    IBOutlet NSColorWell *adSelection;
    IBOutlet NSColorWell *adBold;
    IBOutlet NSColorWell *ansiBlack;
    IBOutlet NSColorWell *ansiRed;
    IBOutlet NSColorWell *ansiGreen;
    IBOutlet NSColorWell *ansiYellow;
    IBOutlet NSColorWell *ansiBlue;
    IBOutlet NSColorWell *ansiMagenta;
    IBOutlet NSColorWell *ansiCyan;
    IBOutlet NSColorWell *ansiWhite;
    IBOutlet NSColorWell *ansiHiBlack;
    IBOutlet NSColorWell *ansiHiRed;
    IBOutlet NSColorWell *ansiHiGreen;
    IBOutlet NSColorWell *ansiHiYellow;
    IBOutlet NSColorWell *ansiHiBlue;
    IBOutlet NSColorWell *ansiHiMagenta;
    IBOutlet NSColorWell *ansiHiCyan;
    IBOutlet NSColorWell *ansiHiWhite;

    // buttons
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *deleteButton;
    IBOutlet NSButton *duplicateButton;
    IBOutlet NSButton *editButton;
    IBOutlet NSButton *openInTab;
    IBOutlet NSButton *openInWindow;

    NSFont *aeFont, *aeNAFont;
    BOOL changingNA;
    BOOL defaultEntry;

    // bookmarks data
    NSMutableArray *addressBook;

    // default values from preference
    PreferencePanel *preferences;

    iTermController *iTerm;

}

// init
+ (id) singleInstance;
- (id) initWithWindowNibName: (NSString *)windowNibName;
- (void) dealloc;

// other class methods
+ (NSColor *) colorFromTable:(int)index highLight:(BOOL)hili;
+ (NSColor *) defaultSelectionColor;
+ (NSColor *) defaultBoldColor;
+ (NSColor *) highlightColor:(NSColor *)color;

// NSWindow delegate methods
- (void)windowWillClose:(NSNotification *)aNotification;

// get/set methods
- (NSMutableArray *) addressBook;
- (void) setAddressBook: (NSMutableArray *) anAddressBook;
- (PreferencePanel *) preferences;
- (void) setPreferences: (PreferencePanel *) thePreferences;
- (iTermController *) iTerm;
- (void) setITermController: (iTermController *) theController;

// Address book window
- (IBAction)adbDuplicateEntry:(id)sender;
- (IBAction)adbRemoveEntry:(id)sender;
- (IBAction)adbEditEntry:(id)sender;
- (void)adbEditEntryAtIndex:(int)index newEntry: (BOOL) newEntry;
- (IBAction)adbAddEntry:(id)sender;
- (IBAction) executeABCommand: (id) sender;

// Address entry window
- (IBAction)adEditBackground:(id)sender;
- (IBAction)adEditCancel:(id)sender;
- (IBAction)adEditFont:(id)sender;
- (IBAction)adEditNAFont:(id)sender;
- (IBAction)adEditForeground:(id)sender;
- (IBAction)adEditOK:(id)sender;
- (IBAction) changeTab: (id) sender;
- (IBAction)changeColorScheme:(id)sender;
- (IBAction)editColorScheme: (id) sender;


// misc
- (void) run;


// Table data source
- (int)numberOfRowsInTableView:(NSTableView*)table;
- (id)tableView:(NSTableView*)table objectValueForTableColumn:(NSTableColumn*)col
			  row:(int)rowIndex;

// Table view delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end

@interface AddressBookWindowController (Private)

- (NSDictionary *) _getUpdatedPropertyDictionary;

@end
