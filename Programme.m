//
//  Programme.m
//  Get_iPlayer GUI
//
//  Created by Thomas Willson on 7/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Programme.h"
#import "NSString+HTML.h"
#import "AppController.h"
#import "HTTPProxy.h"
#import "ASIHTTPRequest.h"
//extern bool runDownloads;


@implementation Programme {
    bool getNameRunning;
}

- (id)initWithLogController:(LogController *)logger
{
    if (![self init]) return nil;
    self->logger = logger;
    return self;
}
- (id)initWithInfo:(id)sender pid:(NSString *)PID programmeName:(NSString *)SHOWNAME network:(NSString *)TVNETWORK logController:(LogController *)logger
{
    if (!(self = [super init])) return nil;
    self->logger = logger;
    pid = [PID stringByReplacingOccurrencesOfString:@";amp" withString:@""];
    showName = [[[NSString alloc] initWithString:SHOWNAME] stringByDecodingHTMLEntities];
    tvNetwork = [[NSString alloc] initWithString:TVNETWORK];
    status = [[NSString alloc] init];
    complete = @NO;
    successful = @NO;
    path = @"Unknown";
    seriesName = [[NSString alloc] init];
    episodeName = [[NSString alloc] init];
    timeadded = [[NSNumber alloc] init];
    processedPID = @YES;
    radio = @NO;
    subtitlePath=[[NSString alloc] init];
    realPID=[[NSString alloc] init];
    reasonForFailure=[[NSString alloc] init];
    availableModes=[[NSString alloc] init];
    desc=[[NSString alloc] init];
    extendedMetadataRetrieved=@NO;
    getNameRunning = false;
    addedByPVR = false;
    return self;
}
- (id)initWithShow:(Programme *)show
{
    pid = [[NSString alloc] initWithString:[show pid]];
    showName = [[[NSString alloc] initWithString:[show showName]] stringByDecodingHTMLEntities];
    tvNetwork = [[NSString alloc] initWithString:[show tvNetwork]];
    status = [[NSString alloc] initWithString:[show status]];
    complete = @NO;
    successful = @NO;
    path = [[NSString alloc] initWithString:[show path]];
    seriesName = [[NSString alloc] init];
    episodeName = [[NSString alloc] init];
    timeadded = [[NSNumber alloc] init];
    processedPID = @YES;
    radio = [show radio];
    realPID = [show realPID];
    subtitlePath = [show subtitlePath];
    reasonForFailure=[show reasonForFailure];
    availableModes=[[NSString alloc] init];
    desc=[[NSString alloc] init];
    extendedMetadataRetrieved=@NO;
    getNameRunning = false;
    addedByPVR = false;
    return self;
}
- (id)init
{
    if (!(self = [super init])) return nil;
    pid = [[NSString alloc] init];
    showName = [[NSString alloc] init];
    tvNetwork = [[NSString alloc] init];
    if (runDownloads)
    {
        status = @"Waiting...";
    }
    else
    {
        status = [[NSString alloc] init];
    }
    seriesName = [[NSString alloc] init];
    episodeName = [[NSString alloc] init];
    complete = @NO;
    successful = @NO;
    timeadded = [[NSNumber alloc] init];
    path = @"Unknown";
    processedPID = @NO;
    radio = @NO;
    url = [[NSString alloc] init];
    realPID=[[NSString alloc] init];
    subtitlePath=[[NSString alloc] init];
    reasonForFailure=[[NSString alloc] init];
    availableModes=[[NSString alloc] init];
    desc=[[NSString alloc] init];
    extendedMetadataRetrieved=@NO;
    getNameRunning = false;
    addedByPVR = false;
    return self;
}
- (id)description
{
    return [NSString stringWithFormat:@"%@: %@",pid,showName];
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: showName forKey:@"showName"];
    [coder encodeObject: pid     forKey:@"pid"];
    [coder encodeObject:tvNetwork forKey:@"tvNetwork"];
    [coder encodeObject:status forKey:@"status"];
    [coder encodeObject:path forKey:@"path"];
    [coder encodeObject:seriesName forKey:@"seriesName"];
    [coder encodeObject:episodeName forKey:@"episodeName"];
    [coder encodeObject:timeadded forKey:@"timeadded"];
    [coder encodeObject:processedPID forKey:@"processedPID"];
    [coder encodeObject:radio forKey:@"radio"];
    [coder encodeObject:realPID forKey:@"realPID"];
    [coder encodeObject:url forKey:@"url"];
    [coder encodeInteger:season forKey:@"season"];
    [coder encodeInteger:episode forKey:@"episode"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (!(self = [super init])) return nil;
    pid = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"pid"]];
    showName = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"showName"]];
    tvNetwork = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"tvNetwork"]];
    status = @"";
    complete = @NO;
    successful = @NO;
    path = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"path"]];
    seriesName = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"seriesName"]];
    episodeName = [[NSString alloc] initWithString:[coder decodeObjectForKey:@"episodeName"]];
    timeadded = [coder decodeObjectForKey:@"timeadded"];
    processedPID = [coder decodeObjectForKey:@"processedPID"];
    radio = [coder decodeObjectForKey:@"radio"];
    realPID = [coder decodeObjectForKey:@"realPID"];
    url = [coder decodeObjectForKey:@"url"];
    subtitlePath=[[NSString alloc] init];
    reasonForFailure=[[NSString alloc] init];
    availableModes=[[NSString alloc] init];
    desc=[[NSString alloc] init];
    extendedMetadataRetrieved=@NO;
    getNameRunning = false;
    addedByPVR = false;
    season = [coder decodeIntegerForKey:@"season"];
    episode = [coder decodeIntegerForKey:@"episode"];
    return self;
}
/*
 - (id)pasteboardPropertyListForType:(NSString *)type
 {
 if ([type isEqualToString:@"com.thomaswillson.programme"])
 {
 return [NSKeyedArchiver archivedDataWithRootObject:self];
 }
 }
 - (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
 {
 return [NSArray arrayWithObject:@"com.thomaswillson.programme"];
 }
 */
