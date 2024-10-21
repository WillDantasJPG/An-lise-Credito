package com.credito.servico_credito.Exception;

public class CreditoException extends RuntimeException {
    public CreditoException(String message) {
        super(message);
    }

    public CreditoException(String message, Throwable cause) {
        super(message, cause);
    }
}

