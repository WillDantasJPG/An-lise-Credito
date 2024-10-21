package com.credito.servico_credito.Entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Entity
@Table(name = "analises_credito")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AnaliseCredito {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idAnalise;

    private String resultado;
    private String motivo;
    private Date dataAnalise;

    @OneToOne
    @JoinColumn(name = "credito_id", nullable = false)
    private Credito credito;
}
