/*****************************************************************
	 Script de criação do banco de dados GEHAB Bank
	 Autor: Matheus Nunes Rossi
	 Data: 23/04/2025
******************************************************************/

USE GEHAB_Bank;
GO

-- Inserção de dados na tabela Agencia (sem Gerente_ID inicialmente)
INSERT INTO Agencia (Nome_Agencia, Numero_Agencia, Endereco, Cidade, Estado, CEP, Telefone, Gerente_ID, Data_Inauguracao, Status)
VALUES 
('GEHAB Central', '0001', 'Av. Paulista, 1000', 'São Paulo', 'SP', '01310-100', '(11) 3333-1000', NULL, '2010-01-15', 'Ativa'),
('GEHAB Zona Sul', '0002', 'Av. Brigadeiro Faria Lima, 500', 'São Paulo', 'SP', '04538-132', '(11) 3333-2000', NULL, '2012-03-20', 'Ativa'),
('GEHAB Rio', '0003', 'Av. Rio Branco, 100', 'Rio de Janeiro', 'RJ', '20040-007', '(21) 3333-3000', NULL, '2013-05-10', 'Ativa'),
('GEHAB Belo Horizonte', '0004', 'Av. Afonso Pena, 1500', 'Belo Horizonte', 'MG', '30130-921', '(31) 3333-4000', NULL, '2015-07-05', 'Ativa'),
('GEHAB Brasília', '0005', 'SBS Quadra 2, Bloco A', 'Brasília', 'DF', '70070-120', '(61) 3333-5000', NULL, '2017-09-12', 'Ativa');
GO

-- Inserção de dados na tabela Cliente
INSERT INTO Cliente (CPF, Nome, Data_Nascimento, Endereco, Cidade, Estado, CEP, Telefone, Email, Data_Cadastro, Status)
VALUES 
('123.456.789-00', 'João Silva', '1980-05-15', 'Rua das Flores, 100', 'São Paulo', 'SP', '01310-200', '(11) 99999-1111', 'joao.silva@email.com', '2018-01-10', 'Ativo'),
('234.567.890-11', 'Maria Oliveira', '1985-08-22', 'Av. Brasil, 200', 'Rio de Janeiro', 'RJ', '20040-100', '(21) 99999-2222', 'maria.oliveira@email.com', '2018-02-15', 'Ativo'),
('345.678.901-22', 'Pedro Santos', '1975-03-10', 'Rua XV de Novembro, 300', 'Curitiba', 'PR', '80020-310', '(41) 99999-3333', 'pedro.santos@email.com', '2018-03-20', 'Ativo'),
('456.789.012-33', 'Ana Souza', '1990-11-05', 'Av. Paulista, 400', 'São Paulo', 'SP', '01310-300', '(11) 99999-4444', 'ana.souza@email.com', '2018-04-25', 'Ativo'),
('567.890.123-44', 'Carlos Ferreira', '1982-07-18', 'Rua Sergipe, 500', 'Belo Horizonte', 'MG', '30130-170', '(31) 99999-5555', 'carlos.ferreira@email.com', '2018-05-30', 'Ativo'),
('678.901.234-55', 'Juliana Lima', '1988-09-25', 'Av. Boa Viagem, 600', 'Recife', 'PE', '51011-000', '(81) 99999-6666', 'juliana.lima@email.com', '2019-01-05', 'Ativo'),
('789.012.345-66', 'Roberto Almeida', '1970-12-30', 'Av. Atlântica, 700', 'Rio de Janeiro', 'RJ', '22010-000', '(21) 99999-7777', 'roberto.almeida@email.com', '2019-02-10', 'Ativo'),
('890.123.456-77', 'Fernanda Costa', '1992-04-08', 'Rua Augusta, 800', 'São Paulo', 'SP', '01305-100', '(11) 99999-8888', 'fernanda.costa@email.com', '2019-03-15', 'Ativo'),
('901.234.567-88', 'Marcelo Dias', '1978-06-20', 'Av. Sete de Setembro, 900', 'Porto Alegre', 'RS', '90010-190', '(51) 99999-9999', 'marcelo.dias@email.com', '2019-04-20', 'Ativo'),
('012.345.678-99', 'Luciana Martins', '1986-02-12', 'Rua Oscar Freire, 1000', 'São Paulo', 'SP', '01426-001', '(11) 99999-0000', 'luciana.martins@email.com', '2019-05-25', 'Ativo');
GO

