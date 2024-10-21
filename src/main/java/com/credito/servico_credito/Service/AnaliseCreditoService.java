package com.credito.servico_credito.Service;

import com.credito.servico_credito.Entity.AnaliseCredito;
import com.credito.servico_credito.Exception.AnaliseCreditoException;
import com.credito.servico_credito.Repository.AnaliseCreditoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class AnaliseCreditoService {

    @Autowired
    private AnaliseCreditoRepository analiseCreditoRepository;

    public AnaliseCredito salvarAnaliseCredito(AnaliseCredito analiseCredito) {
        if (analiseCredito.getCredito() == null || analiseCredito.getCredito().getIdCredito() == null) {
            throw new AnaliseCreditoException("O crédito associado é obrigatório.");
        }
        return analiseCreditoRepository.save(analiseCredito);
    }

    public List<AnaliseCredito> listarAnalisesCredito() {
        return analiseCreditoRepository.findAll();
    }

    public Optional<AnaliseCredito> buscarAnalisePorId(Integer id) {
        return analiseCreditoRepository.findById(id);
    }

    public void excluirAnaliseCredito(Integer id) {
        analiseCreditoRepository.deleteById(id);
    }

    public List<AnaliseCredito> buscarPorResultado(String resultado) {
        return analiseCreditoRepository.findByResultado(resultado);
    }

    public List<AnaliseCredito> buscarPorDataAnalise(Date startDate, Date endDate) {
        return analiseCreditoRepository.findByDataAnaliseBetween(startDate, endDate);
    }

    public List<AnaliseCredito> buscarPorCreditoId(Integer creditoId) {
        return analiseCreditoRepository.findByCredito_IdCredito(creditoId);
    }
}
