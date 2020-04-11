//
// Tomato Clock - Alfonso Orta - 2020
//

using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Time;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Attention;

// The main view for the tomato clock app.
// This displays the remaining time
class TomatoClockView extends WatchUi.View {

	// Periods constants
	static const PERIOD_TOMATO = 0;
	static const PERIOD_SHORT_BREAK = 1;
	static const PERIOD_LONG_BREAK = 2;

	// Storage keys
	static const TIMER_START_TIME_KEY = 0;
	static const TIMER_PAUSE_TIME_KEY = 1;
	static const PERIOD_KEY = 2;

	var mTimer;
	var mTimerStartTime;
	var mTimerPauseTime;
	var mTimerDuration;

	var mCurrentPeriod;

    // Initialize variables for this view
    function initialize(backgroundData) {
        View.initialize();
        mTimer = new Timer.Timer();

        // Fetch the persisted values from the object store
        if(backgroundData == null) {
       		mTimerStartTime = objectStoreGet(TIMER_START_TIME_KEY, null);
            mTimerPauseTime = objectStoreGet(TIMER_PAUSE_TIME_KEY, null);
            setCurrentPeriodAndTimerDuration(objectStoreGet(PERIOD_KEY, PERIOD_TOMATO));
        } else {
        	// If we got an expiration event from the background process
            // when we started up, reset the timer back to the default value.
            var period = objectStoreGet(PERIOD_KEY, null);
            resetTimer();
    		setCurrentPeriodAndTimerDuration( period != PERIOD_TOMATO ? PERIOD_TOMATO : PERIOD_SHORT_BREAK);
        }

        // If the timer is running, we need to start the timer up now.
        if((mTimerStartTime != null) && (mTimerPauseTime == null)) {
            // Update the display each second.
            mTimer.start(method(:requestUpdate), 1000, true);
        }
    }

