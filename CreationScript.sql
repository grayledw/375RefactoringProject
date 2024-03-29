USE [master]
GO
/****** Object:  Database [TestDatabase]    Script Date: 4/29/2021 10:31:46 AM ******/
CREATE DATABASE [TestDatabase]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TestDatabase', FILENAME = N'/var/opt/mssql/data/TestDatabase.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TestDatabase_log', FILENAME = N'/var/opt/mssql/data/TestDatabase_log.ldf' , SIZE = 335872KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [TestDatabase] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TestDatabase].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TestDatabase] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TestDatabase] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TestDatabase] SET ARITHABORT OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TestDatabase] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TestDatabase] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TestDatabase] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TestDatabase] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TestDatabase] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TestDatabase] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TestDatabase] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TestDatabase] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TestDatabase] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TestDatabase] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TestDatabase] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TestDatabase] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TestDatabase] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TestDatabase] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TestDatabase] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TestDatabase] SET RECOVERY FULL 
GO
ALTER DATABASE [TestDatabase] SET  MULTI_USER 
GO
ALTER DATABASE [TestDatabase] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TestDatabase] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TestDatabase] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TestDatabase] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TestDatabase] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TestDatabase] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'TestDatabase', N'ON'
GO
ALTER DATABASE [TestDatabase] SET QUERY_STORE = OFF
GO
USE [TestDatabase]
GO
/****** Object:  Table [dbo].[Game]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Game](
	[GameID] [int] IDENTITY(1,1) NOT NULL,
	[SeasonID] [int] NOT NULL,
 CONSTRAINT [PK__Game__2AB897DDED6E1FEB] PRIMARY KEY CLUSTERED 
(
	[GameID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Plays_A]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Plays_A](
	[GameID] [int] NOT NULL,
	[Name] [varchar](30) NOT NULL,
	[GmPointsFor] [int] NULL,
	[GmPointsAgainst] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WinView]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[WinView] as
select Name, SeasonID, Plays_A.GameID,
case
	when GmPointsFor > GmPointsAgainst then 100
	when GmPointsFor < GmPointsAgainst then 0
end as Win
from Plays_A join Game on Plays_A.GameID = Game.GameID
GO
/****** Object:  Table [dbo].[Plays_In]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Plays_In](
	[PlayerID] [int] NOT NULL,
	[GameID] [int] NOT NULL,
	[GamePoints] [int] NULL,
	[GameAssists] [int] NULL,
	[GameRebounds] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PlayerCareerView]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[PlayerCareerView] as
select PlayerID, Cast(AVG(GamePoints) as float) as CareerPoints, Cast(AVG(GameAssists) as float) as CareerAssists, Cast(AVG(GameRebounds) as float) as CareerRebounds
from Plays_In join Game on Plays_In.GameID = Game.GameID
Group By PlayerID
GO
/****** Object:  View [dbo].[PlayerSeasonView]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[PlayerSeasonView] as
select PlayerID, SeasonID, Cast(AVG(GamePoints) as float) as SeasonPoints, Cast(AVG(GameAssists) as float) as SeasonAssists, Cast(AVG(GameRebounds) as float) as SeasonRebounds
from Plays_In join Game on Plays_In.GameID = Game.GameID
Group By SeasonID, PlayerID
GO
/****** Object:  View [dbo].[TeamFranchiseView]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[TeamFranchiseView] as
select Plays_A.Name, Cast(AVG(GmPointsFor) as float) as FranchisePtsFor, Cast(AVG(GmPointsAgainst) as float) as FranchisePtsAgainst, Cast(AVG(Win) as float) as WinPercentage
from Plays_A join WinView on Plays_A.Name = WinView.Name
Group By Plays_A.Name
GO
/****** Object:  View [dbo].[TeamSeasonView]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[TeamSeasonView] as
select Plays_A.Name, Game.SeasonID, Cast(AVG(GmPointsFor) as float) as SeasonPtsFor, Cast(AVG(GmPointsAgainst) as float) as SeasonPtsAgainst, SUM(Win)/COUNT(WIN) as WinPercentage
from Plays_A join Game on Plays_A.GameID = Game.GameID
	join WinView on Plays_A.GameID = WinView.GameID
where Plays_A.Name != WinView.Name
Group By Plays_A.Name, Game.SeasonID
GO
/****** Object:  Table [dbo].[On_A]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[On_A](
	[PlayerID] [int] NOT NULL,
	[Name] [varchar](30) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Player]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Player](
	[PlayerID] [int] IDENTITY(1,1) NOT NULL,
	[FName] [varchar](20) NOT NULL,
	[LName] [varchar](20) NOT NULL,
 CONSTRAINT [PK__Player__4A4E74A8261BE0F5] PRIMARY KEY CLUSTERED 
(
	[PlayerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Season]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Season](
	[SeasonID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [char](4) NULL,
 CONSTRAINT [PK__Season__C1814E18E5294986] PRIMARY KEY CLUSTERED 
(
	[SeasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Team]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Team](
	[Name] [varchar](30) NOT NULL,
 CONSTRAINT [PK__Team__737584F7A92F754D] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[On_A]  WITH NOCHECK ADD  CONSTRAINT [fk_On_A_Name] FOREIGN KEY([Name])
REFERENCES [dbo].[Team] ([Name])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[On_A] CHECK CONSTRAINT [fk_On_A_Name]
GO
ALTER TABLE [dbo].[On_A]  WITH NOCHECK ADD  CONSTRAINT [fk_On_A_PlayerID] FOREIGN KEY([PlayerID])
REFERENCES [dbo].[Player] ([PlayerID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[On_A] CHECK CONSTRAINT [fk_On_A_PlayerID]
GO
ALTER TABLE [dbo].[Plays_A]  WITH NOCHECK ADD  CONSTRAINT [FK_Plays_A_Game] FOREIGN KEY([GameID])
REFERENCES [dbo].[Game] ([GameID])
GO
ALTER TABLE [dbo].[Plays_A] CHECK CONSTRAINT [FK_Plays_A_Game]
GO
ALTER TABLE [dbo].[Plays_A]  WITH NOCHECK ADD  CONSTRAINT [FK_Plays_A_Team] FOREIGN KEY([Name])
REFERENCES [dbo].[Team] ([Name])
GO
ALTER TABLE [dbo].[Plays_A] CHECK CONSTRAINT [FK_Plays_A_Team]
GO
ALTER TABLE [dbo].[Plays_In]  WITH NOCHECK ADD  CONSTRAINT [FK__Plays_In__GameID__2C3393D0] FOREIGN KEY([GameID])
REFERENCES [dbo].[Game] ([GameID])
GO
ALTER TABLE [dbo].[Plays_In] CHECK CONSTRAINT [FK__Plays_In__GameID__2C3393D0]
GO
ALTER TABLE [dbo].[Plays_In]  WITH NOCHECK ADD  CONSTRAINT [FK__Plays_In__Player__2D27B809] FOREIGN KEY([PlayerID])
REFERENCES [dbo].[Player] ([PlayerID])
GO
ALTER TABLE [dbo].[Plays_In] CHECK CONSTRAINT [FK__Plays_In__Player__2D27B809]
GO
ALTER TABLE [dbo].[Plays_A]  WITH CHECK ADD  CONSTRAINT [CK__Plays_A__GmPoint__2F10007B] CHECK  (([GmPointsFor]>=(0)))
GO
ALTER TABLE [dbo].[Plays_A] CHECK CONSTRAINT [CK__Plays_A__GmPoint__2F10007B]
GO
ALTER TABLE [dbo].[Plays_A]  WITH CHECK ADD  CONSTRAINT [CK__Plays_A__GmPoint__300424B4] CHECK  (([GmPointsAgainst]>=(0)))
GO
ALTER TABLE [dbo].[Plays_A] CHECK CONSTRAINT [CK__Plays_A__GmPoint__300424B4]
GO
ALTER TABLE [dbo].[Plays_In]  WITH CHECK ADD  CONSTRAINT [CK__Plays_In__GameAs__2A4B4B5E] CHECK  (([GameAssists]>=(0)))
GO
ALTER TABLE [dbo].[Plays_In] CHECK CONSTRAINT [CK__Plays_In__GameAs__2A4B4B5E]
GO
ALTER TABLE [dbo].[Plays_In]  WITH CHECK ADD  CONSTRAINT [CK__Plays_In__GamePo__29572725] CHECK  (([GamePoints]>=(0)))
GO
ALTER TABLE [dbo].[Plays_In] CHECK CONSTRAINT [CK__Plays_In__GamePo__29572725]
GO
ALTER TABLE [dbo].[Plays_In]  WITH CHECK ADD  CONSTRAINT [CK__Plays_In__GameRe__2B3F6F97] CHECK  (([GameRebounds]>=(0)))
GO
ALTER TABLE [dbo].[Plays_In] CHECK CONSTRAINT [CK__Plays_In__GameRe__2B3F6F97]
GO
ALTER TABLE [dbo].[Season]  WITH CHECK ADD  CONSTRAINT [CK__Season__Year__15502E78] CHECK  (([Year] like '[0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Season] CHECK CONSTRAINT [CK__Season__Year__15502E78]
GO
/****** Object:  StoredProcedure [dbo].[insertData]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[insertData](
@FName varchar(20),
@LName varchar(20),
@Team_Name varchar(30),
@OppTeam_Name varchar(30),
@GamePoints int,
@GameAssists int,
@GameRebounds int,
@GmPointsFor int,
@GmPointsAgainst int,
@Year int) as
	if (@Team_Name is null or @OppTeam_Name is null or @Year is null or @FName is null or @LName is null)
	begin
		raiserror('You have entered incorrect data', 15, 1)
		return
	end
	-----------
	if @Team_Name not in (select Name from Team)
	begin
		insert into Team(Name)
		values(@Team_Name)
	end
	if @OppTeam_Name not in (select Name from Team)
	begin
		insert into Team(Name)
		values(@OppTeam_Name)
	end
	-----------
	declare @seasonID int
	set @seasonID = (select seasonID from season where Year = @year)
	if (@seasonID is null)
	begin
		insert into Season(Year)
		values(@Year)
		set @seasonID = (select max(SeasonID) from Season)
	end
	-----------
	insert into Game(SeasonID)
	values(@seasonID)
	-----------
	declare @gameID int
	set @gameID = (select max(GameID) from Game)
	-----------
	insert into Plays_A(GameID, Name, GmPointsFor, GmPointsAgainst)
	values(@gameID, @Team_Name, @GmPointsFor, @GmPointsAgainst),
	(@gameID, @OppTeam_Name, @GmPointsAgainst, @GmPointsFor)
	-----------
	declare @playerID int
	set @playerID = (select PlayerID from Player where FName = @FName and LName = @LName)
	if (@playerID is null)
	begin
		insert into Player(FName, LName)
		values(@FName, @LName)
		set @playerID = (select max(PlayerID) from Player)
	end
	-----------
	insert into Plays_In(PlayerID, GameID, GamePoints, GameAssists, GameRebounds)
	values(@playerID, @gameID, @GamePoints, @GameAssists, @GameRebounds)
	-----------
	if @playerID not in (select PlayerID from On_A)
	begin
		insert into On_A(PlayerID, Name)
		values(@playerID, @Team_Name)
	end
	----------
GO
/****** Object:  StoredProcedure [dbo].[player_game_data]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[player_game_data](
@F_Name varchar(20),
@L_Name varchar(20),
@GameID int) as
IF @F_Name not in (select Player.FName
				from Player)
BEGIN
	RAISERROR('Invalid first name entered, please try again',14,1)
	RETURN
END
IF @L_Name not in (select Player.LName
				from Player)
BEGIN
	RAISERROR('Invalid last name entered, please try again',14,1)
	RETURN
END
IF @GameID not in (select GameID from Game)
BEGIN
	RAISERROR('Game does not exists', 15, 1)
	RETURN
END
select GamePoints, GameAssists, GameRebounds
from Game join Plays_In on Game.GameID = Plays_In.GameID
	join Player on Plays_In.PlayerID = Player.PlayerID
where @GameID = Game.GameID and @F_Name = Player.FName and @L_Name = Player.LName
GO
/****** Object:  StoredProcedure [dbo].[player_season_data]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[player_season_data](
@F_Name varchar(20),
@L_Name varchar(20),
@Year int) as
IF @F_Name not in (select Player.FName
				from Player)
BEGIN
	RAISERROR('Invalid first name entered, please try again',14,1)
	RETURN
END
IF @L_Name not in (select Player.LName
				from Player)
BEGIN
	RAISERROR('Invalid last name entered, please try again',14,1)
	RETURN
END
if @Year not in (select Year from Season)
BEGIN
	RAISERROR('Season does not exists', 14, 1)
	RETURN
END
select SeasonPoints, SeasonAssists, SeasonRebounds
from Season join PlayerSeasonView on Season.SeasonID = PlayerSeasonView.SeasonID
	join Player on PlayerSeasonView.PlayerID = Player.PlayerID
where @Year = Season.Year and @F_Name = Player.FName and @L_Name = Player.LName
GO
/****** Object:  StoredProcedure [dbo].[team_game_data]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[team_game_data](
@Team_Name varchar(30),
@SeasonYear int,
@GameID int)
as
IF @Team_Name not in (select [Name] from Team)
BEGIN
	RAISERROR('Invalid team name entered, please try again',14,1)
	RETURN
END
select GmPointsFor, GmPointsAgainst
from Team join Plays_A on Team.Name = Plays_A.Name
	join Game on Game.GameID = Plays_A.GameID
where @Team_Name = Team.Name and Game.GameID = @GameID
GO
/****** Object:  StoredProcedure [dbo].[team_season_data]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[team_season_data](
@Team_Name varchar(30),
@Year int)
as
IF @Team_Name not in (select [Name] from Team)
BEGIN
	RAISERROR('Invalid team name entered, please try again',14,1)
	RETURN
END
select SeasonPtsFor, SeasonPtsAgainst, WinPercentage
from TeamSeasonView join Season on Season.SeasonID = TeamSeasonView.SeasonID
where Name = @Team_Name and Year = @Year
GO
/****** Object:  StoredProcedure [dbo].[view_player_career]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[view_player_career](
@F_Name varchar(20),
@L_Name varchar(20))
AS
IF @F_Name not in (select Player.FName
				from Player)
BEGIN
	RAISERROR('Invalid first name entered, please try again',14,1)
	RETURN
END
IF @L_Name not in (select Player.LName
				from Player)
BEGIN
	RAISERROR('Invalid last name entered, please try again',14,1)
	RETURN
END
Select Player.FName, Player.LName, CareerPoints, CareerAssists, CareerRebounds
from Player join PlayerCareerView on Player.PlayerID = PlayerCareerView.PlayerID
where Player.FName = @F_Name and Player.LName = @L_Name
GO
/****** Object:  StoredProcedure [dbo].[view_player_game]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[view_player_game](
@F_Name varchar(20),
@L_Name varchar(20),
@Year [int])
AS
IF @F_Name not in (select Player.FName
				from Player)
BEGIN
	RAISERROR('Invalid first name entered, please try again',14,1)
	RETURN
END
IF @L_Name not in (select Player.LName
				from Player)
BEGIN
	RAISERROR('Invalid last name entered, please try again',14,1)
	RETURN
END
IF @Year not in (select Season.[Year]
				from Season)
BEGIN
	RAISERROR('Invalid year entered, please try again',14,1)
	RETURN
END
Select Player.FName, Player.LName, On_A.[Name] as Team, Team2.Name as OpposingTeam, Plays_In.GameID
from Player join Plays_In on Player.PlayerID = Plays_In.PlayerID
	join Game on Plays_In.GameID = Game.GameID
	join Season on Game.SeasonID = Season.SeasonID
	join Plays_A as Team2 on Team2.GameID = Plays_In.GameID
	join On_A on On_A.PlayerID = Player.PlayerID
where Player.FName = @F_Name and Player.LName = @L_Name and Season.[Year] = @Year and Team2.[Name] != On_A.Name
GO
/****** Object:  StoredProcedure [dbo].[view_player_season]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[view_player_season](
@F_Name varchar(20),
@L_Name varchar(20))
AS
IF @F_Name not in (select Player.FName
				from Player)
BEGIN
	RAISERROR('Invalid first name entered, please try again',14,1)
	RETURN
END
IF @L_Name not in (select Player.LName
				from Player)
BEGIN
	RAISERROR('Invalid last name entered, please try again',14,1)
	RETURN
END
Select Season.[Year]
from Player join PlayerSeasonView on Player.PlayerID = PlayerSeasonView.PlayerID
	join Season on PlayerSeasonView.SeasonID = Season.SeasonID
where Player.FName = @F_Name and Player.LName = @L_Name
group by Season.[Year]
GO
/****** Object:  StoredProcedure [dbo].[view_team_franchise]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[view_team_franchise](
@Team_Name varchar(30))
AS
IF @Team_Name not in (select [Name]
				from Team)
BEGIN
	RAISERROR('Invalid team name entered, please try again',14,1)
	RETURN
END
Select Name, FranchisePtsFor, FranchisePtsAgainst, WinPercentage
from TeamFranchiseView
where Name = @Team_Name
GO
/****** Object:  StoredProcedure [dbo].[view_team_game]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[view_team_game](
@Team_Name varchar(30),
@Year int)
AS
IF @Team_Name not in (select [Name]
				from Team)
BEGIN
	RAISERROR('Invalid team name entered, please try again',14,1)
	RETURN
END
IF @Year not in (select [Year]
				from Season)
BEGIN
	RAISERROR('Invalid year entered, please try again',14,1)
	RETURN
END
Select Team.Name, OppTeam.Name, Plays_A.GmPointsFor, Plays_A.GmPointsAgainst, Game.GameID
from Team join Plays_A on Team.Name = Plays_A.Name
	join Game on Game.GameID = Plays_A.GameID
	join Season on Game.SeasonID = Season.SeasonID
	join Plays_A as OppTeam on OppTeam.GameID = Game.GameID
where Team.[Name] = @Team_Name and Season.[Year] = @Year and Team.Name != OppTeam.Name
GO
/****** Object:  StoredProcedure [dbo].[view_team_season]    Script Date: 4/29/2021 10:31:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[view_team_season](
@Team_Name varchar(30))
AS
IF @Team_Name not in (select [Name]
				from Team)
BEGIN
	RAISERROR('Invalid team name entered, please try again',14,1)
	RETURN
END
Select Season.[Year]
from TeamSeasonView join Season on TeamSeasonView.SeasonID = Season.SeasonID
where TeamSeasonView.[Name] = @Team_Name
group by Season.[Year]
GO
USE [master]
GO
ALTER DATABASE [TestDatabase] SET  READ_WRITE 
GO
