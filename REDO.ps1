# Solicita a senha do usuário uma única vez
$senha = Read-Host -AsSecureString "Digite a senha do usuario postgreSQL"
$senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))
# Configurações :)
$env:PGHOST = "localhost"
$env:PGPORT = "5432"
$env:PGDATABASE = "DATABASE"
$env:PGUSER = "USUÁRIO"
$env:PGPASSWORD = $senhaTexto



# Busca completa e cronológica
$comando = @"
	SELECT l.log_id, l.acao, l.operation_id, l.nome, l.saldo 
	FROM logs_operacao l 
	ORDER BY l.log_id
"@

$log = psql -t -A -F "|" -c $comando
<# 
-t -> Tira o cabeçalho 
-A -> Tira a formatação
-F -> Serve para separar os campos
-c -> Comando a ser executado
#>

# Variáveis de controle
$executarBloco = $false
$bloco = @()
$blocosValidos = @()


<# LEONARDO
foreach ($linha in $log) {
	$dados = $linha -split '\|'
	$acao = $dados[1]
	$id = $dados[2]
	$nome = $dados[3]
	$saldo = $dados[4]

	if ($acao -eq "BEGIN") { #Existe um BEGIN
		# Começa um novo bloco
		$bloco = @() 
		$executarBloco = $true
	}
	elseif ($acao -eq "END") {
		# Fecha o bloco e armazena para execução
		if ($executarBloco -and $bloco.Count -gt 0) {
			$blocosValidos += ,$bloco
		}
		elseif (-not $executarBloco) {
		Write-Host "⚠️  Encontrado END sem BEGIN. Ignorando bloco."
	}
		$executarBloco = $false
	}
	elseif ($executarBloco) {
		# Adiciona ação ao bloco atual
		$bloco += ,@{
			acao = $acao
			id = $id
			nome = $nome
			saldo = $saldo
		}
		Write-Host " Adicionando $bloco.Length linhas"
	}
}


# Verifica se há bloco aberto não encerrado e mostra todos os dados
if ($executarBloco -and $bloco.Count -gt 0) {
	Write-Host "Bloco com BEGIN no log_id $($bloco[0].log_id) ignorado (sem END)."
	foreach ($registro in $bloco) {
		Write-Host "Registro aberto: $($registro.acao) com ID $($registro.id), Nome: $($registro.nome), Saldo: $($registro.saldo)"
		}
}
#> #LEONARDO

# Executa os blocos válidos
foreach ($bloco in $blocosValidos) {
	foreach ($registro in $bloco) {
		$acao = $registro["acao"]
		$id = $registro["id"]
		$nome = $registro["nome"]
		$saldo = $registro["saldo"]

		if ($acao -eq "INSERT") {
			$comando = "INSERT INTO clientes_em_memoria(id, nome, saldo) VALUES ($id, '$nome', $saldo) ON CONFLICT(id) DO NOTHING;"
		}
		elseif ($acao -eq "UPDATE") {
			$comando = "UPDATE clientes_em_memoria SET nome = '$nome', saldo = $saldo WHERE id = $id;"
		}
		elseif ($acao -eq "DELETE") {
			$comando = "DELETE FROM clientes_em_memoria WHERE id = $id;"
		}
		else {
			continue
		}

		Write-Host "executado: $comando"
		psql -c $comando
	}
}

# Limpa variáveis de ambiente
Remove-Item Env:PGHOST
Remove-Item Env:PGPORT
Remove-Item Env:PGDATABASE
Remove-Item Env:PGUSER
Remove-Item Env:PGPASSWORD
