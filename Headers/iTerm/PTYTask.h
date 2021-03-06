// -*- mode:objc -*-
// $Id: PTYTask.h,v 1.1 2003-08-08 20:12:57 ujwal Exp $
/*
 **  PTYTask.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Sathyam
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the interface to the pty session.
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

/*
  Delegate
      readTask:
      brokenPipe
*/

#import <Foundation/Foundation.h>

@interface PTYTask : NSObject
{
    pid_t PID;
    int FILDES;
    int STATUS;
    id DELEGATEOBJECT;
    NSMutableData *RECVDATA;
    NSString *TTY;
    NSString *PATH;
    NSPort *SENDPORT;
    NSPort *RECVPORT;
    NSConnection *CONNECTION;

    NSString *LOG_PATH;
    NSFileHandle *LOG_HANDLE;
    BOOL hasOutput;
}

- (id)init;
- (void)dealloc;

- (void)launchWithPath:(NSString *)progpath
	     arguments:(NSArray *)args
	   environment:(NSDictionary *)env
		 width:(int)width
		height:(int)height;

- (void)setDelegate:(id)object;
- (id)delegate;

- (NSData *)readData;
- (void)readTask:(NSData *)data;
- (void)writeTask:(NSData *)data;
- (void)brokenPipe;
- (void)sendSignal:(int)signo;
- (void)setWidth:(int)width height:(int)height;
- (pid_t)pid;
- (int)wait;
- (BOOL)exist;
- (void)stop;
- (void)stopNoWait;
- (int)status;
- (NSString *)tty;
- (NSString *)path;
- (BOOL)loggingStartWithPath:(NSString *)path;
- (void)loggingStop;
- (BOOL)logging;
- (BOOL) hasOutput;
- (void) setHasOutput: (BOOL) flag;

- (NSString *)description;

@end
