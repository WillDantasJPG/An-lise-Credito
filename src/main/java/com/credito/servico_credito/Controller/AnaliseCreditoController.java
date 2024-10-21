package com.credito.servico_credito.Controller;

import com.credito.servico_credito.Entity.AnaliseCredito;
import com.credito.servico_credito.Service.AnaliseCreditoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/analises-credito")
public class AnaliseCreditoController {

    @Autowired
    private AnaliseCreditoService analiseCreditoService;

    /**
     * Endpoint para salvar uma nova análise de crédito.
     *
     * @param analiseCredito Objeto AnaliseCredito a ser salvo.
     * @return Resposta com a análise de crédito salva.
     */
    @PostMapping
    public ResponseEntity<AnaliseCredito> salvarAnaliseCredito(@RequestBody AnaliseCredito analiseCredito) {
        AnaliseCredito analiseSalva = analiseCreditoService.salvarAnaliseCredito(analiseCredito);
        return new ResponseEntity<>(analiseSalva, HttpStatus.CREATED);
    }

    /**
     * Endpoint para listar todas as análises de crédito.
     *
     * @return Lista de análises de crédito.
     */
    @GetMapping
    public ResponseEntity<List<AnaliseCredito>> listarAnalisesCredito() {
        List<AnaliseCredito> analises = analiseCreditoService.listarAnalisesCredito();
        return new ResponseEntity<>(analises, HttpStatus.OK);
    }

    /**
     * Endpoint para buscar uma análise de crédito por ID.
     *
     * @param id ID da análise de crédito a ser buscada.
     * @return Resposta com a análise encontrada ou NOT FOUND se não encontrada.
     */
    @GetMapping("/{id}")
    public ResponseEntity<AnaliseCredito> buscarAnalisePorId(@PathVariable Integer id) {
        Optional<AnaliseCredito> analise = analiseCreditoService.buscarAnalisePorId(id);
        return analise.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    /**
     * Endpoint para excluir uma análise de crédito por ID.
     *
     * @param id ID da análise de crédito a ser excluída.
     * @return Resposta de sucesso ou NOT FOUND se não encontrada.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluirAnaliseCredito(@PathVariable Integer id) {
        analiseCreditoService.excluirAnaliseCredito(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Endpoint para buscar análises de crédito por resultado.
     *
     * @param resultado Resultado a ser buscado.
     * @return Lista de análises de crédito que correspondem ao resultado.
     */
    @GetMapping("/resultado/{resultado}")
    public ResponseEntity<List<AnaliseCredito>> buscarPorResultado(@PathVariable String resultado) {
        List<AnaliseCredito> analises = analiseCreditoService.buscarPorResultado(resultado);
        return new ResponseEntity<>(analises, HttpStatus.OK);
    }

    /**
     * Endpoint para buscar análises de crédito por intervalo de datas.
     *
     * @param startDate Data de início do intervalo.
     * @param endDate   Data de fim do intervalo.
     * @return Lista de análises de crédito dentro do intervalo.
     */
    @GetMapping("/data")
    public ResponseEntity<List<AnaliseCredito>> buscarPorDataAnalise(
            @RequestParam("start") Date startDate,
            @RequestParam("end") Date endDate) {
        List<AnaliseCredito> analises = analiseCreditoService.buscarPorDataAnalise(startDate, endDate);
        return new ResponseEntity<>(analises, HttpStatus.OK);
    }

    /**
     * Endpoint para buscar análises de crédito por ID de crédito.
     *
     * @param creditoId ID do crédito associado.
     * @return Lista de análises de crédito que correspondem ao ID do crédito.
     */
    @GetMapping("/credito/{creditoId}")
    public ResponseEntity<List<AnaliseCredito>> buscarPorCreditoId(@PathVariable Integer creditoId) {
        List<AnaliseCredito> analises = analiseCreditoService.buscarPorCreditoId(creditoId);
        return new ResponseEntity<>(analises, HttpStatus.OK);
    }
}
