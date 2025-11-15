const prometheus = require('prom-client');

// Create a Registry which registers all of our metrics
const register = new prometheus.Registry();

// Add default metrics (nodejs process metrics)
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

const studentsTotal = new prometheus.Gauge({
  name: 'students_total',
  help: 'Total number of students in the database',
  registers: [register],
});

// Middleware to track HTTP metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration.observe(
      {
        method: req.method,
        route: route,
        status_code: res.statusCode,
      },
      duration
    );
    
    httpRequestTotal.inc({
      method: req.method,
      route: route,
      status_code: res.statusCode,
    });
  });
  
  next();
};

module.exports = {
  register,
  metricsMiddleware,
  httpRequestDuration,
  httpRequestTotal,
  studentsTotal,
};