-(void)setPid:(NSString *)newPID
{
    self->pid = [newPID stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
}
-(NSString *)pid
{
    return pid;
}
-(void)printLongDescription
{
    NSLog(@"%@:\n   TV Network: %@\n   Processed PID: %@\n   Real PID: %@\n   Available Modes: %@\n   URL: %@\n",
          showName,tvNetwork,processedPID,realPID,availableModes,url);
}

-(void)retrieveExtendedMetadata
{
    [logger addToLog:@"Retrieving Extended Metadata" :self];
    getiPlayerProxy = [[GetiPlayerProxy alloc] initWithLogger:logger];
    [getiPlayerProxy loadProxyInBackgroundForSelector:@selector(proxyRetrievalFinished:proxyDict:) withObject:nil onTarget:self silently:NO];
}

-(void)proxyRetrievalFinished:(id)sender proxyDict:(NSDictionary *)proxyDict
{
    getiPlayerProxy = nil;
    if (proxyDict && [proxyDict[@"error"] code] == kProxyLoadCancelled)
        return;
    
    taskOutput = [[NSMutableString alloc] init];
    metadataTask = [[NSTask alloc] init];
    pipe = [[NSPipe alloc] init];
    
    [metadataTask setLaunchPath:@"/usr/bin/perl"];
    NSMutableArray *args = [NSMutableArray arrayWithArray:@[[[NSBundle mainBundle] pathForResource:@"get_iplayer" ofType:@"pl"],
                                                            @"--nopurge",
                                                            @"--nocopyright",
                                                            @"-e60480000000000000",
                                                            @"-i",
                                                            [NSString stringWithFormat:@"--profile-dir=%@",[@"~/Library/Application Support/Get iPlayer Automator/" stringByExpandingTildeInPath]],@"--pid",pid]];
    if (proxyDict[@"proxy"]) {
        [args addObject:[NSString stringWithFormat:@"-p%@",[proxyDict[@"proxy"] url]]];
        
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"AlwaysUseProxy"] boolValue])
        {
            [args addObject:@"--partial-proxy"];
        }
        
    }
    
    [metadataTask setArguments:args];
    
    [metadataTask setStandardOutput:pipe];
    NSFileHandle *fh = [pipe fileHandleForReading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataRetrievalDataReady:) name:NSFileHandleReadCompletionNotification object:fh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataRetrievalFinished:) name:NSTaskDidTerminateNotification object:metadataTask];
    
    NSMutableDictionary *envVariableDictionary = [NSMutableDictionary dictionaryWithDictionary:[metadataTask environment]];
    envVariableDictionary[@"HOME"] = [@"~" stringByExpandingTildeInPath];
    envVariableDictionary[@"PERL_UNICODE"] = @"AS";
    [metadataTask setEnvironment:envVariableDictionary];
    [metadataTask launch];
    [fh readInBackgroundAndNotify];
}

