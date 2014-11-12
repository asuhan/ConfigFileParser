module antlr.runtime.JavaExceptions;

class RuntimeException: Exception {
    this() {
        super("RuntimeException");
    }
}

class IllegalArgumentException: Exception {
    this() {
        super("IllegalArgumentException");
    }
}

class IllegalStateException: Exception {
    this() {
        super("IllegalStateException");
    }
}

class NoSuchElementException: Exception {
    this() {
        super("NoSuchElementException");
    }
}

class NoSuchMethodError: Exception {
    this() {
        super("NoSuchMethodError");
    }
}

class UnsupportedOperationException: Exception {
    this() {
        super("UnsupportedOperationException");
    }
}
