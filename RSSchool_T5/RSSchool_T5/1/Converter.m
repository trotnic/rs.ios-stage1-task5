#import "Converter.h"

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";

@implementation PNConverter
- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    // good luck
    // thx
    
    NSDictionary *cypher = @{
        @"373": @"MD",
        @"374": @"AM",
        @"375": @"BY",
        @"380": @"UA",
        @"992": @"TJ",
        @"993": @"TM",
        @"994": @"AZ",
        @"996": @"KG",
        @"998": @"UZ"
    };
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableString *processString = [[self filteredString:string] mutableCopy];
    NSString *number = [processString copy];
    NSString *code = @"";
    
    NSRegularExpression *ru = [NSRegularExpression regularExpressionWithPattern:@"^(79)|^(7(?!7))" options:0 error:nil];
    NSRegularExpression *kz = [NSRegularExpression regularExpressionWithPattern:@"^77" options:0 error:nil];
    NSRegularExpression *common = [NSRegularExpression regularExpressionWithPattern:@"^[^39]" options:0 error:nil];
    
    NSRange processRange = NSMakeRange(0, processString.length);
    
    if([ru numberOfMatchesInString:processString options:0 range:processRange] != 0) {
        code = @"RU";
    } else if([kz numberOfMatchesInString:processString options:0 range:processRange] != 0) {
        code = @"KZ";
    } else if([common numberOfMatchesInString:processString options:0 range:processRange] == 0 && processRange.length > 2) {
        code = [cypher valueForKey:[self countrySlice:processString]];
    }
    
    if([code isEqualToString:@""]) {
        number = [NSString stringWithFormat:@"+%@", processString];
    } else {
        number = [self phoneNumber:processString country:code];
    }

    [result setValue:number forKey:KeyPhoneNumber];
    [result setValue:code forKey:KeyCountry];
    
    return result;
}

- (NSString *)filteredString:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{1,12}" options:0 error:nil];
    NSRange match = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    return [string substringWithRange:match];
}

- (NSString *)countrySlice:(NSString *)string {
    if(string.length < 3) return string;
    return [string substringWithRange:NSMakeRange(0, 3)];
}

- (NSString *)phoneNumber:(NSString *)string country:(NSString *)code {
    NSDictionary *lengthPattern = @{
        @"8": @"+___ (__) ___-___",
        @"9": @"+___ (__) ___-__-__",
        @"10": @"+_ (___) ___-__-__"
    };
    
    NSSet *tenth = [NSSet setWithArray:@[@"RU", @"KZ"]];
    NSSet *nineth = [NSSet setWithArray:@[@"BY", @"UA", @"UA", @"TJ", @"AZ", @"KG", @"UZ"]];
    NSSet *eighth = [NSSet setWithArray:@[@"MD", @"AM", @"TM"]];
    
    NSString *result = @"";
    if([tenth containsObject:code])
        result = [self formatted:string format:[lengthPattern valueForKey:@"10"]];
    if([nineth containsObject:code])
        result = [self formatted:string format:[lengthPattern valueForKey:@"9"]];
    if([eighth containsObject:code])
        result = [self formatted:string format:[lengthPattern valueForKey:@"8"]];
    
    return result;
}

- (NSString *)formatted:(NSString *)string format:(NSString *)format {
    NSMutableString *resultForm = [format mutableCopy];
    for(NSUInteger i = 0; i < string.length; i++) {
        NSRange occurence = [resultForm rangeOfString:@"_"];
        if(occurence.location != NSNotFound)
            [resultForm replaceCharactersInRange:occurence withString: [string substringWithRange:NSMakeRange(i, 1)]];
    }
    NSRange occurence = [resultForm rangeOfString:@"_"];
    if(occurence.location != NSNotFound) {
        occurence = [resultForm rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
        resultForm = [[resultForm substringToIndex:occurence.location + 1] mutableCopy];
    }
    return resultForm;
}
@end
