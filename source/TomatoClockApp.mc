using Toybox.Application;
using Toybox.WatchUi;

var tomato_time;
var short_break_time;
var long_break_time;

class TomatoClockApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
    	var view = new TomatoClockView();
    	var viewDelegate = new TomatoClockDelegate(view);
        return [view, viewDelegate];
    }
    
    function onSettingsChanged(){
    }

}
