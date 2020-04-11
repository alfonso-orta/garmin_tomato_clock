//
// Tomato Clock - Alfonso Orta - 2020
//

using Toybox.WatchUi;
using Toybox.System;

// The input handling delegate for the menu
class MenuDelegate extends WatchUi.MenuInputDelegate {
	var parentView;
	
    function initialize(view) {
        MenuInputDelegate.initialize();
        parentView = view;
    }

	// This method is called when a item is selected
    function onMenuItem(item) {
        if (item == :item_tomato) {
        	parentView.setCurrentPeriodAndTimerDuration(TomatoClockView.PERIOD_TOMATO);
        	parentView.resetTimer();
        	parentView.stopTimer();
        } else if (item == :item_short_break) {
        	parentView.setCurrentPeriodAndTimerDuration(TomatoClockView.PERIOD_SHORT_BREAK);
        	parentView.resetTimer();
        	parentView.stopTimer();
	    } else if (item == :item_long_break) {
        	parentView.setCurrentPeriodAndTimerDuration(TomatoClockView.PERIOD_LONG_BREAK);
    		parentView.resetTimer();
        	parentView.stopTimer();
	    }
    }

}