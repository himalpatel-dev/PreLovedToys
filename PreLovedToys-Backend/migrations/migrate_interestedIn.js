/**
 * Migration helper: convert existing tbl_users.interestedIn values (CSV or plain text)
 * into JSON arrays and alter the column type to JSON (Postgres).
 *
 * Usage: node migrations/migrate_interestedIn.js
 * IMPORTANT: Backup your database before running.
 */
require('dotenv').config();
const sequelize = require('../src/config/db.config');

async function run() {
  console.log('Connecting to DB...');
  try {
    await sequelize.authenticate();
    console.log('Connected. Starting migration in a transaction...');

    await sequelize.transaction(async (t) => {
      // 1) Normalize empty strings to JSON empty array
      console.log('-> Normalizing empty strings to []');
      await sequelize.query(
        `UPDATE "tbl_users" SET "interestedIn" = '[]' WHERE "interestedIn" IS NULL OR trim("interestedIn") = ''`,
        { transaction: t }
      );

      // 2) For rows where interestedIn looks like CSV (not starting with '[' or '{'),
      //    split by comma and aggregate into a JSON array. Numeric tokens are cast to integer.
      console.log('-> Converting CSV/text values into JSON arrays');
      await sequelize.query(
        `UPDATE "tbl_users" SET "interestedIn" = (
            SELECT COALESCE(json_agg(val), '[]'::json) FROM (
              SELECT CASE WHEN trim(x) ~ '^[0-9]+$' THEN (trim(x))::int ELSE trim(x) END as val
              FROM regexp_split_to_table("interestedIn", ',') AS t(x)
            ) s
          )
          WHERE "interestedIn" IS NOT NULL AND "interestedIn" NOT LIKE '[%' AND "interestedIn" NOT LIKE '{%';`,
        { transaction: t }
      );

      // 3) Alter the column type to JSON using an explicit cast.
      console.log('-> Altering column type to JSON');
      await sequelize.query(
        `ALTER TABLE "tbl_users" ALTER COLUMN "interestedIn" TYPE JSON USING "interestedIn"::json;`,
        { transaction: t }
      );

      console.log('Migration transaction completed.');
    });

    console.log('Migration finished successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

run();
