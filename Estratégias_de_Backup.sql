/****************************************************************************************
		Script de configura��o de estrat�gias de backup para o banco de dados GEHAB Bank
		Autor: Matheus Nunes Rossi
		Data: 25/04/2025
****************************************************************************************/
USE master;
GO

-- Configura��o do modelo de recupera��o para FULL
-- Isso permite backups completos, diferenciais e de log de transa��es
ALTER DATABASE GEHAB_Bank SET RECOVERY FULL;
GO

-- 1. BACKUP COMPLETO (.MDF)
-- O backup completo cont�m todos os dados do banco de dados no momento da execu��o do backup
-- � a base para os backups diferenciais e de log de transa��es

-- Cria��o do diret�rio para armazenar os backups
-- EXEC xp_cmdshell 'mkdir "C:\SQLBackups\GEHAB_Bank"'
-- GO

-- Backup completo do banco de dados
BACKUP DATABASE GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak'
WITH 
    COMPRESSION, -- Compress�o para reduzir o tamanho do arquivo
    INIT, -- Sobrescreve o arquivo de backup existente
    NAME = 'GEHAB Bank - Backup Completo',
    DESCRIPTION = 'Backup completo do banco de dados GEHAB Bank',
    STATS = 10; -- Exibe o progresso a cada 10%
GO

-- 2. BACKUP DIFERENCIAL
-- O backup diferencial cont�m apenas as altera��es feitas desde o �ltimo backup completo
-- � mais r�pido que um backup completo e requer menos espa�o

BACKUP DATABASE GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff.bak'
WITH 
    DIFFERENTIAL, -- Indica que � um backup diferencial
    COMPRESSION,
    INIT,
    NAME = 'GEHAB Bank - Backup Diferencial',
    DESCRIPTION = 'Backup diferencial do banco de dados GEHAB Bank',
    STATS = 10;
GO

-- 3. BACKUP DE LOG DE TRANSA��ES
-- O backup de log de transa��es cont�m todas as transa��es registradas no log desde o �ltimo backup de log
-- Permite a recupera��o pontual (point-in-time recovery)

BACKUP LOG GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log.trn'
WITH 
    COMPRESSION,
    INIT,
    NAME = 'GEHAB Bank - Backup de Log',
    DESCRIPTION = 'Backup do log de transa��es do banco de dados GEHAB Bank',
    STATS = 10;
GO

-- 4. VERIFICA��O DE BACKUP
-- Verifica a integridade do backup completo
RESTORE VERIFYONLY FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak';
GO

-- 5. CEN�RIO DE RECUPERA��O
-- Exemplo de script para restaurar o banco de dados a partir dos backups

-- 5.1. Restaura��o a partir do backup completo
-- RESTORE DATABASE GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak'
-- WITH NORECOVERY; -- Permite aplicar backups adicionais
-- GO

-- 5.2. Restaura��o a partir do backup diferencial
-- RESTORE DATABASE GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff.bak'
-- WITH NORECOVERY;
-- GO

-- 5.3. Restaura��o a partir do backup de log de transa��es
-- RESTORE LOG GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log.trn'
-- WITH RECOVERY; -- Coloca o banco de dados online ap�s a restaura��o
-- GO

-- 6. ESTRAT�GIA DE BACKUP RECOMENDADA
/*
Para o GEHAB Bank, recomenda-se a seguinte estrat�gia de backup:

1. Backup Completo: Uma vez por semana (domingo � noite)
   BACKUP DATABASE GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full_<DATA>.bak'

2. Backup Diferencial: Diariamente (segunda a s�bado � noite)
   BACKUP DATABASE GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff_<DATA>.bak' WITH DIFFERENTIAL

3. Backup de Log de Transa��es: A cada hora durante o hor�rio comercial
   BACKUP LOG GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log_<DATA_HORA>.trn'

4. Reten��o de Backups:
   - Backups Completos: Manter por 3 meses
   - Backups Diferenciais: Manter por 2 semanas
   - Backups de Log: Manter por 1 semana

5. Verifica��o de Backups:
   - Executar RESTORE VERIFYONLY semanalmente para verificar a integridade dos backups
   - Realizar testes de restaura��o mensalmente em um ambiente de teste

6. Armazenamento Externo:
   - Copiar backups completos semanais para um local externo ou nuvem
   - Implementar criptografia para backups armazenados externamente
*/

-- 7. SCRIPT PARA AUTOMATIZAR A LIMPEZA DE BACKUPS ANTIGOS
/*
-- Este script pode ser agendado para execu��o peri�dica
DECLARE @DeleteDate DATETIME
DECLARE @BackupPath VARCHAR(255)
DECLARE @cmd VARCHAR(1000)

-- Configura��es
SET @BackupPath = 'C:\SQLBackups\GEHAB_Bank\'

-- Excluir backups completos com mais de 3 meses
SET @DeleteDate = DATEADD(MM, -3, GETDATE())
SET @cmd = 'FORFILES /P "' + @BackupPath + '" /M "*_Full_*.bak" /D -' + CAST(DATEDIFF(DD, @DeleteDate, GETDATE()) AS VARCHAR(10)) + ' /C "CMD /C DEL @PATH"'
-- EXEC xp_cmdshell @cmd

-- Excluir backups diferenciais com mais de 2 semanas
SET @DeleteDate = DATEADD(WW, -2, GETDATE())
SET @cmd = 'FORFILES /P "' + @BackupPath + '" /M "*_Diff_*.bak" /D -' + CAST(DATEDIFF(DD, @DeleteDate, GETDATE()) AS VARCHAR(10)) + ' /C "CMD /C DEL @PATH"'
-- EXEC xp_cmdshell @cmd

-- Excluir backups de log com mais de 1 semana
SET @DeleteDate = DATEADD(WW, -1, GETDATE())
SET @cmd = 'FORFILES /P "' + @BackupPath + '" /M "*_Log_*.trn" /D -' + CAST(DATEDIFF(DD, @DeleteDate, GETDATE()) AS VARCHAR(10)) + ' /C "CMD /C DEL @PATH"'
-- EXEC xp_cmdshell @cmd
*/

PRINT 'Configura��o de estrat�gias de backup conclu�da com sucesso!'
GO
