/*
===============================================================================
TRABALHO PRÁTICO 03 - GESTÃO DE BANCO DE DADOS (PostgreSQL)
Aluno: Lucas Eduardo Silva Amorim | RA: 007274
Tema: Loja de Camisas de Futebol - Operadores e Funções SQL
===============================================================================
*/

-- ============================================================================
-- 0. DADOS COMPLEMENTARES (PARA GARANTIR RETORNO EM TODAS AS CONSULTAS)
-- ============================================================================

-- Adicionando clientes extras (um sem telefone em MG para testar o IS NULL na questão 2)
INSERT INTO clientes (nome, email, cpf, telefone, cidade, estado) VALUES
('Lucas Silva', 'lucas.silva@email.com', '777.888.999-07', NULL, 'Belo Horizonte', 'MG'),
('Caroline Costa', 'caroline.costa@email.com', '888.999.000-08', '(35) 99123-4567', 'Passos', 'MG');

-- Adicionando uma camisa tamanho XG (2 caracteres) para testar o curinga '_' na questão 4B
INSERT INTO produtos (id_categoria, nome_camisa, time_selecao, tamanho, preco, quantidade_estoque) VALUES
(5, 'Camisa Comemorativa Centenário', 'Cruzeiro', 'XG', 389.90, 14);

-- Adicionando pedidos com data dinâmica recente para garantir retorno na questão 8
INSERT INTO pedidos (id_cliente, data_pedido, status_pedido, valor_total) VALUES
(7, CURRENT_TIMESTAMP - INTERVAL '2 days', 'Pago', 389.90),
(8, CURRENT_TIMESTAMP - INTERVAL '5 hours', 'Pendente', 349.90);

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(7, 9, 1, 389.90),
(8, 1, 1, 349.90);


-- ============================================================================
-- BLOCO A - OPERADORES LÓGICOS E DE COMPARAÇÃO
-- ============================================================================

-- QUESTÃO 1: Precedência lógica com parênteses (AND, OR)
-- Busca pedidos que já estão pagos ou entregues e que tenham valor de R$ 400 ou mais
-- para liberar um brinde VIP no envio.
SELECT 
    id_pedido AS codigo_pedido,
    id_cliente AS codigo_cliente,
    status_pedido AS situacao,
    valor_total AS valor_compra
FROM pedidos
WHERE (status_pedido = 'Pago' OR status_pedido = 'Entregue')
  AND valor_total >= 400.00
ORDER BY valor_total DESC;


-- QUESTÃO 2: Negação e verificação de nulos (NOT, IS NULL)
-- Lista os clientes que não moram em SP e estão com o telefone em branco no cadastro,
-- para o atendimento mandar e-mail pedindo para atualizar o contato.
SELECT 
    id_cliente AS codigo_cliente,
    nome AS nome_cliente,
    email AS email_contato,
    cidade,
    estado,
    telefone AS telefone_cadastrado
FROM clientes
WHERE NOT (estado = 'SP')
  AND telefone IS NULL;


-- QUESTÃO 3: Intervalos inclusivos e listas (BETWEEN, IN)
-- Filtra camisas na faixa de R$ 340,00 a R$ 430,00 que sejam das categorias
-- 1 (Clubes Nacionais), 3 (Seleções) ou 5 (Edições Especiais) para montar uma vitrine.
SELECT 
    id_produto AS codigo_camisa,
    nome_camisa AS modelo,
    time_selecao AS clube_ou_selecao,
    id_categoria AS categoria,
    preco AS preco_venda
FROM produtos
WHERE preco BETWEEN 340.00 AND 430.00
  AND id_categoria IN (1, 3, 5)
ORDER BY preco ASC;


-- ============================================================================
-- BLOCO B - BUSCAS TEXTUAIS COM PADRÕES
-- ============================================================================

-- QUESTÃO 4 (Parte A): Busca ignorando maiúsculas/minúsculas (ILIKE com %)
-- Simula a busca do cliente no site digitando "flamengo" em minúsculo para achar
-- todas as camisas do time (tanto atual quanto retrô).
SELECT 
    id_produto AS codigo_camisa,
    nome_camisa AS modelo,
    time_selecao AS clube,
    tamanho,
    preco
FROM produtos
WHERE time_selecao ILIKE '%flamengo%';


-- QUESTÃO 4 (Parte B): Busca com curinga de tamanho fixo (LIKE com _)
-- Puxa só as camisas com tamanho de 2 letras (ex: GG, XG) para separar no estoque.
SELECT 
    id_produto AS codigo_camisa,
    nome_camisa AS modelo,
    time_selecao AS clube,
    tamanho AS tamanho_especial,
    quantidade_estoque AS saldo_estoque
FROM produtos
WHERE tamanho LIKE '__';


-- ============================================================================
-- BLOCO C - FUNÇÕES MATEMÁTICAS E DE TEXTO
-- ============================================================================

-- QUESTÃO 5: Simulação de reajuste e arredondamentos (ROUND, TRUNC, CEIL)
-- Simula um aumento de 7,35% no preço das camisas e compara o valor original com
-- o arredondamento normal (ROUND), o corte seco nas casas decimais (TRUNC) e o teto (CEIL).
SELECT 
    nome_camisa AS modelo,
    time_selecao AS clube,
    preco AS preco_atual,
    ROUND(preco * 1.0735, 2) AS preco_arredondado_round,
    TRUNC(preco * 1.0735, 2) AS preco_cortado_trunc,
    CEIL(preco * 1.0735) AS preco_teto_inteiro
