/*****************************************************************
	 Script de criação do banco de dados GEHAB Bank
	 Autor: Matheus Nunes Rossi
	 Data: 23/04/2025
******************************************************************/
USE master
go

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GEHAB_Bank')
BEGIN
    ALTER DATABASE GEHAB_Bank SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GEHAB_Bank;
END
GO

CREATE DATABASE GEHAB_Bank
ON PRIMARY
(
    NAME = 'GEHAB_Bank_Data',
    FILENAME = 'C:\MSSQL_Data\GEHAB_Bank_Data.mdf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 20MB
)
LOG ON
(
    NAME = 'GEHAB_Bank_Log',
    FILENAME = 'C:\MSSQL_Data\GEHAB_Bank_Log.ldf',
    SIZE = 50MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 10MB
);
GO 

USE GEHAB_Bank
go

/***************************
	Criação das Tabelas
****************************/

-- Tabela Agencia
CREATE TABLE Agencia (
    ID_Agencia INT IDENTITY(1,1) NOT NULL,
    Nome_Agencia NVARCHAR(100) NOT NULL,
    Numero_Agencia NVARCHAR(10) NOT NULL,
    Endereco NVARCHAR(200) NOT NULL,
    Cidade NVARCHAR(100) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CEP NVARCHAR(10) NOT NULL,
    Telefone NVARCHAR(20) NOT NULL,
    Gerente_ID INT NULL,
    Data_Inauguracao DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativa',
    
    CONSTRAINT PK_Agencia PRIMARY KEY (ID_Agencia),
    CONSTRAINT UQ_Agencia_Numero UNIQUE (Numero_Agencia),
    CONSTRAINT CK_Agencia_Status CHECK (Status IN ('Ativa', 'Inativa'))
);
go

-- Tabela Cliente
CREATE TABLE Cliente (
    ID_Cliente INT IDENTITY(1,1) NOT NULL,
    CPF NVARCHAR(14) NOT NULL,
    Nome NVARCHAR(200) NOT NULL,
    Data_Nascimento DATE NOT NULL,
    Endereco NVARCHAR(200) NOT NULL,
    Cidade NVARCHAR(100) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CEP NVARCHAR(10) NOT NULL,
    Telefone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NULL,
    Data_Cadastro DATE NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativo',
    
    CONSTRAINT PK_Cliente PRIMARY KEY (ID_Cliente),
    CONSTRAINT UQ_Cliente_CPF UNIQUE (CPF),
    CONSTRAINT CK_Cliente_Status CHECK (Status IN ('Ativo', 'Inativo')),
    CONSTRAINT CK_Cliente_Email CHECK (Email LIKE '%_@__%.__%')
);
go

-- Tabela Funcionario
CREATE TABLE Funcionario (
    ID_Funcionario INT IDENTITY(1,1) NOT NULL,
    CPF NVARCHAR(14) NOT NULL,
    Nome NVARCHAR(200) NOT NULL,
    Data_Nascimento DATE NOT NULL,
    Endereco NVARCHAR(200) NOT NULL,
    Cidade NVARCHAR(100) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CEP NVARCHAR(10) NOT NULL,
    Telefone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Data_Contratacao DATE NOT NULL,
    Cargo NVARCHAR(100) NOT NULL,
    Salario DECIMAL(12,2) NOT NULL,
    ID_Agencia INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativo',
    
    CONSTRAINT PK_Funcionario PRIMARY KEY (ID_Funcionario),
    CONSTRAINT UQ_Funcionario_CPF UNIQUE (CPF),
    CONSTRAINT FK_Funcionario_Agencia FOREIGN KEY (ID_Agencia) REFERENCES Agencia(ID_Agencia),
    CONSTRAINT CK_Funcionario_Status CHECK (Status IN ('Ativo', 'Inativo')),
    CONSTRAINT CK_Funcionario_Email CHECK (Email LIKE '%_@__%.__%'),
    CONSTRAINT CK_Funcionario_Salario CHECK (Salario > 0)
);
GO

