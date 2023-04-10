package event;

typedef Listener<T> = (T) -> Void;
typedef EventListener<T> = {
    callback: () -> Void,
    listener: Listener<T>
}

class EventManager<T> {
    private var listeners = new Array<Listener<T>>();
    private var eventListeners = new Array<EventListener<T>>();

    public function new () {}

    //
    // Listener
    //

    public function hasListener (listener: Listener<T>): Bool {
        return this.listeners.contains(listener);
    }

    public function removeListener (listener: Listener<T>): Void {
        Debug.assert(hasListener(listener));
        this.listeners.remove(listener);
    }

    public function addListener (listener: Listener<T>, oneShot: Bool = false): Void {
        Debug.assert(!hasListener(listener));
        this.listeners.push(listener);
        if (oneShot) {
            function destructorListener (_) {
                removeListener(destructorListener);
                removeListener(listener);
            }
            this.listeners.push(destructorListener);
        }
    }

    //
    // EventListener
    //

    public function hasEventListener (callback: () -> Void): Bool {
        return _getEventListener(callback) != null;
    }

    private function _getEventListener (callback: () -> Void): Null<EventListener<T>> {
        for (eventListener in eventListeners)
            if (eventListener.callback == callback)
                return eventListener;
        return null;
    }

    public function removeEventListener (callback: () -> Void): Void {
        Debug.assert(hasEventListener(callback));
        var eventListener = _getEventListener(callback);
        removeListener(eventListener.listener);
        this.eventListeners.remove(eventListener);
    }

    public function addEventListener (event: T, callback: () -> Void, oneShot: Bool = false): Void {
        Debug.assert(!hasEventListener(callback));
        function listener (e: T) {
            if (e == event) {
                if (oneShot) {
                    removeEventListener(callback);
                }
                callback();
            }
        }
        var eventListener: EventListener<T> = {
            callback: callback,
            listener: listener
        }
        addListener(listener);
        this.eventListeners.push(eventListener);
    }
}