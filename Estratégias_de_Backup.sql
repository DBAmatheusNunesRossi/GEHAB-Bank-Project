/****************************************************************************************
		Script de configuração de estratégias de backup para o banco de dados GEHAB Bank
		Autor: Matheus Nunes Rossi
		Data: 25/04/2025
****************************************************************************************/
USE master;
GO

-- Configuração do modelo de recuperação para FULL
-- Isso permite backups completos, diferenciais e de log de transações
ALTER DATABASE GEHAB_Bank SET RECOVERY FULL;
GO

-- 1. BACKUP COMPLETO (.MDF)
-- O backup completo contém todos os dados do banco de dados no momento da execução do backup
-- É a base para os backups diferenciais e de log de transações

-- Criação do diretório para armazenar os backups
-- EXEC xp_cmdshell 'mkdir "C:\SQLBackups\GEHAB_Bank"'
-- GO

-- Backup completo do banco de dados
BACKUP DATABASE GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak'
WITH 
    COMPRESSION, -- Compressão para reduzir o tamanho do arquivo
    INIT, -- Sobrescreve o arquivo de backup existente
    NAME = 'GEHAB Bank - Backup Completo',
    DESCRIPTION = 'Backup completo do banco de dados GEHAB Bank',
    STATS = 10; -- Exibe o progresso a cada 10%
GO

-- 2. BACKUP DIFERENCIAL
-- O backup diferencial contém apenas as alterações feitas desde o último backup completo
-- É mais rápido que um backup completo e requer menos espaço

BACKUP DATABASE GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff.bak'
WITH 
    DIFFERENTIAL, -- Indica que é um backup diferencial
    COMPRESSION,
    INIT,
    NAME = 'GEHAB Bank - Backup Diferencial',
    DESCRIPTION = 'Backup diferencial do banco de dados GEHAB Bank',
    STATS = 10;
GO

-- 3. BACKUP DE LOG DE TRANSAÇÕES
-- O backup de log de transações contém todas as transações registradas no log desde o último backup de log
-- Permite a recuperação pontual (point-in-time recovery)

BACKUP LOG GEHAB_Bank
TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log.trn'
WITH 
    COMPRESSION,
    INIT,
    NAME = 'GEHAB Bank - Backup de Log',
    DESCRIPTION = 'Backup do log de transações do banco de dados GEHAB Bank',
    STATS = 10;
GO

-- 4. VERIFICAÇÃO DE BACKUP
-- Verifica a integridade do backup completo
RESTORE VERIFYONLY FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak';
GO

-- 5. CENÁRIO DE RECUPERAÇÃO
-- Exemplo de script para restaurar o banco de dados a partir dos backups

-- 5.1. Restauração a partir do backup completo
-- RESTORE DATABASE GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full.bak'
-- WITH NORECOVERY; -- Permite aplicar backups adicionais
-- GO

-- 5.2. Restauração a partir do backup diferencial
-- RESTORE DATABASE GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff.bak'
-- WITH NORECOVERY;
-- GO

-- 5.3. Restauração a partir do backup de log de transações
-- RESTORE LOG GEHAB_Bank
-- FROM DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log.trn'
-- WITH RECOVERY; -- Coloca o banco de dados online após a restauração
-- GO

-- 6. ESTRATÉGIA DE BACKUP RECOMENDADA
/*
Para o GEHAB Bank, recomenda-se a seguinte estratégia de backup:

1. Backup Completo: Uma vez por semana (domingo à noite)
   BACKUP DATABASE GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Full_<DATA>.bak'

2. Backup Diferencial: Diariamente (segunda a sábado à noite)
   BACKUP DATABASE GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Diff_<DATA>.bak' WITH DIFFERENTIAL

3. Backup de Log de Transações: A cada hora durante o horário comercial
   BACKUP LOG GEHAB_Bank TO DISK = 'C:\SQLBackups\GEHAB_Bank\GEHAB_Bank_Log_<DATA_HORA>.trn'

4. Retenção de Backups:
   - Backups Completos: Manter por 3 meses
   - Backups Diferenciais: Manter por 2 semanas
   - Backups de Log: Manter por 1 semana

5. Verificação de Backups:
   - Executar RESTORE VERIFYONLY semanalmente para verificar a integridade dos backups
   - Realizar testes de restauração mensalmente em um ambiente de teste

6. Armazenamento Externo:
   - Copiar backups completos semanais para um local externo ou nuvem
   - Implementar criptografia para backups armazenados externamente
*/

-- 7. SCRIPT PARA AUTOMATIZAR A LIMPEZA DE BACKUPS ANTIGOS
/*
-- Este script pode ser agendado para execução periódica
DECLARE @DeleteDate DATETIME
DECLARE @BackupPath VARCHAR(255)
DECLARE @cmd VARCHAR(1000)

-- Configurações
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

PRINT 'Configuração de estratégias de backup concluída com sucesso!'
GO
