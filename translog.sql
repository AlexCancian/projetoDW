---Eduardo Alex

-- Criação da tabela de dimensão: dim_cliente
CREATE TABLE dim_cliente (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(100),
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    estado VARCHAR(50),
    data_inicio DATE,
    data_fim DATE DEFAULT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    UNIQUE(cliente_id, data_inicio)
);

INSERT INTO dim_cliente (cliente_id, nome, endereco, cidade, estado, data_inicio) VALUES
(1, 'João', 'Rua A, 123', 'Cidade A', 'SP', '2021-01-01'),
(2, 'Maria', 'Rua B, 456', 'Cidade B', 'RJ', '2021-01-01'),
(3, 'José', 'Rua C, 789', 'Cidade C', 'MG', '2021-01-01');

-- Criação da tabela de dimensão: dim_centro
CREATE TABLE dim_centro (
    centro_sk SERIAL PRIMARY KEY,
    centro_id INT,
    nome VARCHAR(100),
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    estado VARCHAR(50),
    data_inicio DATE,
    data_fim DATE DEFAULT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    UNIQUE(centro_id, data_inicio)
);

INSERT INTO dim_centro (centro_id, nome, endereco, cidade, estado, data_inicio) VALUES
(1, 'Centro A', 'Rua A, 123', 'Cidade A', 'SP', '2021-01-01'),
(2, 'Centro B', 'Rua B, 456', 'Cidade B', 'RJ', '2021-01-01'),
(3, 'Centro C', 'Rua C, 789', 'Cidade C', 'MG', '2021-01-01');

-- Criação da tabela de dimensão: dim_tempo
CREATE TABLE dim_tempo (
    tempo_sk SERIAL PRIMARY KEY,
    data DATE,
    ano INT,
    mes INT,
    dia INT,
    dia_da_semana VARCHAR(25)
);

INSERT INTO dim_tempo (data, ano, mes, dia, dia_da_semana) VALUES
('2021-01-01', 2021, 1, 1, 'Sexta-feira'),
('2021-01-02', 2021, 1, 2, 'Sábado'),
('2021-01-03', 2021, 1, 3, 'Domingo');

-- Criação da tabela de fato: fato_entregas
CREATE TABLE fato_entregas (
    entrega_id SERIAL PRIMARY KEY,
    pedido_id INT,
    cliente_sk INT REFERENCES dim_cliente(cliente_sk),
    centro_saida_sk INT REFERENCES dim_centro(centro_sk),
    centro_destino_sk INT REFERENCES dim_centro(centro_sk),
    tempo_pedido_sk INT REFERENCES dim_tempo(tempo_sk),
    tempo_saida_sk INT REFERENCES dim_tempo(tempo_sk),
    tempo_chegada_sk INT REFERENCES dim_tempo(tempo_sk),
    quantidade INT,
    valor_total DECIMAL(10, 2),
    quilometragem DECIMAL(10, 2)
);

INSERT INTO fato_entregas (
    pedido_id, cliente_sk, centro_saida_sk, centro_destino_sk,
    tempo_pedido_sk, tempo_saida_sk, tempo_chegada_sk, quantidade, valor_total, quilometragem
) VALUES
(1, 1, 1, 2, 1, 1, 2, 10, 100.00, 50.0),
(2, 1, 1, 2, 1, 2, 3, 15, 150.00, 75.0);

-- Cálculo do Total de Produtos Transportados
SELECT SUM(quantidade) AS total_produtos FROM fato_entregas;

-- Cálculo do Tempo Total de Entrega
SELECT
    SUM(chegada.data - saida.data) AS tempo_total_entrega
FROM
    fato_entregas
JOIN dim_tempo AS saida ON fato_entregas.tempo_saida_sk = saida.tempo_sk
JOIN dim_tempo AS chegada ON fato_entregas.tempo_chegada_sk = chegada.tempo_sk
WHERE chegada.data >= saida.data;

-- Cálculo do Tempo Médio de Entrega por Pedido
SELECT
    AVG(chegada.data - saida.data) AS tempo_medio_entrega
FROM
    fato_entregas
JOIN dim_tempo AS saida ON fato_entregas.tempo_saida_sk = saida.tempo_sk
JOIN dim_tempo AS chegada ON fato_entregas.tempo_chegada_sk = chegada.tempo_sk
WHERE chegada.data >= saida.data;

-- Cálculo do Custo Médio por Quilômetro
SELECT AVG(valor_total / quilometragem) AS custo_medio_por_quilometro FROM fato_entregas;
