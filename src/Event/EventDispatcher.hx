package event;

class EventDispatcher<T> extends EventManager<T> {
    public function new () {
        super();
    }

    public function dispatch (event: T): Void {
        for (listener in this.listeners) {
            listener(event);
        }
    }
}