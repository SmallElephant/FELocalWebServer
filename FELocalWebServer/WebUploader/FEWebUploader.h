
#import "GCDWebServer.h"

@class FEWebUploader;

/**
 *  Delegate methods for FEWebUploader.
 *
 *  @warning These methods are always called on the main thread in a serialized way.
 */
@protocol FEWebUploaderDelegate <GCDWebServerDelegate>
@optional

/**
 *  This method is called whenever a file has been downloaded.
 */
- (void)webUploader:(FEWebUploader*)uploader didDownloadFileAtPath:(NSString*)path;

/**
 *  This method is called whenever a file has been uploaded.
 */
- (void)webUploader:(FEWebUploader*)uploader didUploadFileAtPath:(NSString*)path;

/**
 *  This method is called whenever a file or directory has been moved.
 */
- (void)webUploader:(FEWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath;

/**
 *  This method is called whenever a file or directory has been deleted.
 */
- (void)webUploader:(FEWebUploader*)uploader didDeleteItemAtPath:(NSString*)path;

/**
 *  This method is called whenever a directory has been created.
 */
- (void)webUploader:(FEWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path;

@end

/**
 *  The FEWebUploader subclass of GCDWebServer implements an HTML 5 web browser
 *  interface for uploading or downloading files, and moving or deleting files
 *  or directories.
 *
 *  See the README.md file for more information about the features of FEWebUploader.
 *
 *  @warning For FEWebUploader to work, "FEWebUploader.bundle" must be added
 *  to the resources of the Xcode target.
 */
@interface FEWebUploader : GCDWebServer

/**
 *  Returns the upload directory as specified when the uploader was initialized.
 */
@property(nonatomic, readonly) NSString* uploadDirectory;

/**
 *  Sets the delegate for the uploader.
 */
@property(nonatomic, assign) id<FEWebUploaderDelegate> delegate;

/**
 *  Sets which files are allowed to be operated on depending on their extension.
 *
 *  The default value is nil i.e. all file extensions are allowed.
 */
@property(nonatomic, copy) NSArray* allowedFileExtensions;

/**
 *  Sets if files and directories whose name start with a period are allowed to
 *  be operated on.
 *
 *  The default value is NO.
 */
@property(nonatomic) BOOL allowHiddenItems;

/**
 *  Sets the title for the uploader web interface.
 *
 *  The default value is the application name.
 *
 *  @warning Any reserved HTML characters in the string value for this property
 *  must have been replaced by character entities e.g. "&" becomes "&amp;".
 */
@property(nonatomic, copy) NSString* title;

/**
 *  Sets the header for the uploader web interface.
 *
 *  The default value is the same as the title property.
 *
 *  @warning Any reserved HTML characters in the string value for this property
 *  must have been replaced by character entities e.g. "&" becomes "&amp;".
 */
@property(nonatomic, copy) NSString* header;

/**
 *  Sets the prologue for the uploader web interface.
 *
 *  The default value is a short help text.
 *
 *  @warning The string value for this property must be raw HTML
 *  e.g. "<p>Some text</p>"
 */
@property(nonatomic, copy) NSString* prologue;

/**
 *  Sets the epilogue for the uploader web interface.
 *
 *  The default value is nil i.e. no epilogue.
 *
 *  @warning The string value for this property must be raw HTML
 *  e.g. "<p>Some text</p>"
 */
@property(nonatomic, copy) NSString* epilogue;

/**
 *  Sets the footer for the uploader web interface.
 *
 *  The default value is the application name and version.
 *
 *  @warning Any reserved HTML characters in the string value for this property
 *  must have been replaced by character entities e.g. "&" becomes "&amp;".
 */
@property(nonatomic, copy) NSString* footer;

/**
 *  This method is the designated initializer for the class.
 */
- (instancetype)initWithUploadDirectory:(NSString*)path;

@end

/**
 *  Hooks to customize the behavior of FEWebUploader.
 *
 *  @warning These methods can be called on any GCD thread.
 */
@interface FEWebUploader (Subclassing)

/**
 *  This method is called to check if a file upload is allowed to complete.
 *  The uploaded file is available for inspection at "tempPath".
 *
 *  The default implementation returns YES.
 */
- (BOOL)shouldUploadFileAtPath:(NSString*)path withTemporaryFile:(NSString*)tempPath;

/**
 *  This method is called to check if a file or directory is allowed to be moved.
 *
 *  The default implementation returns YES.
 */
- (BOOL)shouldMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath;

/**
 *  This method is called to check if a file or directory is allowed to be deleted.
 *
 *  The default implementation returns YES.
 */
- (BOOL)shouldDeleteItemAtPath:(NSString*)path;

/**
 *  This method is called to check if a directory is allowed to be created.
 *
 *  The default implementation returns YES.
 */
- (BOOL)shouldCreateDirectoryAtPath:(NSString*)path;

@end
