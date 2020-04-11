//
// Tomato Clock - Alfonso Orta - 2020
//

using Toybox.Background;
using Toybox.System;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system
(:background)
class TomatoClockrServiceDelegate extends System.ServiceDelegate {
    function initialize() {
        ServiceDelegate.initialize();
    }

    // If our timer expires, it means the application timer ran out,
    // and the main application is not open
    function onTemporalEvent() {

        // Use background resources if they are available
        if (Application has :loadResource) {
            Background.requestApplicationWake(Application.loadResource(Rez.Strings.timer_expired));
        } else {
            Background.requestApplicationWake("Your timer has expired!");
        }

        Background.exit(true);
    }
}