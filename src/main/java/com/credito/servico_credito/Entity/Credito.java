package com.credito.servico_credito.Entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Entity
@Table(name = "creditos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Credito {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idCredito;

    private Double valor;
    private Integer parcelas;
    private Double taxaJuros;
    private Date dataLiberacao;
    private String status;

    @ManyToOne
    @JoinColumn(name = "cliente_id", nullable = false)
    private Cliente cliente;
}