-(void)metadataRetrievalDataReady:(NSNotification *)n
{
    NSData *d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
    
    if ([d length] > 0) {
        NSString *s = [[NSString alloc] initWithData:d
                                            encoding:NSUTF8StringEncoding];
        
        [taskOutput appendString:s];
        [logger addToLog:s :self];
        [[pipe fileHandleForReading] readInBackgroundAndNotify];
    }
    else {
        [self metadataRetrievalFinished:nil];
    }
}

-(void)metadataRetrievalFinished:(NSNotification *)n
{
    taskRunning=NO;
    categories = [self scanField:@"categories" fromList:taskOutput];
    
    NSString *descTemp = [self scanField:@"desc" fromList:taskOutput];
    if (descTemp) {
        desc = descTemp;
    }
    
    NSString *durationTemp = [self scanField:@"duration" fromList:taskOutput];
    if (durationTemp) {
        if ([durationTemp hasSuffix:@"min"])
            duration = [NSNumber numberWithInteger:[durationTemp integerValue]];
        else
            duration = [NSNumber numberWithInteger:[durationTemp integerValue]/60];
    }
    
    firstBroadcast = [self processDate:[self scanField:@"firstbcast" fromList:taskOutput]];
    lastBroadcast = [self processDate:[self scanField:@"lastbcast" fromList:taskOutput]];
    
    seriesName = [self scanField:@"longname" fromList:taskOutput];
    
    episodeName = [self scanField:@"episode" fromList:taskOutput];
    
    NSString *seasonNumber = [self scanField:@"seriesnum" fromList:taskOutput];
    if (seasonNumber) {
        season = [seasonNumber integerValue];
    }
    
    NSString *episodeNumber = [self scanField:@"episodenum" fromList:taskOutput];
    if (episodeNumber) {
        episode = [episodeNumber integerValue];
    }
    // determine default version
    NSString *default_version = nil;
    NSString *info_versions = [self scanField:@"versions" fromList:taskOutput];
    NSArray *versions = [info_versions componentsSeparatedByString:@","];
    for (NSString *version in versions) {
        if (([version isEqualToString:@"default"]) ||
            ([version isEqualToString:@"original"] && ![default_version isEqualToString:@"default"]) ||
            (!default_version && ![version isEqualToString:@"signed"] && ![version isEqualToString:@"audiodescribed"])) {
            default_version = version;
        }
    }
    // parse mode sizes
    NSMutableArray *array = [NSMutableArray array];
    NSScanner *sizeScanner = [NSScanner scannerWithString:taskOutput];
    [sizeScanner scanUpToString:@"modesizes:" intoString:nil];
    while ([sizeScanner scanString:@"modesizes:" intoString:nil]) {
        NSString *version = nil;
        [sizeScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
        [sizeScanner scanUpToString:@":" intoString:&version];
        if (![version isEqualToString:default_version] && ![version isEqualToString:@"signed"] && ![version isEqualToString:@"audiodescribed"]) {
            [sizeScanner scanUpToString:@"modesizes:" intoString:nil];
            continue;
        }
        NSString *group = nil;
        if ([version isEqualToString:default_version]) {
            group = @"A";
        }
        else if ([version isEqualToString:@"signed"]) {
            group = @"C";
        }
        else if ([version isEqualToString:@"audiodescribed"]) {
            group = @"D";
        }
        else {
            group = @"B";
        }
        NSString *newSizesString;
        [sizeScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
        [sizeScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&newSizesString];
        // TODO: adjust with switch to HLS
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"flash[a-z]+[1-9]=[0-9]+MB" options:0 error:nil];
        NSArray *matches = [regex matchesInString:newSizesString options:0 range:NSMakeRange(0, [newSizesString length])];
        if ([matches count] > 0) {
            for (NSTextCheckingResult *modesizeResult in matches) {
                NSString *modesize = [newSizesString substringWithRange:modesizeResult.range];
                NSArray *comps = [modesize componentsSeparatedByString:@"="];
                if ([comps count] == 2) {
                    NSMutableDictionary *item = [NSMutableDictionary dictionary];
                    if ([version isEqualToString:default_version]) {
                        [item setObject:@"default" forKey:@"version"];
                    }
                    else {
                        [item setObject:version forKey:@"version"];
                    }
                    [item setObject:comps[0] forKey:@"mode"];
                    [item setObject:comps[1] forKey:@"size"];
                    [item setObject:group forKey:@"group"];
                    [array addObject:item];
                }
            }
        }
        [sizeScanner scanUpToString:@"modesizes:" intoString:nil];
    }
    modeSizes = array;
    NSString *thumbURL = [self scanField:@"thumbnail4" fromList:taskOutput];
    if (!thumbURL) {
        thumbURL = [self scanField:@"thumbnail" fromList:taskOutput];
    }
    if (thumbURL) {
        NSLog(@"URL: %@", thumbURL);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:thumbURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(thumbnailRequestFinished:)];
        [request setDidFailSelector:@selector(thumbnailRequestFinished:)];
        [request setTimeOutSeconds:3];
        [request setNumberOfTimesToRetryOnTimeout:3];
        [request startAsynchronous];
    }
}

