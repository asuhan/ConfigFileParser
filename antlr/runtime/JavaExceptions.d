module antlr.runtime.JavaExceptions;

class RuntimeException: Exception {
    this(string message) {
        super(message);
    }
}

class IllegalArgumentException: Exception {
    this(string message) {
        super(message);
    }
}

class IllegalStateException: Exception {
    this(string message) {
        super(message);
    }
}

class NoSuchElementException: Exception {
    this(string message) {
        super(message);
    }
}

class NoSuchMethodError: Exception {
    this(string message) {
        super(message);
    }
}

class UnsupportedOperationException: Exception {
    this(string message) {
        super(message);
    }
}
