//
//    Controller.m      Controller for the defaults settings
//
//    Copyright (C) 2010  Christian Balkenius
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//    Created: April 1, 2010
//

#import "Controller.h"
#import "JSWrapper.h"

@implementation Controller

#define defaultValue @"/dev/cu.usbserial-A7005Lxn"
#define myKey @"device"

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *string = [defaults stringForKey:myKey];
    if (string == nil) string = defaultValue;
    [self.myTextField setStringValue:string];
    
}


- (void)textFieldAction:(id)sender
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *string;

    string = [self.myTextField stringValue];

    if ([string isEqualToString:defaultValue]) {
        [defaults removeObjectForKey:myKey];
    } else {
        [defaults setObject:string forKey:myKey];
    }
    
    [self.myWindow orderOut: self];
}

@end
