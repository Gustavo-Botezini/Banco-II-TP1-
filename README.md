# 🗄️ Banco-II-TP1

### 👨‍💻 Alunos:
- @Gustavo-Botezini — `2311100062`  
- @leoliveirak — `2311100019`

---

## 🎯 Objetivo
Simular o mecanismo de **REDO** do **PostgreSQL**, registrando operações de transações (`INSERT`, `UPDATE`, `DELETE`) para possibilitar sua reexecução após falhas.

---

## ⚙️ Funcionamento Básico

1. Execute a função `func_begin()` ➜ adiciona `BEGIN` na tabela de logs;
2. Realize os comandos desejados: `INSERT`, `UPDATE`, `DELETE`;
3. Finalize com `func_end()` ➜ adiciona `END` na tabela de logs;
4. Cada operação é automaticamente registrada na tabela `logs_operacao` por meio da trigger `trg_logs`;
5. Após queda do banco, execute `./REDO` para reprocessar operações.

---

## 🗃️ Estrutura (`schema.sql`)

| Componente               | Descrição                                                           |
|--------------------------|---------------------------------------------------------------------|
| `clientes_em_memoria`    | Tabela `UNLOGGED`, não gera arquivos WAL                            |
| `logs_operacao`          | Tabela de logs das operações executadas                             |
| `trg_logs`               | Trigger responsável por alimentar `logs_operacao`                   |
| `func_begin`, `func_end` | Funções `void` que inserem `BEGIN` e `END` na tabela de logs         |

---

## 🔁 `REDO.ps1`

- Procura blocos completos de transações (`BEGIN` ➜ `END`);
- Ao encontrar `BEGIN`, ativa uma flag e armazena as linhas no array;
- Ao encontrar `END`, desativa a flag e executa os comandos;
- Se um `BEGIN` não for finalizado por um `END`, o bloco é ignorado.

---

## ▶️ Como Executar

1. Crie as tabelas, funções e trigger com o conteúdo de `schema.sql`;
2. Execute as funções `func_begin()` e `func_end()` nos blocos de comandos;
3. Após simular a falha do banco, rode o script `REDO.ps1` para recuperar as transações.

---

![Status](https://img.shields.io/badge/status-%20pronto-green) <br/>
<img alt="Postgres" src ="https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white"/>
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)

