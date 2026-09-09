/** 404 for unmatched API routes. */
export function notFound(req, res) {
  res.status(404).json({
    error: req.t
      ? req.t('error.notFound', { method: req.method, url: req.originalUrl })
      : `Route ${req.method} ${req.originalUrl} does not exist.`
  });
}

/** Central error handler — keeps stack traces out of client responses. */
export function errorHandler(err, req, res, _next) {
  const status = err.status || err.statusCode || 500;
  const t = req.t || ((k) => k);

  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: t('error.validation'),
      details: Object.fromEntries(Object.entries(err.errors).map(([k, v]) => [k, v.message]))
    });
  }
  if (err.name === 'CastError') {
    return res.status(400).json({ error: t('error.badId') });
  }
  if (err.code === 11000) {
    return res.status(409).json({ error: t('error.duplicate') });
  }

  if (status >= 500) console.error('[error]', err);
  res.status(status).json({ error: err.message || t('error.internal') });
}
