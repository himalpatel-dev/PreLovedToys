/**
 * An error whose message is safe to show to the user, with the HTTP status to send.
 * Controllers send `err.status` and `err.message` for these, and a generic 500 otherwise.
 */
class AppError extends Error {
    constructor(message, status = 400, code = undefined) {
        super(message);
        this.status = status;
        if (code) this.code = code;
    }
}

module.exports = AppError;
