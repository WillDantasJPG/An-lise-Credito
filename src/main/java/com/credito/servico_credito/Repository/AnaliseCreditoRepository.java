package com.credito.servico_credito.Repository;

import com.credito.servico_credito.Entity.AnaliseCredito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface AnaliseCreditoRepository extends JpaRepository<AnaliseCredito, Integer> {
    List<AnaliseCredito> findByResultado(String resultado);

    List<AnaliseCredito> findByDataAnaliseBetween(Date startDate, Date endDate);

    List<AnaliseCredito> findByCredito_IdCredito(Integer creditoId);
}
