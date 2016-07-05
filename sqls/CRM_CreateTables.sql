USE [CRM]
GO

/****** Object:  Table [dbo].[product_user]    Script Date: 07/05/2016 16:53:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[product_user](
	[id_product] [int] NULL,
	[id_user] [int] NULL,
	[id_user_remote] [int] NULL,
	[user_email] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[product_user]  WITH CHECK ADD  CONSTRAINT [FK_product_user_product] FOREIGN KEY([id_product])
REFERENCES [dbo].[product] ([id_product])
GO

ALTER TABLE [dbo].[product_user] CHECK CONSTRAINT [FK_product_user_product]
GO

ALTER TABLE [dbo].[product_user]  WITH CHECK ADD  CONSTRAINT [FK_product_user_user] FOREIGN KEY([id_user])
REFERENCES [dbo].[user] ([id_user])
GO

ALTER TABLE [dbo].[product_user] CHECK CONSTRAINT [FK_product_user_user]
GO



/****** Object:  Table [dbo].[state]    Script Date: 07/05/2016 16:54:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[state](
	[state_id] [int] IDENTITY(1,1) NOT NULL,
	[state_name] [varchar](80) NOT NULL,
	[state_code] [varchar](50) NOT NULL,
	[state_is_base] [bit] NOT NULL,
	[product_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[state_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Table [dbo].[state_transition]    Script Date: 07/05/2016 16:55:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[state_transition](
	[state_transition_id] [int] IDENTITY(1,1) NOT NULL,
	[state_transition_from] [int] NOT NULL,
	[state_transition_to] [int] NOT NULL,
	[state_transition_default] [bit] NOT NULL,
	[id_product] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[state_transition_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[state_transition]  WITH CHECK ADD  CONSTRAINT [FK_state_transition_product] FOREIGN KEY([id_product])
REFERENCES [dbo].[product] ([id_product])
GO

ALTER TABLE [dbo].[state_transition] CHECK CONSTRAINT [FK_state_transition_product]
GO


/****** Object:  Table [dbo].[state_current]    Script Date: 07/05/2016 16:55:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[state_current](
	[state_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[state_date] [datetime] NOT NULL,
	[state_end_date] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[state_current]  WITH CHECK ADD  CONSTRAINT [FK_state_current_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([id_product])
GO

ALTER TABLE [dbo].[state_current] CHECK CONSTRAINT [FK_state_current_product]
GO

ALTER TABLE [dbo].[state_current]  WITH CHECK ADD  CONSTRAINT [FK_state_current_state] FOREIGN KEY([state_id])
REFERENCES [dbo].[state] ([state_id])
GO

ALTER TABLE [dbo].[state_current] CHECK CONSTRAINT [FK_state_current_state]
GO

ALTER TABLE [dbo].[state_current]  WITH CHECK ADD  CONSTRAINT [FK_state_current_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id_user])
GO

ALTER TABLE [dbo].[state_current] CHECK CONSTRAINT [FK_state_current_user]
GO



/****** Object:  Table [dbo].[state_log]    Script Date: 07/05/2016 16:56:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[state_log](
	[state_log_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[state_id] [int] NOT NULL,
	[state_id_prev] [int] NULL,
	[state_name] [varchar](50) NOT NULL,
	[state_date] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[state_log_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO






