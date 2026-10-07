-- Temporary test fixture for #995: remove before merge.
CREATE TABLE [dbo].[Widget] (
  [WidgetId] INT NOT NULL,
  [Name] NVARCHAR(100) NOT NULL,
  [CreatedUtc] DATETIME2(7) NOT NULL,
  CONSTRAINT [PK_Widget] PRIMARY KEY CLUSTERED ([WidgetId])
);