-- Adicionar a chave estrangeira para Gerente na tabela Agencia
ALTER TABLE Agencia
ADD CONSTRAINT FK_Agencia_Gerente FOREIGN KEY (Gerente_ID) REFERENCES Funcionario(ID_Funcionario);
GO

-- Tabela Conta
CREATE TABLE Conta (
    ID_Conta INT IDENTITY(1,1) NOT NULL,
    Numero_Conta NVARCHAR(20) NOT NULL,
    Tipo_Conta NVARCHAR(20) NOT NULL,
    Data_Abertura DATE NOT NULL DEFAULT GETDATE(),
    Saldo DECIMAL(15,2) NOT NULL DEFAULT 0,
    Limite_Credito DECIMAL(15,2) NOT NULL DEFAULT 0,
    ID_Cliente INT NOT NULL,
    ID_Agencia INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativa',
    
    CONSTRAINT PK_Conta PRIMARY KEY (ID_Conta),
    CONSTRAINT UQ_Conta_Numero UNIQUE (Numero_Conta),
    CONSTRAINT FK_Conta_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
    CONSTRAINT FK_Conta_Agencia FOREIGN KEY (ID_Agencia) REFERENCES Agencia(ID_Agencia),
    CONSTRAINT CK_Conta_Tipo CHECK (Tipo_Conta IN ('Corrente', 'Poupança', 'Salário', 'Investimento')),
    CONSTRAINT CK_Conta_Status CHECK (Status IN ('Ativa', 'Inativa', 'Bloqueada')),
    CONSTRAINT CK_Conta_Limite CHECK (Limite_Credito >= 0)
);
GO

-- Tabela Transacao
CREATE TABLE Transacao (
    ID_Transacao INT IDENTITY(1,1) NOT NULL,
    Data_Hora DATETIME NOT NULL DEFAULT GETDATE(),
    Tipo_Transacao NVARCHAR(20) NOT NULL,
    Valor DECIMAL(15,2) NOT NULL,
    ID_Conta_Origem INT NOT NULL,
    ID_Conta_Destino INT NULL,
    Descricao NVARCHAR(200) NULL,
    Canal NVARCHAR(50) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Concluída',
    
    CONSTRAINT PK_Transacao PRIMARY KEY (ID_Transacao),
    CONSTRAINT FK_Transacao_Conta_Origem FOREIGN KEY (ID_Conta_Origem) REFERENCES Conta(ID_Conta),
    CONSTRAINT FK_Transacao_Conta_Destino FOREIGN KEY (ID_Conta_Destino) REFERENCES Conta(ID_Conta),
    CONSTRAINT CK_Transacao_Tipo CHECK (Tipo_Transacao IN ('Depósito', 'Saque', 'Transferência', 'Pagamento')),
    CONSTRAINT CK_Transacao_Canal CHECK (Canal IN ('Internet Banking', 'Caixa Eletrônico', 'Agência', 'App')),
    CONSTRAINT CK_Transacao_Status CHECK (Status IN ('Concluída', 'Pendente', 'Cancelada')),
    CONSTRAINT CK_Transacao_Valor CHECK (Valor > 0)
);
GO

-- Tabela Cartao
CREATE TABLE Cartao (
    ID_Cartao INT IDENTITY(1,1) NOT NULL,
    Numero_Cartao NVARCHAR(19) NOT NULL,
    Tipo_Cartao NVARCHAR(20) NOT NULL,
    Data_Emissao DATE NOT NULL DEFAULT GETDATE(),
    Data_Validade DATE NOT NULL,
    Limite_Credito DECIMAL(15,2) NOT NULL DEFAULT 0,
    ID_Conta INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativo',
    
    CONSTRAINT PK_Cartao PRIMARY KEY (ID_Cartao),
    CONSTRAINT UQ_Cartao_Numero UNIQUE (Numero_Cartao),
    CONSTRAINT FK_Cartao_Conta FOREIGN KEY (ID_Conta) REFERENCES Conta(ID_Conta),
    CONSTRAINT CK_Cartao_Tipo CHECK (Tipo_Cartao IN ('Débito', 'Crédito', 'Múltiplo')),
    CONSTRAINT CK_Cartao_Status CHECK (Status IN ('Ativo', 'Bloqueado', 'Cancelado')),
    CONSTRAINT CK_Cartao_Limite CHECK (Limite_Credito >= 0),
    CONSTRAINT CK_Cartao_Validade CHECK (Data_Validade > Data_Emissao)
);
GO

