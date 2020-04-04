using Toybox.WatchUi;
using Toybox.Attention;

class TomatoClockDelegate extends WatchUi.BehaviorDelegate {

	var parentView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        parentView = view;
    }
    
    function onMenu() {
       	WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(parentView), WatchUi.SLIDE_UP);
        return true;
    }
    
   function onTap(event) {
   		WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(parentView), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onKey(event) {
    	if(event.getKey() == WatchUi.KEY_ENTER) {
    	
    		if(parentView.isTimerStopped()) {
       		   parentView.startTimer();
       		   parentView.setStatusTimer(TomatoClockView.STATUS_TIMER_STARTED);
    		   
    		   Attention.vibrate([
		       		new Attention.VibeProfile(50, 1000)
		    	]);
    		} else {
    		   parentView.stopTimer();
    		   parentView.setStatusTimer(TomatoClockView.STATUS_TIMER_STOPPED);
       		}
    		return true;
    	}
    	return false;
    }

}