-- Inserção de dados na tabela Funcionario
INSERT INTO Funcionario (CPF, Nome, Data_Nascimento, Endereco, Cidade, Estado, CEP, Telefone, Email, Data_Contratacao, Cargo, Salario, ID_Agencia, Status)
VALUES 
('111.222.333-44', 'Ricardo Gomes', '1975-01-20', 'Rua Haddock Lobo, 100', 'São Paulo', 'SP', '01414-000', '(11) 98888-1111', 'ricardo.gomes@gehab.com.br', '2010-01-15', 'Gerente Geral', 15000.00, 1, 'Ativo'),
('222.333.444-55', 'Patrícia Mendes', '1980-03-15', 'Av. Rebouças, 200', 'São Paulo', 'SP', '05401-000', '(11) 98888-2222', 'patricia.mendes@gehab.com.br', '2012-03-20', 'Gerente', 12000.00, 2, 'Ativo'),
('333.444.555-66', 'Fernando Castro', '1982-05-10', 'Rua Voluntários da Pátria, 300', 'Rio de Janeiro', 'RJ', '22270-000', '(21) 98888-3333', 'fernando.castro@gehab.com.br', '2013-05-10', 'Gerente', 12000.00, 3, 'Ativo'),
('444.555.666-77', 'Camila Rocha', '1985-07-05', 'Rua dos Timbiras, 400', 'Belo Horizonte', 'MG', '30140-060', '(31) 98888-4444', 'camila.rocha@gehab.com.br', '2015-07-05', 'Gerente', 12000.00, 4, 'Ativo'),
('555.666.777-88', 'Bruno Alves', '1987-09-12', 'SQS 308, Bloco A, Apt 101', 'Brasília', 'DF', '70355-010', '(61) 98888-5555', 'bruno.alves@gehab.com.br', '2017-09-12', 'Gerente', 12000.00, 5, 'Ativo'),
('666.777.888-99', 'Daniela Vieira', '1990-02-25', 'Rua Augusta, 500', 'São Paulo', 'SP', '01305-000', '(11) 98888-6666', 'daniela.vieira@gehab.com.br', '2015-03-10', 'Analista de Crédito', 6000.00, 1, 'Ativo'),
('777.888.999-00', 'Rafael Nunes', '1988-04-18', 'Av. Paulista, 600', 'São Paulo', 'SP', '01310-100', '(11) 98888-7777', 'rafael.nunes@gehab.com.br', '2016-05-15', 'Caixa', 4500.00, 1, 'Ativo'),
('888.999.000-11', 'Juliana Freitas', '1992-06-30', 'Rua Barata Ribeiro, 700', 'Rio de Janeiro', 'RJ', '22040-001', '(21) 98888-8888', 'juliana.freitas@gehab.com.br', '2017-07-20', 'Caixa', 4500.00, 3, 'Ativo'),
('999.000.111-22', 'Marcos Pereira', '1986-08-15', 'Av. Afonso Pena, 800', 'Belo Horizonte', 'MG', '30130-003', '(31) 98888-9999', 'marcos.pereira@gehab.com.br', '2018-09-25', 'Caixa', 4500.00, 4, 'Ativo'),
('000.111.222-33', 'Carla Moreira', '1991-10-22', 'SQN 212, Bloco C, Apt 303', 'Brasília', 'DF', '70864-030', '(61) 98888-0000', 'carla.moreira@gehab.com.br', '2019-11-30', 'Caixa', 4500.00, 5, 'Ativo');
GO

-- Atualização dos gerentes nas agências
UPDATE Agencia SET Gerente_ID = 1 WHERE ID_Agencia = 1;
UPDATE Agencia SET Gerente_ID = 2 WHERE ID_Agencia = 2;
UPDATE Agencia SET Gerente_ID = 3 WHERE ID_Agencia = 3;
UPDATE Agencia SET Gerente_ID = 4 WHERE ID_Agencia = 4;
UPDATE Agencia SET Gerente_ID = 5 WHERE ID_Agencia = 5;
GO

