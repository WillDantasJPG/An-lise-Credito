package com.credito.servico_credito.Controller;

import com.credito.servico_credito.Entity.AnaliseCredito;
import com.credito.servico_credito.Entity.Credito;
import com.credito.servico_credito.Exception.AnaliseCreditoException;
import com.credito.servico_credito.Service.CreditoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/credito")
public class CreditoController {

    @Autowired
    private CreditoService creditoService;

    /**
     * Endpoint para realizar a análise de crédito.
     *
     * @param credito Objeto Credito a ser analisado.
     * @return Resposta com a análise de crédito realizada.
     */
    @PostMapping("/analise")
    public ResponseEntity<AnaliseCredito> realizarAnaliseCredito(@RequestBody Credito credito) {
        AnaliseCredito analiseCredito = creditoService.realizarAnaliseCredito(credito);
        return ResponseEntity.ok(analiseCredito);
    }
}
