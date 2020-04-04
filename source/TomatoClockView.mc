using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Attention;

class TomatoClockView extends WatchUi.View {

	static const PERIOD_TOMATO = 0;
	static const PERIOD_SHORT_BREAK = 1;
	static const PERIOD_LONG_BREAK = 2;
	
	static const STATUS_TIMER_STOPPED = 0;
	static const STATUS_TIMER_STARTED = 1;
	
	var timer;
	var statusTimer;
	var currentPeriod;
	var count;
	
	var font = Graphics.FONT_LARGE;
    var fontHeight = Graphics.getFontHeight(font);
    var centerX;
    var centerY;

    function initialize() {
        View.initialize();
        timer = new Timer.Timer();
        setStatusTimer(STATUS_TIMER_STOPPED);
        setCurrentPeriod(PERIOD_TOMATO);
    }

    function onLayout(dc) {    
        centerY = dc.getHeight() / 2;
    	centerX = dc.getWidth() / 2;
    }
    
    function onUpdate(dc) {
    	var x;
    	var y;
    	var r;
    	
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        
        var tomatoImage = WatchUi.loadResource( Rez.Drawables.Tomato );
        
        
        
        x = centerX - tomatoImage.getWidth() / 2;
        y = centerY - (fontHeight / 2) - tomatoImage.getHeight();
        dc.drawBitmap(x, y, tomatoImage);
        
        x = centerX;
        y = centerY - (fontHeight / 2);
        dc.drawText( x, y, font, getTextTime(), Graphics.TEXT_JUSTIFY_CENTER );
        
        x = centerX;
        y = centerY;
        r = centerX - 5;
        var arcProperties = getArcProperties();        
        dc.setPenWidth(arcProperties["penWith"]);
        dc.setColor(arcProperties["color"], Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, r, arcProperties["attr"], arcProperties["degreeStart"], arcProperties["degreeEnd"]);
        
        x = centerX;
        y = centerY + fontHeight * 1.25;
        dc.drawText( x, y, font, arcProperties["textPeriod"], Graphics.TEXT_JUSTIFY_CENTER );
    }

    function callbackTimer(){
		count--;
		if(count <= 0) {
			stopTimer();
			setStatusTimer(STATUS_TIMER_STOPPED);
						
			Attention.vibrate([
			        new Attention.VibeProfile(50, 1500),
			        new Attention.VibeProfile(0, 1000),
			        new Attention.VibeProfile(50, 1500)
			    ]);
			    
			if (isCurrentPeriodTomato()){
				setCurrentPeriod(TomatoClockView.PERIOD_SHORT_BREAK);
			} else {
				setCurrentPeriod(TomatoClockView.PERIOD_TOMATO);
			}	
	
		}
	    WatchUi.requestUpdate();   	
	}
	
	    
    function startTimer(){
	   timer.start(method(:callbackTimer), 1000, true);
    }
    
    function stopTimer(){
    	timer.stop();
    }
	
	function setCurrentPeriod(period) {
		switch(period) {
        	case PERIOD_TOMATO:
        		count = Application.getApp().getProperty("tomato_time");
        	break;
        	case PERIOD_SHORT_BREAK:
        		count = Application.getApp().getProperty("short_break_time");
        	break;
        	case PERIOD_LONG_BREAK:
        		count = Application.getApp().getProperty("long_break_time");
        	break;
        }
        currentPeriod = period;
	}
	
	function isCurrentPeriodTomato(){
		return currentPeriod == TomatoClockView.PERIOD_TOMATO;
	}
	
	function setStatusTimer(status){
        statusTimer = status;
    }
    
    function isTimerStopped() {
    	return statusTimer == TomatoClockView.STATUS_TIMER_STOPPED;
    }
    
    function getTextTime() {
    	var minutes = Math.floor(count/60);
        var seconds = count - minutes*60;
        
        if(minutes < 10) {
        	minutes = "0" + minutes;
        }
        
        if(seconds < 10){
        	seconds = "0" + seconds;
        }
        
        return minutes + ":" + seconds;
    }
    
    function getArcProperties() {
    	var color;
        var textPeriod;
        var totalCount;
        
        switch(currentPeriod) {
        	case PERIOD_TOMATO:
        		color = Graphics.COLOR_BLUE;
        		totalCount = Application.getApp().getProperty("tomato_time");
        		textPeriod = WatchUi.loadResource(Rez.Strings.menu_label_tomato);
        	break;
        	case PERIOD_SHORT_BREAK:
        		color = Graphics.COLOR_GREEN;
        		totalCount=Application.getApp().getProperty("short_break_time");
        		textPeriod=WatchUi.loadResource(Rez.Strings.menu_label_short_break);
        	break;
        	case PERIOD_LONG_BREAK:
        		color = Graphics.COLOR_YELLOW;
        		totalCount=Application.getApp().getProperty("long_break_time");
        		textPeriod=WatchUi.loadResource(Rez.Strings.menu_label_long_break);
        	break;
        }    
        
        return {
        	"penWith" => 7,
        	"color" => color,
        	"attr" => Graphics.ARC_CLOCKWISE,
        	"degreeStart" => 90,
        	"degreeEnd" => 90 + ((totalCount - count) * 360 / totalCount),
        	"textPeriod" => textPeriod
        };
    }
}