-- Inserção de dados na tabela Conta
INSERT INTO Conta (Numero_Conta, Tipo_Conta, Data_Abertura, Saldo, Limite_Credito, ID_Cliente, ID_Agencia, Status)
VALUES 
('0001-01', 'Corrente', '2018-01-15', 5000.00, 2000.00, 1, 1, 'Ativa'),
('0001-02', 'Poupança', '2018-01-20', 10000.00, 0.00, 1, 1, 'Ativa'),
('0002-01', 'Corrente', '2018-02-20', 7500.00, 3000.00, 2, 3, 'Ativa'),
('0003-01', 'Corrente', '2018-03-25', 3000.00, 1500.00, 3, 2, 'Ativa'),
('0003-02', 'Poupança', '2018-03-30', 15000.00, 0.00, 3, 2, 'Ativa'),
('0004-01', 'Corrente', '2018-04-30', 8000.00, 4000.00, 4, 1, 'Ativa'),
('0005-01', 'Corrente', '2018-06-05', 6000.00, 2500.00, 5, 4, 'Ativa'),
('0006-01', 'Corrente', '2019-01-10', 4500.00, 2000.00, 6, 5, 'Ativa'),
('0007-01', 'Corrente', '2019-02-15', 9000.00, 5000.00, 7, 3, 'Ativa'),
('0008-01', 'Corrente', '2019-03-20', 7200.00, 3500.00, 8, 1, 'Ativa'),
('0009-01', 'Corrente', '2019-04-25', 5800.00, 2800.00, 9, 5, 'Ativa'),
('0010-01', 'Corrente', '2019-05-30', 6500.00, 3200.00, 10, 2, 'Ativa'),
('0010-02', 'Poupança', '2019-06-05', 12000.00, 0.00, 10, 2, 'Ativa');
GO

-- Inserção de dados na tabela Transacao
INSERT INTO Transacao (Data_Hora, Tipo_Transacao, Valor, ID_Conta_Origem, ID_Conta_Destino, Descricao, Canal, Status)
VALUES 
('2023-01-05 10:15:00', 'Depósito', 2000.00, 1, NULL, 'Depósito em dinheiro', 'Agência', 'Concluída'),
('2023-01-10 14:30:00', 'Transferência', 1000.00, 1, 3, 'Transferência para João', 'Internet Banking', 'Concluída'),
('2023-01-15 09:45:00', 'Saque', 500.00, 3, NULL, 'Saque em caixa eletrônico', 'Caixa Eletrônico', 'Concluída'),
('2023-01-20 16:20:00', 'Transferência', 1500.00, 4, 6, 'Pagamento de serviço', 'App', 'Concluída'),
('2023-01-25 11:10:00', 'Depósito', 3000.00, 7, NULL, 'Depósito de cheque', 'Agência', 'Concluída'),
('2023-02-05 13:25:00', 'Transferência', 2000.00, 8, 10, 'Transferência para familiar', 'Internet Banking', 'Concluída'),
('2023-02-10 15:40:00', 'Saque', 1000.00, 9, NULL, 'Saque em caixa eletrônico', 'Caixa Eletrônico', 'Concluída'),
('2023-02-15 10:30:00', 'Pagamento', 800.00, 11, NULL, 'Pagamento de conta de luz', 'App', 'Concluída'),
('2023-02-20 14:15:00', 'Transferência', 2500.00, 12, 2, 'Transferência entre contas', 'Internet Banking', 'Concluída'),
('2023-02-25 09:20:00', 'Depósito', 1500.00, 5, NULL, 'Depósito em dinheiro', 'Agência', 'Concluída');
GO

-- Inserção de dados na tabela Cartao
INSERT INTO Cartao (Numero_Cartao, Tipo_Cartao, Data_Emissao, Data_Validade, Limite_Credito, ID_Conta, Status)
VALUES 
('5555-6666-7777-8888', 'Crédito', '2018-01-20', '2023-01-31', 5000.00, 1, 'Ativo'),
('6666-7777-8888-9999', 'Débito', '2018-01-20', '2023-01-31', 0.00, 1, 'Ativo'),
('7777-8888-9999-0000', 'Crédito', '2018-02-25', '2023-02-28', 8000.00, 3, 'Ativo'),
('8888-9999-0000-1111', 'Múltiplo', '2018-03-30', '2023-03-31', 6000.00, 4, 'Ativo'),
('9999-0000-1111-2222', 'Crédito', '2018-05-05', '2023-05-31', 10000.00, 6, 'Ativo'),
('0000-1111-2222-3333', 'Débito', '2018-06-10', '2023-06-30', 0.00, 7, 'Ativo'),
('1111-2222-3333-4444', 'Múltiplo', '2019-01-15', '2024-01-31', 7000.00, 8, 'Ativo'),
('2222-3333-4444-5555', 'Crédito', '2019-02-20', '2024-02-29', 9000.00, 10, 'Ativo'),
('3333-4444-5555-6666', 'Débito', '2019-03-25', '2024-03-31', 0.00, 11, 'Ativo'),
('4444-5555-6666-7777', 'Múltiplo', '2019-04-30', '2024-04-30', 12000.00, 12, 'Ativo');
GO

