package com.credito.servico_credito.Repository;

import com.credito.servico_credito.Entity.Endereco;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnderecoRepository extends JpaRepository<Endereco, Integer> {


    List<Endereco> findAll();


    Optional<Endereco> findById(Integer id);


    void deleteById(Integer id);


}