-- Tabela Fatura_Cartao
CREATE TABLE Fatura_Cartao (
    ID_Fatura INT IDENTITY(1,1) NOT NULL,
    ID_Cartao INT NOT NULL,
    Data_Fechamento DATE NOT NULL,
    Data_Vencimento DATE NOT NULL,
    Valor_Total DECIMAL(15,2) NOT NULL DEFAULT 0,
    Valor_Minimo DECIMAL(15,2) NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Aberta',
    
    CONSTRAINT PK_Fatura_Cartao PRIMARY KEY (ID_Fatura),
    CONSTRAINT FK_Fatura_Cartao FOREIGN KEY (ID_Cartao) REFERENCES Cartao(ID_Cartao),
    CONSTRAINT CK_Fatura_Status CHECK (Status IN ('Aberta', 'Fechada', 'Paga', 'Atrasada')),
    CONSTRAINT CK_Fatura_Valor CHECK (Valor_Total >= 0 AND Valor_Minimo >= 0),
    CONSTRAINT CK_Fatura_Datas CHECK (Data_Vencimento > Data_Fechamento)
);
GO

-- Tabela Compra_Cartao
CREATE TABLE Compra_Cartao (
    ID_Compra INT IDENTITY(1,1) NOT NULL,
    ID_Cartao INT NOT NULL,
    Data_Compra DATETIME NOT NULL DEFAULT GETDATE(),
    Valor DECIMAL(15,2) NOT NULL,
    Estabelecimento NVARCHAR(200) NOT NULL,
    Categoria NVARCHAR(100) NULL,
    Numero_Parcelas INT NOT NULL DEFAULT 1,
    ID_Fatura INT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Aprovada',
    
    CONSTRAINT PK_Compra_Cartao PRIMARY KEY (ID_Compra),
    CONSTRAINT FK_Compra_Cartao FOREIGN KEY (ID_Cartao) REFERENCES Cartao(ID_Cartao),
    CONSTRAINT FK_Compra_Fatura FOREIGN KEY (ID_Fatura) REFERENCES Fatura_Cartao(ID_Fatura),
    CONSTRAINT CK_Compra_Status CHECK (Status IN ('Aprovada', 'Negada', 'Estornada')),
    CONSTRAINT CK_Compra_Valor CHECK (Valor > 0),
    CONSTRAINT CK_Compra_Parcelas CHECK (Numero_Parcelas >= 1)
);
GO

-- Tabela Emprestimo
CREATE TABLE Emprestimo (
    ID_Emprestimo INT IDENTITY(1,1) NOT NULL,
    ID_Cliente INT NOT NULL,
    ID_Conta INT NOT NULL,
    Data_Solicitacao DATE NOT NULL DEFAULT GETDATE(),
    Valor_Solicitado DECIMAL(15,2) NOT NULL,
    Taxa_Juros DECIMAL(5,2) NOT NULL,
    Prazo_Meses INT NOT NULL,
    Valor_Parcela DECIMAL(15,2) NOT NULL,
    Data_Aprovacao DATE NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Solicitado',
    
    CONSTRAINT PK_Emprestimo PRIMARY KEY (ID_Emprestimo),
    CONSTRAINT FK_Emprestimo_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
    CONSTRAINT FK_Emprestimo_Conta FOREIGN KEY (ID_Conta) REFERENCES Conta(ID_Conta),
    CONSTRAINT CK_Emprestimo_Status CHECK (Status IN ('Solicitado', 'Aprovado', 'Negado', 'Quitado')),
    CONSTRAINT CK_Emprestimo_Valor CHECK (Valor_Solicitado > 0),
    CONSTRAINT CK_Emprestimo_Taxa CHECK (Taxa_Juros > 0),
    CONSTRAINT CK_Emprestimo_Prazo CHECK (Prazo_Meses > 0),
    CONSTRAINT CK_Emprestimo_Parcela CHECK (Valor_Parcela > 0)
);
GO

