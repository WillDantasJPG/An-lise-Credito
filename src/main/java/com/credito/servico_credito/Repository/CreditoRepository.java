package com.credito.servico_credito.Repository;

import com.credito.servico_credito.Entity.Credito;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditoRepository extends JpaRepository<Credito, Integer> {


    List<Credito> findByCliente_Cpf(String cpf);


    List<Credito> findByValorGreaterThanEqual(Double valor);


    List<Credito> findByParcelas(Integer parcelas);
}
