package com.credito.servico_credito.Service;

import com.credito.servico_credito.Entity.Endereco;
import com.credito.servico_credito.Exception.EnderecoException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class ViaCepService {


    private final String BASE_URL = "https://viacep.com.br/ws/";

    public Endereco buscarEnderecoPorCep(String cep) {
        RestTemplate restTemplate = new RestTemplate();
        String url = BASE_URL + cep + "/json/";
        Endereco endereco = restTemplate.getForObject(url, Endereco.class);

        if (endereco == null || "erro".equals(endereco.getLogradouro())) {
            throw new EnderecoException("Endereço não encontrado para o CEP: " + cep);
        }

        return endereco;
    }
}