-- Tabela Parcela_Emprestimo
CREATE TABLE Parcela_Emprestimo (
    ID_Parcela INT IDENTITY(1,1) NOT NULL,
    ID_Emprestimo INT NOT NULL,
    Numero_Parcela INT NOT NULL,
    Data_Vencimento DATE NOT NULL,
    Valor_Parcela DECIMAL(15,2) NOT NULL,
    Data_Pagamento DATE NULL,
    Valor_Pago DECIMAL(15,2) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pendente',
    
    CONSTRAINT PK_Parcela_Emprestimo PRIMARY KEY (ID_Parcela),
    CONSTRAINT FK_Parcela_Emprestimo FOREIGN KEY (ID_Emprestimo) REFERENCES Emprestimo(ID_Emprestimo),
    CONSTRAINT CK_Parcela_Status CHECK (Status IN ('Pendente', 'Paga', 'Atrasada')),
    CONSTRAINT CK_Parcela_Valor CHECK (Valor_Parcela > 0),
    CONSTRAINT CK_Parcela_Valor_Pago CHECK (Valor_Pago IS NULL OR Valor_Pago > 0),
    CONSTRAINT UQ_Parcela_Emprestimo_Numero UNIQUE (ID_Emprestimo, Numero_Parcela)
);
GO

-- Tabela Investimento
CREATE TABLE Investimento (
    ID_Investimento INT IDENTITY(1,1) NOT NULL,
    ID_Cliente INT NOT NULL,
    ID_Conta INT NOT NULL,
    Tipo_Investimento NVARCHAR(50) NOT NULL,
    Data_Aplicacao DATE NOT NULL DEFAULT GETDATE(),
    Valor_Aplicado DECIMAL(15,2) NOT NULL,
    Taxa_Rendimento DECIMAL(5,2) NOT NULL,
    Data_Vencimento DATE NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Ativo',
    
    CONSTRAINT PK_Investimento PRIMARY KEY (ID_Investimento),
    CONSTRAINT FK_Investimento_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
    CONSTRAINT FK_Investimento_Conta FOREIGN KEY (ID_Conta) REFERENCES Conta(ID_Conta),
    CONSTRAINT CK_Investimento_Tipo CHECK (Tipo_Investimento IN ('Poupança', 'CDB', 'LCI', 'LCA', 'Tesouro Direto')),
    CONSTRAINT CK_Investimento_Status CHECK (Status IN ('Ativo', 'Resgatado', 'Vencido')),
    CONSTRAINT CK_Investimento_Valor CHECK (Valor_Aplicado > 0),
    CONSTRAINT CK_Investimento_Taxa CHECK (Taxa_Rendimento >= 0)
);
GO

-- Tabela Atendimento
CREATE TABLE Atendimento (
    ID_Atendimento INT IDENTITY(1,1) NOT NULL,
    ID_Cliente INT NOT NULL,
    ID_Funcionario INT NOT NULL,
    Data_Hora DATETIME NOT NULL DEFAULT GETDATE(),
    Canal NVARCHAR(50) NOT NULL,
    Assunto NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(MAX) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Aberto',
    
    CONSTRAINT PK_Atendimento PRIMARY KEY (ID_Atendimento),
    CONSTRAINT FK_Atendimento_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente),
    CONSTRAINT FK_Atendimento_Funcionario FOREIGN KEY (ID_Funcionario) REFERENCES Funcionario(ID_Funcionario),
    CONSTRAINT CK_Atendimento_Canal CHECK (Canal IN ('Presencial', 'Telefone', 'Chat', 'Email')),
    CONSTRAINT CK_Atendimento_Status CHECK (Status IN ('Aberto', 'Em Andamento', 'Concluído', 'Cancelado'))
);
GO

PRINT 'Banco de dados GEHAB_Bank criado com sucesso!'
GO
