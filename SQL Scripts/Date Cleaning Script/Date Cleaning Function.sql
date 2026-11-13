-- =====================================================================
-- SILVER LAYER | DATE PARSING FUNCTION
-- Function: silver.parse_date()
-- Purpose: Parse and standardise inconsistent source date values.
-- Output:  DATE (displayed as YYYY-MM-DD)
-- Handles: Multiple separators, timestamps, month names and abbreviations.
-- =====================================================================

CREATE OR REPLACE FUNCTION silver.parse_date(p_date TEXT)
RETURNS DATE
LANGUAGE plpgsql
AS $$
DECLARE
    v_date  TEXT;
    v_parts TEXT[];
    v_day   INT;
    v_month INT;
    v_year  INT;
    v_month_name TEXT;
    v_result DATE;
BEGIN

    -- 1. Handle NULL, blank and common missing-value indicators
    IF p_date IS NULL OR BTRIM(p_date) = '' THEN
        RETURN NULL;
    END IF;

    v_date := BTRIM(p_date);

    IF LOWER(v_date) IN (
        'na', 'n/a', 'null', 'none', 'unknown',
        'not-a-date', '-', '?'
    ) THEN
        RETURN NULL;
    END IF;

    -- 2. Remove a time component from timestamps
    v_date := REGEXP_REPLACE(
        v_date,
        '[ T]\d{2}:\d{2}(:\d{2}(\.\d+)?)?([+-]\d{2}(:?\d{2})?)?$',
        ''
    );

    v_date := BTRIM(v_date);

    -- 3. Handle year-first formats:
    --    YYYY-MM-DD, YYYY/MM/DD, YYYY.MM.DD
    IF v_date ~ '^\d{4}[-/.]\d{1,2}[-/.]\d{1,2}$' THEN

        v_parts := REGEXP_SPLIT_TO_ARRAY(v_date, '[-/.]');

        v_year  := v_parts[1]::INT;
        v_month := v_parts[2]::INT;
        v_day   := v_parts[3]::INT;

    -- 4. Handle numeric day-first / month-first formats:
    --    DD/MM/YYYY, MM/DD/YYYY, DD-MM-YYYY, etc.
    ELSIF v_date ~ '^\d{1,2}[-/.]\d{1,2}[-/.]\d{4}$' THEN

        v_parts := REGEXP_SPLIT_TO_ARRAY(v_date, '[-/.]');

        IF v_parts[1]::INT > 12 THEN
            -- First component must be the day
            v_day   := v_parts[1]::INT;
            v_month := v_parts[2]::INT;

        ELSIF v_parts[2]::INT > 12 THEN
            -- Second component must be the day
            v_month := v_parts[1]::INT;
            v_day   := v_parts[2]::INT;

        ELSE
            -- Ambiguous values default to DD/MM/YYYY
            v_day   := v_parts[1]::INT;
            v_month := v_parts[2]::INT;
        END IF;

        v_year := v_parts[3]::INT;

    -- 5. Handle dates containing month names:
    --    19 July 2022, 08-Apr-22, 18 May 2019
    ELSIF v_date ~* '^\d{1,2}[\s-]+[A-Za-z]+[\s,-]+\d{2,4}$' THEN

        v_parts := REGEXP_MATCH(
            v_date,
            '^(\d{1,2})[\s-]+([A-Za-z]+)[\s,-]+(\d{2,4})$'
        );

        v_day := v_parts[1]::INT;
        v_month_name := LOWER(LEFT(v_parts[2], 3));
        v_year := v_parts[3]::INT;

        v_month := CASE v_month_name
            WHEN 'jan' THEN 1
            WHEN 'feb' THEN 2
            WHEN 'mar' THEN 3
            WHEN 'apr' THEN 4
            WHEN 'may' THEN 5
            WHEN 'jun' THEN 6
            WHEN 'jul' THEN 7
            WHEN 'aug' THEN 8
            WHEN 'sep' THEN 9
            WHEN 'oct' THEN 10
            WHEN 'nov' THEN 11
            WHEN 'dec' THEN 12
            ELSE NULL
        END;

        -- Convert two-digit years consistently
        IF LENGTH(v_parts[3]) = 2 THEN
            IF v_year >= 70 THEN
                v_year := 1900 + v_year;
            ELSE
                v_year := 2000 + v_year;
            END IF;
        END IF;

        IF v_month IS NULL THEN
            RETURN NULL;
        END IF;

    ELSE
        -- Unsupported format
        RETURN NULL;
    END IF;

    -- 6. Validate the components and construct a real calendar date
    IF v_year NOT BETWEEN 1 AND 9999
       OR v_month NOT BETWEEN 1 AND 12
       OR v_day NOT BETWEEN 1 AND 31 THEN
        RETURN NULL;
    END IF;

    BEGIN
        v_result := MAKE_DATE(v_year, v_month, v_day);
        RETURN v_result;

    EXCEPTION
        WHEN OTHERS THEN
            -- Reject impossible dates, e.g. 31/02/2024
            RETURN NULL;
    END;

END;
$$;