CREATE TABLESPACE COMPANY_SAIQDATA
DATAFILE 'company_saiqdata.dbf'
SIZE 150M
OFFLINE;




alter session set "_ORACLE_SCRIPT"=true;
CREATE ROLE manager_role;
GRANT CREATE SESSION,
      CREATE ANY TABLE, 
      CREATE VIEW,
      CREATE TRIGGER,
      CREATE PROCEDURE,
      DROP ANY TABLE,
      DROP ANY VIEW,
      DROP ANY PROCEDURE TO manager_role;    
COMMIT;
GRANT CREATE PROCEDURE TO manager_role;
GRANT ALTER ANY TABLE TO manager_role;
GRANT CREATE TABLE TO manager_role;
GRANT CREATE SEQUENCE TO manager_role;
GRANT ALTER TABLE TO manager_role;
GRANT SELECT any sequence TO manager_role;
--создание профиля менеджера
CREATE PROFILE manager_profile LIMIT
    PASSWORD_LIFE_TIME 180      --кол-во дней жизни пароля
    SESSIONS_PER_USER 3         --кол-во сессий для юзера
    FAILED_LOGIN_ATTEMPTS 7     --кол-во попыток ввода
    PASSWORD_LOCK_TIME 1        --кол-во дней блока после ошибок
    PASSWORD_REUSE_TIME 10      --через скок дней можно повторить пароль
    PASSWORD_GRACE_TIME DEFAULT --кол-во дней предупрежд.о смене пароля
    CONNECT_TIME 180            --время соед (мин)
    IDLE_TIME 30 ;              --кол-во мин простоя 
    
    
--создание пользователя Менеджер
CREATE USER COMPANY_MANAGER IDENTIFIED BY 123
DEFAULT TABLESPACE COMPANY_SAIQDATA QUOTA UNLIMITED ON COMPANY_SAIQDATA
PROFILE  manager_profile
ACCOUNT UNLOCK;
---выделяем квоту для пользователя менеджер

GRANT manager_role TO COMPANY_MANAGER;
ALTER USER COMPANY_MANAGER QUOTA 100M ON COMPANY_SAIQDATA;
alter tablespace COMPANY_SAIQDATA Online;