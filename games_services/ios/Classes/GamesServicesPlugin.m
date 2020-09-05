#import "GamesServicesPlugin.h"
#import <games_services/games_services-Swift.h>

@implementation GamesServicesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGamesServicesPlugin registerWithRegistrar:registrar];
}
@end
