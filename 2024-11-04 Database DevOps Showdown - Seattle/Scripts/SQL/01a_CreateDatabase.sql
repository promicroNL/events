USE [master]
GO

/****** Object:  Database [DatabaseDevOpsShowdown]    Script Date: 17/10/2024 17:04:56 ******/
CREATE DATABASE [DatabaseDevOpsShowdown]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DatabaseDevOpsShowdown', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\DatabaseDevOpsShowdown.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DatabaseDevOpsShowdown_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\DatabaseDevOpsShowdown_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DatabaseDevOpsShowdown].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ARITHABORT OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET  DISABLE_BROKER 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET  MULTI_USER 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET DB_CHAINING OFF 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET QUERY_STORE = OFF
GO

ALTER DATABASE [DatabaseDevOpsShowdown] SET  READ_WRITE 
GO


