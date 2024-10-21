package com.credito.servico_credito.Exception;

public class EnderecoException extends RuntimeException {
    public EnderecoException(String message) {
        super(message);
    }

    public EnderecoException(String message, Throwable cause) {
        super(message, cause);
    }
}