FROM produtos
ORDER BY preco DESC;


-- QUESTÃO 6 (Parte A): Classificação por resto da divisão (MOD)
-- Divide os produtos em dois lotes usando o ID (par ou ímpar) para organizar a
-- conferência física do estoque entre duas equipes.
SELECT 
    id_produto AS codigo_camisa,
    nome_camisa AS modelo,
    quantidade_estoque AS qtd_estoque,
    MOD(id_produto, 2) AS resto_divisao,
    CASE 
        WHEN MOD(id_produto, 2) = 0 THEN 'Equipe A - Lote Par'
        ELSE 'Equipe B - Lote Ímpar'
    END AS equipe_conferencia
FROM produtos
ORDER BY id_produto;


-- QUESTÃO 6 (Parte B): Sorteio aleatório (RANDOM)
-- Sorteia 1 camisa que tenha saldo em estoque para colocar como destaque do dia na loja.
SELECT 
    id_produto AS codigo_sorteado,
    nome_camisa AS manto_destaque_do_dia,
    time_selecao AS clube,
    tamanho,
    preco AS preco_oferta
FROM produtos
WHERE quantidade_estoque > 0
ORDER BY RANDOM()
LIMIT 1;


-- QUESTÃO 7: Manipulação de texto (CONCAT, UPPER, SPLIT_PART)
-- Monta os dados para etiqueta de envio: pega só o primeiro nome do cliente, deixa
-- cidade/estado em maiúsculo e junta o nome com o telefone tratando caso seja NULL.
SELECT 
    id_cliente AS codigo,
    SPLIT_PART(nome, ' ', 1) AS primeiro_nome_etiqueta,
    UPPER(cidade) || ' - ' || UPPER(estado) AS destino_padronizado,
    CONCAT(nome, ' | Tel: ', COALESCE(telefone, 'Não informado')) AS destinatario_contato
FROM clientes
ORDER BY id_cliente;


-- ============================================================================
-- BLOCO D - FUNÇÕES DE DATA/HORA E FORMATAÇÃO
-- ============================================================================

-- QUESTÃO 8: Extração de datas e filtro de período (EXTRACT, DATE_TRUNC, INTERVAL)
-- Mostra os pedidos feitos nos últimos 15 dias separando o dia zerado, ano, mês e hora.
SELECT 
    id_pedido AS numero_pedido,
    status_pedido AS status,
    data_pedido AS data_hora_original,
    DATE_TRUNC('day', data_pedido) AS dia_truncado,
    EXTRACT(YEAR FROM data_pedido) AS ano_pedido,
    EXTRACT(MONTH FROM data_pedido) AS mes_pedido,
    EXTRACT(HOUR FROM data_pedido) AS hora_compra
FROM pedidos
WHERE data_pedido >= NOW() - INTERVAL '15 days'
ORDER BY data_pedido DESC;


-- QUESTÃO 9: Tempo decorrido e projeção futura (AGE, NOW, + INTERVAL)
-- Calcula há quanto tempo cada pedido foi feito e soma 30 dias na data da compra
-- para saber até quando o cliente pode pedir troca da camisa.
SELECT 
    id_pedido AS numero_pedido,
    status_pedido AS situacao,
    data_pedido AS data_compra,
    AGE(NOW(), data_pedido) AS tempo_decorrido_desde_compra,
    data_pedido + INTERVAL '30 days' AS prazo_limite_garantia
FROM pedidos
ORDER BY data_pedido DESC;


-- QUESTÃO 10: Relatório gerencial formatado (INNER JOIN, TO_CHAR, LPAD, FORMAT)
-- Junta as 5 tabelas do banco (pedidos, clientes, itens_pedido, produtos e categorias)
-- para gerar um resumo completo com código preenchido com zeros à esquerda, data no
-- formato BR e valor em reais formatado.
SELECT 
    LPAD(p.id_pedido::TEXT, 5, '0') AS codigo_pedido_padronizado,
    c.nome AS nome_cliente,
    cat.nome_categoria AS categoria_camisa,
    TO_CHAR(p.data_pedido, 'DD/MM/YYYY') AS data_brasileira,
    TO_CHAR(p.valor_total, 'FML999G990D00') AS valor_formatado_brl,
    FORMAT(
        'Pedido #%s (%s) - Cliente: %s | Item: %sx %s (%s - %s)',
        LPAD(p.id_pedido::TEXT, 4, '0'),
        p.status_pedido,
        c.nome,
        ip.quantidade,
        prod.nome_camisa,
        prod.time_selecao,
        cat.nome_categoria
    ) AS resumo_gerencial_completo
FROM pedidos p
INNER JOIN clientes c ON p.id_cliente = c.id_cliente
INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
INNER JOIN produtos prod ON ip.id_produto = prod.id_produto
INNER JOIN categorias cat ON prod.id_categoria = cat.id_categoria
ORDER BY p.id_pedido ASC, prod.nome_camisa ASC;