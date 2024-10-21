package com.credito.servico_credito.Utils;

import java.math.BigDecimal;
import java.util.UUID;

public class CreditoUtils {

    /**
     * Calcula a taxa de juros simples.
     *
     * @param principal O valor principal (capital).
     * @param taxa      A taxa de juros (em percentual).
     * @param tempo     O tempo em anos.
     * @return O valor dos juros calculados.
     */
    public static BigDecimal calcularJurosSimples(BigDecimal principal, BigDecimal taxa, int tempo) {
        BigDecimal juros = principal.multiply(taxa.divide(BigDecimal.valueOf(100))).multiply(BigDecimal.valueOf(tempo));
        return juros;
    }

    /**
     * Converte um valor monetário para formato padrão de moeda.
     *
     * @param valor O valor a ser formatado.
     * @return O valor formatado como String.
     */
    public static String formatarValorMonetario(BigDecimal valor) {
        return String.format("R$ %.2f", valor.setScale(2, BigDecimal.ROUND_HALF_EVEN));
    }

    /**
     * Gera um identificador único para um cliente.
     *
     * @return Um UUID como String.
     */
    public static String gerarIdentificadorUnico() {
        return UUID.randomUUID().toString();
    }

    /**
     * Verifica se um valor é positivo.
     *
     * @param valor O valor a ser verificado.
     * @return true se o valor for positivo, false caso contrário.
     */
    public static boolean isValorPositivo(BigDecimal valor) {
        return valor.compareTo(BigDecimal.ZERO) > 0;
    }

    /**
     * Converte uma taxa de juros percentual em taxa decimal.
     *
     * @param taxaPercentual A taxa de juros em percentual.
     * @return A taxa de juros em formato decimal.
     */
    public static BigDecimal converterTaxaParaDecimal(BigDecimal taxaPercentual) {
        return taxaPercentual.divide(BigDecimal.valueOf(100));
    }
}
