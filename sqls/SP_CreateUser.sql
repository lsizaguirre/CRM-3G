USE [CRM]
GO

/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 07/05/2016 16:58:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CreateUser]
	@UserIdRemote int,
	@ProductId int,
	@Email nvarchar(255),
	@Ani nvarchar(25),
	@LastName nvarchar(50),   
	@FirstName nvarchar(50)
AS   
BEGIN -- BEGIN SP
	
	-- 1. Buscamos si existe el id_remoto en product_user
	-- En caso de que exista retornamos ERROR (1)
	DECLARE @ExisteIdRemoto INT;
    SELECT @ExisteIdRemoto = count(*)
		FROM product_user
		WHERE (product_user.id_user_remote=@UserIdRemote AND product_user.id_product=@ProductId) 
			OR (product_user.user_email=@Email AND product_user.user_email IS NOT NULL);
	IF(@ExisteIdRemoto > 0)
	BEGIN
		PRINT 'ERROR: User identified with ID or EMAIL already exist.'  
		RETURN(1)  
	END
	
	-- 1.2 Buscamos si existe el producto
	-- En caso de que no exista retornamos ERROR (4)
	DECLARE @ExisteProducto INT;
    SELECT @ExisteProducto = count(*)
		FROM product
		WHERE id_product = @ProductId;
	IF(@ExisteProducto = 0)
	BEGIN
		PRINT 'ERROR: Product doesnt exist.'  
		RETURN(4)  
	END

	-- 2. Buscamos si existe el Ani y el CrmUser de ese Ani
	DECLARE @crmUserId INT;
	DECLARE @CrmAni nvarchar(25);
	-- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	SELECT @CrmAni = ani, @CrmUserId = id_user FROM ani WHERE ani.ani=@Ani;
	-- 3. Si no existe lo insertamos Ani y User
	IF (@CrmAni IS NULL AND @CrmUserId IS NULL AND @Ani IS NOT NULL)
	BEGIN -- BEGIN IF (@CrmAni IS NULL AND @CrmUserId IS NULL)
		-- Como no existe el Ani ni el User los creamos
		-- Primero el User y luego el Ani
		-- En caso contrario (si ya existieran Ani y User) no habría necesidad de crearlos
		-- @crmUserId estaría seteado, por lo tanto continuo
		INSERT INTO [dbo].[user]
			([user_dni]
			,[user_first_name]
			,[user_last_name]
			,[user_birth_date]
			,[tmp]
			,[user_capture_date]
			,[user_email])
		VALUES
			(NULL
			,@FirstName
			,@LastName
			,NULL
			,NULL
			,getdate()
			,@Email)
		SET @crmUserId = @@IDENTITY ;

		INSERT INTO [CRM].[dbo].[ani]
			([ani]
			,[id_operator]
			,[id_user]
			,[age_id])
		VALUES
			(@Ani
			,0
			,@crmUserId
			,NULL) 
	END -- END IF (@CrmAni IS NULL AND @CrmUserId IS NULL)

	IF @@ERROR <> 0   
	BEGIN 
		PRINT 'ERROR: SQL Server Error. Pre-process'  
		RETURN(3)  
	END  

	-- 5. Si el Ani es null insertamos el User y obtenemos @crmUserId
	IF (@Ani IS NULL)
		BEGIN
			INSERT INTO [dbo].[user]
				([user_dni]
				,[user_first_name]
				,[user_last_name]
				,[user_birth_date]
				,[tmp]
				,[user_capture_date]
				,[user_email])
			VALUES
				(NULL
				,@FirstName
				,@LastName
				,NULL
				,NULL
				,getdate()
				,@Email)
			SET @crmUserId = @@IDENTITY ;
		END
	ELSE
		BEGIN
		--Tengo que verificar que @CrmUserId que obtuve por @Ani no este en product_user
		DECLARE @ExisteCrmUser INT;
		SELECT @ExisteCrmUser = count(*)
			FROM product_user
			WHERE (product_user.id_user=@CrmUserId);
		IF(@ExisteCrmUser > 0)
		BEGIN
			PRINT 'ERROR: User identified with ANI already exist.'  
			RETURN(5)  
		END
	END

	--Siempre hará esto 
	INSERT INTO [dbo].[product_user]
		([id_product]
		,[id_user]
		,[id_user_remote]
		,[user_email])
	VALUES
		(@ProductId
		,@crmUserId
		,@UserIdRemote
		,@Email);

	DECLARE @DefaultStateId INT;
	DECLARE @DefaultStateName nvarchar(80);
	SELECT @DefaultStateId = [state_id], @DefaultStateName = [state_name]
		FROM [CRM].[dbo].[state]
		WHERE [product_id] = @ProductId AND [state_is_base] = 1;

	INSERT INTO [dbo].[state_current]
		([state_id]
		,[user_id]
		,[product_id]
		,[state_date]
		,[state_end_date])
	VALUES
		(@DefaultStateId
		,@crmUserId
		,@ProductId
		,getdate()
		,NULL);

	-- UPDATE THE STATE LOG
	INSERT INTO [dbo].[state_log]
        ([user_id]
        ,[product_id]
        ,[state_id]
        ,[state_id_prev]
        ,[state_name]
        ,[state_date])
	VALUES
        (@CrmUserId
        ,@ProductId
        ,@DefaultStateId
        ,NULL
        ,@DefaultStateName
        ,getdate())
	
	IF @@ERROR <> 0   
	BEGIN 
		PRINT 'ERROR: SQL Server Error'  
		RETURN(2)  
	END  
	ELSE  
	BEGIN  
		-- SUCCESS!!  
        RETURN(0)  
	END  
END -- END SP


GO

