package com.credito.servico_credito.Repository;

import com.credito.servico_credito.Entity.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Integer> {


    List<Cliente> findByNome(String nome);


    Cliente findByCpf(String cpf);


    List<Cliente> findByNomeContaining(String nomeParcial);
}
