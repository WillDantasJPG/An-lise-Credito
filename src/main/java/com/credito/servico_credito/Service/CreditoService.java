package com.credito.servico_credito.Service;

import com.credito.servico_credito.Entity.AnaliseCredito;
import com.credito.servico_credito.Entity.Credito;
import com.credito.servico_credito.Exception.AnaliseCreditoException;
import com.credito.servico_credito.Exception.CreditoException;
import com.credito.servico_credito.Repository.AnaliseCreditoRepository;
import com.credito.servico_credito.Repository.CreditoRepository;
import com.credito.servico_credito.Utils.CreditoUtils; // Importando CreditoUtils
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class CreditoService {

    @Autowired
    private CreditoRepository creditoRepository;

    @Autowired
    private AnaliseCreditoRepository analiseCreditoRepository;

    @Value("${mercado_pago_access_token}")
    private String accessToken;

    private static final String MERCADO_PAGO_API_URL = "https://api.mercadopago.com/v1/credit_cards";

    private static final Logger logger = LoggerFactory.getLogger(CreditoService.class);

    public AnaliseCredito realizarAnaliseCredito(Credito credito) {
        validarCredito(credito);
        boolean creditoAprovado = analisarCreditoNoMercadoPago(credito);

        AnaliseCredito analiseCredito = new AnaliseCredito();
        analiseCredito.setCredito(credito);
        analiseCredito.setDataAnalise(new Date());

        if (creditoAprovado) {
            analiseCredito.setResultado("Aprovado");
            analiseCredito.setMotivo("Crédito aprovado com sucesso.");
        } else {
            analiseCredito.setResultado("Rejeitado");
            analiseCredito.setMotivo("Crédito não aprovado.");
        }

        relatarResultado(analiseCredito);

        return analiseCreditoRepository.save(analiseCredito);
    }

    private void validarCredito(Credito credito) {
        if (credito.getCliente().getCpf() == null || credito.getCliente().getCpf().isEmpty()) {
            throw new AnaliseCreditoException("O CPF é obrigatório.");
        }


        BigDecimal valorCredito = BigDecimal.valueOf(credito.getValor());


        if (valorCredito == null || valorCredito.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AnaliseCreditoException("O valor do crédito deve ser maior que zero.");
        }


        if (credito.getParcelas() == null || credito.getParcelas() <= 0) {
            throw new AnaliseCreditoException("O número de parcelas deve ser maior que zero.");
        }
    }


    private boolean analisarCreditoNoMercadoPago(Credito credito) {
        RestTemplate restTemplate = new RestTemplate();

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("cpf", credito.getCliente().getCpf());
        requestBody.put("valor", credito.getValor());
        requestBody.put("parcelas", credito.getParcelas());

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    MERCADO_PAGO_API_URL,
                    HttpMethod.POST,
                    entity,
                    new ParameterizedTypeReference<>() {}
            );
            Map<String, Object> responseBody = response.getBody();
            return responseBody != null && Boolean.TRUE.equals(responseBody.get("aprovado"));
        } catch (Exception e) {
            throw new CreditoException("Falha ao analisar crédito no Mercado Pago.", e);
        }
    }

    /**
     * Método para relatar o resultado da análise de crédito.
     *
     * @param analiseCredito A análise de crédito a ser relatada.
     */
    private void relatarResultado(AnaliseCredito analiseCredito) {
        // Obtendo o valor do crédito de forma correta
        BigDecimal valorCredito = BigDecimal.valueOf(analiseCredito.getCredito().getValor());


        String valorFormatado = CreditoUtils.formatarValorMonetario(valorCredito);
        logger.info("Resultado da Análise: {} - {}", analiseCredito.getResultado(), analiseCredito.getMotivo());
        logger.info("Valor do Crédito: {}", valorFormatado);


        BigDecimal taxaJuros = BigDecimal.valueOf(analiseCredito.getCredito().getTaxaJuros());
        BigDecimal jurosCalculados = CreditoUtils.calcularJurosSimples(
                valorCredito,
                taxaJuros,
                1 ///
        );
        logger.info("Juros Calculados: {}", CreditoUtils.formatarValorMonetario(jurosCalculados));
    }

}
