package com.credito.servico_credito.Service;

import com.credito.servico_credito.Entity.Endereco;
import com.credito.servico_credito.Exception.AnaliseCreditoException; // Ajuste para sua exceção específica
import com.credito.servico_credito.Exception.EnderecoException;
import com.credito.servico_credito.Repository.EnderecoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EnderecoService {

    @Autowired
    private EnderecoRepository enderecoRepository;

    public Endereco salvarEndereco(Endereco endereco) {
        // Validação de exemplo
        if (endereco.getCep() == null || endereco.getCep().isEmpty()) {
            throw new EnderecoException("O CEP é obrigatório.");
        }
        return enderecoRepository.save(endereco);
    }

    public List<Endereco> listarEnderecos() {
        return enderecoRepository.findAll();
    }

    public Optional<Endereco> buscarEnderecoPorId(Integer id) {
        return enderecoRepository.findById(id);
    }

    public void excluirEndereco(Integer id) {
        enderecoRepository.deleteById(id);
    }
}
