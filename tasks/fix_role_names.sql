/* Align role names with what the backend enum (UserRole) + frontend expect.
   DB currently has 'Dentist'/'Assistant'; the app checks 'Dentiste'/'Secretaire'.
   FK is on ROL_ID, so renaming the name column is safe (no user rows re-point). */
SET NOCOUNT ON;
UPDATE dbo.[ROLE] SET ROL_NAME = 'Dentiste'   WHERE ROL_NAME = 'Dentist';
UPDATE dbo.[ROLE] SET ROL_NAME = 'Secretaire' WHERE ROL_NAME = 'Assistant';
SELECT ROL_ID, ROL_NAME FROM dbo.[ROLE] ORDER BY ROL_ID;
