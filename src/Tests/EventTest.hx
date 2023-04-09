package tests;

import utest.Assert;
import event.EventDispatcher;

class EventTest extends utest.Test {
    private function testListeners () {
        var dispatcher = new EventDispatcher<Int>();
        var listenerGot: Null<Int> = null;

        function listener (event: Int) {
            listenerGot = event;    
        }

        Assert.isFalse(dispatcher.hasListener(listener));

        dispatcher.addListener(listener);
        
        Assert.isTrue(dispatcher.hasListener(listener));
        
        dispatcher.removeListener(listener);
        
        Assert.isFalse(dispatcher.hasListener(listener));
        
        dispatcher.addListener(listener);
    
        dispatcher.dispatch(69);
        Assert.equals(listenerGot, 69);
        dispatcher.dispatch(420);
        Assert.equals(listenerGot, 420);

        dispatcher.removeListener(listener);
        dispatcher.addListener(listener, true);

        dispatcher.dispatch(69);
        Assert.equals(listenerGot, 69);
        dispatcher.dispatch(420);
        Assert.equals(listenerGot, 69); // prev
    }

    private function testEventListeners () {
        var dispatcher = new EventDispatcher<Int>();
        var eventListenerCalls: Int = 0;

        function eventListener () {
            eventListenerCalls++;   
        }

        Assert.isFalse(dispatcher.hasEventListener(eventListener));

        dispatcher.addEventListener(69, eventListener);
        
        Assert.isTrue(dispatcher.hasEventListener(eventListener));
        
        dispatcher.removeEventListener(eventListener);
        
        Assert.isFalse(dispatcher.hasEventListener(eventListener));
        
        dispatcher.addEventListener(69, eventListener);
    
        dispatcher.dispatch(69);
        Assert.equals(eventListenerCalls, 1);
        dispatcher.dispatch(420);
        Assert.equals(eventListenerCalls, 1); // unchanged

        dispatcher.removeEventListener(eventListener);
        dispatcher.addEventListener(420, eventListener, true);

        dispatcher.dispatch(420);
        Assert.equals(eventListenerCalls, 2);
        dispatcher.dispatch(69);
        Assert.equals(eventListenerCalls, 2); // prev
    }
}
