USE [master]
GO
/****** Object:  Database [PowerShellServerInventory]    Script Date: 2015-07-22 09:12:22 ******/
CREATE DATABASE [PowerShellServerInventory]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PowerShellServerInventory', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\PowerShellServerInventory.mdf' , SIZE = 14336KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'PowerShellServerInventory_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\PowerShellServerInventory_log.ldf' , SIZE = 16576KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [PowerShellServerInventory] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PowerShellServerInventory].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PowerShellServerInventory] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET ARITHABORT OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PowerShellServerInventory] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PowerShellServerInventory] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PowerShellServerInventory] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PowerShellServerInventory] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PowerShellServerInventory] SET  MULTI_USER 
GO
ALTER DATABASE [PowerShellServerInventory] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PowerShellServerInventory] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PowerShellServerInventory] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PowerShellServerInventory] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [PowerShellServerInventory] SET DELAYED_DURABILITY = DISABLED 
GO
USE [PowerShellServerInventory]
GO
/****** Object:  Table [dbo].[DriveAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DriveAudited](
	[diskID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[diskType] [varchar](25) NULL,
	[driveLetter] [varchar](5) NULL,
	[capacity] [int] NULL,
	[freeSpace] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[diskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InstalledProgramAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstalledProgramAudited](
	[installedProgramID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[displayName] [varchar](150) NULL,
	[displayVersion] [varchar](80) NULL,
	[installLocation] [varchar](200) NULL,
	[publisher] [varchar](100) NULL,
	[displayicon] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[installedProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LocalGroupAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LocalGroupAudited](
	[localGroupAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[localGroup] [varchar](200) NULL,
	[userNested] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[localGroupAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MemoryAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MemoryAudited](
	[memoryID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[Label] [varchar](50) NULL,
	[Capacity] [int] NULL,
	[Form] [int] NULL,
	[TypeM] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[memoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NetworkAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NetworkAudited](
	[networkID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[networkCard] [varchar](50) NULL,
	[dhcpEnabled] [varchar](5) NULL,
	[ipAddress] [varchar](50) NULL,
	[subnetMask] [varchar](50) NULL,
	[defaultGateway] [varchar](50) NULL,
	[dnsServers] [varchar](50) NULL,
	[dnsReg] [varchar](5) NULL,
	[primaryWins] [varchar](50) NULL,
	[secondaryWins] [varchar](50) NULL,
	[winsLookup] [varchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[networkID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ODBCConfiguredAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ODBCConfiguredAudited](
	[odbcConfiguredAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[dsn] [varchar](150) NULL,
	[serverName] [varchar](150) NULL,
	[port] [int] NULL,
	[dataBaseFile] [varchar](150) NULL,
	[dataBaseName] [varchar](150) NULL,
	[odbcUID] [varchar](150) NULL,
	[odbcPWD] [varchar](150) NULL,
	[start] [varchar](150) NULL,
	[lastUser] [varchar](150) NULL,
	[odbcDatabase] [varchar](150) NULL,
	[defaultLibraries] [varchar](150) NULL,
	[defaultPackage] [varchar](150) NULL,
	[defaultPkgLibrary] [varchar](150) NULL,
	[odbcSystem] [varchar](150) NULL,
	[driver] [varchar](150) NULL,
	[odbcDescription] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[odbcConfiguredAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ODBCInstalledAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ODBCInstalledAudited](
	[odbcInstalledAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[driver] [varchar](150) NULL,
	[driverODBCVer] [varchar](150) NULL,
	[fileExtns] [varchar](150) NULL,
	[setup] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[odbcInstalledAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OSPrivilegeAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OSPrivilegeAudited](
	[privilegeID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[strategy] [varchar](100) NULL,
	[securityParameter] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[privilegeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PrinterAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PrinterAudited](
	[printerAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[printerState] [int] NULL,
	[printerStatus] [int] NULL,
	[shareName] [varchar](100) NULL,
	[systemName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[printerAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProcessAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProcessAudited](
	[processAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[name] [varchar](100) NOT NULL,
	[location] [varchar](150) NOT NULL,
	[sessionID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[processAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProcessorAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProcessorAudited](
	[processorAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[Name] [varchar](100) NULL,
	[TypeP] [varchar](100) NULL,
	[Family] [varchar](10) NULL,
	[Speed] [int] NULL,
	[CacheSize] [int] NULL,
	[Interface] [int] NULL,
	[SocketNumber] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[processorAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScheduledTaskAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScheduledTaskAudited](
	[scheduledTaskAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[name] [varchar](150) NULL,
	[runAs] [varchar](150) NULL,
	[scheduledAction] [varchar](200) NULL,
	[nextRunTime] [datetime] NOT NULL,
	[lastRunTime] [datetime] NOT NULL,
	[pathName] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[scheduledTaskAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerAudited](
	[serverID] [int] NOT NULL,
	[serverName] [varchar](100) NULL,
	[domain] [varchar](100) NULL,
	[role] [varchar](50) NULL,
	[HW_Make] [varchar](100) NULL,
	[HW_Model] [varchar](100) NULL,
	[HW_Type] [varchar](100) NULL,
	[cpuCount] [int] NULL,
	[memoryGB] [int] NULL,
	[operatingSystem] [varchar](100) NULL,
	[servicePackLevel] [varchar](50) NULL,
	[biosName] [varchar](100) NULL,
	[biosVersion] [varchar](100) NULL,
	[hardwareSerial] [varchar](100) NULL,
	[timeZone] [varchar](50) NULL,
	[wmiVersion] [varchar](20) NULL,
	[virtualMemoryName] [varchar](50) NULL,
	[virtualMemoryCurrentUsage] [int] NULL,
	[virtualMermoryPeakUsage] [int] NULL,
	[virtualMemoryAllocatedBaseSize] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[serverID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServiceAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServiceAudited](
	[serviceAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[displayName] [varchar](150) NULL,
	[name] [varchar](150) NULL,
	[startName] [varchar](150) NULL,
	[startMode] [varchar](10) NOT NULL,
	[servicePathName] [varchar](150) NULL,
	[serviceDescription] [varchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[serviceAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShareAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShareAudited](
	[shareAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[serverID] [int] NOT NULL,
	[shareName] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[shareAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShareRightsAudited]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShareRightsAudited](
	[shareRightsAuditedID] [int] IDENTITY(1,1) NOT NULL,
	[shareAuditedID] [int] NOT NULL,
	[account] [varchar](100) NOT NULL,
	[rights] [varchar](200) NOT NULL,
	[aceFlags] [varchar](100) NOT NULL,
	[aceType] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[shareRightsAuditedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_localGroupOnServer]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_localGroupOnServer]
   AS
SELECT sa.[serverID]
      ,[serverName]
      ,[domain]
      ,[role]
      ,[HW_Make]
      ,[HW_Model]
      ,[HW_Type]
      ,[cpuCount]
      ,[memoryGB]
      ,[operatingSystem]
      ,[servicePackLevel]
      ,[biosName]
      ,[biosVersion]
      ,[hardwareSerial]
      ,[timeZone]
      ,[wmiVersion]
      ,[virtualMemoryName]
      ,[virtualMemoryCurrentUsage]
      ,[virtualMermoryPeakUsage]
      ,[virtualMemoryAllocatedBaseSize]
	  ,[localGroupAuditedID]
      ,[localGroup]
      ,[userNested]
  FROM [PowerShellServerInventory].[dbo].[LocalGroupAudited] lga JOIN [PowerShellServerInventory].[dbo].[ServerAudited] sa
      ON lga.serverID = sa.serverID


GO
/****** Object:  View [dbo].[vw_NLDOM01LocalGroupOnServers]    Script Date: 2015-07-22 09:12:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_NLDOM01LocalGroupOnServers]
   AS
SELECT distinct [userNested] as userNestedToronto
	  ,sa.[serverName]
	  ,sa.[domain]
      ,[localGroup]
      
  FROM [PowerShellServerInventory].[dbo].[ServerAudited] sa JOIN [PowerShellServerInventory].[dbo].[LocalGroupAudited] lga
  ON lga.serverID = sa.serverID
  WHERE [userNested] LIKE '%NLDOM%'


GO
ALTER TABLE [dbo].[DriveAudited]  WITH CHECK ADD  CONSTRAINT [FK_Drive_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[DriveAudited] CHECK CONSTRAINT [FK_Drive_ServerAudited]
GO
ALTER TABLE [dbo].[InstalledProgramAudited]  WITH CHECK ADD  CONSTRAINT [FK_InstalledProgramAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[InstalledProgramAudited] CHECK CONSTRAINT [FK_InstalledProgramAudited_ServerAudited]
GO
ALTER TABLE [dbo].[LocalGroupAudited]  WITH CHECK ADD  CONSTRAINT [FK_LocalGroupAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[LocalGroupAudited] CHECK CONSTRAINT [FK_LocalGroupAudited_ServerAudited]
GO
ALTER TABLE [dbo].[MemoryAudited]  WITH CHECK ADD  CONSTRAINT [FK_Memory_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[MemoryAudited] CHECK CONSTRAINT [FK_Memory_ServerAudited]
GO
ALTER TABLE [dbo].[NetworkAudited]  WITH CHECK ADD  CONSTRAINT [FK_NetworkAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[NetworkAudited] CHECK CONSTRAINT [FK_NetworkAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ODBCConfiguredAudited]  WITH CHECK ADD  CONSTRAINT [FK_ODBCConfiguredAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ODBCConfiguredAudited] CHECK CONSTRAINT [FK_ODBCConfiguredAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ODBCInstalledAudited]  WITH CHECK ADD  CONSTRAINT [FK_ODBCInstalledAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ODBCInstalledAudited] CHECK CONSTRAINT [FK_ODBCInstalledAudited_ServerAudited]
GO
ALTER TABLE [dbo].[OSPrivilegeAudited]  WITH CHECK ADD  CONSTRAINT [FK_OSPrivilege_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[OSPrivilegeAudited] CHECK CONSTRAINT [FK_OSPrivilege_ServerAudited]
GO
ALTER TABLE [dbo].[PrinterAudited]  WITH CHECK ADD  CONSTRAINT [FK_PrinterAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[PrinterAudited] CHECK CONSTRAINT [FK_PrinterAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ProcessAudited]  WITH CHECK ADD  CONSTRAINT [FK_ProcessAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ProcessAudited] CHECK CONSTRAINT [FK_ProcessAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ProcessorAudited]  WITH CHECK ADD  CONSTRAINT [FK_ProcessorAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ProcessorAudited] CHECK CONSTRAINT [FK_ProcessorAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ScheduledTaskAudited]  WITH CHECK ADD  CONSTRAINT [FK_ScheduledTaskAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ScheduledTaskAudited] CHECK CONSTRAINT [FK_ScheduledTaskAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ServiceAudited]  WITH CHECK ADD  CONSTRAINT [FK_ServicesAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ServiceAudited] CHECK CONSTRAINT [FK_ServicesAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ShareAudited]  WITH CHECK ADD  CONSTRAINT [FK_ShareAudited_ServerAudited] FOREIGN KEY([serverID])
REFERENCES [dbo].[ServerAudited] ([serverID])
GO
ALTER TABLE [dbo].[ShareAudited] CHECK CONSTRAINT [FK_ShareAudited_ServerAudited]
GO
ALTER TABLE [dbo].[ShareRightsAudited]  WITH CHECK ADD  CONSTRAINT [FK_ShareRightsAudited_ShareAudited] FOREIGN KEY([shareAuditedID])
REFERENCES [dbo].[ShareAudited] ([shareAuditedID])
GO
ALTER TABLE [dbo].[ShareRightsAudited] CHECK CONSTRAINT [FK_ShareRightsAudited_ShareAudited]
GO
USE [master]
GO
ALTER DATABASE [PowerShellServerInventory] SET  READ_WRITE 
GO
