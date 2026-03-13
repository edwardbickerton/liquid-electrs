module.exports = function safeHandler(handler) {
  return async function wrappedHandler(req, res, next) {
    try {
      await handler(req, res, next);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        message: error.message || "Internal server error",
      });
    }
  };
};
