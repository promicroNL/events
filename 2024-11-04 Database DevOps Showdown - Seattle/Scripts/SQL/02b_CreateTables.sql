SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[Arenas]'
GO
CREATE TABLE [dbo].[Arenas]
(
[ArenaID] [int] NOT NULL IDENTITY(1, 1),
[ArenaName] [nvarchar] (100) NULL,
[Location] [nvarchar] (100) NULL,
[Capacity] [int] NULL
)
GO
PRINT N'Creating primary key [PK__Arenas] on [dbo].[Arenas]'
GO
ALTER TABLE [dbo].[Arenas] ADD CONSTRAINT [PK__Arenas] PRIMARY KEY CLUSTERED ([ArenaID])
GO
PRINT N'Creating [dbo].[Games]'
GO
CREATE TABLE [dbo].[Games]
(
[GameID] [int] NOT NULL IDENTITY(1, 1),
[GameDate] [date] NULL,
[ArenaID] [int] NULL,
[MainEvent] [nvarchar] (100) NULL
)
GO
PRINT N'Creating primary key [PK__Games] on [dbo].[Games]'
GO
ALTER TABLE [dbo].[Games] ADD CONSTRAINT [PK__Games] PRIMARY KEY CLUSTERED ([GameID])
GO
PRINT N'Creating [dbo].[Results]'
GO
CREATE TABLE [dbo].[Results]
(
[ResultID] [int] NOT NULL IDENTITY(1, 1),
[GameID] [int] NULL,
[WinnerID] [int] NULL,
[LoserID] [int] NULL,
[WinningMethod] [nvarchar] (20) NULL,
[Round] [int] NULL,
[Time] [time] NULL
)
GO
PRINT N'Creating primary key [PK__Results] on [dbo].[Results]'
GO
ALTER TABLE [dbo].[Results] ADD CONSTRAINT [PK__Results] PRIMARY KEY CLUSTERED ([ResultID])
GO
PRINT N'Creating [dbo].[Boxers]'
GO
CREATE TABLE [dbo].[Boxers]
(
[BoxerID] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [nvarchar] (50) NULL,
[LastName] [nvarchar] (50) NULL,
[Nationality] [nvarchar] (50) NULL,
[BirthDate] [date] NULL,
[Stance] [nvarchar] (20) NULL,
[WeightClass] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK__Boxers] on [dbo].[Boxers]'
GO
ALTER TABLE [dbo].[Boxers] ADD CONSTRAINT [PK__Boxers] PRIMARY KEY CLUSTERED ([BoxerID])
GO
PRINT N'Adding foreign keys to [dbo].[Games]'
GO
ALTER TABLE [dbo].[Games] ADD CONSTRAINT [FK__Games__ArenaID] FOREIGN KEY ([ArenaID]) REFERENCES [dbo].[Arenas] ([ArenaID])
GO
PRINT N'Adding foreign keys to [dbo].[Results]'
GO
ALTER TABLE [dbo].[Results] ADD CONSTRAINT [FK__Results__LoserID] FOREIGN KEY ([LoserID]) REFERENCES [dbo].[Boxers] ([BoxerID])
GO
ALTER TABLE [dbo].[Results] ADD CONSTRAINT [FK__Results__WinnerI] FOREIGN KEY ([WinnerID]) REFERENCES [dbo].[Boxers] ([BoxerID])
GO
ALTER TABLE [dbo].[Results] ADD CONSTRAINT [FK__Results__GameID] FOREIGN KEY ([GameID]) REFERENCES [dbo].[Games] ([GameID])
GO

