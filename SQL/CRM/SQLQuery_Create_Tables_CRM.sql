USE ContosoCRM;
GO

CREATE TABLE dbo.SalesRepresentative (
    RepID        INT IDENTITY(1,1) PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Region       NVARCHAR(50) NOT NULL,
    HireDate     DATE NOT NULL,
    CreatedDate  DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted    BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.Customer (
    CustomerID   INT PRIMARY KEY,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Email        NVARCHAR(100) NULL,
    Phone        NVARCHAR(30) NULL,
    Region       NVARCHAR(50) NULL,
    CreatedDate  DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted    BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.Campaign (
    CampaignID   INT IDENTITY(1,1) PRIMARY KEY,
    CampaignName NVARCHAR(100) NOT NULL,
    Channel      NVARCHAR(50) NOT NULL,
    StartDate    DATE NOT NULL,
    EndDate      DATE NULL,
    Budget       DECIMAL(12,2) NULL,
    CreatedDate  DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted    BIT NOT NULL DEFAULT 0,
    CONSTRAINT CHK_Campaign_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

CREATE TABLE dbo.Lead (
    LeadID       INT IDENTITY(1,1) PRIMARY KEY,
    CampaignID   INT NULL,
    LeadSource   NVARCHAR(50) NOT NULL,
    Status       NVARCHAR(20) NOT NULL DEFAULT 'New',
    CreatedDate  DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted    BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Lead_Campaign FOREIGN KEY (CampaignID) REFERENCES dbo.Campaign(CampaignID),
    CONSTRAINT CHK_Lead_Status CHECK (Status IN ('New','Contacted','Qualified','Disqualified','Converted'))
);
GO

CREATE TABLE dbo.Opportunity (
    OpportunityID  INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID     INT NOT NULL,
    RepID          INT NOT NULL,
    Stage          NVARCHAR(20) NOT NULL DEFAULT 'Open',
    EstimatedValue DECIMAL(12,2) NOT NULL,
    CloseDate      DATE NULL,
    CreatedDate    DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate   DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted      BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Opportunity_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
    CONSTRAINT FK_Opportunity_Rep FOREIGN KEY (RepID) REFERENCES dbo.SalesRepresentative(RepID),
    CONSTRAINT CHK_Opportunity_Value CHECK (EstimatedValue >= 0),
    CONSTRAINT CHK_Opportunity_Stage CHECK (Stage IN ('Open','Qualifying','Proposal','Negotiation','Closed Won','Closed Lost'))
);
GO

CREATE TABLE dbo.CustomerInteraction (
    InteractionID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID       INT NOT NULL,
    RepID            INT NULL,
    InteractionType  NVARCHAR(30) NOT NULL,
    InteractionDate  DATETIME NOT NULL,
    Notes            NVARCHAR(500) NULL,
    CreatedDate      DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate     DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted        BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Interaction_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
    CONSTRAINT FK_Interaction_Rep FOREIGN KEY (RepID) REFERENCES dbo.SalesRepresentative(RepID)
);
GO