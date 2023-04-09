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

    private function getEventListener (callback: () -> Void): Null<EventListener<T>> {
        for (eventListener in eventListeners)
            if (eventListener.callback == callback)
                return eventListener;
        return null;
    }

    public function hasListener (listener: Listener<T>): Bool {
        return this.listeners.contains(listener);
    }

    public function hasEventListener (callback: () -> Void): Bool {
        return getEventListener(callback) != null;
    }

    public function removeListener (listener: Listener<T>): Void {
        Debug.assert(hasListener(listener));
        this.listeners.remove(listener);
    }

    public function removeEventListener (callback: () -> Void): Void {
        Debug.assert(hasEventListener(callback));
        var eventListener = getEventListener(callback);
        removeListener(eventListener.listener);
        this.eventListeners.remove(eventListener);
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