- (void)thumbnailRequestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode == 200) {
        thumbnail = [[NSImage alloc] initWithData:request.responseData];
    }
    successfulRetrieval = @YES;
    extendedMetadataRetrieved = @YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExtendedInfoRetrieved" object:self];
    
}

-(NSString *)scanField:(NSString *)field fromList:(NSString *)list
{
    NSString __autoreleasing *buffer;
    
    NSScanner *scanner = [NSScanner scannerWithString:list];
    [scanner scanUpToString:[NSString stringWithFormat:@"%@:",field] intoString:nil];
    [scanner scanString:[NSString stringWithFormat:@"%@:",field] intoString:nil];
    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&buffer];
    
    return [buffer copy];
}

-(NSDate *)processDate:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_8) //10.8, 10.9
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
    else //10.7
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZ"];
    
    if (date) {
        date = [self scanField:@"default" fromList:date];
        if (date) {
            if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_8) { //Before 10.9 doesn't recognize the Z
                if ([date hasSuffix:@"Z"]) {
                    date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
                }
            }
            if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_7) {
                date = [date stringByReplacingCharactersInRange:NSMakeRange(date.length - 3, 1) withString:@""];
            }
            return [dateFormatter dateFromString:date];
        }
    }
    return nil;
}

-(void)cancelMetadataRetrieval
{
    if ([metadataTask isRunning]) {
        [metadataTask interrupt];
    }
    [logger addToLog:@"Metadata Retrieval Cancelled" :self];
}

- (GIA_ProgrammeType)type
{
    if (radio.boolValue)
        return GiA_ProgrammeTypeBBC_Radio;
    else if ([tvNetwork hasPrefix:@"ITV"])
        return GIA_ProgrammeTypeITV;
    else
        return GiA_ProgrammeTypeBBC_TV;
}

