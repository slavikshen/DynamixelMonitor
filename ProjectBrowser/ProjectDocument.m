//
//  ProjectDocument.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/14/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "ProjectDocument.h"
#import "ProjectWindowController.h"

NSString* const ProjectDocumentProperty_FileURL = @"fileURL";

@implementation ProjectDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

//- (NSString *)windowNibName
//{
//    // Override returning the nib file name of the document
//    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
//    return @"ProjectDocument";
//}

- (void)setOutlineView:(NSOutlineView *)outlineView {
 
    if(_outlineView) {
        _outlineView.dataSource = nil;
    }
    
    _outlineView = outlineView;
    
    if( _outlineView ) {
        _outlineView.dataSource = self;
    }
    
}

- (void)makeWindowControllers {
    
    ProjectWindowController* winController = [[ProjectWindowController alloc] initWithWindowNibName:@"ProjectWindowController"];
    [self addWindowController:winController];
    
}

- (void)setFileURL:(NSURL *)url {

    [super setFileURL:url];
    if( self.fileURL ) {
        [self loadProjectOutline];
    }
     
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSString* author = self.authorName;
    
    if( 0 == author.length ) {
        author = @"Unknown";
    }
    
    NSDictionary* projInfo = @{
       @"authorName" : author,
       @"version" : @"1.0"
    };

    NSData* data = [NSArchiver archivedDataWithRootObject:projInfo];
    
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    

    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSDictionary* projInfo = [NSUnarchiver unarchiveObjectWithData:data];
    NSString* author = projInfo[@"authorName"];
    
    self.authorName = author;
    
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)loadProjectOutline {
    
    NSURL* url = self.fileURL;
    ProjectItem* root = [[ProjectItem alloc] initWithProjectURL:url];
    self.projectItem = root;
    
    [self.outlineView reloadData];
    
}

- (void)_dumpProjectTemplate:(NSString*)path {
    
    DLog(@"dump project template to %@", path);
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* bundlePath = [mainBundle bundlePath];
    NSString* projTemplatePath = [bundlePath stringByAppendingPathComponent:@"Contents/ProjectTemplate"];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:projTemplatePath];
    NSString *f = nil;
    while ((f = [de nextObject]))
    {
        // make the filename |f| a fully qualifed filename
        NSString* src = [projTemplatePath stringByAppendingPathComponent:f];
        NSString* dest = [path stringByAppendingPathComponent:f];
        NSLog(@"copy %@", src);
        NSLog(@"to   %@", dest);
        NSError* err = nil;
        [fm copyItemAtPath:src toPath:dest error:&err];
    }
    

    NSError* err = nil;
    [fm copyItemAtPath:projTemplatePath toPath:path error:&err];
    
}

- (BOOL)writeSafelyToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {

    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* filepath = url.path;
    BOOL overWrite = [fm fileExistsAtPath:filepath];

    BOOL ret = [super writeSafelyToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
    
    if( !overWrite && ret ) {
        DLog(@"init project");
        [self _dumpProjectTemplate:[filepath stringByDeletingLastPathComponent]];
    }

    return ret;
}

// Data Source methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(ProjectItem*)item {
    return (item == nil) ? 1 : item.children.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(ProjectItem*)item {
    return (item == nil) ? YES : item.isDir;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(ProjectItem*)item {
    
    return (item == nil) ? self.projectItem : item.children[index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(ProjectItem*)item {
    return (item == nil) ? [self.projectItem fullPath] : [item fullPath];
}


@end
