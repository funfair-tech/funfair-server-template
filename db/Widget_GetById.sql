-- Temporary test fixture for #995: remove before merge.
CREATE PROCEDURE [dbo].[Widget_GetById]
  @WidgetId INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    [w].[WidgetId],
    [w].[Name],
    [w].[CreatedUtc]
  FROM [dbo].[Widget] AS [w]
  WHERE [w].[WidgetId] = @WidgetId;
END;