- (NSString *)typeDescription
{
    NSDictionary *dic = @{@(GiA_ProgrammeTypeBBC_TV): @"BBC TV",
                          @(GiA_ProgrammeTypeBBC_Radio): @"BBC Radio",
                          @(GIA_ProgrammeTypeITV): @"ITV"};
    
    return [dic objectForKey:@([self type])];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        Programme *otherP = (Programme *)object;
        return [otherP.showName isEqual:showName] && [otherP.pid isEqual:pid];
    }
    else {
        return false;
    }
}

- (void)getNameSynchronous
{
    [self getName];
    while (getNameRunning) {
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.1]];
    }
}

- (void)getName
{
    // skip if pid looks like ITV productionId
    if ([pid rangeOfString:@"/"].location != NSNotFound ||
           [pid rangeOfString:@"#"].location != NSNotFound) {
        
            if ( [[[NSUserDefaults standardUserDefaults] valueForKey:@"CacheITV_TV"] isEqualTo:@YES] )
                [self setStatus:@"New ITV Cache"];
            else
                [self setStatus:@"Undetermined-ITV"];
        return;
    }
    @autoreleasepool {
        getNameRunning = true;
        
        NSTask *getNameTask = [[NSTask alloc] init];
        NSPipe *getNamePipe = [[NSPipe alloc] init];
        NSMutableString *getNameData = [[NSMutableString alloc] initWithString:@""];
        NSString *listArgument = @"--listformat=<index> <pid> <type> <name> - <episode>,<channel>|<web>|";
        NSString *fieldsArgument = @"--fields=index,pid";
        NSString *wantedID = pid;
        NSString *cacheExpiryArg = [[GetiPlayerArguments sharedController] cacheExpiryArgument:nil];
        NSArray *args = @[[[NSBundle mainBundle] pathForResource:@"get_iplayer" ofType:@"pl"],@"--nocopyright",@"--nopurge",cacheExpiryArg,[[GetiPlayerArguments sharedController] typeArgumentForCacheUpdate:NO andIncludeITV:YES],listArgument,[GetiPlayerArguments sharedController].profileDirArg,fieldsArgument,wantedID];
        [getNameTask setArguments:args];
        [getNameTask setLaunchPath:@"/usr/bin/perl"];
        
        [getNameTask setStandardOutput:getNamePipe];
        NSFileHandle *getNameFh = [getNamePipe fileHandleForReading];
        NSData *inData;
        
        NSMutableDictionary *envVariableDictionary = [NSMutableDictionary dictionaryWithDictionary:[getNameTask environment]];
        envVariableDictionary[@"HOME"] = [@"~" stringByExpandingTildeInPath];
        envVariableDictionary[@"PERL_UNICODE"] = @"AS";
        [getNameTask setEnvironment:envVariableDictionary];
        [getNameTask launch];
        
        while ((inData = [getNameFh availableData]) && [inData length]) {
            NSString *tempData = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
            [getNameData appendString:tempData];
        }
        [self performSelectorOnMainThread:@selector(processGetNameData:) withObject:getNameData waitUntilDone:YES];
        getNameRunning = false;
    }
}

