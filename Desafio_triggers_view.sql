use company;

CREATE USER "gerente"@"localhost" identified by "gerente";
CREATE USER "funcionario"@"localhost" identified by "funcionario";

GRANT SELECT ON company.v_empregados_departamento_localidade TO 'gerente'@'localhost';

-- Número de empregados por departamento e localidade
CREATE VIEW v_empregados_departamento_localidade AS
SELECT Dname AS Nome_Departamento,COUNT(Dname) AS total_de_funcionarios, dl.Dlocation AS Localidade
FROM employee e 
JOIN department d ON (e.Dno = d.Dnumber) 
JOIN dept_locations dl ON (dl.Dnumber = d.Dnumber)
GROUP BY Dname ORDER BY total_de_funcionarios DESC;

select * from v_relatorio_projetos;
-- Listar departamentos e seus gerentes
CREATE VIEW v_departamento_gerente AS
SELECT Dname AS Nome_Departamento, CONCAT(e.Fname," ", e.Minit,". ", e.Lname) AS Gerente
FROM department d
JOIN employee e ON (d.Mgr_ssn = e.Ssn);

GRANT SELECT ON company.v_departamento_gerente TO 'gerente'@'localhost';

-- Projetos com maior numero de empregados
CREATE VIEW v_projetos_funcionarios AS
SELECT p.Pname AS Nome_Projeto, COUNT(e.Ssn) as total_de_funcionarios from project p
JOIN employee e ON (e.Dno = p.Dnum)
GROUP BY Pname ORDER BY total_de_funcionarios DESC;

GRANT SELECT ON company.v_projetos_funcionarios TO 'gerente'@'localhost';

-- Lista projeto, departamentos e gerentes
CREATE VIEW v_relatorio_projetos AS
SELECT p.Pname AS Projeto, d.Dname AS Departamento,  CONCAT(e.Fname," ", e.Minit,". ", e.Lname) AS Gerente
FROM project p
JOIN department d ON (p.Dnum = d.Dnumber)
JOIN employee e ON (e.Ssn = d.Mgr_ssn);

GRANT SELECT ON company.v_relatorio_projetos TO 'gerente'@'localhost';

-- quais empregados possuem dependentes e se são gerentes
CREATE VIEW v_funcionarios_dependents AS
SELECT
	 CONCAT(e.Fname," ", e.Minit,". ", e.Lname) AS Funcionario,
    CASE
        WHEN de.Mgr_ssn = e.Ssn THEN 'SIM'
        WHEN de.Mgr_ssn <> e.Ssn THEN 'NÃO'
    END AS Gerente
FROM
    dependent d
JOIN
    employee e ON d.Essn = e.Ssn
JOIN
    department de ON de.Mgr_ssn = d.Essn;

GRANT SELECT ON company.v_funcionarios_dependents TO 'gerente'@'localhost';
GRANT SELECT ON company.v_funcionarios_dependents TO 'funcionario'@'localhost';

USE ecommerce;
create table clientesDeletados(
id int not null auto_increment primary key,
cpf varchar(11),
cnpj varchar(20)
);

DELIMITER //
CREATE TRIGGER delete_clientes
BEFORE DELETE ON cliente
FOR EACH ROW
BEGIN
    DECLARE cpf_var VARCHAR(11);
    DECLARE cnpj_var VARCHAR(20);
    
    SELECT cpf, cnpj INTO cpf_var, cnpj_var
    FROM pessoa WHERE idPessoa = OLD.CodPessoa;
    
    INSERT INTO clientesDeletados (cpf, cnpj) VALUES (cpf_var, cnpj_var);
END;
//
DELIMITER ;
