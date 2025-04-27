/********************************************************************************************
		Script de cria��o de stored procedures e triggers para o banco de dados GEHAB Bank
		Autor: Matheus Nunes Rossi
		Data: 26/04/2025
********************************************************************************************/
USE GEHAB_Bank;
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- 1. Stored Procedure para abertura de nova conta
CREATE OR ALTER PROCEDURE sp_AbrirConta
	@CPF_Cliente NVARCHAR(14),
	@Tipo_Conta NVARCHAR(20),
	@ID_Agencia INT,
	@Saldo_Inicial DECIMAL(15,2) = 0,
	@Limite_Credito DECIMAL(15,2) = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID_Cliente INT;
	DECLARE @Numero_Conta NVARCHAR(20);
	DECLARE @Data_Atual DATE = GETDATE();
	DECLARE @Mensagem NVARCHAR(200);

	-- Verificar se o cliente existe
	SELECT @ID_Cliente = [ID_Cliente]
	FROM dbo.Cliente
	WHERE CPF = @CPF_Cliente AND Status = 'Ativo';

	IF @ID_Cliente IS NULL
	BEGIN
		RAISERROR ('Cliente n�o encontrado ou inativo.', 16, 1); 
		RETURN;
	END

	-- Verificar se a ag�ncia existe
	IF NOT EXISTS (SELECT 1
				   FROM dbo.Agencia
				   WHERE ID_Agencia = @ID_Agencia AND Status = 'Ativa')
	BEGIN
		RAISERROR ('Ag�ncia n�o encontrada ou inativa.', 16, 1);
		RETURN;
	END

	-- Verificar se o tipo de conta � v�lido
	IF @Tipo_Conta NOT IN ('Corrente', 'Poupan�a', 'Sal�rio', 'Investimento')
	BEGIN
		RAISERROR ('Tipo de conta inv�lido. Tipos v�lidos: Corrente, Poupan�a, Sal�rio, Investimento.', 16, 1);
		RETURN;
	END

	 -- Gerar n�mero da conta (formato: AGENCIA-SEQUENCIAL)
	 DECLARE @Numero_Agencia NVARCHAR(10);
	 DECLARE @Sequencial INT;

	 SELECT @Numero_Agencia = [Numero_Agencia] FROM dbo.Agencia WHERE ID_Agencia = @ID_Agencia;
	 SELECT @Sequencial = COUNT(*) + 1 FROM dbo.Conta WHERE ID_Agencia = @ID_Agencia;

	 SET @Numero_Conta = @Numero_Agencia + '-' + RIGHT('00' + CAST(@Sequencial AS NVARCHAR(10)), 2);

	 -- Inserir nova conta
	 BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO dbo.Conta (Numero_Conta, Tipo_Conta, Data_Abertura, Saldo, Limite_Credito, ID_Cliente, ID_Agencia, Status)
		VALUES (@Numero_Conta, @Tipo_Conta, @Data_Atual, @Saldo_Inicial, @Limite_Credito, @ID_Cliente, @ID_Agencia, 'Ativa');

		-- Se houver saldo inicial, registrar como dep�sito
		IF @Saldo_Inicial > 0
		BEGIN
			DECLARE @ID_Conta INT = SCOPE_IDENTITY();

			INSERT INTO dbo.Transacao (Data_Hora, Tipo_Transacao, Valor, ID_Conta_Origem, ID_Conta_Destino, Descricao, Canal, Status)
			VALUES (GETDATE(), 'Dep�sito', @Saldo_Inicial, @ID_Conta, NULL, 'Dep�sito inicial', 'Ag�ncia', 'Conclu�da');
		END
		COMMIT TRANSACTION;

		SET @Mensagem = 'Conta' + @Numero_Conta + ' Aberta com sucesso para o cliente ID ' + CAST(@ID_Cliente AS NVARCHAR(10)) + '-';
		PRINT @Mensagem
	 END TRY
	 BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMensage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();

		RAISERROR(@ErrorMensage, @ErrorSeverity, @ErrorState);
	 END CATCH
END;
GO


