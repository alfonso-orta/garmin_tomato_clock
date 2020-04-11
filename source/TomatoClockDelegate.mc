//
// Tomato Clock - Alfonso Orta - 2020
//

using Toybox.WatchUi;
using Toybox.Attention;

// The primary input handling delegate for the app
class TomatoClockDelegate extends WatchUi.BehaviorDelegate {

	var parentView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        parentView = view;
    }

    // Call show the main menu when menu event occurs
    function onMenu() {
    	showMenu();
        return true;
    }

    // Call show the main menu when tap event occurs
    function onTap(event) {
		showMenu();
		return true;
    }

    // Call the start stop timer method on the parent view
    // when the KEY_ENTER occurs
    function onKey(event) {
    	if(event.getKey() == WatchUi.KEY_ENTER) {
	    	parentView.startStopTimer();
    		return true;
    	}
    	return false;
    }

    // Show the main menu
    function showMenu() {
    	WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(parentView), WatchUi.SLIDE_UP);
    }
}