    // Draw the time remaining on the timer to the display
    function onUpdate(dc) {
	    var font = Graphics.FONT_LARGE;
	    var fontHeight = Graphics.getFontHeight(font);
	    var centerX = dc.getWidth() / 2;
	    var centerY = dc.getHeight() / 2;
    	var x;
    	var y;
    	var r;
    	var elapsedTime;
    	var tomatoImage;
    	var arcProperties;

    	// Clear screen
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_BLACK );
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );

        // Draw tomato icon
        tomatoImage = WatchUi.loadResource( Rez.Drawables.Tomato );
        x = centerX - tomatoImage.getWidth() / 2;
        y = centerY - (fontHeight / 2) - tomatoImage.getHeight();
        dc.drawBitmap(x, y, tomatoImage);

        // Calculate elapsed time
        elapsedTime = getElapsedTime();

        // Check if the countdown is finished
        if(elapsedTime >= mTimerDuration){
        	Attention.vibrate([
		        new Attention.VibeProfile(50, 1500),
		        new Attention.VibeProfile(0, 1000),
		        new Attention.VibeProfile(50, 1500)
		    ]);
        	stopTimer();
		    resetTimer();
			setCurrentPeriodAndTimerDuration( mCurrentPeriod != PERIOD_TOMATO ? PERIOD_TOMATO : PERIOD_SHORT_BREAK);
		    elapsedTime = 0;
        }
        
        // Draw the countdown
        x = centerX;
        y = centerY - (fontHeight / 2);
        dc.drawText( x, y, font, getTextTime(mTimerDuration - elapsedTime), Graphics.TEXT_JUSTIFY_CENTER );
        
        // Draw the countdown graphically
        x = centerX;
        y = centerY;
        r = centerX - 5;
        arcProperties = getArcProperties(elapsedTime);        
        dc.setPenWidth(arcProperties["penWith"]);
        dc.setColor(arcProperties["color"], Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, r, arcProperties["attr"], arcProperties["degreeStart"], arcProperties["degreeEnd"]);
        
        // Draw the current period time
        x = centerX;
        y = centerY + fontHeight * 1.25;
        dc.drawText( x, y, font, arcProperties["textPeriod"], Graphics.TEXT_JUSTIFY_CENTER );
    }
    
    // Save all the persisted values into the object store
    function saveProperties() {
        objectStorePut(PERIOD_KEY, mCurrentPeriod);
        objectStorePut(TIMER_START_TIME_KEY, mTimerStartTime);
        objectStorePut(TIMER_PAUSE_TIME_KEY, mTimerPauseTime);
    }

    // Set up a background event to occur when the timer expires. This
    // will alert the user that the timer has expired even if the
    // application does not remain open.
    function setBackgroundEvent() {
        if((mTimerStartTime != null) && (mTimerPauseTime == null)) {
            var time = new Time.Moment(mTimerStartTime);
            time = time.add(new Time.Duration(mTimerDuration));
            try {
                var info = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                Background.registerForTemporalEvent(time);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
            }
        }
    }

    // Delete the background event. We can get rid of this event when the
    // application opens because now we can see exactly when the timer
    // is going to expire
    function deleteBackgroundEvent() {
        Background.deleteTemporalEvent();
    }

    // If we do receive a background event while the appliation is open,
    // go ahead and reset to the default timer.
    function backgroundEvent(data) {
		setCurrentPeriodAndTimerDuration(PERIOD_TOMATO);
    	resetTimer();
        requestUpdate();
    }	
    
	// It is only needed to request display updates as the timer counts
    // down so we see the updated time on the display.
    function requestUpdate() {
        WatchUi.requestUpdate();
    }		    
	
	// If the timer is running, pause it. Otherwise, start it up.
    function startStopTimer() {
    	var now = Time.now().value();

        if(mTimerStartTime == null) {
            mTimerStartTime = now;
            mTimer.start(method(:requestUpdate), 1000, true);
            Attention.vibrate([
		       		new Attention.VibeProfile(50, 1000)
		    	]);
        } else {
            if(mTimerPauseTime == null) {
                mTimerPauseTime = now;
                stopTimer();
                requestUpdate();
            } else if( mTimerPauseTime - mTimerStartTime < mTimerDuration ) {
                mTimerStartTime += (now - mTimerPauseTime);
                mTimerPauseTime = null;
                mTimer.start(method(:requestUpdate), 1000, true);
                Attention.vibrate([
		       		new Attention.VibeProfile(50, 1000)
		    	]);
            }
        }
    }
    
    // Stop the timer
    function stopTimer() {
    	mTimer.stop();
    }
    
    // Reset time values
    function resetTimer() {
        mTimerStartTime = null;
        mTimerPauseTime = null;
    }
    
    // Set the current period and the timer duration depend on the current period
    function setCurrentPeriodAndTimerDuration(currentPeriod) {
    	mCurrentPeriod = currentPeriod;
    	switch(currentPeriod) {
        	case PERIOD_TOMATO:
        		mTimerDuration = Application.getApp().getProperty("tomato_time");
        	break;
        	case PERIOD_SHORT_BREAK:
        		mTimerDuration = Application.getApp().getProperty("short_break_time");
        	break;
        	case PERIOD_LONG_BREAK:
        		mTimerDuration = Application.getApp().getProperty("long_break_time");
        	break;
        } 
    }
    
    // Calculate the elapsed time
    function getElapsedTime() {
    	var elapsed = 0;
        if(mTimerStartTime != null) {
            if(mTimerPauseTime != null) {
                elapsed = mTimerPauseTime - mTimerStartTime;
            } else {
                elapsed = Time.now().value() - mTimerStartTime;
            }
            
            if( elapsed >= mTimerDuration ) {
                elapsed = mTimerDuration;
            }
        }
        return elapsed;
    }

    // Get the countdown text from the time value in seconds
    function getTextTime(timeValue) {
    	var seconds = timeValue % 60;
        var minutes = timeValue / 60;

        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }
    
    // Get the arc properties to draw it
    function getArcProperties(elapsedTime) {
    	var color;
        var textPeriod;
        var totalCount;
        
        switch(mCurrentPeriod) {
        	case PERIOD_TOMATO:
        		color = Graphics.COLOR_BLUE;
        		textPeriod = WatchUi.loadResource(Rez.Strings.menu_label_tomato);
        	break;
        	case PERIOD_SHORT_BREAK:
        		color = Graphics.COLOR_GREEN;
        		textPeriod=WatchUi.loadResource(Rez.Strings.menu_label_short_break);
        	break;
        	case PERIOD_LONG_BREAK:
        		color = Graphics.COLOR_YELLOW;
        		textPeriod=WatchUi.loadResource(Rez.Strings.menu_label_long_break);
        	break;
        }    
                
        return {
        	"penWith" => 7,
        	"color" => color,
        	"attr" => Graphics.ARC_CLOCKWISE,
        	"degreeStart" => 90,
        	"degreeEnd" => 90 + (elapsedTime * 360 / mTimerDuration),
        	"textPeriod" => textPeriod
        };
    }
}