-- 2. Stored Procedure para realizar transfer�ncia entre contas
CREATE OR ALTER PROCEDURE sp_RealizarTransferencia
	@Numero_Conta_Origem NVARCHAR(20),
	@Numero_Conta_Destino NVARCHAR(20),
	@Valor DECIMAL(15,2),
	@Descricao NVARCHAR(200) = NULL,
	@Canal NVARCHAR(50) = 'Internet Banking'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID_Conta_Origem INT;
	DECLARE @ID_Conta_Destino INT;
	DECLARE @Saldo_Origem DECIMAL(15,2);
	DECLARE @Limite_Origem DECIMAL(15,2);
	DECLARE @Status_Origem NVARCHAR(20);
	DECLARE @Status_Destino NVARCHAR(20);
	DECLARE @Mensagem NVARCHAR(200);

	-- Validar valor da transfer�ncia
	IF @Valor <= 0
	BEGIN
		RAISERROR ('O valor da transfer�ncia deve ser maior que zero.', 16, 1);
		RETURN;
	END

	-- Obter informa��es das contas
	SELECT 
		@ID_Conta_Origem = [ID_Conta],
		@Saldo_Origem = [Saldo],
		@Limite_Origem = [Limite_Credito],
		@Status_Origem = [Status]
	FROM dbo.Conta
	WHERE Numero_Conta = @Numero_Conta_Origem

	SELECT
		@ID_Conta_Destino = [ID_Conta],
		@Status_Destino = [Status]
	FROM dbo.Conta
	WHERE Numero_Conta = @Numero_Conta_Destino

	 -- Verificar se as contas existem
	 IF @ID_Conta_Origem IS NULL
	 BEGIN
		RAISERROR ('Conta de origem n�o encontrada.', 16, 1);
		RETURN;
	 END

	 IF @ID_Conta_Destino IS NULL
	 BEGIN
		RAISERROR ('Conta de destino n�o encontrada.', 16, 1);
		RETURN;
	 END

	 -- Verificar se as contas est�o ativas
	 IF @Status_Origem <> 'Ativa'
	 BEGIN
		RAISERROR ('Conta de origem n�o est� ativa.', 16, 1);
		RETURN;
	 END

	 IF @Status_Destino <> 'Ativa'
	 BEGIN
		RAISERROR ('Conta de destino n�o est� ativa.', 16, 1);
		RETURN;
	 END

	-- Verificar se a conta de origem tem saldo suficiente (considerando limite)
	IF @Saldo_Origem + @Limite_Origem < @Valor
	BEGIN
		RAISERROR('Saldo insuficiente para realizar a transfer�ncia.', 16, 1);
        RETURN;
	END

	-- Realizar a transfer�ncia
	BEGIN TRY
		BEGIN TRANSACTION

		-- Atualizar saldo da conta de origem
		UPDATE dbo.Conta SET Saldo = Saldo - @Valor
		WHERE ID_Conta = @ID_Conta_Origem;

		-- Atualizar saldo da conta de destino
		UPDATE dbo.Conta SET Saldo = Saldo + @Valor
		WHERE ID_Conta = @ID_Conta_Origem;

		-- Registrar a transa��o
		INSERT INTO dbo.Transacao (Data_Hora, Tipo_Transacao, Valor, ID_Conta_Origem, ID_Conta_Destino, Descricao, Canal, Status)
		VALUES (GETDATE(), 'Transfer�ncia', @Valor, @ID_Conta_Origem, @ID_Conta_Destino, @Descricao, @Canal, 'Conclu�da');

		COMMIT TRANSACTION;

		SET @Mensagem = 'Transfer�ncia de R$ ' + CAST(@Valor AS NVARCHAR(20)) + ' realizada com sucesso da conta ' + 
                        @Numero_Conta_Origem + ' para a conta ' + @Numero_Conta_Destino + '.';
		PRINT @Mensagem;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END;
GO


