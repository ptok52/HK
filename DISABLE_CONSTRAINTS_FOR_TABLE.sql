--------------------------------------------------------
--  DDL for Procedure DISABLE_CONSTRAINTS_FOR_TABLE
--------------------------------------------------------
set define off;

--dsfsdf
--sdfsdf
--   
--
--sdfdfsdf



  CREATE OR REPLACE EDITIONABLE PROCEDURE "DISABLE_CONSTRAINTS_FOR_TABLE" (p_table IN VARCHAR2) AS
BEGIN
    -- 1) Zuerst alle abhängigen Foreign Keys anderer Tabellen deaktivieren
    FOR fk_rec IN (
        SELECT r.table_name AS ref_table,
               r.constraint_name AS ref_constraint
        FROM user_constraints r
        WHERE r.constraint_type = 'R'
          AND r.r_constraint_name IN (
                SELECT constraint_name
                FROM user_constraints
                WHERE table_name = UPPER(p_table)
          )
        ORDER BY r.table_name, r.constraint_name
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE
                'ALTER TABLE ' || fk_rec.ref_table ||
                ' DISABLE CONSTRAINT ' || fk_rec.ref_constraint;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Fehler bei FK-Constraint: ' ||
                                     fk_rec.ref_constraint || ' -> ' || SQLERRM);
        END;
    END LOOP;

    -- 2) Danach alle Constraints der Tabelle selbst deaktivieren
    FOR base_rec IN (
        SELECT constraint_name
        FROM user_constraints
        WHERE table_name = UPPER(p_table)
        ORDER BY constraint_name
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE
                'ALTER TABLE ' || p_table ||
                ' DISABLE CONSTRAINT ' || base_rec.constraint_name;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Fehler bei Basis-Constraint: ' ||
                                     base_rec.constraint_name || ' -> ' || SQLERRM);
        END;
    END LOOP;
    
--Als SQL
--WITH base AS (
--    SELECT
--        c.owner,
--        c.table_name,
--        c.constraint_name,
--        c.constraint_type
--    FROM user_constraints c
--    WHERE c.table_name = UPPER('&TABLE_NAME')
--),
--refs AS (
--    SELECT
--        r.owner,
--        r.table_name,
--        r.constraint_name,
--        r.constraint_type,
--        r.r_constraint_name
--    FROM user_constraints r
--    WHERE r.constraint_type = 'R'
--      AND r.r_constraint_name IN (
--            SELECT constraint_name FROM base
--      )
--)
--SELECT
--    'ALTER TABLE ' || r.table_name ||
--    ' DISABLE CONSTRAINT ' || r.constraint_name || ';' AS disable_stmt,
--    1 AS sort_order
--FROM refs r
--
--UNION ALL
--
--SELECT
--    'ALTER TABLE ' || b.table_name ||
--    ' DISABLE CONSTRAINT ' || b.constraint_name || ';' AS disable_stmt,
--    2 AS sort_order
--FROM base b
--
--ORDER BY sort_order, disable_stmt;
--/
END;
