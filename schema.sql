CREATE UNLOGGED TABLE clientes_em_memoria (
  id SERIAL,
  nome TEXT,
  saldo NUMERIC,

  CONSTRAINT pk_id PRIMARY KEY(id)
);


CREATE TABLE logs_operacao (
    log_id SERIAL PRIMARY KEY,
    operation_id INTEGER,
    nome TEXT,
    saldo NUMERIC,
    acao VARCHAR(15) NOT NULL,
    consulta TEXT, -- a consulta toda
    data_base TEXT ,
    user_name TEXT DEFAULT current_user,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION logs() 
RETURNS TRIGGER 
AS $$
	DECLARE
	banco TEXT:= current_database();
	consulta_atual TEXT;
	BEGIN
	-- Pegar a consulta
	SELECT query INTO consulta_atual
	FROM pg_stat_activity
	WHERE pid = pg_backend_pid();


	-- parte de INSERT
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO logs_operacao (operation_id, nome, saldo, acao, consulta, data_base)
		VALUES(NEW.id, NEW.nome, NEW.saldo, 'INSERT', consulta_atual,banco);
		RETURN NEW;
		
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO logs_operacao (operation_id, nome, saldo, acao, consulta, data_base)
		VALUES(NEW.id, NEW.nome, NEW.saldo, 'UPDATE', consulta_atual,banco);
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
    	INSERT INTO logs_operacao (operation_id, nome, saldo, acao, consulta, data_base)
		VALUES(OLD.id, OLD.nome, OLD.saldo, 'DELETE', consulta_atual,banco);
		RETURN NEW;
	END IF;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_logs BEFORE INSERT OR UPDATE OR DELETE ON clientes_em_memoria
FOR EACH ROW EXECUTE FUNCTION logs();
