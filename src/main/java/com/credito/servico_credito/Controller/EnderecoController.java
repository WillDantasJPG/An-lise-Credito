package com.credito.servico_credito.Controller;

import com.credito.servico_credito.Entity.Endereco;
import com.credito.servico_credito.Service.EnderecoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/enderecos")
public class EnderecoController {

    @Autowired
    private EnderecoService enderecoService;

    /**
     * Endpoint para salvar um novo endereço.
     *
     * @param endereco Objeto Endereco a ser salvo.
     * @return Resposta com o endereço salvo.
     */
    @PostMapping
    public ResponseEntity<Endereco> salvarEndereco(@RequestBody Endereco endereco) {
        Endereco enderecoSalvo = enderecoService.salvarEndereco(endereco);
        return new ResponseEntity<>(enderecoSalvo, HttpStatus.CREATED);
    }

    /**
     * Endpoint para listar todos os endereços.
     *
     * @return Lista de endereços.
     */
    @GetMapping
    public ResponseEntity<List<Endereco>> listarEnderecos() {
        List<Endereco> enderecos = enderecoService.listarEnderecos();
        return new ResponseEntity<>(enderecos, HttpStatus.OK);
    }

    /**
     * Endpoint para buscar um endereço por ID.
     *
     * @param id ID do endereço a ser buscado.
     * @return Resposta com o endereço encontrado ou NOT FOUND se não encontrado.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Endereco> buscarEnderecoPorId(@PathVariable Integer id) {
        Optional<Endereco> endereco = enderecoService.buscarEnderecoPorId(id);
        return endereco.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    /**
     * Endpoint para excluir um endereço por ID.
     *
     * @param id ID do endereço a ser excluído.
     * @return Resposta de sucesso ou NOT FOUND se não encontrado.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluirEndereco(@PathVariable Integer id) {
        enderecoService.excluirEndereco(id);
        return ResponseEntity.noContent().build();
    }
}
