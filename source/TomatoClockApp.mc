//
// Tomato Clock - Alfonso Orta - 2020
//

using Toybox.Application;

// We must annotate (with the :background annotation) the application
// base so it can be accessed in the background process
(:background)
class TomatoClockApp extends Application.AppBase {

	var mTomatoView;
	var mBackgroundData;

    function initialize() {
        AppBase.initialize();
    }
    
    // This method is called when app is started
    function onStart(state) {
    }
    
    // This method is called when app is stopped
    function onStop(state) {    
        if( mTomatoView ) {        
            mTomatoView.saveProperties();
            mTomatoView.setBackgroundEvent();
        }
    }
    
    // This method is called when data is returned from our
    // Background process.
    function onBackgroundData(data) {    
        if( mTomatoView ) {
            mTomatoView.backgroundEvent(data);
        } else {
            mBackgroundData = data;
        }
    }
    
    // This method runs each time the main application starts.
    function getInitialView() {    
    	mTomatoView = new TomatoClockView(mBackgroundData);
    	mTomatoView.deleteBackgroundEvent();
        return [mTomatoView, new TomatoClockDelegate(mTomatoView)];
    }
    
    // This method runs each time the background process starts
    function getServiceDelegate(){    
        return [new TomatoClockrServiceDelegate()];
    }
}

// Global method for getting a key from the object store
// with a specified default
function objectStoreGet(key, defaultValue) {
    var value = Application.getApp().getProperty(key);
    if((value == null) && (defaultValue != null)) {
        value = defaultValue;
        Application.getApp().setProperty(key, value);
        }
    return value;
}

// Global method for putting a key value pair into the
// object store
function objectStorePut(key, value) {
    Application.getApp().setProperty(key, value);
}