-- Inserção de dados na tabela Fatura_Cartao
INSERT INTO Fatura_Cartao (ID_Cartao, Data_Fechamento, Data_Vencimento, Valor_Total, Valor_Minimo, Status)
VALUES 
(1, '2023-01-31', '2023-02-10', 1200.00, 240.00, 'Paga'),
(3, '2023-01-31', '2023-02-10', 1800.00, 360.00, 'Paga'),
(4, '2023-01-31', '2023-02-10', 950.00, 190.00, 'Paga'),
(5, '2023-01-31', '2023-02-10', 2500.00, 500.00, 'Paga'),
(7, '2023-01-31', '2023-02-10', 1600.00, 320.00, 'Paga'),
(8, '2023-01-31', '2023-02-10', 2200.00, 440.00, 'Paga'),
(10, '2023-01-31', '2023-02-10', 3100.00, 620.00, 'Paga'),
(1, '2023-02-28', '2023-03-10', 1500.00, 300.00, 'Aberta'),
(3, '2023-02-28', '2023-03-10', 2100.00, 420.00, 'Aberta'),
(5, '2023-02-28', '2023-03-10', 2800.00, 560.00, 'Aberta');
GO

-- Inserção de dados na tabela Compra_Cartao
INSERT INTO Compra_Cartao (ID_Cartao, Data_Compra, Valor, Estabelecimento, Categoria, Numero_Parcelas, ID_Fatura, Status)
VALUES 
(1, '2023-01-05 12:30:00', 500.00, 'Shopping Center Norte', 'Vestuário', 1, 1, 'Aprovada'),
(1, '2023-01-10 19:45:00', 700.00, 'Supermercado Extra', 'Alimentação', 1, 1, 'Aprovada'),
(3, '2023-01-08 14:20:00', 1800.00, 'Magazine Luiza', 'Eletrônicos', 3, 3, 'Aprovada'),
(4, '2023-01-12 10:15:00', 950.00, 'Posto Ipiranga', 'Combustível', 1, 4, 'Aprovada'),
(5, '2023-01-15 16:30:00', 2500.00, 'Casas Bahia', 'Móveis', 5, 5, 'Aprovada'),
(7, '2023-01-18 11:45:00', 1600.00, 'Americanas', 'Eletrodomésticos', 2, 7, 'Aprovada'),
(8, '2023-01-20 13:10:00', 2200.00, 'Decathlon', 'Esportes', 3, 8, 'Aprovada'),
(10, '2023-01-25 15:25:00', 3100.00, 'Fast Shop', 'Eletrônicos', 6, 10, 'Aprovada'),
(1, '2023-02-05 09:40:00', 600.00, 'Drogaria São Paulo', 'Saúde', 1, 8, 'Aprovada'),
(3, '2023-02-10 17:55:00', 1500.00, 'Ponto Frio', 'Eletrodomésticos', 3, 9, 'Aprovada');
GO

-- Inserção de dados na tabela Emprestimo
INSERT INTO Emprestimo (ID_Cliente, ID_Conta, Data_Solicitacao, Valor_Solicitado, Taxa_Juros, Prazo_Meses, Valor_Parcela, Data_Aprovacao, Status)
VALUES 
(1, 1, '2023-01-10', 10000.00, 1.5, 12, 916.67, '2023-01-12', 'Aprovado'),
(3, 4, '2023-01-15', 15000.00, 1.8, 24, 750.00, '2023-01-18', 'Aprovado'),
(5, 7, '2023-01-20', 20000.00, 1.6, 36, 694.44, '2023-01-23', 'Aprovado'),
(7, 9, '2023-01-25', 30000.00, 1.7, 48, 743.75, '2023-01-28', 'Aprovado'),
(9, 11, '2023-02-05', 5000.00, 1.4, 6, 866.67, '2023-02-08', 'Aprovado'),
(2, 3, '2023-02-10', 12000.00, 1.5, 12, 1100.00, '2023-02-13', 'Aprovado'),
(4, 6, '2023-02-15', 25000.00, 1.6, 24, 1250.00, '2023-02-18', 'Aprovado'),
(6, 8, '2023-02-20', 8000.00, 1.4, 12, 733.33, '2023-02-23', 'Aprovado'),
(8, 10, '2023-02-25', 18000.00, 1.5, 24, 900.00, NULL, 'Solicitado'),
(10, 12, '2023-03-01', 40000.00, 1.8, 48, 991.67, NULL, 'Solicitado');
GO