- (void)processGetNameData:(NSString *)getNameData
{
    NSArray *array = [getNameData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    Programme *p = self;
    int i = 0;
    NSString *wantedID = [p valueForKey:@"pid"];
    BOOL found=NO;
    for (NSString *string in array)
    {
        i++;
        if (i>1 && i<[array count]-1)
        {
            // TODO: remove use of index in future version
            NSString *pid, *showName, *index, *type, *tvNetwork, *url;
            @try{
                NSScanner *scanner = [NSScanner scannerWithString:string];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&index];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:NULL];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&pid];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:NULL];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&type];
                [scanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:NULL];
                [scanner scanUpToString:@","  intoString:&showName];
                [scanner scanString:@"," intoString:nil];
                [scanner scanUpToString:@"|" intoString:&tvNetwork];
                [scanner scanString:@"|" intoString:nil];
                [scanner scanUpToString:@"|" intoString:&url];
                scanner = nil;
            }
            @catch (NSException *e) {
                NSAlert *getNameException = [[NSAlert alloc] init];
                [getNameException addButtonWithTitle:@"OK"];
                [getNameException setMessageText:[NSString stringWithFormat:@"Unknown Error!"]];
                [getNameException setInformativeText:@"An unknown error occured whilst trying to parse Get_iPlayer output (processGetNameData)."];
                [getNameException setAlertStyle:NSWarningAlertStyle];
                [getNameException runModal];
                getNameException = nil;
            }
            if ([wantedID isEqualToString:pid] || [wantedID isEqualToString:index])
            {
                found=YES;
                [p setValue:showName forKey:@"showName"];
                [p setValue:pid forKey:@"pid"];
                [p setValue:tvNetwork forKey:@"tvNetwork"];
                [p setUrl:url];
                p.status = @"Available";
                if ([type isEqualToString:@"radio"]) [p setValue:@YES forKey:@"radio"];
            }
        }
        
    }
    if (!found)
    {
        if ([[p showName] isEqualToString:@""] || [[p showName] isEqualToString:@"Unknown: Not in Cache"])
            [p setValue:@"Unknown: Not in Cache" forKey:@"showName"];
        [p setProcessedPID:@NO];
        [p getNameFromPID];
    }
    else
    {
        [p setProcessedPID:@YES];
    }
    
}

- (void)getNameFromPID
{
    [logger addToLog:@"Retrieving Metadata For PID" :self];
    getiPlayerProxy = [[GetiPlayerProxy alloc] initWithLogger:logger];
    [getiPlayerProxy loadProxyInBackgroundForSelector:@selector(getNameFromPIDProxyLoadFinished:proxyDict:) withObject:nil onTarget:self silently:NO];
}

-(void)getNameFromPIDProxyLoadFinished:(id)sender proxyDict:(NSDictionary *)proxyDict
{
    [self performSelectorInBackground:@selector(spawnGetNameFromPIDThreadWitProxyDict:) withObject:proxyDict];
}

-(void)spawnGetNameFromPIDThreadWitProxyDict:(NSDictionary *)proxyDict
{
    @autoreleasepool {
        getiPlayerProxy = nil;
        if (proxyDict && [proxyDict[@"error"] code] == kProxyLoadCancelled)
            return;
        NSTask *getNameTask = [[NSTask alloc] init];
        NSPipe *getNamePipe = [[NSPipe alloc] init];
        NSMutableString *getNameData = [[NSMutableString alloc] initWithString:@""];
        NSMutableString *versionArg = [NSMutableString stringWithString:@"--versions="];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"AudioDescribedNew"] boolValue])
            [versionArg appendString:@"audiodescribed,"];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"SignedNew"] boolValue])
            [versionArg appendString:@"signed,"];
        [versionArg  appendString:@"default"];
        NSString *infoArgument = @"--info";
        NSString *pidArgument = [NSString stringWithFormat:@"--pid=%@", pid];
        NSString *cacheExpiryArg = [[GetiPlayerArguments sharedController] cacheExpiryArgument:nil];
        NSMutableArray *args = [[NSMutableArray alloc] initWithObjects:[[NSBundle mainBundle] pathForResource:@"get_iplayer" ofType:@"pl"],@"--nocopyright",@"--nopurge",versionArg,cacheExpiryArg,[GetiPlayerArguments sharedController].profileDirArg,infoArgument,pidArgument,nil];
        if (proxyDict[@"proxy"]) {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"AlwaysUseProxy"] boolValue]) //Don't need proxy
            {
                [args addObject:[NSString stringWithFormat:@"-p%@",[proxyDict[@"proxy"] url]]];
            }
            
        }
        [getNameTask setArguments:args];
        [getNameTask setLaunchPath:@"/usr/bin/perl"];
        
        [getNameTask setStandardOutput:getNamePipe];
        NSFileHandle *getNameFh = [getNamePipe fileHandleForReading];
        NSData *inData;
        
        NSMutableDictionary *envVariableDictionary = [NSMutableDictionary dictionaryWithDictionary:[getNameTask environment]];
        envVariableDictionary[@"HOME"] = [@"~" stringByExpandingTildeInPath];
        envVariableDictionary[@"PERL_UNICODE"] = @"AS";
        [getNameTask setEnvironment:envVariableDictionary];
        [getNameTask launch];
        
        while ((inData = [getNameFh availableData]) && [inData length]) {
            NSString *tempData = [[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding];
            [getNameData appendString:tempData];
        }
        [self performSelectorOnMainThread:@selector(processGetNameDataFromPID:) withObject:getNameData waitUntilDone:YES];
        getNameRunning = false;
    }
}

