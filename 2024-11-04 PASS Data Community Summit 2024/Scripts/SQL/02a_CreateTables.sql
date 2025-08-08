USE [DatabaseDevOpsShowdown]
GO

/****** Object:  Table [dbo].[Arenas]    Script Date: 17/10/2024 18:05:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Arenas](
	[ArenaID] [int] IDENTITY(1,1) NOT NULL,
	[ArenaName] [nvarchar](100) NULL,
	[Location] [nvarchar](100) NULL,
	[Capacity] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ArenaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Boxers]    Script Date: 17/10/2024 18:05:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Boxers](
	[BoxerID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Nationality] [nvarchar](50) NULL,
	[BirthDate] [date] NULL,
	[Stance] [nvarchar](20) NULL,
	[WeightClass] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[BoxerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Games]    Script Date: 17/10/2024 18:05:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Games](
	[GameID] [int] IDENTITY(1,1) NOT NULL,
	[GameDate] [date] NULL,
	[ArenaID] [int] NULL,
	[MainEvent] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[GameID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Results]    Script Date: 17/10/2024 18:05:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Results](
	[ResultID] [int] IDENTITY(1,1) NOT NULL,
	[GameID] [int] NULL,
	[WinnerID] [int] NULL,
	[LoserID] [int] NULL,
	[WinningMethod] [nvarchar](20) NULL,
	[Round] [int] NULL,
	[Time] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Games]  WITH CHECK ADD FOREIGN KEY([ArenaID])
REFERENCES [dbo].[Arenas] ([ArenaID])
GO

ALTER TABLE [dbo].[Results]  WITH CHECK ADD FOREIGN KEY([GameID])
REFERENCES [dbo].[Games] ([GameID])
GO

ALTER TABLE [dbo].[Results]  WITH CHECK ADD FOREIGN KEY([LoserID])
REFERENCES [dbo].[Boxers] ([BoxerID])
GO

ALTER TABLE [dbo].[Results]  WITH CHECK ADD FOREIGN KEY([WinnerID])
REFERENCES [dbo].[Boxers] ([BoxerID])
GO