-- Inserção de dados na tabela Parcela_Emprestimo
INSERT INTO Parcela_Emprestimo (ID_Emprestimo, Numero_Parcela, Data_Vencimento, Valor_Parcela, Data_Pagamento, Valor_Pago, Status)
VALUES 
(1, 1, '2023-02-12', 916.67, '2023-02-10', 916.67, 'Paga'),
(1, 2, '2023-03-12', 916.67, NULL, NULL, 'Pendente'),
(2, 1, '2023-02-18', 750.00, '2023-02-15', 750.00, 'Paga'),
(2, 2, '2023-03-18', 750.00, NULL, NULL, 'Pendente'),
(3, 1, '2023-02-23', 694.44, '2023-02-20', 694.44, 'Paga'),
(3, 2, '2023-03-23', 694.44, NULL, NULL, 'Pendente'),
(4, 1, '2023-02-28', 743.75, '2023-02-25', 743.75, 'Paga'),
(4, 2, '2023-03-28', 743.75, NULL, NULL, 'Pendente'),
(5, 1, '2023-03-08', 866.67, '2023-03-05', 866.67, 'Paga'),
(5, 2, '2023-04-08', 866.67, NULL, NULL, 'Pendente');
GO

-- Inserção de dados na tabela Investimento
INSERT INTO Investimento (ID_Cliente, ID_Conta, Tipo_Investimento, Data_Aplicacao, Valor_Aplicado, Taxa_Rendimento, Data_Vencimento, Status)
VALUES 
(1, 2, 'Poupança', '2023-01-15', 5000.00, 0.5, NULL, 'Ativo'),
(3, 5, 'CDB', '2023-01-20', 10000.00, 1.0, '2024-01-20', 'Ativo'),
(5, 7, 'LCI', '2023-01-25', 15000.00, 0.9, '2024-07-25', 'Ativo'),
(7, 9, 'Tesouro Direto', '2023-02-01', 20000.00, 1.1, '2026-02-01', 'Ativo'),
(9, 11, 'Poupança', '2023-02-05', 3000.00, 0.5, NULL, 'Ativo'),
(2, 3, 'CDB', '2023-02-10', 8000.00, 1.0, '2024-02-10', 'Ativo'),
(4, 6, 'LCA', '2023-02-15', 12000.00, 0.95, '2024-08-15', 'Ativo'),
(6, 8, 'Tesouro Direto', '2023-02-20', 25000.00, 1.15, '2028-02-20', 'Ativo'),
(8, 10, 'CDB', '2023-02-25', 7000.00, 1.05, '2024-02-25', 'Ativo'),
(10, 13, 'LCI', '2023-03-01', 18000.00, 0.92, '2024-09-01', 'Ativo');
GO

-- Inserção de dados na tabela Atendimento
INSERT INTO Atendimento (ID_Cliente, ID_Funcionario, Data_Hora, Canal, Assunto, Descricao, Status)
VALUES 
(1, 6, '2023-01-10 10:30:00', 'Presencial', 'Abertura de conta', 'Cliente solicitou abertura de conta corrente e poupança', 'Concluído'),
(2, 8, '2023-01-15 14:45:00', 'Telefone', 'Cartão bloqueado', 'Cliente relatou que seu cartão foi bloqueado após tentativa de compra', 'Concluído'),
(3, 9, '2023-01-20 11:15:00', 'Presencial', 'Empréstimo', 'Cliente solicitou informações sobre empréstimo pessoal', 'Concluído'),
(4, 7, '2023-01-25 16:30:00', 'Chat', 'Limite de crédito', 'Cliente solicitou aumento do limite de crédito', 'Concluído'),
(5, 10, '2023-02-01 09:45:00', 'Email', 'Investimentos', 'Cliente solicitou informações sobre opções de investimento', 'Concluído'),
(6, 6, '2023-02-05 13:20:00', 'Presencial', 'Cartão de crédito', 'Cliente solicitou segunda via do cartão de crédito', 'Concluído'),
(7, 8, '2023-02-10 15:10:00', 'Telefone', 'Contestação de compra', 'Cliente não reconhece uma compra em sua fatura', 'Em Andamento'),
(8, 9, '2023-02-15 10:50:00', 'Presencial', 'Financiamento', 'Cliente solicitou informações sobre financiamento imobiliário', 'Concluído'),
(9, 7, '2023-02-20 14:30:00', 'Chat', 'Transferência internacional', 'Cliente precisa realizar uma transferência para o exterior', 'Em Andamento'),
(10, 10, '2023-02-25 11:40:00', 'Email', 'Seguro de vida', 'Cliente solicitou informações sobre seguro de vida', 'Aberto');
GO


