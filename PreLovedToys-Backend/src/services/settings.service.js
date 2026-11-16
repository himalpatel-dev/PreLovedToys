/**
 * Admin-editable points rules. Values live in tbl_settings; anything not saved yet uses
 * DEFAULTS (the values that used to be hard-coded). Reads are cached in memory and the
 * cache is cleared on every update.
 */
const db = require('../models');
const AppError = require('../utils/app-error');

// Profile fields that earn points the first time they are filled in.
const PROFILE_FIELDS = ['name', 'email', 'gender', 'occupation', 'collegeOrUniversity', 'purpose', 'aboutMe', 'interestedIn'];

const DEFAULTS = Object.freeze({
    // Points given to every new account.
    welcomeBonus: 300,
    // Points-based sales a seller must complete before they may list items for rupees.
    cashUnlockSales: 3,
    // Points per profile field.
    profilePoints: Object.freeze({
        name: 20,
        email: 30,
        gender: 20,
        occupation: 20,
        collegeOrUniversity: 20,
        purpose: 30,
        aboutMe: 30,
        interestedIn: 30,
    }),
});

let cache = null;

const clone = (v) => JSON.parse(JSON.stringify(v));

async function getAll() {
    if (!cache) {
        const rows = await db.Setting.findAll();
        const saved = Object.fromEntries(rows.map((r) => [r.key, r.value]));
        cache = {
            welcomeBonus: saved.welcomeBonus ?? DEFAULTS.welcomeBonus,
            cashUnlockSales: saved.cashUnlockSales ?? DEFAULTS.cashUnlockSales,
            profilePoints: { ...DEFAULTS.profilePoints, ...(saved.profilePoints || {}) },
        };
    }
    return clone(cache);
}

async function get(key) {
    return (await getAll())[key];
}

function wholeNumber(value, label, max) {
    const n = Number(value);
    if (!Number.isInteger(n) || n < 0 || n > max) {
        throw new AppError(`${label} must be a whole number from 0 to ${max.toLocaleString('en-IN')}.`);
    }
    return n;
}

/** Validates and saves any of: welcomeBonus, cashUnlockSales, profilePoints (partial map). */
async function update(changes = {}) {
    const current = await getAll();
    const next = {};

    if (changes.welcomeBonus !== undefined) {
        next.welcomeBonus = wholeNumber(changes.welcomeBonus, 'Welcome bonus', 100000);
    }
    if (changes.cashUnlockSales !== undefined) {
        next.cashUnlockSales = wholeNumber(changes.cashUnlockSales, 'Sales needed for rupee listings', 100);
    }
    if (changes.profilePoints !== undefined) {
        if (!changes.profilePoints || typeof changes.profilePoints !== 'object' || Array.isArray(changes.profilePoints)) {
            throw new AppError('profilePoints must be an object of field: points.');
        }
        const points = { ...current.profilePoints };
        for (const [field, value] of Object.entries(changes.profilePoints)) {
            if (!PROFILE_FIELDS.includes(field)) throw new AppError(`Unknown profile field: ${field}.`);
            points[field] = wholeNumber(value, `Points for ${field}`, 10000);
        }
        next.profilePoints = points;
    }

    if (!Object.keys(next).length) throw new AppError('Nothing to update.');

    await db.sequelize.transaction(async (transaction) => {
        for (const [key, value] of Object.entries(next)) {
            await db.Setting.upsert({ key, value }, { transaction });
        }
    });
    cache = null;
    return getAll();
}

module.exports = { DEFAULTS, PROFILE_FIELDS, getAll, get, update };
