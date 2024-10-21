-- Criação do banco de dados (se necessário)
CREATE DATABASE IF NOT EXISTS analiseDB;
USE analiseDB;

-- Criação da tabela "clientes"
CREATE TABLE IF NOT EXISTS clientes (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(11) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(15)
);

-- Criação da tabela "creditos"
CREATE TABLE IF NOT EXISTS creditos (
    idCredito INT AUTO_INCREMENT PRIMARY KEY,
    valor DOUBLE NOT NULL,
    parcelas INT NOT NULL,
    taxaJuros DOUBLE,
    dataLiberacao DATE,
    status VARCHAR(50),
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(idCliente)
);

-- Criação da tabela "analises_credito"
CREATE TABLE IF NOT EXISTS analises_credito (
    idAnalise INT AUTO_INCREMENT PRIMARY KEY,
    resultado VARCHAR(50),
    motivo VARCHAR(255),
    dataAnalise DATE,
    credito_id INT NOT NULL,
    FOREIGN KEY (credito_id) REFERENCES creditos(idCredito)
);

-- Criação da tabela "enderecos" (se necessário)
CREATE TABLE IF NOT EXISTS enderecos (
    idEndereco INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(255),
    bairro VARCHAR(255),
    localidade VARCHAR(255),
    uf VARCHAR(2),
    cep VARCHAR(10),
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(idCliente)
);

-- Inserções de dados nas tabelas

-- Inserindo clientes
INSERT INTO clientes (nome, cpf, email, telefone) VALUES
('João da Silva', '12345678901', 'joao.silva@example.com', '11987654321'),
('Maria Oliveira', '10987654321', 'maria.oliveira@example.com', '11876543210'),
('Pedro Santos', '98765432100', 'pedro.santos@example.com', '11765432109');

-- Inserindo créditos
INSERT INTO creditos (valor, parcelas, taxaJuros, dataLiberacao, status, cliente_id) VALUES
(15000.00, 12, 1.5, '2024-10-01', 'Liberado', 1),
(20000.00, 18, 2.0, '2024-10-10', 'Aguardando Análise', 2),
(30000.00, 24, 1.8, '2024-10-15', 'Reprovado', 3);

-- Inserindo análises de crédito
INSERT INTO analises_credito (resultado, motivo, dataAnalise, credito_id) VALUES
('Aprovado', 'Documentação Completa', '2024-10-02', 1),
('Aguardando Documentação', 'Faltam Documentos', '2024-10-11', 2),
('Reprovado', 'Nome em Negativação', '2024-10-16', 3);

-- Inserindo endereços (se necessário)
INSERT INTO enderecos (logradouro, bairro, localidade, uf, cep, cliente_id) VALUES
('Rua das Flores', 'Jardim das Rosas', 'São Paulo', 'SP', '01234567', 1),
('Avenida Paulista', 'Centro', 'São Paulo', 'SP', '98765432', 2),
('Praça da Liberdade', 'Liberdade', 'São Paulo', 'SP', '12345678', 3);
