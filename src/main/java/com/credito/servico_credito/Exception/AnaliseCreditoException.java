package com.credito.servico_credito.Exception;

public class AnaliseCreditoException extends RuntimeException {
    public AnaliseCreditoException (String message) {
        super(message);
    }

    public AnaliseCreditoException (String message, Throwable cause) {
        super(message, cause);
    }
}
