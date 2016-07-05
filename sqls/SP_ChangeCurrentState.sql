USE [CRM]
GO

/****** Object:  StoredProcedure [dbo].[ChangeCurrentState]    Script Date: 07/05/2016 16:58:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ChangeCurrentState]
	@UserIdRemote int,
	@ProductId int, 
    @StateCode nvarchar(50),
	@EndDate datetime   
AS   
BEGIN
	DECLARE @CrmUserId INT;
	DECLARE @StateId INT;
	DECLARE @StateName nvarchar(80);
	DECLARE @CurrentStateId INT;
	DECLARE @TransitionExist INT;

	-- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- SEARCH FOR CRM_USER_ID FROM REMOTE USER ID AND PRODUCT_ID
	SELECT @CrmUserId = id_user
		FROM product_user
		WHERE product_user.id_user_remote=@UserIdRemote AND product_user.id_product=@ProductId;

	-- SEARCH FOR NEW_STATE_ID FROM STATE_CODE
	SELECT @StateId = state_id, @StateName = state_name
		FROM [state]
		WHERE [state].state_code=@StateCode AND [state].product_id=@ProductId;

	-- SEARCH THE CURRENT STATE_ID IN ORDER TO VERIFY IF THE TRANSITION EXIST
	SELECT @CurrentStateId = state_id
		FROM [state_current]
		WHERE [state_current].user_id=@CrmUserId AND [state_current].product_id=@ProductId;

	-- VERIFYING IF THE TRANSTION IS POSSIBLE
	SELECT @TransitionExist = state_transition_id
		FROM state_transition
		WHERE state_transition.state_transition_from=@CurrentStateId AND state_transition.state_transition_to=@StateId;

	-- IF THE USER EXIST, THE STATE CODE EXIST AND THE TRANSITION IS POSSIBLE 
	IF(@CrmUserId > 0 AND @StateId > 0 AND @TransitionExist > 0)
	BEGIN 
		-- UPDATE THE CURRENT STATE
		UPDATE [dbo].[state_current]
			SET [state_id] = @StateId
			,[state_date] = getdate()
			,[state_end_date] = @EndDate
		WHERE [user_id] = @CrmUserId AND [product_id] = @ProductId;

		-- UPDATE THE STATE LOG
		INSERT INTO [dbo].[state_log]
           ([user_id]
           ,[product_id]
           ,[state_id]
           ,[state_name]
           ,[state_date])
		VALUES
           (@CrmUserId
           ,@ProductId
           ,@StateId
           ,@StateName
           ,getdate())
	END
	ELSE
	BEGIN 
		PRINT 'ERROR: We need CrmUserId, StateId and TransitionId'  
		RETURN(1)  
	END  

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
END


GO

