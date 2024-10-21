package com.credito.servico_credito.Controller;

import com.credito.servico_credito.Entity.Cliente;
import com.credito.servico_credito.Entity.Endereco;
import com.credito.servico_credito.Service.ClienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/clientes")
public class ClienteController {

    @Autowired
    private ClienteService clienteService;

    /**
     * Endpoint para salvar um novo cliente.
     *
     * @param cliente Objeto Cliente a ser salvo.
     * @return Resposta com o cliente salvo.
     */
    @PostMapping
    public ResponseEntity<Cliente> salvarCliente(@RequestBody Cliente cliente) {
        Cliente clienteSalvo = clienteService.salvarCliente(cliente);
        return ResponseEntity.ok(clienteSalvo);
    }

    /**
     * Endpoint para listar todos os clientes.
     *
     * @return Lista de clientes.
     */
    @GetMapping
    public ResponseEntity<List<Cliente>> listarClientes() {
        List<Cliente> clientes = clienteService.listarClientes();
        return ResponseEntity.ok(clientes);
    }

    /**
     * Endpoint para buscar um cliente por ID.
     *
     * @param id ID do cliente a ser buscado.
     * @return Resposta com o cliente encontrado ou NOT FOUND se não encontrado.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Cliente> buscarClientePorId(@PathVariable Integer id) {
        Cliente cliente = clienteService.buscarClientePorId(id);
        return ResponseEntity.ok(cliente);
    }

    /**
     * Endpoint para excluir um cliente por ID.
     *
     * @param id ID do cliente a ser excluído.
     * @return Resposta de sucesso ou NOT FOUND se não encontrado.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluirCliente(@PathVariable Integer id) {
        clienteService.excluirCliente(id);
        return ResponseEntity.noContent().build();
    }


}
