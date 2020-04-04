using Toybox.WatchUi;
using Toybox.System;

class MenuDelegate extends WatchUi.MenuInputDelegate {
	var parentView;
	
    function initialize(view) {
        MenuInputDelegate.initialize();
        parentView = view;
    }

    function onMenuItem(item) {
        if (item == :item_tomato) {
        	parentView.setCurrentPeriod(TomatoClockView.PERIOD_TOMATO);
        	parentView.setStatusTimer(TomatoClockView.STATUS_TIMER_STOPPED);
        	parentView.stopTimer();
        } else if (item == :item_short_break) {
        	parentView.setCurrentPeriod(TomatoClockView.PERIOD_SHORT_BREAK);
        	parentView.setStatusTimer(TomatoClockView.STATUS_TIMER_STOPPED);
        	parentView.stopTimer();
	    } else if (item == :item_long_break) {
        	parentView.setCurrentPeriod(TomatoClockView.PERIOD_LONG_BREAK);
        	parentView.setStatusTimer(TomatoClockView.STATUS_TIMER_STOPPED);
        	parentView.stopTimer();
	    }
    }

}