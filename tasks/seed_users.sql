/* ---------------------------------------------------------------------------
   Seed 5 users for dentiste_db — password for ALL = "SecurePass123!"
   Hash scheme (from PasswordHasher.cs): Base64( SHA256( UTF8(password + salt) ) )
   Role IDs resolved BY NAME (tolerates Dentist/Dentiste & Assistant/Secretaire).
   Safe to re-run: skips usernames/emails that already exist.
--------------------------------------------------------------------------- */
SET NOCOUNT ON;

DECLARE @adminId   INT = (SELECT TOP 1 ROL_ID FROM dbo.[ROLE] WHERE ROL_NAME IN ('Admin','Administrateur'));
DECLARE @dentistId INT = (SELECT TOP 1 ROL_ID FROM dbo.[ROLE] WHERE ROL_NAME IN ('Dentiste','Dentist'));
DECLARE @assistId  INT = (SELECT TOP 1 ROL_ID FROM dbo.[ROLE] WHERE ROL_NAME IN ('Secretaire','Assistant'));

INSERT INTO dbo.[USER]
    (USR_USERNAME, USR_EMAIL, USR_PASSWORD_HASH, USR_PASSWORD_SALT,
     USR_NOM, USR_PRENOM, USR_IS_ACTIVE, USR_CREATED_AT, USR_ROLE_ID)
SELECT v.USR_USERNAME, v.USR_EMAIL, v.USR_PASSWORD_HASH, v.USR_PASSWORD_SALT,
       v.USR_NOM, v.USR_PRENOM, v.USR_IS_ACTIVE, GETDATE(), v.USR_ROLE_ID
FROM (VALUES
    ('m.benali',   'mohamed.benali@dentiste.tn', '+ajt9pQSvdGBzN000aVR67+ub9N+QNe/jmyfkSQrR44=', 'salt_xyz123', 'Ben Ali',  'Mohamed', 1, @dentistId),
    ('a.trabelsi', 'amel.trabelsi@gmail.com',    '5tyHMGZrmWvS1CzZlvXjBh4X0EbbTMQ0G66LF3WRRiI=', 'salt_abc456', 'Trabelsi', 'Amel',    1, @dentistId),
    ('y.jouini',   'yassine.jouini@outlook.tn',  'yisIn6lNFCbOTuRW9NeBl/q+Mxm6adzuCBSd1sdhvkE=', 'salt_def789', 'Jouini',   'Yassine', 1, @assistId),
    ('s.chaari',   'sonia.chaari@dentiste.tn',   'THygcH125cciWi7EM48JtBfhn++q+bWk1eMgmXdvP0Q=', 'salt_ghi012', 'Chaari',   'Sonia',   1, @adminId),
    ('a.louati',   'anis.louati@topnet.tn',      'lQAcLxZnd5u4tMLVlKbXijFebIxeRQrBchQqbdsJfnE=', 'salt_jkl345', 'Louati',   'Anis',    1, @dentistId)
) AS v(USR_USERNAME, USR_EMAIL, USR_PASSWORD_HASH, USR_PASSWORD_SALT,
       USR_NOM, USR_PRENOM, USR_IS_ACTIVE, USR_ROLE_ID)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.[USER] u
    WHERE u.USR_USERNAME = v.USR_USERNAME OR u.USR_EMAIL = v.USR_EMAIL
);

PRINT 'Inserted rows: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
