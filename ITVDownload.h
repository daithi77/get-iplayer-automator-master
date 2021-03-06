//
//  ITVDownload.h
//  Get_iPlayer GUI
//
//  Created by Thomas Willson on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"
#import "TVFormat.h"
#import "LogController.h"

@interface ITVDownload : Download {
    

}
- (id)initWithProgramme:(Programme *)tempShow itvFormats:(NSArray *)itvFormatList proxy:(HTTPProxy *)aProxy logController:(LogController *)logger;
- (id)initTest:(Programme *)tempShow proxy:(HTTPProxy *)aProxy;
@end
