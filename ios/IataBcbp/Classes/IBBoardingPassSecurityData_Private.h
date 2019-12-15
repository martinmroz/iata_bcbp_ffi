//
//  IBBoardingPass.h
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBBcbp;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPassSecurityData ()

/**
 Creates a new instance of the receiver with the specified Bcbp instance.
 */
+ (instancetype)securityDataWithBcbp:(IBBcbp *)bcbp;

/**
 @return A new instance of the receiver with all fields populated.
 */
- (instancetype)initWithTypeOfSecurityData:(NSString *_Nullable)typeOfSecurityData
                              securityData:(NSString *_Nullable)securityData NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