-- 3. Stored Procedure para solicitar empr�stimo
CREATE OR ALTER PROCEDURE sp_SolicitarEmprestimo
	@CPF_Cliente NVARCHAR(14),
	@Numero_Conta NVARCHAR(20),
	@Valor_Solicitado DECIMAL(15,2),
	@Prazo_Meses INT,
	@Taxa_Juros DECIMAL(5,2) = NULL --NULL, ser� calculada automaticamente 
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID_Cliente INT;
	DECLARE @ID_Conta INT;
	DECLARE @Taxa_Calculada DECIMAL(5,2);
	DECLARE @Valor_Parcela DECIMAL(15,2);
	DECLARE @Mensagem NVARCHAR(200);

	-- Verificar se o cliente existe
	SELECT @ID_Cliente = [ID_Cliente]
	FROM dbo.Cliente
	WHERE CPF = @CPF_Cliente AND Status = 'Ativo';

	IF @ID_Cliente IS NULL
	BEGIN
		RAISERROR('Cliente n�o encontrado ou inativo.', 16, 1);
		RETURN;
	END

	 -- Verificar se a conta existe e pertence ao cliente
	 SELECT @ID_Conta = C.ID_Conta
	 FROM dbo.Conta C
	 WHERE C.Numero_Conta =  @Numero_Conta AND C.ID_Cliente = @ID_Cliente AND C.Status = 'Ativa';

	 IF @ID_Conta IS NULL
	 BEGIN
		RAISERROR ('Conta n�o encontrada, n�o pertence ao cliente informado ou n�o est� ativa.', 16, 1);
		RETURN;
	 END

	  -- Validar valor e prazo
	  IF @Valor_Solicitado <= 0
	  BEGIN
		 RAISERROR('O valor do empr�stimo deve ser maior que zero.', 16, 1);
		 RETURN;
	  END

	  IF @Prazo_Meses <= 0
	  BEGIN
		 RAISERROR('O prazo do empr�stimo deve ser maior que zero.', 16, 1);
		 RETURN;
	  END

	  -- Calcular taxa de juros se n�o informada
	  IF @Taxa_Juros IS NULL
	  BEGIN
			-- L�gica para calcular taxa baseada no hist�rico do cliente, valor e prazo
            -- Quanto maior o prazo, maior a taxa
            -- Quanto maior o valor, menor a taxa
		SET @Taxa_Calculada = 1.0 + (@Prazo_Meses / 100.0) - (@Valor_Solicitado / 100000.0);

		-- Garantir que a taxa esteja entre 0.8% e 2.5%
		SET @Taxa_Calculada = CASE
								WHEN @Taxa_Calculada < 0.8 THEN 0.8
								WHEN @Taxa_Calculada > 2.5 THEN 2.5
								ELSE @Taxa_Calculada
							  END;
	  END
	  ELSE
	  BEGIN
		SET @Taxa_Calculada = @Taxa_Juros;
	  END

	  -- Calcular valor da parcela (f�rmula simplificada)
      -- Valor da parcela = (Valor solicitado * (1 + Taxa * Prazo)) / Prazo
	  SET @Valor_Parcela = (@Valor_Solicitado * (1 + (@Taxa_Calculada * @Prazo_Meses))) / @Prazo_Meses;

	  -- Registrar a solicita��o de empr�stimo
	  BEGIN TRY
		 BEGIN TRANSACTION;
		 INSERT INTO dbo.Emprestimo (ID_Cliente, ID_Conta, Data_Solicitacao, Valor_Solicitado,
									 Taxa_Juros, Prazo_Meses, Valor_Parcela, Data_Aprovacao, Status)
		 VALUES (@ID_Cliente, @ID_Conta, GETDATE(), @Valor_Solicitado,
				 @Taxa_Calculada, @Prazo_Meses, @Valor_Parcela, NULL, 'Solicitado');

		 COMMIT TRANSACTION;

		 SET @Mensagem = 'Empr�stimo de R$ ' + CAST(@Valor_Solicitado AS NVARCHAR(20)) + 
                        ' solicitado com sucesso. Taxa de juros: ' + CAST(@Taxa_Calculada AS NVARCHAR(10)) + 
                        '%. Valor da parcela: R$ ' + CAST(@Valor_Parcela AS NVARCHAR(20)) + '.';
        PRINT @Mensagem;
	  END TRY
	  BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


