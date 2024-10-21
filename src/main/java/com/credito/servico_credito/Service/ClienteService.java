package com.credito.servico_credito.Service;

import com.credito.servico_credito.Entity.Cliente;
import com.credito.servico_credito.Entity.Endereco;
import com.credito.servico_credito.Exception.AnaliseCreditoException;
import com.credito.servico_credito.Exception.ClienteException;
import com.credito.servico_credito.Exception.EnderecoException;
import com.credito.servico_credito.Repository.ClienteRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class ClienteService {

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private ViaCepService viaCepService;  // Injeção do serviço ViaCepService

    private static final Logger logger = LoggerFactory.getLogger(ClienteService.class);

    public Cliente salvarCliente(Cliente cliente) {
        return clienteRepository.save(cliente);
    }

    public List<Cliente> listarClientes() {
        return clienteRepository.findAll();
    }

    public Cliente buscarClientePorId(Integer id) {
        return clienteRepository.findById(id).orElseThrow(() -> new ClienteException("Cliente não encontrado."));
    }

    public void excluirCliente(Integer id) {
        clienteRepository.deleteById(id);
    }

    public Cliente buscarClientePorCpf(String cpf) {
        return clienteRepository.findByCpf(cpf);
    }

    public List<Cliente> buscarClientesPorNome(String nome) {
        return clienteRepository.findByNome(nome);
    }

    public List<Cliente> buscarClientesPorNomeParcial(String nomeParcial) {
        return clienteRepository.findByNomeContaining(nomeParcial);
    }

    public Endereco buscarEnderecoPorCep(String cep) {
        try {
            return viaCepService.buscarEnderecoPorCep(cep);
        } catch (EnderecoException e) {
            logger.error("Erro ao buscar endereço: ", e);
            throw new ClienteException("Erro ao buscar endereço para o CEP: " + cep);
        }
    }
}
