# Solicita a senha do usuário uma única vez
$senha = Read-Host -AsSecureString "Digite a senha do usuario postgreSQL"
$senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))


#Configurações :)
$env:PGHOST = "localhost"
$env:PGPORT = "5432" # <- Porta padrão do postgres, caso precise é só modificar
$env:PGDATABASE = "TB1" # <- Nome do data base que estão as tabelas
$env:PGUSER = "postgres" # <- Nome do usuário
$env:PGPASSWORD = $senhaTextoqui

# Realiza a busca cronólogica
$comando = @"
	SELECT l.acao, l.operation_id, l.nome, l.saldo 
	FROM logs_operacao l 
	ORDER BY l.log_timestamp 
"@

$log = psql -t -A -F "|" -c $comando
<# 
-t -> Tira o cabeçalho 
-A -> Tira a formatação
-F -> Serve para separar os campos
-c -> Comando a ser executado
#>

foreach ($linha in $log){
	$dados = $linha -split '\|'
	$acao = $dados[0]
	$id = $dados[1]
	$nome = $dados[2]
	$saldo = $dados[3]
	
	if($acao -eq 'INSERT'){
		$comando = "INSERT INTO clientes_em_memoria(id, nome, saldo) VALUES ($id, '$nome', $saldo) ON CONFLICT(id) DO NOTHING;"
	}
	elseif($acao -eq 'UPDATE'){
		$comando = "UPDATE clientes_em_memoria SET nome = '$nome', saldo = $saldo WHERE id = $id;"
	}
	elseif($acao -eq 'DELETE'){
		$comando = "DELETE FROM clientes_em_memoria WHERE id = $id;"
	}
	
	#executado
	Write-Host "executado: $comando"
	psql -c $comando
}

#Limpa e fecha a Porta
Remove-Item: env:PGHOST, env:PGPORT, env:PGDATABASE, env:PGUSER, env:PGSENHA