-- 4. Stored Procedure para aprovar empr�stimo
CREATE OR ALTER PROCEDURE sp_AprovarEmprestimo
	@ID_Emprestimo INT,
	@ID_Funcionario INT,
	@Aprovar BIT = 1  -- 1 = Aprovar, 0 = Negar
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID_Conta INT;
	DECLARE @Valor_Solicitado DECIMAL(15,2);
	DECLARE @Status_Atual NVARCHAR(20);
	DECLARE @Prazo_Meses INT;
	DECLARE @Valor_Parcela DECIMAL(15,2);
	DECLARE @Mensagem NVARCHAR(200);

	-- Verificar se o empr�stimo existe
	SELECT
		@ID_Conta = [ID_Conta],
		@Valor_Solicitado = [Valor_Solicitado],
		@Status_Atual = [Status],
		@Prazo_Meses = [Prazo_Meses],
		@Valor_Parcela = [Valor_Parcela]
	FROM dbo.Emprestimo
	WHERE ID_Emprestimo = @ID_Emprestimo;

	IF @ID_Conta IS NULL
	BEGIN
		RAISERROR('Empr�stimo n�o encontrado.', 16, 1);
		RETURN;
	END

	-- Verificar se o funcion�rio existe
	IF NOT EXISTS (SELECT 1
				   FROM dbo.Funcionario 
				   WHERE ID_Funcionario = @ID_Funcionario AND Status = 'Ativo')
	BEGIN
		RAISERROR('Funcion�rio n�o encontrado ou inativo.', 16, 1);
		RETURN;
	END

	-- Verificar se o empr�stimo est� no status correto para aprova��o/nega��o
	IF @Status_Atual <> 'Solicitado'
	BEGIN
		RAISERROR('Este empr�stimo n�o pode ser aprovado/negado pois n�o est� no status "Solicitado".', 16, 1);
		RETURN;
	END

	-- Aprovar ou negar o empr�stimo
	BEGIN TRY
		BEGIN TRANSACTION;

		IF @Aprovar = 1
		BEGIN
			-- Aprovar empr�stimo
			UPDATE dbo.Emprestimo SET Status = 'Aprovado', Data_Aprovacao = GETDATE()
			WHERE ID_Emprestimo = @ID_Emprestimo;

			-- Adicionar valor � conta do cliente
			UPDATE dbo.Conta SET Saldo = Saldo + @Valor_Solicitado
			WHERE ID_Conta = @ID_Conta;

			-- Registrar a transa��o
			INSERT INTO dbo.Transacao (Data_Hora, Tipo_Transacao, Valor, ID_Conta_Origem, ID_Conta_Destino,
									   Descricao, Canal, Status)
			VALUES (GETDATE(), 'Dep�sito', @Valor_Solicitado, @ID_Conta, NULL, 
                   'Cr�dito de empr�stimo #' + CAST(@ID_Emprestimo AS NVARCHAR(10)), 'Ag�ncia', 'Conclu�da');

			-- Gerar parcelas
			DECLARE @i INT = 1;
			DECLARE @Data_Vencimento DATE = DATEADD(MONTH, 1, GETDATE());

			WHILE @i <= @Prazo_Meses
			BEGIN
				INSERT INTO dbo.Parcela_Emprestimo (ID_Emprestimo, Numero_Parcela, Data_Vencimento,
													Valor_Parcela, Data_Pagamento, Valor_Pago, Status)
				VALUES (@ID_Emprestimo, @i, @Data_Vencimento, @Valor_Parcela, NULL, NULL, 'Pendente'); 

				SET @Data_Vencimento = DATEADD(MONTH, 1, @Data_Vencimento);
				SET @i = @i + 1;
			END

			SET @Mensagem = 'Empr�stimo #' + CAST(@ID_Emprestimo AS NVARCHAR(10)) + ' aprovado com sucesso.';
		END
		ELSE
		BEGIN
			-- Negar empr�stimo
			UPDATE dbo.Emprestimo SET Status = 'Negado', Data_Aprovacao = GETDATE()
			WHERE ID_Emprestimo = @ID_Emprestimo;

			SET @Mensagem = 'Empr�stimo #' + CAST(@ID_Emprestimo AS NVARCHAR(10)) + ' negado.';
		END

		COMMIT TRANSACTION;
		PRINT @Mensagem;
	END TRY
	BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


-- 5. Stored Procedure para gerar extrato de conta
CREATE OR ALTER PROCEDURE sp_GerarExtrato
	@Numero_Conta NVARCHAR(20),
	@Data_Inicio DATE,
	@Data_Fim DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID_Conta INT;
	DECLARE @Nome_Cliente NVARCHAR(200);
	DECLARE @Saldo_Atual DECIMAL(15,2);

	-- Se data fim n�o informada, usar data atual
	IF @Data_Fim IS NULL
        SET @Data_Fim = GETDATE();
    
    -- Verificar se a conta existe
    SELECT 
		@ID_Conta = c.ID_Conta, 
		@Nome_Cliente = cl.Nome, 
		@Saldo_Atual = c.Saldo
    FROM Conta c
    JOIN Cliente cl ON c.ID_Cliente = cl.ID_Cliente
    WHERE c.Numero_Conta = @Numero_Conta;
    
    IF @ID_Conta IS NULL
    BEGIN
        RAISERROR('Conta n�o encontrada.', 16, 1);
        RETURN;
    END
    
    -- Imprimir cabe�alho do extrato
    PRINT '===============================================================';
    PRINT 'EXTRATO BANC�RIO - GEHAB BANK';
    PRINT '===============================================================';
    PRINT 'Conta: ' + @Numero_Conta;
    PRINT 'Cliente: ' + @Nome_Cliente;
    PRINT 'Per�odo: ' + CONVERT(NVARCHAR, @Data_Inicio, 103) + ' a ' + CONVERT(NVARCHAR, @Data_Fim, 103);
    PRINT 'Saldo Atual: R$ ' + CAST(@Saldo_Atual AS NVARCHAR(20));
    PRINT '===============================================================';
    PRINT 'DATA       | TIPO           | VALOR      | DESCRI��O';
    PRINT '---------------------------------------------------------------';
END
GO
