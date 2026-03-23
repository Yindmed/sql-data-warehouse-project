/* ============================================================
  Store Procedure: Load Bronze Layer (Soruec -> Bronze)
   ============================================================
   This stored procedure loads data into the Bronze layer tables 
   from source CSV files.

   It performs a full reload by:
     - Truncating existing tables
     - Bulk inserting raw data

   This ensures that the Bronze layer always reflects the latest 
   data from CRM and ERP source systems.

   The procedure acts as the entry point of the ETL process, 
   enabling consistent and automated data ingestion.

   USAGE EXAMPLE
   -- Execute the procedure to load all Bronze tables
   EXEC bronze.load_bronze;
   ============================================================ */

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Variables para medir tiempo por tabla y del proceso completo
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        -- Inicio de la carga completa de la capa Bronze
        SET @batch_start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer';
        PRINT '==========================================';

        PRINT '------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------';

        -- ==========================================
        -- Tabla: bronze.crm_cust_info
        -- Se vacía completamente y se recarga desde el CSV
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting the Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,          -- Omite la cabecera del CSV
            FIELDTERMINATOR = ',', -- Separador de columnas
            TABLOCK                -- Mejora rendimiento en cargas masivas
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        -- ==========================================
        -- Tabla: bronze.crm_prd_info
        -- Carga completa de productos desde archivo fuente
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting the Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        -- ==========================================
        -- Tabla: bronze.crm_sales_details
        -- Carga completa del detalle de ventas
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting the Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        PRINT '------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------';

        -- ==========================================
        -- Tabla: bronze.erp_loc_a101
        -- Carga datos de localización desde ERP
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting the Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        -- ==========================================
        -- Tabla: bronze.erp_cust_az12
        -- Carga datos de clientes procedentes del ERP
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting the Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        -- ==========================================
        -- Tabla: bronze.erp_px_cat_g1v2
        -- Carga categorías/productos desde ERP
        -- ==========================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting the Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\yindr\Downloads\DWH_PROJECT\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ------------------';

        -- Fin del proceso completo Bronze
        SET @batch_end_time = GETDATE();

        PRINT '=========================================';
        PRINT 'LOADING BRONZE LAYER COMPLETED';
        PRINT '  - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=========================================';
    END TRY

    BEGIN CATCH
        -- Captura y muestra información básica del error
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END;
GO

-- Ejecuta el procedimiento para cargar toda la capa Bronze
EXEC bronze.load_bronze;