- (void)processGetNameDataFromPID:(NSString *)getNameData
{
    NSArray *array = [getNameData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    Programme *p = self;
    int i = 0;
    NSString *available = nil, *versions = nil, *title = nil;
    for (NSString *string in array)
    {
        i++;
        if (i>1 && i<[array count]-1)
        {
            NSString *tmp_info = nil, *tmp_title = nil;
            @try{
                NSScanner *scanner = [NSScanner scannerWithString:string];
                [scanner scanString:@"INFO:" intoString:&tmp_info];
                if (tmp_info) {
                    if (!available) {
                        [scanner scanUpToString:@"(available versions:" intoString:nil];
                        [scanner scanString:@"(available versions:" intoString:&available];
                        if (available) {
                            [scanner scanUpToString:@")" intoString:&versions];
                        }
                    }
                } else {
                    [scanner setScanLocation:0];
                    if (!title) {
                        [scanner scanString:@"title:" intoString:&tmp_title];
                        if (tmp_title) {
                            [scanner scanUpToString:@"asdfasdf" intoString:&title];
                        }
                    }
                    scanner = nil;
                    if (title) {
                        break;
                    }
                }
            }
            @catch (NSException *e) {
                NSAlert *getNameException = [[NSAlert alloc] init];
                [getNameException addButtonWithTitle:@"OK"];
                [getNameException setMessageText:[NSString stringWithFormat:@"Unknown Error!"]];
                [getNameException setInformativeText:@"An unknown error occured whilst trying to parse Get_iPlayer output (processGetNameDataFromPID)."];
                [getNameException setAlertStyle:NSWarningAlertStyle];
                [getNameException runModal];
                getNameException = nil;
            }
        }
        
    }
    if (available) {
        if (versions) {
            [p setValue:[NSString stringWithFormat:@"Available: %@", versions] forKey:@"status"];
        } else {
            [p setValue:@"Not Available" forKey:@"status"];
        }
    } else {
        [p setValue:@"Available" forKey:@"status"];
    }
    if (title) {
        [p setValue:title forKey:@"showName"];
    } else {
        [p setValue:@"Unknown: PID Not Found" forKey:@"showName"];
    }
    [p setProcessedPID:@NO];
}

@synthesize showName;
@synthesize tvNetwork;
@synthesize status;
@synthesize complete;
@synthesize successful;
@synthesize path;
@synthesize seriesName;
@synthesize episodeName;
@synthesize season;
@synthesize episode;
@synthesize timeadded;
@synthesize processedPID;
@synthesize radio;
@synthesize realPID;
@synthesize subtitlePath;
@synthesize reasonForFailure;
@synthesize availableModes;
@synthesize url;
@synthesize dateAired;
@synthesize desc;

@synthesize extendedMetadataRetrieved;
@synthesize successfulRetrieval;
@synthesize duration;
@synthesize categories;
@synthesize firstBroadcast;
@synthesize lastBroadcast;
@synthesize modeSizes;
@synthesize thumbnail;
@synthesize addedByPVR;
@end
